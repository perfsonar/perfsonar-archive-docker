#!/bin/sh
set -eu

PASSWORD_DIR=/etc/perfsonar/opensearch
PROXY_AUTH_DIR=/etc/perfsonar/logstash

PROXY_AUTH_JSON="${PROXY_AUTH_DIR}/proxy_auth.json"
LOGSTASH_PROXY_LOGIN_FILE="${PASSWORD_DIR}/logstash_login"

LOGSTASH_PROXY_USER=perfsonar

mkdir -p "$PASSWORD_DIR" "$PROXY_AUTH_DIR"

# Generate credentials only on the first startup.
# This preserves them across container restarts.
if [ ! -s "$LOGSTASH_PROXY_LOGIN_FILE" ] || [ ! -s "$PROXY_AUTH_JSON" ]; then

    echo "Generating Logstash proxy credentials..."

    PROXY_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)

    # Create Apache htpasswd file using bcrypt
    printf '%s\n' "$PROXY_PASS" | \
        htpasswd -B -c -i "$LOGSTASH_PROXY_LOGIN_FILE" "$LOGSTASH_PROXY_USER"

    # Generate Base64 authentication header
    LOGIN_BASE64=$(printf '%s' \
        "${LOGSTASH_PROXY_USER}:${PROXY_PASS}" | base64 | tr -d '\n')

    # Create proxy authentication JSON
    printf '"Authorization":"Basic %s"\n' "$LOGIN_BASE64" \
        > "$PROXY_AUTH_JSON"

    chmod 0644 "$LOGSTASH_PROXY_LOGIN_FILE"
    chmod 0644 "$PROXY_AUTH_JSON"

    echo "Logstash proxy credentials generated."

else
    echo "Existing Logstash proxy credentials found."
fi

# Start Apache
exec httpd-foreground