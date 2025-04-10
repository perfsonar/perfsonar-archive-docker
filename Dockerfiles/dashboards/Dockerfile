ARG OPENSEARCH_VERSION=2.18.0
FROM opensearchproject/opensearch-dashboards:${OPENSEARCH_VERSION}

USER root

# Install required dependencies
RUN dnf update -y && dnf install -y jq

# Install gosu to allow privilege dropping
RUN curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Link config directory and password file
RUN ln -s /usr/share/opensearch-dashboards/config/ /etc/opensearch-dashboards && \
    mkdir -p /etc/perfsonar/opensearch && \
    ln -s /usr/lib/perfsonar/archive/auth_setup.out /etc/perfsonar/opensearch/auth_setup.out && \
    chown opensearch-dashboards:opensearch-dashboards -R /etc/perfsonar

# Set entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]