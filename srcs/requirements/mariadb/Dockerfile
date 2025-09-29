FROM alpine:3.22
EXPOSE 3306

RUN apk update && apk add mariadb mariadb-client

COPY          init-mariadb.sh /
RUN chmod +x /init-mariadb.sh
CMD        ["/init-mariadb.sh"]
