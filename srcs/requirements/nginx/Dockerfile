FROM alpine:3.21

RUN apk update && apk add nginx openssl

COPY nginx.conf /etc/nginx/

# https://www.feistyduck.com/library/openssl-cookbook/
RUN openssl genpkey -out site.key \
      -algorithm RSA \
      -pkeyopt rsa_keygen_bits:2048 \
      && openssl pkey -in site.key -pubout -out site-public.key \
      && openssl req -new -x509 -days 365 -key site.key -out site.crt \
          -subj "/C=FI/L=Helsinki/O=FakethenticIO/CN=copireyr.42.fr"

CMD ["nginx", "-e", "stderr", "-g", "daemon off;"]
