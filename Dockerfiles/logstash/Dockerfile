ARG LOGSTASH_VERSION=8.17.3
FROM docker.elastic.co/logstash/logstash-oss:${LOGSTASH_VERSION}

USER root

# Install required dependencies
RUN apt-get update && apt-get install -y python3 python3-yaml && rm -rf /var/lib/apt/lists/*

# Install Logstash plugin
RUN bin/logstash-plugin install logstash-output-opensearch

# Create necessary directories
RUN mkdir -p /etc/logstash 

# Ensure logstash user owns the directory
RUN chown -R logstash:logstash /etc/logstash

# Create the symlink and set permissions
RUN ln -s /usr/share/logstash/config/pipelines.yml /etc/logstash/pipelines.yml && \
    chown -h logstash:logstash /etc/logstash/pipelines.yml && \
    chmod 664 /etc/logstash/pipelines.yml && \
    ln -s /usr/lib/perfsonar/logstash/sysconfig /etc/default/logstash

# Set entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER logstash

ENTRYPOINT ["/entrypoint.sh"]