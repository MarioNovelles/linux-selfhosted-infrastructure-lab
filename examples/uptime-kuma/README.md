## Validation and troubleshooting

After starting the service, validate it layer by layer.

First, check whether the Docker Compose service is running:

```bash
docker compose ps
```

This confirms whether the Uptime Kuma container is running, restarting, stopped, or unhealthy.

Check the recent application logs:

```bash
docker compose logs --tail=100
```

This is useful for finding startup errors, application errors, permission problems, or data directory issues.

Check whether the host is listening on the expected port:

```bash
ss -tulpn | grep 3001
```

The `ss` command shows listening network sockets. The options mean:

* `-t`: show TCP sockets
* `-u`: show UDP sockets
* `-l`: show listening sockets
* `-p`: show the process using the socket
* `-n`: show numeric addresses and ports

Because this example binds Uptime Kuma to localhost by default, the expected listener should normally be on `127.0.0.1:3001`.

Check whether the application responds locally:

```bash
curl -I http://127.0.0.1:3001
```

The `-I` option requests only the HTTP response headers. This confirms whether the web application responds from the server itself.

If the local `curl` request works but the service is unreachable through the browser or reverse proxy, investigate the next layers separately:

* DNS resolution
* firewall rules
* reverse proxy configuration
* TLS certificate handling
* VPN or access-control path

If the local `curl` request fails, investigate the service locally first:

* `docker compose ps`
* `docker compose logs --tail=100`
* port binding
* application data directory permissions
* available disk space

## Validation performed

The Compose file was validated before documenting this example.

```bash
docker compose config
```

The service was started successfully:

```bash
docker compose up -d
```

The running container was checked with:

```bash
docker compose ps
```

Recent logs were reviewed with:

```bash
docker compose logs --tail=100
```

The local port binding was checked with:

```bash
ss -tulpn | grep 3001
```

Local HTTP response was tested with:

```bash
curl -I http://127.0.0.1:3001
```

This validation confirms that the service can be started, inspected through Docker Compose, checked at the network socket layer, and tested locally before investigating reverse proxy, DNS, TLS, or firewall layers.

## Database backend

This example uses MariaDB as the database backend for Uptime Kuma.

The stack contains two services:

| Service       | Purpose                    |
| ------------- | -------------------------- |
| `uptime-kuma` | The monitoring application |
| `mariadb`     | The database backend       |

MariaDB is not exposed with a host port. It is only reachable by Uptime Kuma through the private Docker Compose network.

During setup, the database connection values are:

| Uptime Kuma field | Value                                          |
| ----------------- | ---------------------------------------------- |
| Hostname          | `mariadb`                                      |
| Port              | `3306`                                         |
| Username          | value of `MARIADB_USER`                        |
| Password          | value of `MARIADB_PASSWORD`                    |
| Database Name     | value of `MARIADB_DATABASE`                    |
| Enable SSL/TLS    | Disabled for this local private Docker network |

The database values are stored in a private `.env` file. The public repository only contains `.env.example` with placeholder values.

## Data locations

When deployed under `/srv/docker/uptime-kuma`, the persistent data layout is:

```text
/srv/docker/uptime-kuma/
├── compose.yml
├── .env
├── data/
└── database/
```

The directories have different purposes:

| Path         | Purpose                                             |
| ------------ | --------------------------------------------------- |
| `./data`     | Uptime Kuma runtime data and database configuration |
| `./database` | MariaDB database files                              |

This follows the lab architecture rule that each Compose project should keep its application data and database data in predictable, documented locations.

## Deployment variants

This example includes two deployment variants:

| Variant | Purpose |
|---|---|
| `compose.embedded.example.yml` | Simpler deployment using Uptime Kuma's embedded MariaDB option |
| `compose.external-mariadb.example.yml` | Advanced variant showing an external MariaDB container, private Docker networking, healthchecks, and database separation |

For my lab learning path, I deployed the external MariaDB variant to practice operating a database-backed Docker Compose stack.

## Reverse proxy integration

This service was successfully routed through the shared Traefik reverse proxy network.

See [`../traefik/README.md`](../traefik/README.md) for the reverse proxy deployment and validation notes.

## Security notes

* The MariaDB service has no published host port.
* Uptime Kuma connects to MariaDB through the internal Docker Compose network.
* Real database passwords are stored only in the private `.env` file.
* `.env.example` contains placeholder values only.
* For a local Compose network, database SSL/TLS is disabled.
* For a remote or cloud database, SSL/TLS should be enabled if required by the provider.
* For the real server ownership model, see [`docs/docker-compose-architecture.md`](../../docs/docker-compose-architecture.md)
