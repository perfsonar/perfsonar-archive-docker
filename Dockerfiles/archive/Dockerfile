ARG OPENSEARCH_VERSION=2.18.0
FROM opensearchproject/opensearch:${OPENSEARCH_VERSION}

USER root

# Install required dependencies
RUN dnf update -y && dnf install -y openssl procps-ng

# Install gosu to allow privilege dropping
RUN curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Link config directory, create password file and prepare sysconfig file
RUN ln -s /usr/share/opensearch/config /etc/opensearch && \
    mkdir -p /etc/perfsonar/opensearch && \
    touch /etc/perfsonar/opensearch/auth_setup.out && \
    mkdir -p /etc/perfsonar/logstash && \
    chown opensearch:opensearch -R /etc/perfsonar && \
    touch /etc/sysconfig/logstash && \
    chown opensearch:opensearch /etc/sysconfig/logstash && \
    chmod 664 /etc/sysconfig/logstash && \
    touch /etc/redhat-release

# Set entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]