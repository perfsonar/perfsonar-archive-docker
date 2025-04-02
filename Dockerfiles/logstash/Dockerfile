ARG LOGSTASH_VERSION
FROM docker.elastic.co/logstash/logstash-oss:${LOGSTASH_VERSION}

USER root

RUN apt-get update && apt-get install -y \
    git \
    make \
    python3 \
    python3-yaml \
    maven \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh

USER logstash

ENTRYPOINT ["/usr/local/bin/install.sh"]