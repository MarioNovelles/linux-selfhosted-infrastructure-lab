# Existing pfSense DNS, HAProxy, and ACME Setup

Before introducing Traefik, the lab already had a working reverse proxy and certificate setup on pfSense.

This document explains the current baseline so the Traefik migration has context. The goal is not to replace a broken setup immediately. The goal is to move Docker-hosted services toward a setup that is easier to document in Git and easier to manage close to the Compose files.

## Current pfSense-managed path

The current path uses pfSense for three related jobs:

```text
pfSense DNS Resolver
→ local DNS host overrides

pfSense HAProxy
→ reverse proxy rules managed through the pfSense web interface

pfSense ACME package
→ Let's Encrypt certificates using Cloudflare DNS validation
```

This setup is treated as the known-good path during the Traefik migration.

## Current local DNS role

pfSense DNS Resolver currently provides local DNS host overrides for internal service names.

This means lab services can use names instead of only direct IP addresses and ports.

Example pattern:

```text
service.lab.example.com
→ internal service IP or reverse proxy IP
```

For the Traefik migration, I plan to keep local DNS documented clearly.

The intended DNS model now is:

```text
Pi-hole
→ primary DNS path for lab clients

pfSense DNS Resolver
→ fallback DNS path with important host overrides mirrored
```

Important internal service names should exist in both places so that DNS still works if clients fall back to pfSense.

## Current reverse proxy role

pfSense HAProxy currently provides the working reverse proxy setup.

This is managed through the pfSense web interface.

This is useful because it gives me a working fallback while I build and test Traefik separately.

During the migration, I do not want to move everything at once. The safer approach is:

```text
keep pfSense HAProxy working
build Traefik on ubuntu-docker
test Traefik with whoami
move one non-critical service
validate
then migrate more services gradually
```

## Current certificate role

pfSense ACME currently manages Let's Encrypt certificates.

The ACME workflow already works with Cloudflare DNS validation.

This means the lab already has a working certificate automation path before Traefik is introduced.

During the first Traefik phase, I am not moving certificate automation immediately. I will start Traefik with local self-signed HTTPS first, then test Cloudflare and Let's Encrypt ACME later.

The safer order is:

```text
1. Keep pfSense ACME working
2. Test Traefik with local self-signed HTTPS
3. Validate Traefik routing with whoami
4. Move one non-critical service
5. Test Traefik ACME with Let's Encrypt staging
6. Move to Let's Encrypt production after validation
```

## Why introduce Traefik

Traefik is being introduced because more services are moving to the `ubuntu-docker` VM inside Proxmox.

For Docker-hosted services, Traefik has some advantages:

```text
routing can be documented in Compose files
Docker labels stay close to the service definition
example configs can be sanitized and committed to Git
services can be migrated one at a time
```

This does not mean the pfSense setup was wrong.

The current pfSense setup is the stable baseline. Traefik is being added as a Docker-focused reverse proxy path.

## Migration approach

The migration should stay gradual.

Current state:

```text
pfSense DNS Resolver
pfSense HAProxy
pfSense ACME
Cloudflare DNS validation
```

Target direction:

```text
Pi-hole primary local DNS
pfSense DNS Resolver fallback
Traefik on ubuntu-docker
Docker label-based routing
Cloudflare DNS-01 ACME in Traefik after validation
```

During the migration:

```text
pfSense remains the known-good fallback
Traefik is tested with non-critical routes first
certificate automation is moved only after routing is proven
rollback remains possible by pointing DNS back to the pfSense HAProxy path
```

## Rollback idea

If Traefik does not work as expected, rollback should be simple.

Rollback options:

```text
stop the Traefik test container
point the local DNS record back to the pfSense HAProxy path
keep the existing pfSense HAProxy rule enabled
keep pfSense ACME certificate management unchanged
```

This is why pfSense HAProxy and pfSense ACME should stay in place until Traefik routing and certificate automation are fully validated.

## What this project should show

This migration should show more than a working reverse proxy.

It should show:

```text
existing infrastructure was understood before changing it
a known-good fallback was kept
DNS, reverse proxying, and certificates were documented together
changes were tested with a simple service before real services
rollback was considered before migration
```

That is the main reason this project is worth documenting in the portfolio.

## References

* Netgate pfSense Documentation: DNS Resolver Host Overrides
  https://docs.netgate.com/pfsense/en/latest/services/dns/resolver-host-overrides.html

* Netgate pfSense Documentation: HAProxy package
  https://docs.netgate.com/pfsense/en/latest/packages/haproxy.html

* Netgate pfSense Documentation: ACME package
  https://docs.netgate.com/pfsense/en/latest/packages/acme/index.html

