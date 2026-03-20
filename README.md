# xpinger

xpinger is an isolated network monitoring stack utilizing Python, InfluxDB, and Grafana to track device ping metrics (availability, latency, and packet loss) in parallel batches.

## Features
- **Parallel Batch Pinging**: Pings multiple devices concurrently (configured via `PING_PARALLEL`) to quickly harvest metrics without creating a network bottleneck.
- **InfluxDB Integration**: Metrics like latency, jitter, and packet loss are continuously pushed to InfluxDB.
- **Grafana Monitoring**: Ready-to-go Grafana setup. Add your dashboard templates in the `xpingerTemplates/` directory to have them mounted automatically.
- **Automated Bootstrap**: Secure startup handles InfluxDB tokens and credentials securely via `deploy.sh`.

## Prerequisites
- Docker
- Docker Compose

## Quick Start

The entire stack is fully pre-configured! To start monitoring your devices, simply follow these two steps:

1. **Update `devices.csv`**:
   Open the `devices.csv` file and define the targets you want to ping. Just ensure you keep the CSV header completely intact (`Group,Location,Hostname,IP`).

2. **Run Deploy**:
   From your terminal, run the deployment script:
   ```bash
   bash deploy.sh
   ```
   *That's it!* The script handles everything automatically:
   - Configures your `.env` file with secure, auto-generated tokens.
   - Sets InfluxDB as the default data source for Grafana.
   - Automatically mounts and displays your UI dashboards from `xpingerTemplates`.
   - Builds and starts all the containers.

3. **Customize your Environment / Change Ports**:
   Open the newly generated `.env` file at the root of the project to change the defaults:
   - `GRAFANA_PORT` (Default is `3000` — modify this if you have a port collision)
   - `INFLUXDB_USERNAME` / `INFLUXDB_PASSWORD` (Default: `admin` / `admin12345`)
   - `GRAFANA_USER` / `GRAFANA_PASSWORD` (Default: `admin` / `admin12345`)
   
   If you change any configuration, just re-run `bash deploy.sh` to apply them.

4. **Access the Web Interfaces**:
   - **Grafana**: Available at `http://localhost:3000` (or the custom port you defined).
   - **InfluxDB**: Available at `http://localhost:8086`.

## File Structure Overview
- `deploy.sh`: Bootstrap script to prepare local environments and launch the stack.
- `docker-compose.yml`: Defines `xpinger`, `influxdb`, and `grafana`.
- `devices.csv`: Your target list.
- `xpinger.py`: Core logic loop managing the continuous, parallel pings.
- `xpingerTemplates/`: Drop any preconfigured JSON Grafana dashboards here for mapping.
