# 05 - Cloudflare and Let's Encrypt ACME

This step documents the planned certificate automation path for Traefik.

The lab already has a working certificate workflow through the pfSense ACME package with Cloudflare DNS validation. That setup should stay in place while Traefik routing is being tested.

Traefik ACME is not enabled in the first local HTTPS setup. It will be tested later, after the dashboard, `whoami`, and at least one non-critical service route work reliably.

## Current certificate baseline

Current working setup:

```text
pfSense ACME package
→ Cloudflare DNS validation
→ Let's Encrypt certificates
→ pfSense HAProxy
```

This is the known-good certificate path.

During the first Traefik phases, this setup should not be changed.

## Planned Traefik certificate path

Future Traefik setup:

```text
Traefik
→ ACME client
→ Let's Encrypt
→ Cloudflare DNS-01 challenge
→ certificate stored in acme.json
```

Traefik will eventually manage certificates for routes handled by Traefik.

This should only happen after:

```text
local Traefik HTTPS works
dashboard authentication works
whoami route works
one non-critical service route works
rollback to pfSense is documented
```

## Why use DNS-01

DNS-01 is useful for this lab because some services are internal only.

With DNS-01:

```text
services do not need to be publicly reachable on port 80
Traefik can request certificates for internal hostnames under a real domain
wildcard certificates are possible
Cloudflare can validate domain ownership through DNS
```

This is different from HTTP-01, where Let's Encrypt needs to reach the service over HTTP.

## How the DNS-01 flow works

High-level flow:

```text
1. Traefik asks Let's Encrypt for a certificate
2. Let's Encrypt asks for DNS proof
3. Traefik uses the Cloudflare API token to create a TXT record
4. Let's Encrypt checks the TXT record
5. Let's Encrypt issues the certificate
6. Traefik stores the certificate data in acme.json
7. Traefik renews the certificate later
```

## Test staging before production

Let's Encrypt staging should be tested before production.

Planned order:

```text
1. Configure Traefik ACME with Let's Encrypt staging
2. Confirm TXT record creation through Cloudflare
3. Confirm certificate storage in acme.json
4. Confirm Traefik can serve the staging certificate
5. Switch to Let's Encrypt production only after staging works
```

A staging certificate is not trusted by browsers. Browser warnings are expected during staging.

## Cloudflare token handling

The Cloudflare token must not be committed to Git.

The real token belongs in the real runtime `.env` file:

```text
/srv/docker/traefik/.env
```

Example variable name:

```text
CF_DNS_API_TOKEN=CHANGEME_CLOUDFLARE_DNS_TOKEN
```

The repository should only include placeholders in `.env.example`.

The token should be scoped only for the DNS changes needed by the ACME challenge.

## acme.json

Traefik stores ACME account and certificate data in `acme.json`.

Runtime file:

```text
/srv/docker/traefik/acme.json
```

Create it before enabling ACME:

```bash
touch /srv/docker/traefik/acme.json
chmod 600 /srv/docker/traefik/acme.json
```

This file may contain private key material and certificate data, so it should not be committed.

## Future Compose changes

The local HTTPS setup uses a self-signed certificate loaded through the file provider.

The future ACME setup will need:

```text
Cloudflare token available to Traefik
acme.json mounted into the Traefik container
ACME certificate resolver configured
router labels pointing to the resolver
```

Example Compose shape:

```yaml
volumes:
  - "./acme.json:/acme.json"

command:
  - "--certificatesresolvers.cloudflare.acme.email=${LETSENCRYPT_EMAIL}"
  - "--certificatesresolvers.cloudflare.acme.storage=/acme.json"
  - "--certificatesresolvers.cloudflare.acme.dnschallenge=true"
  - "--certificatesresolvers.cloudflare.acme.dnschallenge.provider=cloudflare"
```

For Let's Encrypt staging, add the staging CA server first:

```yaml
  - "--certificatesresolvers.cloudflare.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
```

After staging works, remove or replace the staging CA server to use production.

## Future router labels

Routes that should use the ACME resolver will later use labels like:

```yaml
labels:
  - "traefik.http.routers.app.tls=true"
  - "traefik.http.routers.app.tls.certresolver=cloudflare"
```

The exact label pattern may be adjusted after testing, especially if wildcard certificates are used.

## What stays on pfSense for now

During this phase, pfSense remains unchanged.

Keep:

```text
pfSense HAProxy
pfSense ACME package
Cloudflare DNS validation in pfSense
existing certificates
existing working reverse proxy routes
```

Traefik ACME should be tested separately and only promoted after validation.

## Future validation checklist

When this step is implemented, validate:

```text
Cloudflare token is only in /srv/docker/traefik/.env
acme.json exists
acme.json permissions are 600
Traefik logs show ACME challenge activity
Let's Encrypt staging certificate is issued
DNS TXT record is created and cleaned up
route serves a certificate from Traefik
production ACME is tested only after staging succeeds
```

Useful commands:

```bash
ls -l /srv/docker/traefik/acme.json
docker logs traefik --tail=200
dig TXT _acme-challenge.lab.example.com
curl -vk https://whoami.lab.example.com/
```

## Rollback

If Traefik ACME fails:

```text
leave pfSense ACME untouched
remove or disable the Traefik ACME resolver
return routes to the self-signed local TLS test setup
or point DNS back to the pfSense HAProxy path
```

Do not delete the working pfSense certificate setup until Traefik certificate automation is proven.

## What not to publish

Do not publish:

```text
Cloudflare API tokens
real acme.json
real private keys
real certificate files
full pfSense ACME exports
screenshots showing tokens or account IDs
```

Safe placeholders:

```text
CF_DNS_API_TOKEN
LETSENCRYPT_EMAIL
lab.example.com
acme.json
```

## References

* Traefik ACME certificate resolver: https://doc.traefik.io/traefik/reference/install-configuration/tls/certificate-resolvers/acme/
* Lego Cloudflare DNS provider: https://go-acme.github.io/lego/dns/cloudflare/
* Let's Encrypt staging environment: https://letsencrypt.org/docs/staging-environment/
* pfSense ACME package: https://docs.netgate.com/pfsense/en/latest/packages/acme/index.html

