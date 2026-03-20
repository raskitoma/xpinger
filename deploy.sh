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

is_port_in_use() {
    local port=$1
    if command -v ss >/dev/null 2>&1; then
        ss -ltn | awk '{print $4}' | grep -qE ".*:$port$"
        return $?
    elif command -v netstat >/dev/null 2>&1; then
        netstat -ltn | awk '{print $4}' | grep -qE ".*:$port$"
        return $?
    elif command -v nc >/dev/null 2>&1; then
        nc -z 127.0.0.1 $port
        return $?
    elif command -v lsof >/dev/null 2>&1; then
        lsof -i :$port >/dev/null 2>&1
        return $?
    else
        echo "Error: Networking utilities not found."
        echo "Please install 'iproute2' (ss), 'net-tools' (netstat), 'netcat' (nc), or 'lsof' to check port availability."
        exit 1
    fi
}

if ! grep -q "^GRAFANA_PORT=" .env; then
    echo "Setting up Grafana Web Interface..."
    while true; do
        read -p "Enter an available port for Grafana (default 3000): " input_port
        input_port=${input_port:-3000}
        
        if ! [[ "$input_port" =~ ^[0-9]+$ ]]; then
            echo "Invalid port. Please deeply enter a number."
            continue
        fi

        if is_port_in_use $input_port; then
            echo "Port $input_port is already in use by another application. Please select a different port."
        else
            echo "GRAFANA_PORT=$input_port" >> .env
            echo "Successfully allocated Grafana port to $input_port."
            break
        fi
    done
else
    # Check if the existing port is still available before starting
    EXISTING_PORT=$(grep "^GRAFANA_PORT=" .env | cut -d'=' -f2)
    if is_port_in_use $EXISTING_PORT; then
        echo "WARNING: The configured GRAFANA_PORT ($EXISTING_PORT) from .env is currently in use!"
        echo "Please update .env to a free port or stop the conflicting service, then re-run deploy.sh."
        exit 1
    fi
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
