# 02 - Local DNS Overrides

This step documents the local DNS plan for the Traefik migration.

Traefik routing depends on hostnames. Before testing Traefik routes, the lab needs local DNS names that point to the Docker host running Traefik.

Example goal:

```text
whoami.lab.example.com
→ DOCKER_HOST_IP
```

## Current DNS baseline

The lab already uses pfSense DNS Resolver Host Overrides for internal service names.

During the Traefik migration, pfSense DNS Resolver remains important because it provides a known-good fallback DNS path.

The intended DNS model is:

```text
Pi-hole
→ primary DNS path for lab clients

pfSense DNS Resolver
→ fallback DNS path with important host overrides mirrored
```

## Why local DNS matters

Traefik uses hostname-based routing.

A client requests:

```text
https://whoami.lab.example.com
```

Local DNS resolves that name to the Docker host running Traefik:

```text
whoami.lab.example.com
→ DOCKER_HOST_IP
```

Traefik then reads the requested hostname and sends the request to the correct container based on Docker labels.

Traffic flow:

```text
client
→ local DNS
→ Traefik host
→ Traefik router rule
→ target Docker container
```

## DNS source of truth

For the lab, the documented intended DNS records should be treated as the source of truth.

The records should then be created in both:

```text
Pi-hole Local DNS
pfSense DNS Resolver Host Overrides
```

This keeps the primary and fallback DNS paths consistent.

## Example records

Use sanitized examples in Git.

```text
traefik.lab.example.com  → DOCKER_HOST_IP
whoami.lab.example.com   → DOCKER_HOST_IP
app.lab.example.com      → DOCKER_HOST_IP
```

All Traefik-routed service names should point to the Traefik host, not directly to the application container.

## Pi-hole local DNS

In Pi-hole, add local DNS records for the Traefik hostnames.

Example:

```text
Local DNS
→ DNS Records
→ Add a new domain/IP combination
```

Example record:

```text
whoami.lab.example.com
DOCKER_HOST_IP
```

Repeat this for each hostname routed through Traefik.

## pfSense DNS Resolver host overrides

In pfSense, mirror the important records as DNS Resolver Host Overrides.

Example path:

```text
Services
→ DNS Resolver
→ Host Overrides
```

Example override:

```text
Host: whoami
Domain: lab.example.com
IP Address: DOCKER_HOST_IP
```

This keeps pfSense available as a fallback resolver if Pi-hole is unavailable or if a client falls back to pfSense.

## Recommended migration approach

Do not move every service name at once.

Start with test hostnames:

```text
traefik.lab.example.com
whoami.lab.example.com
```

Then add one non-critical real service later.

Safer order:

```text
1. Add traefik.lab.example.com
2. Add whoami.lab.example.com
3. Validate DNS from a client
4. Start Traefik
5. Test the whoami route
6. Add one non-critical service name
7. Migrate more services only after validation
```

## Avoiding confusion during migration

During migration, avoid pointing the same important hostname back and forth repeatedly.

For testing, use a temporary hostname if needed:

```text
service-traefik.lab.example.com
```

This allows the existing pfSense HAProxy route to remain untouched while Traefik is being tested.

Example:

```text
service.lab.example.com
→ existing pfSense HAProxy path

service-traefik.lab.example.com
→ Traefik test path
```

After the Traefik route is validated, the main service name can be moved.

## Validation commands

From a client machine, check DNS resolution:

```bash
dig traefik.lab.example.com
dig whoami.lab.example.com
```

Query Pi-hole directly:

```bash
dig @PIHOLE_IP whoami.lab.example.com
```

Query pfSense directly:

```bash
dig @PFSENSE_IP whoami.lab.example.com
```

Both should return the Traefik Docker host IP.

Expected pattern:

```text
whoami.lab.example.com
→ DOCKER_HOST_IP
```

## Testing without DNS

If DNS is not working yet, Traefik can still be tested by sending a Host header directly to the Traefik host.

Example:

```bash
curl -k -H "Host: whoami.lab.example.com" https://DOCKER_HOST_IP/
```

This helps separate DNS problems from Traefik routing problems.

If the Host-header test works but the normal hostname does not, the problem is probably DNS.

## Rollback notes

Rollback should be simple.

If a Traefik route fails, point the DNS record back to the previous known-good path.

Rollback options:

```text
change the Pi-hole DNS record back
change the pfSense Host Override back
disable the Traefik test route
keep the existing pfSense HAProxy rule available
```

If using a temporary Traefik test hostname, rollback is even simpler because the existing production-like hostname was never changed.

## What not to publish

Do not publish sensitive DNS details.

Avoid committing:

```text
real public domains if you prefer keeping them private
real public IP addresses
Cloudflare account details
full pfSense configuration exports
screenshots with tokens or real WAN details
```

Sanitized examples are fine:

```text
lab.example.com
DOCKER_HOST_IP
PIHOLE_IP
PFSENSE_IP
```

## Validation checklist

Before moving to the next step, confirm:

```text
Pi-hole has the test hostname
pfSense has the same test hostname as fallback
both resolvers return the Traefik Docker host IP
normal client DNS resolution works
Host-header testing is available as a fallback test method
```

Useful commands:

```bash
dig whoami.lab.example.com
dig @PIHOLE_IP whoami.lab.example.com
dig @PFSENSE_IP whoami.lab.example.com
```

## References

* Pi-hole documentation: Local DNS Records
  https://docs.pi-hole.net/database/gravity/example/

* Netgate pfSense documentation: DNS Resolver Host Overrides
  https://docs.netgate.com/pfsense/en/latest/services/dns/resolver-host-overrides.html

* Traefik documentation: Routers
  https://doc.traefik.io/traefik/routing/routers/

