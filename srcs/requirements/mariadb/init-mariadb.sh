#!/bin/sh
# shellcheck shell=sh
set -eux

addgroup mysql || true
adduser -S mysql -G mysql -h /var/lib/mariadb || true

directories="/run/mysqld /tmp/mariadb /var/lib/mariadb"
mkdir -p $directories
chown -R mysql $directories

cat > /etc/my.cnf.d/mariadb-server.cnf <<EOF
  [mariadb]
  bind-address = 0.0.0.0
  datadir      = /var/lib/mariadb
  port         = 3306
  socket       = /run/mysqld/mysqld.sock
  tmpdir       = /tmp/mariadb
EOF

if [ ! -d "/var/lib/mariadb/mysql" ]; then
  echo "Installing MariaDB..."

mariadb-install-db --user=mysql

mariadbd --bootstrap --user=mysql <<EOF
		use mysql;
		flush privileges;
		alter user 'root'@'localhost' identified by '$DB_ROOT_PASSWORD';
		create user '$DB_USER'@'%' identified by '$DB_PASSWORD';
		create user '$DB_USER'@'localhost' identified by '$DB_PASSWORD';
		grant all privileges on *.* to '$DB_USER'@'%';
		grant all privileges on *.* to '$DB_USER'@'localhost';
		flush privileges;
EOF

else
  echo "Skipping MariaDB install..."
fi

# mariadbd-safe refuses to quit on SIGQUIT
exec mariadbd --user=mysql
