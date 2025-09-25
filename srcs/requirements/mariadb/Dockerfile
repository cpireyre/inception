FROM alpine:3.22
EXPOSE 3306

RUN apk update && apk add mariadb mariadb-client

COPY init.sh /
RUN chmod +x init.sh
CMD ["/init.sh"]
