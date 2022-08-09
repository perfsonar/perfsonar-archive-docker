#!/bin/bash

OPENSEARCH_CERTS_DIR=$PWD/certs

mkdir -p ${OPENSEARCH_CERTS_DIR}

# Generate Opensearch Certificates
# Root CA
openssl genrsa -out ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem -subj "/CN=localhost/OU=Example/O=Example/C=br" -out ${OPENSEARCH_CERTS_DIR}/root-ca.pem -days 180
# Admin cert
openssl genrsa -out ${OPENSEARCH_CERTS_DIR}/admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ${OPENSEARCH_CERTS_DIR}/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${OPENSEARCH_CERTS_DIR}/admin-key.pem
openssl req -new -key ${OPENSEARCH_CERTS_DIR}/admin-key.pem -subj "/CN=admin" -out ${OPENSEARCH_CERTS_DIR}/admin.csr
openssl x509 -req -in ${OPENSEARCH_CERTS_DIR}/admin.csr -CA ${OPENSEARCH_CERTS_DIR}/root-ca.pem -CAkey ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem -CAcreateserial -sha256 -out ${OPENSEARCH_CERTS_DIR}/admin.pem -days 180
# Node cert
openssl genrsa -out ${OPENSEARCH_CERTS_DIR}/node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ${OPENSEARCH_CERTS_DIR}/node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${OPENSEARCH_CERTS_DIR}/node-key.pem
openssl req -new -key ${OPENSEARCH_CERTS_DIR}/node-key.pem -subj "/CN=localhost/OU=node/O=node/L=test/C=br" -out ${OPENSEARCH_CERTS_DIR}/node.csr
openssl x509 -req -in ${OPENSEARCH_CERTS_DIR}/node.csr -CA ${OPENSEARCH_CERTS_DIR}/root-ca.pem -CAkey ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem -CAcreateserial -sha256 -out ${OPENSEARCH_CERTS_DIR}/node.pem -days 180
# Cleanup
rm -f ${OPENSEARCH_CERTS_DIR}/admin-key-temp.pem ${OPENSEARCH_CERTS_DIR}/admin.csr ${OPENSEARCH_CERTS_DIR}/node-key-temp.pem ${OPENSEARCH_CERTS_DIR}/node.csr
# Add to Java cacerts
openssl x509 -outform der -in ${OPENSEARCH_CERTS_DIR}/node.pem -out ${OPENSEARCH_CERTS_DIR}/node.der
