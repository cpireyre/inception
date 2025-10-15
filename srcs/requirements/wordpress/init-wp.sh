#!/bin/sh
# shellcheck shell=sh
set -eux

addgroup user || true
adduser -S user -G user || true

if [ ! -f "/wp/wp-config.php" ]; then
  echo "Installing Wordpress..."
  cd  /wp
  php -d memory_limit=512M wp-cli.phar core download
  php wp-cli.phar config create \
    --allow-root \
    --dbhost=mariadb:3306 \
    --dbname=wordpress \
    --dbpass=$DB_PASSWORD \
    --dbuser=$DB_USER
  php wp-cli.phar db create
  php wp-cli.phar core install \
    --admin_email=$WP_ADMIN_EMAIL \
    --admin_password=$WP_ADMIN_PASSWORD \
    --admin_user=$WP_ADMIN_USER \
    --title=Blog \
    --url=$WP_URL
  php wp-cli.phar user create \
    $WP_USER \
    $WP_USER_EMAIL \
    --user_pass=$WP_USER_PASSWORD
else
  echo "Skipping Wordpress install..."
fi

chown -R user:user /var/lib
chmod -R 755 /var/lib

exec php-fpm83 -F
