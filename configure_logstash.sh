#!/bin/bash

PASSWORD_FILE=${PASSWORD_DIR}/auth_setup.out
PROXY_AUTH_JSON=/etc/perfsonar/logstash/proxy_auth.json
LOGSTASH_PROXY_LOGIN_FILE=${PASSWORD_DIR}/logstash_login
LOGSTASH_PROXY_USER=perfsonar
LOGSTASH_USER=pscheduler_logstash

CACERTS_FILE=/etc/pki/java/cacerts
LOGSTASH_SYSCONFIG=/etc/sysconfig/logstash

# Create perfsonar usar for logstash auth in proxy layer
if [ -f "$LOGSTASH_PROXY_LOGIN_FILE" ] ; then
    rm "$LOGSTASH_PROXY_LOGIN_FILE"
fi
PROXY_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20)
htpasswd -bc $LOGSTASH_PROXY_LOGIN_FILE $LOGSTASH_PROXY_USER $PROXY_PASS
LOGIN_BASE64=$(echo -n "$LOGSTASH_PROXY_USER:$PROXY_PASS" | base64 -i)
echo "\"Authorization\":\"Basic $LOGIN_BASE64\"" | tee -a $PROXY_AUTH_JSON > /dev/null

# 5. Configure logstash to use pscheduler_logstash user/password
echo "[Configure logstash]"
LOGSTASH_PASS=$(grep "pscheduler_logstash " $PASSWORD_FILE | head -n 1 | sed 's/^pscheduler_logstash //')
echo "LOGSTASH_ELASTIC_USER=${LOGSTASH_USER}" | tee -a $LOGSTASH_SYSCONFIG > /dev/null
sed -i 's/opensearch_output_password=pscheduler_logstash/opensearch_output_password='$LOGSTASH_PASS'/g' $LOGSTASH_SYSCONFIG
echo "[DONE]"
echo ""

# 6. Fixes
#changing the logstash port range to avoid conflict with opendistro-performance-analyzer
sed -i 's/# api.http.port: 9600-9700/api.http.port: 9601-9700/g' /etc/logstash/logstash.yml