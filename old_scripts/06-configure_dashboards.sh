#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out
OPENSEARCHDASH_CONFIG=${OPENSEARCH_CONFIG_DIR}/opensearch_dashboards.yml
OPENSEARCHDASH_USER=kibanaserver

# Configure opensearch dashboards to use new kibanaserver password
echo "[Configure Opensearch-Dashboards]"

DASHBOARDS_PASS=$(grep -m1 -e ^${OPENSEARCHDASH_USER} ${PASSWORD_FILE} | awk '{print $2}')

sed -i "s/opensearch.password: kibanaserver/opensearch.password: ${DASHBOARDS_PASS}/g" $OPENSEARCHDASH_CONFIG