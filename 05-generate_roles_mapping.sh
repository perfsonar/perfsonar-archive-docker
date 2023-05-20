#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs

# 3. Map users to roles
echo "[Mapping pscheduler users to pscheduler roles]"
grep "pscheduler" $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
if [ $? -eq 0 ]; then
    echo "Map already created"
else
    # pscheduler_logstash
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo 'pscheduler_logstash:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  reserved: true' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  users:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  - "pscheduler_logstash"' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null

    # pscheduler_reader
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo 'pscheduler_reader:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  reserved: true' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  users:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  - "pscheduler_reader"' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    # maps pscheduler_reader role with the anonymous user backend role
    echo '  backend_roles:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  - "opendistro_security_anonymous_backendrole"' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null

    # pscheduler_writer
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo 'pscheduler_writer:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  reserved: true' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  users:' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
    echo '  - "pscheduler_writer"' | tee -a $OPENSEARCH_CONFIG_DIR/roles_mapping.yml > /dev/null
fi

#issue: https://github.com/opendistro-for-elasticsearch/performance-analyzer/issues/229
#echo false | tee /usr/share/opensearch/data/batch_metrics_enabled.conf