FROM alpine:3.22

RUN apk update && apk add nginx curl

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-e", "stderr", "-g", "daemon off;"]
