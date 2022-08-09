#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out
LOGSTASH_OUTPUT=$PWD/pipeline/99-outputs.conf
LOGSTASH_USER=pscheduler_logstash

# 5. Configure logstash to use pscheduler_logstash user/password
echo "[Configure logstash]"
LOGSTASH_PASS=$(grep -m1 -e ^${LOGSTASH_USER} ${PASSWORD_FILE} | awk '{print $2}')
sed -i 's/password => "PASSWORD"/password => "'$LOGSTASH_PASS'"/g' $LOGSTASH_OUTPUT