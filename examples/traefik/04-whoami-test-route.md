# 04 - Whoami Test Route

This step validates Traefik routing with a simple test container.

The goal is to prove that Traefik can read Docker labels, match a hostname rule, use the shared `proxy` network, and forward traffic to a container before routing any real service.

## Why use whoami

The `whoami` container is useful because it returns request details back to the client.

This makes it easy to check:

```text
requested hostname
forwarded headers
client IP information
protocol used by the proxy
```

It is safer to test Traefik with `whoami` before moving real applications.

## DNS requirement

Before starting the test route, local DNS should point the test hostname to the Docker host running Traefik.

Example:

```text
whoami.lab.example.com
→ DOCKER_HOST_IP
```

Check from a client:

```bash
dig whoami.lab.example.com
```

The result should point to the Traefik Docker host.

## Create the test runtime folder

Create a small runtime folder for the test container:

```bash
mkdir -p /srv/docker/traefik-test
```

From the repository root, copy the example Compose file:

```bash
cp examples/traefik/whoami.example.yml /srv/docker/traefik-test/compose.yml
```

Move into the runtime folder:

```bash
cd /srv/docker/traefik-test
```

## Start whoami

Start the test container:

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

Expected result:

```text
whoami container is running
```

## Confirm the proxy network

Inspect the shared proxy network:

```bash
docker network inspect proxy
```

The `whoami` container should appear in the `proxy` network.

## Test the HTTPS route

From a client machine:

```bash
curl -k https://whoami.lab.example.com/
```

The `-k` flag is used because this phase still uses a self-signed local certificate.

A successful response should include request information from the `whoami` container.

Expected signs:

```text
Hostname: whoami
request headers
X-Forwarded-* headers
```

## Test HTTP to HTTPS redirect

Run:

```bash
curl -I http://whoami.lab.example.com
```

Expected result:

```text
301 Moved Permanently
```

This confirms that HTTP traffic is redirected to HTTPS.

## Test without working DNS

If DNS is not ready yet, test the route by forcing the hostname to resolve to the Docker host IP for this request:

```bash
curl -k --resolve whoami.lab.example.com:443:DOCKER_HOST_IP https://whoami.lab.example.com/
```

This helps separate DNS problems from Traefik routing problems.

If this works but normal hostname access does not, the problem is probably DNS.

If this does not work either, check Traefik, Docker labels, the `proxy` network, and the `whoami` container.

## Check logs

Check Traefik logs:

```bash
docker logs traefik --tail=100
```

Check the test container logs:

```bash
cd /srv/docker/traefik-test
docker compose logs --tail=100
```

Useful things to look for:

```text
router creation
service discovery
routing errors
bad gateway errors
```

## Common problems

### DNS points to the wrong IP

Check:

```bash
dig whoami.lab.example.com
```

Fix the Pi-hole and pfSense DNS records so the hostname points to the Traefik Docker host.

### Container is not on the proxy network

Check:

```bash
docker network inspect proxy
```

Fix the Compose file so the service joins the `proxy` network.

### Traefik does not route to the container

Check the labels:

```bash
docker inspect whoami
```

Confirm:

```text
traefik.enable=true
Host rule matches whoami.lab.example.com
router uses the websecure entrypoint
service port is 80
```

### Browser warns about the certificate

This is expected during the local self-signed certificate phase.

The warning should go away later when ACME and trusted certificates are configured.

## Validation checklist

Before moving to real services, confirm:

```text
whoami.lab.example.com resolves to the Traefik host
Traefik container is running
whoami container is running
whoami is attached to the proxy network
HTTPS route works
HTTP redirects to HTTPS
forwarded headers appear in the response
Traefik logs do not show routing errors
```

Useful commands:

```bash
dig whoami.lab.example.com
docker ps
docker network inspect proxy
curl -k https://whoami.lab.example.com/
curl -I http://whoami.lab.example.com
curl -k --resolve whoami.lab.example.com:443:DOCKER_HOST_IP https://whoami.lab.example.com/
docker logs traefik --tail=100
```

## Stop the test route

Stop the whoami test container:

```bash
cd /srv/docker/traefik-test
docker compose down
```

## Rollback notes

This test is low risk.

Rollback options:

```text
stop the whoami container
remove the whoami DNS record
leave Traefik running for dashboard testing
stop Traefik if needed
```

No existing pfSense HAProxy or pfSense ACME configuration should be changed during this step.

## What this validates

This test confirms that the basic Traefik path works:

```text
client
→ local DNS
→ Traefik
→ proxy network
→ whoami container
```

After this works, it is safer to move one non-critical real service behind Traefik.

## References

* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/
* Traefik Docker provider: https://doc.traefik.io/traefik/reference/install-configuration/providers/docker/
* Traefik routing routers: https://doc.traefik.io/traefik/routing/routers/

