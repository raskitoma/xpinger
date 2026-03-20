import os
import csv
import subprocess
import re
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from config import (INFLUXDB_URL, INFLUXDB_TOKEN, INFLUXDB_ORG, INFLUXDB_BUCKET, 
                    PING_PACKETS, PING_INTERVAL, PING_TRIGGER, PING_PARALLEL, 
                    PING_TIMEOUT, DRYRUN)

base_path = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(base_path, 'devices.csv')

def ping_device_task(row):
    group, location, hostname, ip = row
    cmd = f"ping -c {PING_PACKETS} -i {PING_INTERVAL} -W {PING_TIMEOUT} {ip}"
    try:
        output = subprocess.check_output(cmd, shell=True, text=True, stderr=subprocess.STDOUT)
        
        # Ping output might contain rtt or round-trip
        stats = re.search(r'(?:rtt|round-trip) min/avg/max/(?:mdev|stddev) = ([\d.]+)/([\d.]+)/([\d.]+)/([\d.]+)', output)
        loss = re.search(r'(\d+)% packet loss', output)

        if stats and loss:
            avg_ms = float(stats.group(2))
            jitter = float(stats.group(4))
            loss_pct = float(loss.group(1))
            status = "online" if loss_pct < 100 else "offline"
        else:
            raise Exception("Regex match failed")
            
    except Exception:
        avg_ms, jitter, loss_pct = 0.0, 0.0, 100.0
        status = "offline"

    point = Point("ping_metrics") \
        .tag("group", group) \
        .tag("location", location) \
        .tag("device", hostname) \
        .tag("ip", ip) \
        .tag("status", status) \
        .field("ms", avg_ms) \
        .field("jitter", jitter) \
        .field("loss", loss_pct)

    return point, hostname, ip, status, avg_ms, loss_pct

def ping_loop():
    if not DRYRUN:
        client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
        write_api = client.write_api(write_options=SYNCHRONOUS)
    else:
        print("--- DRYRUN MODE: Data will NOT be sent to InfluxDB ---")

    if not os.path.exists(csv_path):
        print(f"Error: {csv_path} not found!")
        return

    while True:
        devices = []
        with open(csv_path, mode='r') as file:
            reader = csv.reader(file)
            next(reader)  # Skip header
            for row in reader:
                if row and len(row) >= 4:
                    devices.append(row)
        
        print(f"Loaded {len(devices)} devices. Starting ping scan...")
        
        for i in range(0, len(devices), PING_PARALLEL):
            batch = devices[i:i + PING_PARALLEL]
            points = []
            
            with ThreadPoolExecutor(max_workers=PING_PARALLEL) as executor:
                # Submit jobs
                futures = [executor.submit(ping_device_task, row) for row in batch]
                
                # Fetch results concurrently as they finish
                for future in as_completed(futures):
                    point, hostname, ip, status, avg_ms, loss_pct = future.result()
                    points.append(point)
                    print(f"[{'DRYRUN-' if DRYRUN else ''}{status.upper()}] {hostname} ({ip}): {avg_ms}ms, {loss_pct}% loss")
            
            # Send batch data to influx
            if not DRYRUN and points:
                try:
                    write_api.write(bucket=INFLUXDB_BUCKET, record=points)
                    print(f"--- Wrote batch of {len(points)} ping metrics to InfluxDB ---")
                except Exception as e:
                    print(f"Error writing batch to InfluxDB: {e}")

        print(f"Scan complete. Sleeping for {PING_TRIGGER} seconds...")
        time.sleep(PING_TRIGGER)

if __name__ == "__main__":
    ping_loop()