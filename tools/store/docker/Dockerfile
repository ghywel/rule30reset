# The project's shared store as one container: store.php, unchanged, behind FrankenPHP (PHP inside the Caddy web
# server, which obtains and renews the HTTPS certificate by itself).
# Build from tools/store:   docker build -f docker/Dockerfile -t rule30-store .
FROM dunglas/frankenphp:1-php8.4-alpine

# The base image lets its server binary bind low ports. The store listens on high ports as an ordinary user with every
# capability dropped, and a binary that carries a capability will not start there: remove it. Remove the base
# image's sample site too, and take PHP's production settings.
RUN setcap -r /usr/local/bin/frankenphp \
 && rm -rf /app/public /etc/frankenphp /data /config \
 && mkdir -p /app/public /data /config \
 && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY store.php /app/public/store.php
COPY docker/config.php docker/registry.php /app/
COPY docker/store.ini /usr/local/etc/php/conf.d/zz-store.ini
COPY --chmod=755 docker/store-admin /usr/local/bin/store-admin
COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/store-entrypoint

LABEL org.opencontainers.image.title="rule30-store" \
      org.opencontainers.image.description="The Rule 30 project's shared store: store.php behind FrankenPHP, HTTPS certificate included"

ENV SHAREDSTORE_CONFIG=/app/config.php \
    HOME=/tmp \
    XDG_CONFIG_HOME=/tmp/xdg/config \
    XDG_DATA_HOME=/tmp/xdg/data

# 568 is the "apps" user of TrueNAS. Another host sets its own with user: in the YAML.
USER 568:568
WORKDIR /app
EXPOSE 8443 8080
HEALTHCHECK --interval=30s --timeout=8s --start-period=20s --retries=3 CMD ["store-admin", "health"]
ENTRYPOINT ["store-entrypoint"]
