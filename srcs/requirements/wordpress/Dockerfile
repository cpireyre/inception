FROM alpine:3.22

COPY wp-cli.phar wp-cli.phar

RUN apk update && apk add \
      php \
      php-curl \
      php-fpm \
      php-mysqli \
      php-phar
RUN export WORDPRESS_DB_HOST=mariadb
RUN php -d memory_limit=512M wp-cli.phar core download
RUN php wp-cli.phar config create \
      --allow-root \
      --dbhost=mariadb:3306 \
      --dbname=wordpress \
      --dbpass=dontcommitthis \
      --dbuser=colin

RUN php wp-cli.phar db create
RUN php wp-cli.phar core install
