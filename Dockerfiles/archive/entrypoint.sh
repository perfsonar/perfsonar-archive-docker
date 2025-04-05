#!/bin/bash
set -e

if [ ! -f /usr/share/opensearch/data/.initialized ]; then
    # Disable htpasswd in secure_pre.sh
    sed -i '/htpasswd -bc/s/^/#/' /usr/lib/perfsonar/archive/perfsonar-scripts/pselastic_secure_pre.sh

    echo "Running pre-startup script..."
    if bash /usr/lib/perfsonar/archive/perfsonar-scripts/pselastic_secure_pre.sh install; then
        echo "Pre-startup script completed successfully."
    else
        echo "Error: pselastic_secure_pre.sh failed!" >&2
        exit 1
    fi

    # Modify config files
    sed -i 's|^opensearch_output_host=https://localhost:9200|opensearch_output_host=https://opensearch-node:9200|' /etc/sysconfig/logstash

    cp /etc/perfsonar/opensearch/auth_setup.out /usr/lib/perfsonar/archive/
    cp /etc/sysconfig/logstash /usr/lib/perfsonar/logstash/sysconfig
    chown 1000:1000 /usr/lib/perfsonar/logstash/sysconfig
fi

echo "Starting OpenSearch..."
# Drop privileges and start OpenSearch
gosu opensearch ./opensearch-docker-entrypoint.sh opensearch &
OPENSEARCH_PID=$!

# Wait for OpenSearch to start
echo "Waiting for OpenSearch..."
until curl -k https://localhost:9200 --silent; do
    sleep 5
done

if [ ! -f /usr/share/opensearch/data/.initialized ]; then

    # Override systemd status checks to always assume OpenSearch and Logstash are active since systemctl is not available inside the container
    sed -i 's|opensearch_systemctl_status=.*|opensearch_systemctl_status=active|' /usr/lib/perfsonar/archive/perfsonar-scripts/pselastic_secure_pos.sh
    sed -i 's|logstash_systemctl_status=.*|logstash_systemctl_status=active|' /usr/lib/perfsonar/archive/perfsonar-scripts/pselastic_secure_pos.sh

    echo "Running post-startup script..."
    if bash /usr/lib/perfsonar/archive/perfsonar-scripts/pselastic_secure_pos.sh; then
        touch /usr/share/opensearch/data/.initialized
        echo "Post-startup script completed successfully."
    else
        echo "Error: pselastic_secure_pos.sh failed!" >&2
        exit 1
    fi
fi

# Re-parent OpenSearch to PID 1 and forward signals
trap 'kill -TERM $OPENSEARCH_PID' TERM INT
wait $OPENSEARCH_PID