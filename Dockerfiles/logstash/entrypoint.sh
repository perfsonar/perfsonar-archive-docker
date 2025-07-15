#!/bin/bash
set -e

# Ensure logstash config is set up
python3 /usr/lib/perfsonar/logstash/scripts/update_logstash_pipeline_yml.py
python3 /usr/lib/perfsonar/logstash/scripts/enable_prometheus_pipeline.py

## update pipeline to use 0.0.0.0 instead of localhost
sed -i /usr/lib/perfsonar/logstash/pipeline/01-inputs.conf -e 's/localhost/0.0.0.0/g'

echo "Waiting for sysconfig file..."
while [ ! -f /usr/lib/perfsonar/logstash/sysconfig ]; do
  sleep 2
done

# Set up environment variables for Logstash
source /usr/lib/perfsonar/logstash/sysconfig

# Start Logstash
exec /usr/local/bin/docker-entrypoint