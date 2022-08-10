#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out
OPENSEARCH_SECURITY_PLUGIN=$PWD/security_tool

# new users: pscheduler_logstash, pscheduler_reader and pscheduler_writer
# 1. Create users, generate passwords and save them to file 
echo "[Creating pscheduler_logstash user]"
grep "# Pscheduler Logstash" $OPENSEARCH_CONFIG_DIR/internal_users.yml
if [ $? -eq 0 ]; then
    echo "User already created"
else
    # pscheduler_logstash
    PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20)
    HASHED_PASS=$(${OPENSEARCH_SECURITY_PLUGIN}/hash.sh -p $PASS | tail -n 1)
    echo "pscheduler_logstash $PASS" | tee -a $PASSWORD_FILE  > /dev/null
    echo | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo 'pscheduler_logstash:' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  hash: "'$HASHED_PASS'"' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  reserved: true' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  description: "pscheduler logstash user"' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null

    # pscheduler_reader
    PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20)
    HASHED_PASS=$(${OPENSEARCH_SECURITY_PLUGIN}/hash.sh -p $PASS | tail -n 1)
    echo "pscheduler_reader $PASS" | tee -a $PASSWORD_FILE  > /dev/null
    echo | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo 'pscheduler_reader:' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  hash: "'$HASHED_PASS'"' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  reserved: true' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  description: "pscheduler reader user"' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
 
    # pscheduler_writer
    PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20)
    HASHED_PASS=$(${OPENSEARCH_SECURITY_PLUGIN}/hash.sh -p $PASS | tail -n 1)
    echo "pscheduler_writer $PASS" | tee -a $PASSWORD_FILE  > /dev/null
    echo | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo 'pscheduler_writer:' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  hash: "'$HASHED_PASS'"' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  reserved: true' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
    echo '  description: "pscheduler writer user"' | tee -a $OPENSEARCH_CONFIG_DIR/internal_users.yml > /dev/null
fi