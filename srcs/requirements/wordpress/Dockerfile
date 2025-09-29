FROM alpine:3.22

COPY wp-cli.phar /wp/wp-cli.phar

RUN apk update && apk add \
      mariadb-client \
      php \
      php-curl \
      php-fpm \
      php-iconv \
      php-mysqli \
      php-phar

COPY          init-wp.sh /wp/init-wp.sh
RUN chmod +x             /wp/init-wp.sh
CMD                    ["/wp/init-wp.sh"]
