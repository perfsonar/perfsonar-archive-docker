#!/bin/bash
set -e

# Ensure logstash config is set up
python3 /usr/lib/perfsonar/logstash/scripts/update_logstash_pipeline_yml.py
python3 /usr/lib/perfsonar/logstash/scripts/enable_prometheus_pipeline.py

echo "Waiting for sysconfig file..."
while [ ! -f /usr/lib/perfsonar/logstash/sysconfig ]; do
  sleep 2
done

# Start Logstash
exec /usr/local/bin/docker-entrypoint