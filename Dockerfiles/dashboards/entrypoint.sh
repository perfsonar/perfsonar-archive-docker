#!/bin/bash
set -e

# do not run this command
sed -i '/server.basePath/s/^/#/' /usr/lib/perfsonar/dashboards/dashboards-scripts/dashboards_secure_pre.sh

echo "Waiting for auth file..."
while [ ! -f //usr/lib/perfsonar/archive/auth_setup.out ]; do
  sleep 2
done

echo "Running pre-startup script..."
bash /usr/lib/perfsonar/dashboards/dashboards-scripts/dashboards_secure_pre.sh

echo "Starting OpenSearch-Dashboards..."
# Drop privileges and start OpenSearch
gosu opensearch-dashboards ./opensearch-dashboards-docker-entrypoint.sh opensearch-dashboards &
OPENSEARCH_DASHBOARDS_PID=$!

# Wait for OpenSearch-Dashboards to start
sleep 10

echo "Running post-startup script..."
bash /usr/lib/perfsonar/dashboards/dashboards-scripts/dashboards_secure_pos.sh

# Re-parent OpenSearch-Dashboards to PID 1 and forward signals
trap 'kill -TERM $OPENSEARCH_DASHBOARDS_PID' TERM INT
wait $OPENSEARCH_DASHBOARDS_PID