# 07 - Troubleshooting

This document collects troubleshooting checks for the Traefik reverse proxy migration.

The goal is to avoid guessing. Start with DNS, then check Traefik, Docker networking, labels, TLS, and the target container.

## Debug order

Use this order when troubleshooting:

```text
1. Does DNS resolve to the Traefik host?
2. Is Traefik running?
3. Are ports 80 and 443 listening?
4. Is the target container running?
5. Is the target container attached to the proxy network?
6. Are Traefik labels present and correct?
7. Does the Host rule match the requested hostname?
8. Is the internal service port correct?
9. Do Traefik logs show an error?
10. Does the route work with curl --resolve?
```

This order helps separate DNS problems from Traefik, Docker, and application problems.

## Quick status checks

Check the Traefik container:

```bash
cd /srv/docker/traefik
docker compose ps
```

Check Traefik logs:

```bash
docker logs traefik --tail=100
```

Check listening ports:

```bash
ss -tulpn | grep -E ':80|:443|:8080'
```

Expected result:

```text
80/tcp is listening
443/tcp is listening
8080/tcp is not exposed
```

Check the proxy network:

```bash
docker network inspect proxy
```

## DNS checks

Check normal DNS resolution from a client:

```bash
dig whoami.lab.example.com
```

Check Pi-hole directly:

```bash
dig @PIHOLE_IP whoami.lab.example.com
```

Check pfSense DNS Resolver directly:

```bash
dig @PFSENSE_IP whoami.lab.example.com
```

Expected pattern:

```text
whoami.lab.example.com
→ DOCKER_HOST_IP
```

If Pi-hole and pfSense return different answers, fix the local DNS records so both resolvers match.

## Test without working DNS

If DNS is not working yet, force the hostname to resolve to the Docker host IP for one request:

```bash
curl -k --resolve whoami.lab.example.com:443:DOCKER_HOST_IP https://whoami.lab.example.com/
```

If this works but normal hostname access does not, the problem is probably DNS.

If this does not work either, check Traefik, Docker networking, labels, TLS, and the target container.

## Dashboard checks

The dashboard URL should include the trailing slash:

```text
https://traefik.lab.example.com/dashboard/
```

Check with curl:

```bash
curl -k -I https://traefik.lab.example.com/dashboard/
```

Expected signs:

```text
HTTPS response from Traefik
basic auth required
no insecure dashboard on port 8080
```

Check that port `8080` is not exposed:

```bash
ss -tulpn | grep ':8080'
```

Expected result:

```text
no output
```

If port `8080` is exposed, check the Traefik Compose file for:

```text
api.insecure=true
8080:8080
```

Those should not be used in this setup.

## Service route checks

Test HTTPS:

```bash
curl -k https://whoami.lab.example.com/
```

Test HTTP to HTTPS redirect:

```bash
curl -I http://whoami.lab.example.com
```

Expected result:

```text
301 Moved Permanently
```

Test without relying on DNS:

```bash
curl -k --resolve whoami.lab.example.com:443:DOCKER_HOST_IP https://whoami.lab.example.com/
```

## Docker label checks

Inspect the container:

```bash
docker inspect whoami
```

Check that the expected labels exist:

```text
traefik.enable=true
traefik.http.routers.whoami.rule=Host(`whoami.lab.example.com`)
traefik.http.routers.whoami.entrypoints=websecure
traefik.http.routers.whoami.tls=true
traefik.http.services.whoami.loadbalancer.server.port=80
```

The `Host(...)` rule must match the DNS name being used by the client.

## Docker network checks

Check that Traefik and the routed container are both attached to the same external proxy network:

```bash
docker network inspect proxy
```

Expected result:

```text
traefik container is attached
target service container is attached
```

If the target container is missing, attach it through the Compose file:

```yaml
services:
  app:
    networks:
      - proxy

networks:
  proxy:
    external: true
    name: proxy
```

## Certificate checks

During the local HTTPS phase, the certificate is self-signed.

Browser warnings are expected.

Check certificate behavior with curl:

```bash
curl -vk https://traefik.lab.example.com/dashboard/
```

The `-k` flag allows curl to continue despite the self-signed certificate.

Check that the certificate files exist on the Docker host:

```bash
ls -l /srv/docker/traefik/certs
```

Expected files:

```text
local.crt
local.key
```

