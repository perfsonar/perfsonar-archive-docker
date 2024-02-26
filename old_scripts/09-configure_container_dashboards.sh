#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out

ADMIN_PASS=$(grep -m1 -e ^admin ${PASSWORD_FILE} | awk '{print $2}')
DASHBOARDS_VERSION=$(docker exec opensearch-dashboards /usr/share/opensearch-dashboards/bin/opensearch-dashboards --version)

# Check if the API is running
echo "Waiting for opensearch dashboards API to start..."
api_status=$(curl -s -o /dev/null -w "%{http_code}" -u admin:${ADMIN_PASS} http://localhost:5601/api/status)
i=0
while [[ $api_status -ne 200 ]]
do
    sleep 1
    ((i++))
    # Wait a maximum of 100 seconds for the API to start
    if [[ $i -eq 100 ]]; then
        echo "[ERROR] API start timeout"
        exit 1
    fi
    api_status=$(curl -s -o /dev/null -w "%{http_code}" -u admin:${ADMIN_PASS} http://localhost:5601/api/status)
done

echo "API started!"

curl -4 -X POST -u admin:${ADMIN_PASS} http://localhost:5601/api/saved_objects/index-pattern -H "osd-version: ${DASHBOARDS_VERSION}" -H "osd-xsrf: true" -H "content-type: application/json; charset=utf-8" -d '{"attributes":{"title":"pscheduler*","timeFieldName":"pscheduler.start_time","fields":"[]"}}'