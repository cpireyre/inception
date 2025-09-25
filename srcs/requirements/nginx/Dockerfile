FROM alpine:3.22

RUN apk update && apk add nginx curl

COPY <<EOF /etc/nginx/nginx.conf
events {}
http {
  server {
    listen 80;
    server_name copireyr.42.fr;
  }
}
EOF

RUN nginx -t
CMD ["nginx", "-g", "daemon off;"]
