# 01 - Prerequisites

This step prepares the Docker host before deploying Traefik.

The goal is to make sure Docker works, the shared proxy network exists, and the real runtime directory is ready. Traefik is not started in this step.

## Target host

Traefik will run on the Docker VM inside Proxmox:

```text
ubuntu-docker
```

This host runs Docker Compose services and will become the reverse proxy host for Docker-based applications.

## Required tools

The host should already have:

```text
Docker Engine
Docker Compose plugin
```

This step also uses:

```text
openssl
apache2-utils
```

`openssl` is used later for the first local self-signed certificate.

`apache2-utils` provides `htpasswd`, which is used to generate the Traefik dashboard basic authentication hash.

Install the helper packages if needed:

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

Check that Docker is running:

```bash
systemctl status docker --no-pager -l
```

Optional basic test:

```bash
docker run --rm hello-world
```

## Create the proxy network

Traefik and routed containers will share an external Docker network named `proxy`.

Create it if it does not already exist:

```bash
docker network inspect proxy >/dev/null 2>&1 || docker network create proxy
```

Verify it:

```bash
docker network ls | grep proxy
docker network inspect proxy
```

## Create the runtime directory

The real Traefik deployment files live outside the Git repository.

Runtime path:

```text
/srv/docker/traefik
```

Create the directory structure:

```bash
sudo mkdir -p /srv/docker/traefik/{certs,dynamic}
sudo chown -R "$USER:$USER" /srv/docker/traefik
```

Expected layout at this stage:

```text
/srv/docker/traefik/
├── certs/
└── dynamic/
```

Later steps will add the real runtime files:

```text
/srv/docker/traefik/
├── compose.yml
├── .env
├── acme.json
├── certs/
└── dynamic/
```

These real files are not committed to Git.

## Copy example files

The repository contains sanitized examples:

```text
examples/traefik/
├── compose.example.yml
├── whoami.example.yml
├── .env.example
└── dynamic/
    └── tls.example.yml
```

Copy the Traefik examples into the runtime folder:

```bash
cp examples/traefik/compose.example.yml /srv/docker/traefik/compose.yml
cp examples/traefik/.env.example /srv/docker/traefik/.env
cp examples/traefik/dynamic/tls.example.yml /srv/docker/traefik/dynamic/tls.yml
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

## Firewall expectation

Traefik is not running yet.

When deployed later, only these ports should be exposed from the Docker host:

```text
80/tcp
443/tcp
```

The insecure dashboard port should not be published.

Check current listening ports:

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
/srv/docker/traefik exists
/srv/docker/traefik/certs exists
/srv/docker/traefik/dynamic exists
real runtime files are outside the Git repository
```

Useful commands:

```bash
docker --version
docker compose version
docker network ls | grep proxy
ls -la /srv/docker/traefik
find examples/traefik -maxdepth 3 -type f | sort
git status --short
```

## Cleanup notes

This step is low risk because it only prepares the host.

Cleanup commands:

```bash
docker network rm proxy
sudo rm -rf /srv/docker/traefik
```

Only remove the `proxy` network if no containers are using it.

Check first:

```bash
docker network inspect proxy
```

## References

* Docker Compose networking: https://docs.docker.com/compose/how-tos/networking/
* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/

