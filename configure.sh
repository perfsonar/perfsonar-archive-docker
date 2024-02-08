#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit
fi

PERFSONAR_VERSION="${PERFSONAR_VERSION:-5.1.0}"
OPENSEARCH_VERSION="${OPENSEARCH_VERSION:-2.7}"
OPENSEARCH_VERSION_LONG="${OPENSEARCH_VERSION_LONG:-2.7.0}"

if [ $1 = "pre" ]; then

    ### LOGSTASH SETUP

    git clone --branch $PERFSONAR_VERSION https://github.com/perfsonar/logstash.git logstash-git

    BASE_DIR=logstash-git/perfsonar-logstash/perfsonar-logstash

    mkdir -p /etc/logstash
    echo "[]" > /etc/logstash/pipelines.yml 
    python3 $BASE_DIR/scripts/update_logstash_pipeline_yml.py
    python3 $BASE_DIR/scripts/enable_prometheus_pipeline.py

    mkdir -p $BASE_DIR/java/maven
    mvn -Dmaven.repo.local=$BASE_DIR/java/maven -f ${BASE_DIR}/java/pom.xml dependency:resolve

    # COPYING FILES TO BINDED DIRECTORY
    mkdir -p logstash/configs
    mkdir -p logstash/pipeline
    mkdir -p logstash/prometheus_pipeline
    mkdir -p logstash/ruby
    mkdir -p logstash/java

    cp /etc/logstash/pipelines.yml logstash/configs/
    cp -r $BASE_DIR/pipeline/* logstash/pipeline/
    cp -r $BASE_DIR/prometheus_pipeline/* logstash/prometheus_pipeline/
    cp -r $BASE_DIR/ruby/* logstash/ruby/
    cp -r $BASE_DIR/java/* logstash/java/

    ### ARCHIVE SETUP

    git clone --branch $PERFSONAR_VERSION https://github.com/perfsonar/archive.git archive-git

    BASE_DIR=archive-git/perfsonar-archive/perfsonar-archive

    PASSWORD_DIR=/etc/perfsonar/opensearch
    mkdir -p ${PASSWORD_DIR}
    OPENSEARCH_CONFIG_DIR=/etc/opensearch
    mkdir -p ${OPENSEARCH_CONFIG_DIR}
    wget -O ${OPENSEARCH_CONFIG_DIR}/opensearch.yml https://raw.githubusercontent.com/opensearch-project/OpenSearch/${OPENSEARCH_VERSION}/distribution/docker/src/docker/config/opensearch.yml
    touch ${OPENSEARCH_CONFIG_DIR}/jvm.options
    mkdir -p /etc/perfsonar/logstash/

    git clone --branch $OPENSEARCH_VERSION https://github.com/opensearch-project/security.git

    OPENSEARCH_SECURITY_CONFIG=${OPENSEARCH_CONFIG_DIR}/opensearch-security
    mkdir -p ${OPENSEARCH_SECURITY_CONFIG}

    cp security/config/config.yml ${OPENSEARCH_SECURITY_CONFIG}/
    cp security/config/internal_users.yml ${OPENSEARCH_SECURITY_CONFIG}/
    cp security/config/roles.yml ${OPENSEARCH_SECURITY_CONFIG}/
    cp security/config/roles_mapping.yml ${OPENSEARCH_SECURITY_CONFIG}/

    OPENSEARCH_SECURITY_PLUGIN=/usr/share/opensearch/plugins/opensearch-security
    mkdir -p $OPENSEARCH_SECURITY_PLUGIN
    ln -s /usr/local/openjdk-17 /usr/share/opensearch/jdk
    ln -s /home/archive/security_tool $OPENSEARCH_SECURITY_PLUGIN/tools

    LOGSTASH_SYSCONFIG=/etc/default/logstash
    touch ${LOGSTASH_SYSCONFIG}

    # DO NOT RUN THESE COMMANDS
    sed -r -i 's/^(\/usr\/share\/opensearch\/jdk\/bin\/keytool.*)$/#\1/' ${BASE_DIR}/opensearch-scripts/pselastic_secure_pre.sh
    sed -r -i 's/^(htpasswd.*)$/#\1/' ${BASE_DIR}/opensearch-scripts/pselastic_secure_pre.sh

    bash ${BASE_DIR}/opensearch-scripts/pselastic_secure_pre.sh

    # COPYING FILES TO BINDED DIRECTORY
    mkdir -p archive/configs
    mkdir -p archive/certs

    cp $BASE_DIR/config/01-input-local_prometheus.conf logstash/prometheus_pipeline/
    cp ${PASSWORD_DIR}/auth_setup.out archive/
    cp ${OPENSEARCH_CONFIG_DIR}/*.pem archive/certs/
    cp ${OPENSEARCH_CONFIG_DIR}/*.der archive/certs/
    cp ${OPENSEARCH_CONFIG_DIR}/opensearch.yml archive/configs/
    cp -r ${OPENSEARCH_SECURITY_CONFIG}/* archive/configs/
    cp ${LOGSTASH_SYSCONFIG} logstash/.env

    # DASHBOARDS SETUP

    DASHBOARDS_PASS=$(grep -m1 -e ^kibanaserver ${PASSWORD_DIR}/auth_setup.out | awk '{print $2}')
    sed -i "s/opensearch.password: kibanaserver/opensearch.password: ${DASHBOARDS_PASS}/g" dashboards/opensearch_dashboards.yml

elif [ $1 = "post" ]; then

    ### ARCHIVE SETUP

    git clone --branch $PERFSONAR_VERSION https://github.com/perfsonar/archive.git archive-git

    BASE_DIR=archive-git/perfsonar-archive/perfsonar-archive

    OPENSEARCH_CONFIG_DIR=/etc/opensearch
    OPENSEARCH_SECURITY_CONFIG=${OPENSEARCH_CONFIG_DIR}/opensearch-security
    mkdir -p ${OPENSEARCH_SECURITY_CONFIG}
    ln -s archive/config/roles.yml ${OPENSEARCH_SECURITY_CONFIG}/roles.yml

    mkdir -p /etc/perfsonar/opensearch
    cp archive/auth_setup.out /etc/perfsonar/opensearch/

    mkdir -p /etc/logstash
    cp logstash/configs/pipelines.yml /etc/logstash/

    mkdir -p /usr/lib/perfsonar/archive/config/ilm/
    cp -r $BASE_DIR/config/ilm/* /usr/lib/perfsonar/archive/config/ilm/
    cp $BASE_DIR/config/index_template* /usr/lib/perfsonar/archive/config/

    # DO NOT RUN THIS COMMAND
    sed -r -i 's/^(.*\/tools\/securityadmin\.sh.*)$/#\1/' ${BASE_DIR}/opensearch-scripts/pselastic_secure_pos.sh

    bash ${BASE_DIR}/opensearch-scripts/pselastic_secure_pos.sh

    # DASHBOARDS SETUP

    BASE_DIR=archive-git/perfsonar-dashboards/perfsonar-dashboards

    # DO NOT RUN THIS COMMAND
    sed -r -i "s/^(DASHBOARDS_VERSION=).*$/\1${OPENSEARCH_VERSION_LONG}/" ${BASE_DIR}/dashboards-scripts/dashboards_secure_pos.sh

    bash ${BASE_DIR}/dashboards-scripts/dashboards_secure_pos.sh

else
    # Otherwise, just exec the command.
    exec "$@"
fi