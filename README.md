# Inception

A small WordPress hosting stack run as three Docker containers — an NGINX
front end, WordPress on PHP-FPM, and a MariaDB database — each built from a
custom Alpine image and orchestrated with Docker Compose.

This was built for the 42 / Hive Helsinki *Inception* project. The constraint
that shapes the whole design: no pre-built application images. Every service
starts from `alpine:3.22` and is configured from a Dockerfile and an init
script, rather than pulling `wordpress:latest` or `mariadb:latest`.

## Architecture

```
                        :443 (TLS)
   browser  ──────────────▶  nginx  ──────────────▶  wordpress  ──────────────▶  mariadb
                          (TLS term,        FastCGI :9000      (php-fpm 8.3,        :3306
                           static files)                       wp-cli)
```

Three services on a single user-defined bridge network (`app`):

- **nginx** — the only container exposed to the host (port `443`). Terminates
  TLS (1.2/1.3, self-signed certificate generated at build time) and serves the
  site, passing `.php` requests to WordPress over FastCGI. No plain-HTTP port is
  opened.
- **wordpress** — PHP-FPM 8.3 listening on `:9000`, with no public port. On
  first boot an init script downloads WordPress via `wp-cli`, writes
  `wp-config.php`, creates the database, and installs the site. The check is
  idempotent: if `wp-config.php` already exists on the volume, install is
  skipped.
- **mariadb** — the database, reachable only inside the network on `:3306`. Its
  init script bootstraps the data directory and creates the application user on
  first run, then skips that work on subsequent starts.

Two named volumes hold the persistent state:

- `wp-data` — the WordPress install, shared between the `wordpress` and `nginx`
  containers (PHP executes the files, NGINX serves them).
- `db-data` — the MariaDB data directory.

Startup ordering is enforced rather than assumed: MariaDB defines a
`healthcheck` (a `mariadb-admin ping`), and WordPress declares
`depends_on: { mariadb: { condition: service_healthy } }`, so the WordPress
install only runs once the database is actually accepting connections. All
services use `restart: unless-stopped`.

## Layout

```
srcs/
├── compose.yaml
├── .env                      # secrets — git-ignored
└── requirements/
    ├── nginx/
    │   ├── Dockerfile         # alpine + nginx + openssl, generates the cert
    │   └── nginx.conf
    ├── wordpress/
    │   ├── Dockerfile         # alpine + php-fpm 8.3 + wp-cli deps
    │   ├── php.ini            # php-fpm pool config
    │   ├── wp-cli.phar
    │   └── init-wp.sh         # idempotent WordPress install
    └── mariadb/
        ├── Dockerfile
        └── init-mariadb.sh    # idempotent DB bootstrap
```

## Running it

Requires Docker with the Compose plugin.

1. Create `srcs/.env` with the variables listed below.

2. Map the site's domain to localhost so the certificate's CN resolves. Add to
   `/etc/hosts`:

   ```
   127.0.0.1   copireyr.42.fr
   ```

3. Build and start everything from the repository root:

   ```sh
   docker compose -f srcs/compose.yaml up --build -d
   ```

4. Open `https://copireyr.42.fr/`. The certificate is self-signed, so the
   browser will warn before you continue.

Tear down with `docker compose -f srcs/compose.yaml down`, or
`down -v` to also drop the volumes and reset the install.

## Configuration

All configuration is supplied through `srcs/.env`, which is git-ignored and not
committed. The Compose file reads it for variable substitution and passes the
values into the containers.

| Variable             | Used by   | Purpose                                   |
| -------------------- | --------- | ----------------------------------------- |
| `DB_USER`            | mariadb, wordpress | Application database user          |
| `DB_PASSWORD`        | mariadb, wordpress | Password for `DB_USER`             |
| `DB_ROOT_PASSWORD`   | mariadb   | MariaDB root password                     |
| `WP_ADMIN_USER`      | wordpress | WordPress admin account name              |
| `WP_ADMIN_PASSWORD`  | wordpress | WordPress admin password                  |
| `WP_ADMIN_EMAIL`     | wordpress | WordPress admin email                     |
| `WP_URL`             | wordpress | Site URL (e.g. `https://copireyr.42.fr`)  |

Example `srcs/.env`:

```sh
DB_USER=wp_user
DB_PASSWORD=change_me
DB_ROOT_PASSWORD=change_me_too
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=change_me_admin
WP_ADMIN_EMAIL=admin@example.com
WP_URL=https://copireyr.42.fr
```
