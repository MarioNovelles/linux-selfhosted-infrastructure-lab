# Traefik Reverse Proxy Migration

This folder documents a staged Traefik reverse proxy migration for the homelab.

The lab already has a working pfSense-managed setup for local DNS, reverse proxying, and Let's Encrypt certificates. Traefik is being introduced because more Docker services are moving to the `ubuntu-docker` VM inside Proxmox, where Docker labels and Compose examples are easier to document in Git.

This is not a one-shot replacement. pfSense remains the known-good fallback while Traefik is tested service by service.

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

This baseline is documented in:

```text
00-existing-pfsense-dns-haproxy-acme.md
```

## Target direction

Target Traefik direction:

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

## Why Traefik

Traefik is useful for the Docker side of the lab because routing can be kept close to the service definition.

Instead of only managing reverse proxy rules through a web interface, the Traefik examples can show:

```text
Compose files
Docker networks
Traefik labels
sanitized environment variables
validation commands
rollback notes
```

This makes the migration easier to review in Git.

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

## What is committed

The repository only includes sanitized example files:

```text
compose.example.yml
whoami.example.yml
.env.example
dynamic/tls.example.yml
```

These files are safe examples and do not contain real secrets.

## What is not committed

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

The migration should stay gradual.

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

This is why the pfSense setup is kept as the fallback until Traefik routing and certificate automation are fully validated.

## Security notes

The example is designed for a private homelab.

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

The Docker socket mount used by Traefik is a known security trade-off. It should be documented and treated carefully.

## References

* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/
* Traefik Docker provider: https://doc.traefik.io/traefik/reference/install-configuration/providers/docker/
* Traefik API and dashboard: https://doc.traefik.io/traefik/reference/install-configuration/api-dashboard/
* Traefik ACME certificate resolver: https://doc.traefik.io/traefik/reference/install-configuration/tls/certificate-resolvers/acme/
* pfSense DNS Resolver Host Overrides: https://docs.netgate.com/pfsense/en/latest/services/dns/resolver-host-overrides.html
* pfSense HAProxy package: https://docs.netgate.com/pfsense/en/latest/packages/haproxy.html
* pfSense ACME package: https://docs.netgate.com/pfsense/en/latest/packages/acme/index.html

