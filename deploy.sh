#!/bin/bash

# Ensure .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    touch .env
fi

# Initialize variables if they are missing from .env
if ! grep -q "^INFLUXDB_API_TOKEN=" .env; then
    TOKEN=$(openssl rand -hex 32)
    echo "INFLUXDB_API_TOKEN=$TOKEN" >> .env
    echo "Generated new InfluxDB API token."
fi

if ! grep -q "^GRAFANA_PORT=" .env; then
    # Default port. You can change this in the .env file later.
    echo "GRAFANA_PORT=3000" >> .env
    echo "Set default Grafana port to 3000."
fi

if ! grep -q "^INFLUXDB_USERNAME=" .env; then echo "INFLUXDB_USERNAME=admin" >> .env; fi
if ! grep -q "^INFLUXDB_PASSWORD=" .env; then echo "INFLUXDB_PASSWORD=admin12345" >> .env; fi
if ! grep -q "^INFLUXDB_BUCKET=" .env; then echo "INFLUXDB_BUCKET=warehouse" >> .env; fi
if ! grep -q "^INFLUXDB_ORG=" .env; then echo "INFLUXDB_ORG=xpinger" >> .env; fi
if ! grep -q "^GRAFANA_USER=" .env; then echo "GRAFANA_USER=admin" >> .env; fi
if ! grep -q "^GRAFANA_PASSWORD=" .env; then echo "GRAFANA_PASSWORD=admin12345" >> .env; fi

echo ""
echo "==== Deployment Configuration ===="
cat .env
echo "=================================="
echo ""

# Build and start the services
docker-compose up -d --build

echo ""
echo "Deployment complete!"
echo "You can check the .env file to view or change your passwords/ports."
echo "If you change the port, run ./deploy.sh again."
