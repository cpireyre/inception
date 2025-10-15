FROM alpine:3.21
EXPOSE 9000

COPY wp-cli.phar /wp/wp-cli.phar
COPY php.ini /etc/php83/php-fpm.conf

RUN apk update && apk add \
      mariadb-client \
      php \
      php-curl \
      php-fpm \
      php-iconv \
      php-mysqli \
      php-phar

RUN mkdir -p /var/lib && addgroup user && adduser -S user && chown -R user:user /var/lib
COPY          init-wp.sh /wp/init-wp.sh
RUN chmod +x             /wp/init-wp.sh
CMD                    ["/wp/init-wp.sh"]
