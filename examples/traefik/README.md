# Traefik Reverse Proxy Migration

This folder documents my Traefik reverse proxy migration for the homelab.

The lab already has a working pfSense setup for local DNS, HAProxy reverse proxying, and Let's Encrypt certificates through the pfSense ACME package. I am introducing Traefik because more Docker services are moving to the `ubuntu-docker` VM inside Proxmox, where Docker labels and Compose examples are easier to document in Git.

This is not meant to be a one-shot replacement. The existing pfSense setup stays available as the known-good fallback while Traefik is tested one service at a time.

## Current baseline

Current working setup:

```text
pfSense DNS Resolver
→ local DNS host overrides

pfSense HAProxy
→ current reverse proxy path

pfSense ACME package
→ Let's Encrypt certificates using Cloudflare DNS validation
```

The baseline is documented in:

```text
00-existing-pfsense-dns-haproxy-acme.md
```

## Where this is going

Target direction:

```text
Pi-hole
→ primary local DNS path

pfSense DNS Resolver
→ fallback DNS path

Traefik on ubuntu-docker
→ Docker reverse proxy

Docker labels
→ service routing configuration

Cloudflare DNS-01 ACME
→ future certificate automation after validation
```

The main goal is to move Docker-hosted services from direct `IP:port` access to clean internal service names, while keeping rollback options available.

Example:

```text
Before:
  http://DOCKER_HOST_IP:3000

After:
  https://service.lab.example.com
```

## Why Traefik

Traefik is useful for the Docker side of this lab because routing can live close to the service definition.

With the current pfSense HAProxy setup, reverse proxy rules are managed through the pfSense web interface. That works, and I am keeping it as a fallback.

For Docker services, Traefik lets me document more of the routing setup in Git:

```text
Compose files
Docker networks
Traefik labels
sanitized environment variables
validation commands
rollback notes
```

This makes the migration easier to review and easier to repeat later.

## Documentation order

Read the files in this order:

```text
00-existing-pfsense-dns-haproxy-acme.md
01-prerequisites.md
02-local-dns-overrides.md
03-traefik-local-https.md
04-whoami-test-route.md
05-cloudflare-letsencrypt-acme.md
06-routing-real-services.md
07-troubleshooting.md
```

## File layout

Repository example files:

```text
examples/traefik/
├── README.md
├── 00-existing-pfsense-dns-haproxy-acme.md
├── 01-prerequisites.md
├── 02-local-dns-overrides.md
├── 03-traefik-local-https.md
├── 04-whoami-test-route.md
├── 05-cloudflare-letsencrypt-acme.md
├── 06-routing-real-services.md
├── 07-troubleshooting.md
├── compose.example.yml
├── whoami.example.yml
├── .env.example
└── dynamic/
    └── tls.example.yml
```

Real deployment files are kept outside the repository:

```text
/srv/docker/traefik/
├── compose.yml
├── .env
├── acme.json
├── certs/
└── dynamic/
```

## Committed vs local files

The repository only includes sanitized example files:

```text
compose.example.yml
whoami.example.yml
.env.example
dynamic/tls.example.yml
```

These files are examples only. They do not contain real secrets, real certificates, or real runtime values.

The real runtime files are not committed:

```text
compose.yml
.env
acme.json
certs/
dynamic/tls.yml
```

These files may contain local hostnames, generated password hashes, Cloudflare tokens, certificates, or environment-specific values.

## Migration approach

The migration stays gradual.

Planned order:

```text
1. Document the existing pfSense baseline
2. Prepare Traefik prerequisites
3. Configure local DNS records
4. Start Traefik with local self-signed HTTPS
5. Validate routing with whoami
6. Test Cloudflare and Let's Encrypt ACME with staging
7. Move one non-critical real service
8. Migrate more services after validation
```

pfSense HAProxy and pfSense ACME stay available during the migration.

## Validation focus

Each stage should have validation commands before moving forward.

Examples:

```bash
docker compose ps
docker logs traefik --tail=100
dig whoami.lab.example.com
curl -k https://whoami.lab.example.com/
curl -I http://whoami.lab.example.com
```

The `whoami` container is used first because it is a simple test target before routing real services.

## Rollback approach

Rollback should remain simple during the migration.

Options include:

```text
stop Traefik
disable a test route
point local DNS back to the pfSense HAProxy path
keep pfSense ACME certificate management unchanged
restore the previous Compose file
```

This is why the pfSense setup stays available until Traefik routing and certificate automation are fully validated.

## Security notes

This example is designed for a private homelab.

Important security choices:

```text
do not commit real .env files
do not commit Cloudflare tokens
do not commit acme.json
do not expose the insecure dashboard port
protect the dashboard with authentication
expose only ports 80 and 443 from Traefik
avoid direct host port publishing for services after migration
```

The Docker socket mount used by Traefik is a known security trade-off. I am documenting it here because it should be treated carefully, even in a lab.

## Later public demo

The real lab documentation is the main focus first.

After the real Traefik deployment is working and validated, I plan to add a smaller public demo that can be run without pfSense, Cloudflare, or private lab DNS.

That demo will be separate from the real lab notes and will use only sanitized example values.

## References

* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/
* Traefik Docker provider: https://doc.traefik.io/traefik/reference/install-configuration/providers/docker/
* Traefik API and dashboard: https://doc.traefik.io/traefik/reference/install-configuration/api-dashboard/
* Traefik ACME certificate resolver: https://doc.traefik.io/traefik/reference/install-configuration/tls/certificate-resolvers/acme/
* pfSense DNS Resolver Host Overrides: https://docs.netgate.com/pfsense/en/latest/services/dns/resolver-host-overrides.html
* pfSense HAProxy package: https://docs.netgate.com/pfsense/en/latest/packages/haproxy.html
* pfSense ACME package: https://docs.netgate.com/pfsense/en/latest/packages/acme/index.html

