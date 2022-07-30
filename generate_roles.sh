#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs

# 2. Create roles
echo "[Creating pscheduler_logstash role]"
grep "# Pscheduler Logstash" $OPENSEARCH_CONFIG_DIR/roles.yml
if [ $? -eq 0 ]; then
    echo "Role already created"
else
    # pscheduler_logstash
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "pscheduler_logstash:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "  cluster_permissions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "    - 'cluster_monitor'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "    - 'cluster_manage_index_templates'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "  index_permissions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "    - index_patterns:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'pscheduler_*'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      allowed_actions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'write'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'read'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'delete'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'create_index'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'manage'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'indices:admin/template/delete'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'indices:admin/template/get'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'indices:admin/template/put'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null

    # pscheduler_reader => read-only access to the pscheduler indices
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "pscheduler_reader:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "  reserved: true" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "  index_permissions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "    - index_patterns:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'pscheduler*'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      allowed_actions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'read'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null

    # pscheduler_writer => write-only access to the pscheduler indices
    echo | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "pscheduler_writer:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "  reserved: true" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "  index_permissions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "    - index_patterns:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'pscheduler*'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      allowed_actions:" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
    echo "      - 'write'" | tee -a $OPENSEARCH_CONFIG_DIR/roles.yml > /dev/null
fi