# 05 - Cloudflare and Let's Encrypt ACME

This step documents the planned certificate automation path for Traefik.

The lab already has a working certificate workflow through the pfSense ACME package with Cloudflare DNS validation. That existing setup should stay in place while Traefik is being tested.

The goal of this step is to document how Traefik will later request and renew Let's Encrypt certificates using ACME DNS-01 through Cloudflare.

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

Traefik will eventually manage certificates directly for routes handled by Traefik.

This should only be done after:

```text
local Traefik HTTPS works
dashboard authentication works
whoami route works
one non-critical service route works
rollback to pfSense is documented
```

## What ACME means here

ACME is the protocol used to request and renew certificates automatically.

In this setup:

```text
Traefik acts as the ACME client
Let's Encrypt acts as the certificate authority
Cloudflare DNS is used to prove domain ownership
```

The DNS-01 challenge works by creating a temporary DNS TXT record.

High-level flow:

```text
1. Traefik asks Let's Encrypt for a certificate
2. Let's Encrypt asks for DNS proof
3. Traefik uses the Cloudflare API token to create a TXT record
4. Let's Encrypt checks the TXT record
5. Let's Encrypt issues the certificate
6. Traefik stores the certificate data in acme.json
7. Traefik renews the certificate automatically later
```

## Why use DNS-01

DNS-01 is useful for this lab because services may be internal only.

With DNS-01:

```text
services do not need to be publicly reachable on port 80
Traefik can request certificates for internal hostnames under a real domain
wildcard certificates are possible
Cloudflare can validate domain ownership through DNS
```

This is different from HTTP-01, where the certificate authority needs to reach the service over HTTP.

## Staging before production

Let's Encrypt staging should be tested before production.

Staging is useful because it lets me test the ACME workflow without risking production rate limits.

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

The repository should only include a placeholder in `.env.example`.

The token should be scoped as narrowly as possible for DNS validation.

## acme.json

Traefik stores certificate account and certificate data in `acme.json`.

Example runtime file:

```text
/srv/docker/traefik/acme.json
```

This file should not be committed.

Recommended permissions:

```bash
touch /srv/docker/traefik/acme.json
chmod 600 /srv/docker/traefik/acme.json
```

The file may contain private key material and certificate data, so it should be treated as sensitive.

## Future Compose changes

The local HTTPS setup uses a self-signed certificate loaded through the file provider.

The future ACME setup will add a certificate resolver.

Example shape:

```yaml
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

For wildcard certificates, the exact label pattern may be adjusted later after testing.

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

## Validation plan

When this step is implemented later, validate:

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

