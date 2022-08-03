#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out
OPENSEARCHDASH_CONFIG=${OPENSEARCH_CONFIG_DIR}/opensearch_dashboards.yml

# Configure opensearch dashboards to use new kibanaserver password
echo "[Configure Opensearch-Dashboards]"

DASHBOARDS_PASS=$(grep "kibanaserver " ${PASSWORD_FILE} | head -n 1 | sed 's/^kibanaserver //')

sed -i "s/opensearch.password: kibanaserver/opensearch.password: ${DASHBOARDS_PASS}/g" $OPENSEARCHDASH_CONFIG
# Clear and then set reverse proxy settings
#sed -i '/^server.basePath:.*/d' $OPENSEARCHDASH_CONFIG
#sed -i '/^server.host:.*/d' $OPENSEARCHDASH_CONFIG

#echo "server.basePath: /opensearchdash" | tee -a $OPENSEARCHDASH_CONFIG > /dev/null
#echo "server.host: 127.0.0.1" | tee -a $OPENSEARCHDASH_CONFIG > /dev/null