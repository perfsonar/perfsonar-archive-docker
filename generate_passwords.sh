#!/bin/bash

OPENSEARCH_CONFIG_DIR=$PWD/configs
PASSWORD_FILE=${OPENSEARCH_CONFIG_DIR}/auth_setup.out
OPENSEARCH_SECURITY_PLUGIN=$PWD/security_tool

# Give execute permission to opensearch hash script

chmod +x ${OPENSEARCH_SECURITY_PLUGIN}/hash.sh

# Generate default users random passwords, write them to tmp file and, if it works, move to permanent file
echo "[Generating opensearch passwords]"
if [ -e "$PASSWORD_FILE" ]; then
    echo "$PASSWORD_FILE already exists, so not generating new passwords"
else
    mkdir -p $PASSWORD_DIR
    TEMPFILE=$(mktemp)
    egrep -v '^[[:blank:]]' "${OPENSEARCH_CONFIG_DIR}/internal_users.yml" | egrep "\:$" | egrep -v '^\_' | sed 's\:\\g' | while read user; do
        PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20)
        echo "$user $PASS" >> $TEMPFILE
        HASHED_PASS=$(${OPENSEARCH_SECURITY_PLUGIN}/hash.sh -p $PASS | tail -n 1 | sed -e 's/[&\\/]/\\&/g')
        if [[ $OS == *"CentOS"* ]]; then
            sed -i -e '/^'$user'\:$/,/[^hash.*$]/s/\(hash\: \).*$/\1"'$HASHED_PASS'"/' "${OPENSEARCH_CONFIG_DIR}/internal_users.yml"
        elif [[ $OS == *"Debian"* ]] || [[ $OS == *"Ubuntu"* ]]; then
            sed -i -e '/^'$user'\:$/,/[^hash.*$]/      s/\(hash\: \).*$/\1"'$HASHED_PASS'"/' "${OPENSEARCH_CONFIG_DIR}/internal_users.yml"
        fi
    done
    mv $TEMPFILE $PASSWORD_FILE
    chmod 600 $PASSWORD_FILE
fi