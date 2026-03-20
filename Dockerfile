FROM python:3.11-slim-bookworm

WORKDIR /app

# Install system dependencies
RUN apt update && apt install --no-install-recommends -y \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*


# Install Python requirements
RUN pip install --no-cache-dir influxdb-client==1.36.0

# Copy project files
COPY . .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]