Check the dynamic TLS config:

```bash
cat /srv/docker/traefik/dynamic/tls.yml
```

Expected shape:

```yaml
tls:
  certificates:
    - certFile: /certs/local.crt
      keyFile: /certs/local.key
```

The paths are container paths.

The host folder is mounted into the container as:

```text
/srv/docker/traefik/certs
→ /certs
```

## ACME checks

ACME with Cloudflare and Let's Encrypt should only be tested after local HTTPS and the `whoami` route work.

Check that `acme.json` exists:

```bash
ls -l /srv/docker/traefik/acme.json
```

Recommended permissions:

```text
-rw-------
```

Set permissions if needed:

```bash
chmod 600 /srv/docker/traefik/acme.json
```

Check Traefik logs:

```bash
docker logs traefik --tail=200
```

Look for ACME or DNS challenge messages.

If testing DNS-01, check the TXT record:

```bash
dig TXT _acme-challenge.lab.example.com
```

If staging certificates work but browsers still warn, that is expected because Let's Encrypt staging certificates are not trusted by browsers.

## Common symptoms and fixes

| Symptom                                   | Likely cause                                | Check                          | Fix                                                       |
| ----------------------------------------- | ------------------------------------------- | ------------------------------ | --------------------------------------------------------- |
| Hostname does not resolve                 | Missing or wrong DNS override               | `dig service.lab.example.com`  | Add or fix Pi-hole and pfSense DNS records                |
| Pi-hole and pfSense return different IPs  | DNS fallback mismatch                       | Run direct resolver checks     | Mirror important records in both                          |
| Dashboard shows 404                       | Missing trailing slash or router rule issue | Open `/dashboard/`             | Use `/dashboard/` and check dashboard labels              |
| Dashboard exposed on 8080                 | Insecure dashboard enabled                  | Check listening ports          | Remove `api.insecure=true` and `8080:8080`                |
| Route returns 404                         | Host rule mismatch                          | `docker inspect container`     | Fix the `Host(...)` label                                 |
| Route returns 502                         | Wrong internal service port                 | App docs and logs              | Fix `loadbalancer.server.port`                            |
| Service ignored by Traefik                | Missing enable label                        | `docker inspect container`     | Add `traefik.enable=true`                                 |
| Service unreachable                       | Not on proxy network                        | `docker network inspect proxy` | Attach service to `proxy`                                 |
| HTTP does not redirect                    | Redirect flags missing                      | `docker compose config`        | Add web-to-websecure redirect flags                       |
| Browser certificate warning               | Self-signed cert or staging cert            | Browser or curl output         | Expected until production ACME works                      |
| ACME fails with Cloudflare                | Token or DNS permissions issue              | Traefik logs                   | Check Cloudflare token and DNS zone permissions           |
| `acme.json` permission error              | Wrong file permissions                      | `ls -l acme.json`              | Set `chmod 600 acme.json`                                 |
| App still reachable by IP and port        | Old direct port still published             | `docker ps`                    | Remove direct `ports:` after Traefik validation           |
| Works with `--resolve` but not normal URL | DNS issue                                   | `curl --resolve ...`           | Fix local DNS                                             |
| Works on LAN but not VPN                  | VPN DNS or route issue                      | Client DNS and routes          | Confirm VPN client uses lab DNS and can reach Docker host |

## Rollback checks

If a real service migration fails, rollback should stay simple.

Options:

```text
restore the previous Compose file
restore the old direct host port
remove Traefik labels
remove the service from the proxy network
point DNS back to the pfSense HAProxy path
keep using pfSense HAProxy until the issue is fixed
```

If a test hostname was used, rollback is easier because the original service hostname was not changed.

## What to document after fixing an issue

For useful troubleshooting cases, document:

```text
what failed
what command showed the problem
what change fixed it
how to validate the fix
how to avoid the same issue later
```

This makes the project more useful than just a working Compose file.

## References

* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/
* Traefik API and dashboard: https://doc.traefik.io/traefik/reference/install-configuration/api-dashboard/
* Traefik Docker provider: https://doc.traefik.io/traefik/reference/install-configuration/providers/docker/
* Traefik ACME certificate resolver: https://doc.traefik.io/traefik/reference/install-configuration/tls/certificate-resolvers/acme/
* Docker Compose networking: https://docs.docker.com/compose/how-tos/networking/

