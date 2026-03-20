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

1. **Prepare `devices.csv`**:
   Copy the provided sample file to create your local copy:
   ```bash
   cp devices_sample.csv devices.csv
   ```
   Open `devices.csv` and define the targets you want to ping. Ensure you keep the CSV header completely intact (`Group,Location,Hostname,IP`).

2. **Run Deploy**:
   From your terminal, run the deployment script:
   ```bash
   bash deploy.sh
   ```
   *That's it!* The script handles everything automatically:
   - Configures your `.env` file with secure, auto-generated tokens.
   - Sets InfluxDB as the default data source for Grafana targeting the `xpinger` organization and bucket.
   - Automatically mounts and displays your UI dashboards from `xpingerTemplates`.
   - Builds and starts all the containers.
   - **Immediately tails the live logs (`docker-compose logs -f`) so you can watch your pings succeeding contextually. Press `Ctrl+C` to exit the logs (the containers will keep working in the background).**

3. **Customize your Environment / Change Ports**:
   Open the newly generated `.env` file at the root of the project to change the defaults:
   - `GRAFANA_PORT` — If you don't enter this during deploy, you can change it manually here. The deployment script prevents collisions by ensuring the port is actually free. Be sure to have `ss`, `netstat`, `nc`, or `lsof` installed on your system!
   - `INFLUXDB_USERNAME` / `INFLUXDB_PASSWORD` (Default: `admin` / `admin12345`)
   - `GRAFANA_USER` / `GRAFANA_PASSWORD` (Default: `admin` / `admin12345`)
   
4. **Updating or Deleting the Deployment**:
   If you ever modify `devices.csv`, customize your `.env` file, or want to tear down the stack, simply re-run the script:
   ```bash
   bash deploy.sh
   ```
   The script will detect your existing configuration and prompt you with:
   - **[u] Update deployment**: Applies your changes and restarts the containers without wiping your data.
   - **[d] Delete deployment**: Safely stops all containers, permanently deletes all InfluxDB/Grafana database volumes, and removes the `.env` file. (WARNING: This destroys all historical data).

5. **Access the Web Interfaces**:
   - **Grafana**: Available at `http://localhost:3000` (or the custom port you defined).

## File Structure Overview
- `deploy.sh`: Bootstrap script to prepare local environments and launch the stack.
- `docker-compose.yml`: Defines `xpinger`, `influxdb`, and `grafana`.
- `devices.csv`: Your target list.
- `xpinger.py`: Core logic loop managing the continuous, parallel pings.
- `xpingerTemplates/`: Drop any preconfigured JSON Grafana dashboards here for mapping.
