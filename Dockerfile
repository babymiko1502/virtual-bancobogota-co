FROM php:8.2-apache

# Extensiones necesarias
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Habilitar mod_rewrite (si usas .htaccess)
RUN a2enmod rewrite

# Copiamos plantillas de Apache que respetan $PORT de Render
COPY apache/ports.conf.template /etc/apache2/ports.conf.template
COPY apache/000-default.conf.template /etc/apache2/sites-available/000-default.conf.template

# Copiamos entrypoint que sustituye $PORT al arrancar
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copiamos tu app
COPY . /var/www/html/

# Render inyecta PORT en runtime; exponemos algo por claridad
EXPOSE 10000
ENV PORT=10000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
