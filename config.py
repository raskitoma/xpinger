import os

# Fetch from environment (Docker), or use defaults for local testing
INFLUXDB_BUCKET = os.getenv("INFLUXDB_BUCKET", "network-stats")
INFLUXDB_ORG = os.getenv("INFLUXDB_ORG", "my-org")
INFLUXDB_TOKEN = os.getenv("INFLUXDB_TOKEN", "your-secret-token")
INFLUXDB_URL = os.getenv("INFLUXDB_URL", "http://localhost:8086")

# Ping settings
MINUTES_INTERVAL = int(os.getenv("MINUTES_INTERVAL", 1))
PING_PACKETS = int(os.getenv("PING_PACKETS", 5))
PING_INTERVAL = float(os.getenv("PING_INTERVAL", 0.5))
PING_TRIGGER = int(os.getenv("PING_TRIGGER", 5))
PING_PARALLEL = int(os.getenv("PING_PARALLEL", 5))
PING_TIMEOUT = int(os.getenv("PING_TIMEOUT", 2))
DRYRUN = str(os.getenv("DRYRUN", "false")).lower() == "true"