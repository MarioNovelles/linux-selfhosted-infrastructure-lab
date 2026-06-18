# Docker Compose Architecture Plan

This document describes the Docker Compose structure I plan to use for my self-hosted infrastructure lab.

The goal is to clean up the current container setup and make it easier to understand, back up, rebuild, and document. Some services were originally installed with `docker run`, some with Docker Compose, some through Portainer, and some through Portainer templates. That was useful while learning and experimenting, but a more consistent layout is better for long-term maintenance.

Real production configuration stays private. This repository only contains sanitized notes and examples.

## Goal

The main goal is to make containerized services easier to manage and rebuild.

The target approach is:

- use Docker Compose for containerized applications where it makes sense
- keep one Compose project per service or logical stack
- keep persistent data and configuration in predictable locations
- avoid storing secrets in public repositories
- use Portainer as a management interface, not as the only source of truth
- publish only sanitized examples in this public repository

This should make the lab easier to maintain and also make the documentation clearer for anyone reviewing the project.

## Filesystem Location

The planned host location for Compose projects is:

```text
/srv/docker/
```

I prefer `/srv/docker` because these services are part of the server workload and provide services from the system. This makes `/srv` a clean and Linux-friendly place for self-hosted application stacks and their related data.

Other options were considered:

| Path              | Notes                                                                                                               |
| ----------------- | ------------------------------------------------------------------------------------------------------------------- |
| `/srv/docker`     | Preferred option for self-hosted service stacks and related data                                                    |
| `/opt/docker`     | Also reasonable, but `/opt` is more commonly associated with optional application software                          |
| `/docker`         | Technically works, but it is a custom top-level directory and less aligned with normal Linux filesystem conventions |
| `/var/lib/docker` | Managed internally by Docker and should not be used for manually organizing Compose projects                        |

## Target Directory Layout

The planned structure is one folder per Compose project:

```text
/srv/docker/
  searxng/
    compose.yml
    .env
    config/
    data/

  uptime-kuma/
    compose.yml
    .env
    data/

  jellyfin/
    compose.yml
    .env
    config/
    cache/

  monitoring/
    compose.yml
    prometheus/
    grafana/

  wordpress/
    compose.yml
    .env
    wordpress/
    database/

  _shared/
    networks/
    proxy/
    notes/
```

The exact folders can change depending on the service, but the general pattern should stay consistent:

- `compose.yml` defines the service or stack
- `.env` stores local environment values and stays private
- `config/` stores application configuration when useful
- `data/` stores persistent application data when using bind mounts
- database-backed services keep application data and database data clearly separated
- shared notes, networks, or reverse proxy information can live under `_shared/`

## Single-Service and Multi-Service Stacks

Single-container applications should still use Docker Compose. This keeps the management style consistent and avoids having some services managed with `docker run` and others with Compose.

Example single-service layout:

```text
/srv/docker/uptime-kuma/
  compose.yml
  .env
  data/
```

Multi-container applications should keep related services together in the same Compose project.

Example application with a database:

```text
/srv/docker/wordpress/
  compose.yml
  .env
  wordpress/
  database/
```

This makes it easier to see which database belongs to which application and reduces the chance of leaving behind unknown containers, unused volumes, or undocumented dependencies.

## Compose Project Naming

Folder names should be simple, lowercase, and predictable.

Examples:

```text
searxng
uptime-kuma
vaultwarden
jellyfin
navidrome
monitoring
wordpress
```

The folder name should usually match the Compose project name and the main service name. This makes commands easier to understand:

```bash
cd /srv/docker/searxng
docker compose up -d
docker compose logs -f
docker compose pull
```

## Bind Mounts and Named Volumes

Both bind mounts and Docker named volumes can be useful. The important part is to choose them intentionally and document where the data lives.

Bind mounts are useful when I want the data to be visible on the host and easy to include in backups.

Example:

```yaml
volumes:
  - ./data:/app/data
```

Named volumes are useful when Docker-managed storage is acceptable or when the service documentation recommends them.

Example:

```yaml
services:
  app:
    volumes:
      - app_data:/app/data

volumes:
  app_data:
```

For this lab, the preferred approach is:

- use bind mounts for configuration and data that should be easy to inspect or back up
- use named volumes when the service documentation recommends them or direct host access is not needed
- document the data location for every service
- avoid changing storage paths without a backup and restore plan

## Environment Files and Secrets

Each Compose project can use a local `.env` file for values such as ports, time zone, user IDs, domain names, or other local settings.

Example:

```text
/srv/docker/service-name/.env
```

Real `.env` files should not be committed to the public repository.

Public examples should use:

```text
.env.example
```

with placeholder values such as:

```text
TZ=Europe/Berlin
APP_PORT=8080
DOMAIN=example.local
PASSWORD=CHANGE_ME
```

Secrets, passwords, API keys, tokens, private domains, internal IP addresses, and real host paths should stay private.

## Portainer Role

