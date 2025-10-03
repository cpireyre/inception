FROM alpine:3.22

RUN apk update && apk add nginx openssl

COPY nginx.conf /etc/nginx/nginx.conf

# https://www.feistyduck.com/library/openssl-cookbook/online/openssl-command-line/key-generation.html
# https://www.feistyduck.com/library/openssl-cookbook/online/openssl-command-line/signing-your-own-certificates.html
RUN openssl genpkey -out fd.key \
      -algorithm RSA \
      -pkeyopt rsa_keygen_bits:2048 \
      && openssl pkey -in fd.key -pubout -out fd-public.key

CMD ["nginx", "-e", "stderr", "-g", "daemon off;"]
