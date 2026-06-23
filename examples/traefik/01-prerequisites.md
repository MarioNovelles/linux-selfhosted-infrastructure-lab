# 01 - Prerequisites

This step documents what needs to exist before deploying Traefik.

The goal is to make sure the Docker host is ready, the runtime folder exists, and the shared proxy network is available before any reverse proxy configuration is started.

## Target host

Traefik will run on the Docker VM inside Proxmox.

Example lab role:

```text
ubuntu-docker
```

This host is used for Docker Compose services and will become the main reverse proxy host for Docker-based applications.

## Required packages

The host should have:

```text
Docker Engine
Docker Compose plugin
openssl
apache2-utils
```

`openssl` is used for the first local self-signed certificate.

`apache2-utils` provides `htpasswd`, which is used to generate the Traefik dashboard basic authentication hash.

Install helper packages if needed:

```bash
sudo apt update
sudo apt install apache2-utils openssl
```

## Verify Docker

Check Docker:

```bash
docker --version
```

Check Docker Compose:

```bash
docker compose version
```

Check that the Docker service is running:

```bash
systemctl status docker --no-pager -l
```

A basic container test can also be used:

```bash
docker run --rm hello-world
```

## Create the proxy network

Traefik and routed containers will share an external Docker network.

Create it once:

```bash
docker network create proxy
```

If the network already exists, Docker will print an error. That is not a problem.

Verify the network:

```bash
docker network ls | grep proxy
```

Inspect it if needed:

```bash
docker network inspect proxy
```

## Create the runtime directory

The real Traefik deployment files should live outside the Git repository.

Example runtime path:

```text
/opt/traefik
```

Create the folder structure:

```bash
sudo mkdir -p /opt/traefik/{certs,dynamic}
sudo chown -R "$USER:$USER" /opt/traefik
```

Expected layout:

```text
/opt/traefik/
├── certs/
└── dynamic/
```

The real runtime files will later be added here:

```text
/opt/traefik/
├── compose.yml
├── .env
├── acme.json
├── certs/
└── dynamic/
```

These real files are not committed to Git.

## Repository example files

The repository contains sanitized examples only:

```text
examples/traefik/
├── compose.example.yml
├── whoami.example.yml
├── .env.example
└── dynamic/
    └── tls.example.yml
```

These are copied into the runtime folder when building the real deployment.

Example:

```bash
cp examples/traefik/compose.example.yml /opt/traefik/compose.yml
cp examples/traefik/.env.example /opt/traefik/.env
cp examples/traefik/dynamic/tls.example.yml /opt/traefik/dynamic/tls.yml
```

The copied files must be edited before use.

## Files that should not be committed

Do not commit real runtime files:

```text
compose.yml
.env
acme.json
certs/
dynamic/tls.yml
```

These may contain local hostnames, generated dashboard password hashes, Cloudflare tokens, certificates, or environment-specific paths.

## Firewall expectations

At this stage, Traefik is not running yet.

When Traefik is deployed later, only these ports should be exposed from the Docker host:

```text
80/tcp
443/tcp
```

The insecure dashboard port should not be published.

Check listening ports before deployment:

```bash
ss -tulpn | grep -E ':80|:443|:8080'
```

It is fine if nothing is listening yet.

## Validation checklist

Before moving to the next step, confirm:

```text
Docker works
Docker Compose works
proxy network exists
/opt/traefik exists
/opt/traefik/certs exists
/opt/traefik/dynamic exists
real runtime files are outside the Git repository
```

Useful commands:

```bash
docker --version
docker compose version
docker network ls | grep proxy
ls -la /opt/traefik
find examples/traefik -maxdepth 3 -type f | sort
git status --short
```

## Rollback notes

This step is low risk.

Rollback options:

```bash
docker network rm proxy
sudo rm -rf /opt/traefik
```

Only remove the `proxy` network if no containers are using it.

Check first:

```bash
docker network inspect proxy
```

## Notes

This step only prepares the host.

Traefik routing, local DNS records, certificates, and test services are documented in later steps.

## References

* Docker Compose networking: https://docs.docker.com/compose/how-tos/networking/
* Docker restart policies: https://docs.docker.com/engine/containers/start-containers-automatically/
* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/

