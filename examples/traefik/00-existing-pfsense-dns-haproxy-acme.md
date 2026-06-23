# Existing pfSense DNS, HAProxy, and ACME Setup

Before introducing Traefik, the lab already had a working pfSense-managed path for local DNS, reverse proxying, and certificate management.

This document explains that baseline so the Traefik migration has context. The goal is not to replace everything at once. The goal is to move Docker-hosted services toward a setup that is easier to document in Git and easier to manage close to the Compose files.

## Current pfSense-managed path

The current setup uses pfSense for three related jobs:

```text
pfSense DNS Resolver
→ local DNS host overrides

pfSense HAProxy
→ reverse proxy rules managed through the pfSense web interface

pfSense ACME package
→ Let's Encrypt certificates using Cloudflare DNS validation
```

This pfSense path is treated as the known-good fallback while Traefik is tested.

## DNS baseline

pfSense DNS Resolver currently provides local DNS host overrides for internal service names.

Example pattern:

```text
service.lab.example.com
→ internal service IP or reverse proxy IP
```

For the Traefik migration, the intended DNS model is:

```text
Pi-hole
→ primary DNS path for lab clients

pfSense DNS Resolver
→ fallback DNS path with important host overrides mirrored
```

Important internal service names should exist in both places so DNS still works if clients fall back to pfSense.

## Reverse proxy baseline

pfSense HAProxy currently provides the working reverse proxy setup.

It is managed through the pfSense web interface and remains useful as a fallback while Traefik is built and tested separately.

The migration approach is:

```text
keep pfSense HAProxy working
build Traefik on ubuntu-docker
test Traefik with whoami
move one non-critical service
validate the route
then migrate more services gradually
```

This keeps the existing path available while the new Docker-focused path is tested.

## Certificate baseline

pfSense ACME currently manages Let's Encrypt certificates.

The existing ACME workflow already works with Cloudflare DNS validation. That means the lab already has a working certificate automation path before Traefik is introduced.

During the first Traefik phase, I am not moving certificate automation immediately. I will start Traefik with local self-signed HTTPS first, then test Cloudflare and Let's Encrypt ACME later.

## Why introduce Traefik

Traefik is being introduced because more services are moving to the `ubuntu-docker` VM inside Proxmox.

For Docker-hosted services, Traefik has some advantages:

```text
routing can be documented in Compose files
Docker labels stay close to the service definition
example configs can be sanitized and committed to Git
services can be migrated one at a time
```

This does not mean the pfSense setup was wrong. pfSense is the working baseline. Traefik is being added as a Docker-focused reverse proxy path.

## Rollback approach

Rollback should remain simple while the migration is in progress.

Options include:

```text
stop the Traefik test container
point the local DNS record back to the pfSense HAProxy path
keep the existing pfSense HAProxy rule enabled
keep pfSense ACME certificate management unchanged
restore the previous Compose file
```

This is why pfSense HAProxy and pfSense ACME stay in place until Traefik routing and certificate automation are fully validated.

## What this demonstrates

This migration should show:

```text
existing infrastructure was understood before changing it
a known-good fallback was kept
DNS, reverse proxying, and certificates were documented together
changes were tested with a simple service before real services
rollback was considered before migration
```

## References

* Netgate pfSense Documentation: DNS Resolver Host Overrides
  https://docs.netgate.com/pfsense/en/latest/services/dns/resolver-host-overrides.html

* Netgate pfSense Documentation: HAProxy package
  https://docs.netgate.com/pfsense/en/latest/packages/haproxy.html

* Netgate pfSense Documentation: ACME package
  https://docs.netgate.com/pfsense/en/latest/packages/acme/index.html`examples/traefik/00-existing-pfsense-dns-haproxy-acme.md`.


