#!/bin/sh
# shellcheck shell=sh
set -eux

php -d memory_limit=512M wp-cli.phar core download
php wp-cli.phar config create \
  --allow-root \
  --dbhost=mariadb:3306 \
  --dbname=wordpress \
  --dbpass=dontcommitthis \
  --dbuser=colin

php wp-cli.phar db create
php wp-cli.phar core install
