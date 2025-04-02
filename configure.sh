#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit
fi

PERFSONAR_VERSION="${PERFSONAR_VERSION:-5.1.0}"
OPENSEARCH_VERSION="${OPENSEARCH_VERSION:-2.18}"
OPENSEARCH_VERSION_LONG="${OPENSEARCH_VERSION_LONG:-2.18.0}"

LOGSTASH_DIR=/usr/lib/perfsonar/logstash
ARCHIVE_DIR=/usr/lib/perfsonar/archive
DAHSBOARDS_DIR=/usr/lib/perfsonar/dashboards

if [ $1 = "pre" ]; then

    ### LOGSTASH SETUP

    git clone --branch $PERFSONAR_VERSION https://github.com/perfsonar/logstash.git logstash-git

    LOGSTASH_MAKE_DIR=logstash-git/perfsonar-logstash/perfsonar-logstash
    make -C $LOGSTASH_MAKE_DIR ROOTPATH=$LOGSTASH_DIR CONFIGPATH=$LOGSTASH_DIR SYSTEMDPATH=/etc/systemd/system install

    mkdir -p /etc/logstash
    touch /etc/logstash/pipelines.yml
    echo [] > /etc/logstash/pipelines.yml

    python3 $LOGSTASH_DIR/scripts/update_logstash_pipeline_yml.py
    python3 $LOGSTASH_DIR/scripts/enable_prometheus_pipeline.py

    ### ARCHIVE SETUP

    git clone --branch $PERFSONAR_VERSION https://github.com/perfsonar/archive.git archive-git
    
    ARCHIVE_MAKE_DIR=archive-git/perfsonar-archive/perfsonar-archive
    make -C ${ARCHIVE_MAKE_DIR} PERFSONAR-ROOTPATH=${ARCHIVE_DIR} LOGSTASH-ROOTPATH=${LOGSTASH_DIR} HTTPD-CONFIGPATH=/etc/http SYSTEMD-CONFIGPATH=/etc/systemd/system BINPATH=/usr/bin install

    #touch /etc/debian_version
    ln -s /usr/share/opensearch/config /etc/opensearch
    #touch /etc/default/logstash

    #parei na configuracao de logstash do archive pre

    # setting up environment with defaults to run perfsonar config script
    #LOGSTASH_SYSCONFIG=/etc/default/logstash
    LOGSTASH_SYSCONFIG=/etc/sysconfig/logstash
    touch ${LOGSTASH_SYSCONFIG}
    #ln -s /usr/local/openjdk-17 /usr/share/opensearch/jdk

    # do not run these commands
    #sed -i '/keytool -import/s/^/#/' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pre.sh
    sed -i '/htpasswd -bc/s/^/#/' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pre.sh
    #sed -i '/chown/s/^/#/' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pre.sh

    bash ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pre.sh install

    sed -i 's|^opensearch_output_host=https://localhost:9200|opensearch_output_host=https://opensearch-node:9200|' ${LOGSTASH_SYSCONFIG}
    PASSWORD_DIR=/etc/perfsonar/opensearch
    cp ${PASSWORD_DIR}/auth_setup.out ${ARCHIVE_DIR}
    cp ${LOGSTASH_SYSCONFIG} ${LOGSTASH_DIR}

    #OPENSEARCH_CONFIG_DIR=/etc/opensearch
    #chown --reference=${OPENSEARCH_CONFIG_DIR}/opensearch.yml ${OPENSEARCH_CONFIG_DIR}/*.pem
    #chown --reference=${OPENSEARCH_CONFIG_DIR}/opensearch.yml ${OPENSEARCH_CONFIG_DIR}/*.der
    #chown --reference=${OPENSEARCH_CONFIG_DIR}/opensearch.yml ${OPENSEARCH_CONFIG_DIR}/*.srl

    # # DASHBOARDS SETUP

    DASHBOARDS_MAKE_DIR=archive-git/perfsonar-dashboards/perfsonar-dashboards
    make -C ${DASHBOARDS_MAKE_DIR} DASHBOARDS-ROOTPATH=${DAHSBOARDS_DIR} HTTPD-CONFIGPATH=/etc/http install

    # do not run this command
    sed -i '/server.basePath/s/^/#/' ${DAHSBOARDS_DIR}/dashboards-scripts/dashboards_secure_pre.sh

    bash ${DAHSBOARDS_DIR}/dashboards-scripts/dashboards_secure_pre.sh

elif [ $1 = "post" ]; then

    PASSWORD_DIR=/etc/perfsonar/opensearch
    mkdir -p ${PASSWORD_DIR}
    cp ${ARCHIVE_DIR}/auth_setup.out ${PASSWORD_DIR}

    # do no run this command
    sed -r -i '/securityadmin\.sh/s/^/#/' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pos.sh

    # replace these lines
    sed -i 's|localhost:9200|opensearch-node-setup:9200|g' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pos.sh
    sed -i 's|opensearch_systemctl_status=.*|opensearch_systemctl_status=active|' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pos.sh
    sed -i 's|logstash_systemctl_status=.*|logstash_systemctl_status=active|' ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pos.sh

    bash ${ARCHIVE_DIR}/perfsonar-scripts/pselastic_secure_pos.sh

    # DASHBOARDS SETUP

    #replace these lines
    sed -i "s|^DASHBOARDS_VERSION=.*|DASHBOARDS_VERSION=${OPENSEARCH_VERSION_LONG}|" ${DAHSBOARDS_DIR}/dashboards-scripts/dashboards_secure_pos.sh
    sed -i 's|localhost:5601|opensearch-dashboards-setup:5601|g' ${DAHSBOARDS_DIR}/dashboards-scripts/dashboards_secure_pos.sh

    bash ${DAHSBOARDS_DIR}/dashboards-scripts/dashboards_secure_pos.sh

else
    # Otherwise, just exec the command.
    exec "$@"
fi