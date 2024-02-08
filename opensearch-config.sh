#!/bin/bash

OPENSEARCH_CONTAINER=opensearch-node

container_id=$(docker ps --filter "name=$OPENSEARCH_CONTAINER" --filter "status=running" -q)

if [[ -z "$container_id" ]]; then 
    echo "Opensearch container is not running"
    exit
else
    docker exec $container_id keytool -import -alias node -keystore /etc/pki/java/cacerts -file /usr/share/opensearch/config/root-ca.der -storepass changeit -noprompt
    docker exec $container_id bash /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/opensearch/config/opensearch-security -icl -nhnv -cacert /usr/share/opensearch/config/root-ca.pem -cert /usr/share/opensearch/config/admin.pem -key /usr/share/opensearch/config/admin-key.pem
fi