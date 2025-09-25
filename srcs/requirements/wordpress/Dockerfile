FROM alpine:3.22

COPY wp-cli.phar wp-cli.phar

RUN apk update && apk add \
      php \
      php-curl \
      php-fpm \
      php-mysqli \
      php-phar

COPY init.sh /
RUN chmod +x init.sh
CMD ["init.sh"]
