FROM httpd:2.4-alpine

RUN apk add --no-cache apache2-utils

# Enable required Apache modules
RUN sed -i \
    -e 's/^#LoadModule proxy_module/LoadModule proxy_module/' \
    -e 's/^#LoadModule proxy_http_module/LoadModule proxy_http_module/' \
    -e 's/^#LoadModule ssl_module/LoadModule ssl_module/' \
    -e 's/^#LoadModule socache_shmcb_module/LoadModule socache_shmcb_module/' \
    -e 's/^#LoadModule auth_basic_module/LoadModule auth_basic_module/' \
    -e 's/^#LoadModule authn_file_module/LoadModule authn_file_module/' \
    -e 's/^#LoadModule authz_core_module/LoadModule authz_core_module/' \
    -e 's/^#LoadModule authz_user_module/LoadModule authz_user_module/' \
    conf/httpd.conf

COPY httpd.conf conf/extra/perfsonar-proxy.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN echo "Include conf/extra/perfsonar-proxy.conf" >> conf/httpd.conf \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]