Portainer can still be useful for checking containers, reading logs, restarting services, and managing stacks.

The long-term rule for this lab is:

```text
Compose files are the source of truth.
Portainer is a management interface, not the only place where configuration lives.
```

This avoids losing track of how a container was created and makes the setup easier to rebuild from files.

For services created through Portainer templates, the migration process should be:

1. inspect the existing container or stack
2. identify image, ports, volumes, environment variables, restart policy, and networks
3. recreate the service as a clean Compose project under `/srv/docker`
4. test the new Compose project
5. remove the old container only after confirming the new one works

## Public Repository Structure

The public GitHub repository should not contain real production Compose files.

Instead, it should contain sanitized examples:

```text
examples/
  searxng/
    compose.example.yml
    .env.example
    settings.example.yml
    README.md

  uptime-kuma/
    compose.example.yml
    README.md

  monitoring/
    compose.example.yml
    prometheus.example.yml
    README.md
```

Sanitized examples should show the structure and operational thinking without exposing sensitive information.

Public examples may include:

- placeholder domains
- placeholder ports
- fake internal paths
- example environment variables
- comments explaining what must be changed
- notes about backups, permissions, and security

Public examples should not include:

- real domains
- real public IP addresses
- internal IP addresses
- passwords
- API keys
- tokens
- private volume paths
- production database credentials
- full production firewall or reverse proxy configuration

## Migration Strategy

Services should be migrated one at a time.

The safest approach is to start with low-risk services and move gradually toward more important or more complex services.

Suggested migration order:

1. Uptime Kuma
2. SearXNG
3. Navidrome
4. Jellyfin
5. Grafana and Prometheus
6. WordPress or other database-backed apps
7. Vaultwarden
8. Nextcloud, Immich, or other high-value data services

High-risk services should be migrated last because they may contain important data, credentials, databases, or more complex dependencies.

Before migrating any service:

- identify the current install method
- inspect the container
- document ports, volumes, networks, and environment variables
- confirm where persistent data is stored
- create a backup
- create the new Compose project
- stop the old container
- start the new Compose project
- check logs
- test the service
- remove the old container only after successful testing

## Backup and Restore Notes

A clean Docker Compose structure is only useful if the data can be backed up and restored.

Each service should have documented backup-relevant paths, such as:

- application data
- configuration files
- database data
- uploaded files
- media folders
- private environment files or secrets

Backups should be tested by restoring to a safe test location when possible.

A service should not be considered properly maintained until there is at least a basic understanding of how to restore it.

## Final Target State

The final target state is a clean, documented, and repeatable Docker setup:

```text
/srv/docker/
  service-name/
    compose.yml
    .env
    config/
    data/
```

The public GitHub repository explains the architecture and provides sanitized examples.

The private server keeps the real configuration.

This keeps the lab practical for daily use while also making the repository useful as a professional portfolio project.

Network exposure decisions are documented separately in [Firewall Policy Notes](./firewall-policy.md). In general, private lab services are designed for VPN-style access rather than direct public exposure.

## `/srv/docker` ownership model

For real deployments, Docker Compose projects are stored under `/srv/docker`.

/srv/docker directories are owned by root and a restricted admin group. Runtime secrets such as .env are not committed to Git and are permission-restricted on the server. Container-created runtime data is not manually re-owned unless required by the service documentation.

Example layout:

```text
/srv/docker/uptime-kuma/
├── compose.yml
├── .env
├── data/
└── database/
```

Instead of making the directory owned by a normal user, keep `root` as the owner and use a dedicated admin group:

```bash
# Create a group for Docker administrators.
sudo groupadd --system docker-admins

# Allow the user to manage Docker projects.
sudo usermod -aG docker-admins <user-name>

# Create the project directory.
sudo mkdir -p /srv/docker/uptime-kuma

# Set ownership and permissions.
sudo chown root:docker-admins /srv/docker/uptime-kuma
sudo chmod 2770 /srv/docker/uptime-kuma
```

Expected permissions:

```text
drwxrws--- root docker-admins /srv/docker/uptime-kuma
```

Create the real deployment files from the public examples:

```bash
# Create the real Compose file.
cp compose.example.yml compose.yml

# Create the private environment file.
cp .env.example .env

# Restrict access to secrets.
chmod 640 .env
```

For extra security:

```bash
# Make root the owner of the .env file.
sudo chown root:docker-admins .env

# Allow only root and the admin group to access it.
sudo chmod 640 .env

# Edit the file safely.
sudoedit .env
```

Avoid changing ownership of container data directories unless the service documentation specifically requires it:

```bash
# Avoid changing ownership of database files!
sudo chown -R <user-name>:<user-name> /srv/docker/uptime-kuma/database/
```

### Summary

* Store Compose projects under `/srv/docker`
* Keep `root` as the directory owner
* Use a dedicated admin group for management
* Restrict access to `.env` files
* Leave container-created data ownership unchanged unless required

