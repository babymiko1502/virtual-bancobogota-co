# Build a single container running Nginx + PHP-FPM on Render
FROM php:8.2-fpm-alpine

# Install system deps + nginx + supervisor + envsubst
RUN apk add --no-cache nginx supervisor bash gettext

# PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Create app dir
WORKDIR /var/www/html

# Copy application (Render will build from your repo root, leave this as is.
# When you push your code, it will be copied here by Render)
COPY . /var/www/html

# Nginx config template and supervisor config
COPY deploy/nginx.conf.template /etc/nginx/nginx.conf.template
COPY deploy/supervisord.conf /etc/supervisord.conf
COPY deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Render sets $PORT. We'll expose for clarity.
EXPOSE 10000

# Healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:${PORT:-10000}/ || exit 1

# Start supervisor which manages php-fpm and nginx
CMD ["/entrypoint.sh"]
