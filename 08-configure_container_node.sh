#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out

ADMIN_PASS=$(grep -m1 -e ^admin ${PASSWORD_FILE} | awk '{print $2}')

docker exec opensearch-node keytool -import -alias node -keystore /etc/pki/java/cacerts -file /usr/share/opensearch/config/node.der -storepass changeit -noprompt

bash plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/opensearch/config/opensearch-security -icl -nhnv -cacert /usr/share/opensearch/config/root-ca.pem -cert /usr/share/opensearch/config/admin.pem -key /usr/share/opensearch/config/admin-key.pem

echo "Waiting for opensearch API to start..."
api_status=$(curl -s -o /dev/null -w "%{http_code}" -u admin:${ADMIN_PASS} -k https://localhost:9200/_cluster/health)
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
    api_status=$(curl -s -o /dev/null -w "%{http_code}" -u admin:${ADMIN_PASS} -k https://localhost:9200/_cluster/health)
done

echo "API started!"

curl -k -u admin:${ADMIN_PASS} -H 'Content-Type: application/json' -X PUT "https://localhost:9200/_opendistro/_ism/policies/pscheduler_default_policy" -d "@./configs/pscheduler_default_policy.json"
curl -k -u admin:${ADMIN_PASS} -H 'Content-Type: application/json' -X POST "https://localhost:9200/_opendistro/_ism/add/pscheduler*" -d '{ "policy_id": "pscheduler_default_policy" }'
curl -k -u admin:${ADMIN_PASS} -H 'Content-Type: application/json' -X PUT "https://localhost:9200/_index_template/pscheduler_default_policy" -d "@./configs/index_template-pscheduler.json"