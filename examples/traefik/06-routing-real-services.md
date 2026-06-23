# 06 - Routing Real Services

This step documents how to move real Docker services behind Traefik.

This should only happen after the `whoami` test route works. The goal is to migrate one service at a time while keeping the existing pfSense HAProxy path available as a fallback.

## Before moving a real service

Confirm these already work:

```text
Traefik starts successfully
the dashboard is reachable
basic auth protects the dashboard
whoami.lab.example.com resolves correctly
whoami routes through Traefik
HTTP redirects to HTTPS
pfSense HAProxy remains available as fallback
```

Do not move an important service first. Start with a low-risk service.

## Migration idea

Before Traefik, a service may be accessed through a direct host-published port:

```text
http://DOCKER_HOST_IP:3000
```

After Traefik, the service should be accessed by name:

```text
https://service.lab.example.com
```

Traffic flow:

```text
client
→ local DNS
→ Traefik
→ proxy Docker network
→ service container internal port
```

## DNS record

Create or update the local DNS record:

```text
service.lab.example.com
→ DOCKER_HOST_IP
```

The record should exist in both:

```text
Pi-hole Local DNS
pfSense DNS Resolver Host Overrides
```

This keeps the primary DNS path and fallback DNS path consistent.

## Network pattern

A service behind Traefik should join the shared `proxy` network.

If the service also has a database or backend container, keep that traffic on a private internal network.

Example pattern:

```text
proxy network:
  Traefik
  application container

app-internal network:
  application container
  database container
```

This lets Traefik reach the application while keeping the database private.

## Example service pattern

This is a sanitized example for a service that listens internally on port `3000`.

```yaml
services:
  app:
    image: example/app:1.0
    container_name: example-app
    restart: unless-stopped

    networks:
      - app-internal
      - proxy

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.example-app.rule=Host(`app.lab.example.com`)"
      - "traefik.http.routers.example-app.entrypoints=websecure"
      - "traefik.http.routers.example-app.tls=true"
      - "traefik.http.services.example-app.loadbalancer.server.port=3000"

  database:
    image: mariadb:11
    container_name: example-db
    restart: unless-stopped

    networks:
      - app-internal

    volumes:
      - database:/var/lib/mysql

volumes:
  database:

networks:
  app-internal:
    internal: true

  proxy:
    external: true
    name: proxy
```

The important part is that the database is not attached to the `proxy` network. Only the application container needs to be reachable by Traefik.

## About `loadbalancer.server.port`

The Traefik service port should be the internal port used by the container.

Example:

```yaml
- "traefik.http.services.example-app.loadbalancer.server.port=3000"
```

This is not always the same as the old host-published port. It should match the port the application listens on inside the container.

## Removing direct port publishing

Before Traefik, a service may have this:

```yaml
ports:
  - "3000:3000"
```

After the Traefik route works, the direct port can usually be removed.

Safer order:

```text
1. Keep the old port published at first
2. Add Traefik labels
3. Confirm the Traefik route works
4. Confirm the old direct route still works as fallback
5. Remove the direct port only after validation
6. Test again
```

This reduces the risk of locking yourself out of the service.

## Suggested migration workflow

Use this workflow for each real service:

```text
1. Pick one non-critical service
2. Confirm the current access path works
3. Back up the current Compose file
4. Add the service to the proxy network
5. Add Traefik labels
6. Add or update the local DNS record
7. Restart only that service stack
8. Test through Traefik
9. Check application and Traefik logs
10. Remove the direct host port only after validation
11. Document what changed
```

## Backup before editing

Before changing a real service Compose file, make a copy:

```bash
cp compose.yml compose.yml.before-traefik.$(date +%F-%H%M%S)
```

If the service is documented in Git, make sure the current state is committed before editing.

## Start or restart the service

From the service folder:

```bash
docker compose config
docker compose up -d
```

Check status:

```bash
docker compose ps
```

Check logs:

```bash
docker compose logs --tail=100
docker logs traefik --tail=100
```

## Test the new route

Test DNS:

```bash
dig app.lab.example.com
```

Test HTTPS:

```bash
curl -k https://app.lab.example.com/
```

Test HTTP redirect:

```bash
curl -I http://app.lab.example.com
```

Test without relying on DNS:

```bash
curl -k --resolve app.lab.example.com:443:DOCKER_HOST_IP https://app.lab.example.com/
```

If the `--resolve` test works but normal hostname access does not, the problem is probably DNS.

## Validation checklist

Before considering the migration successful, confirm:

```text
local DNS resolves to the Traefik Docker host
application container is running
application container is attached to the proxy network
Traefik labels are present
Traefik route works over HTTPS
HTTP redirects to HTTPS
application logs do not show errors
Traefik logs do not show routing errors
old direct port is removed only after validation
rollback path still exists
```

Useful commands:

```bash
dig app.lab.example.com
docker compose ps
docker network inspect proxy
docker inspect example-app
curl -k https://app.lab.example.com/
curl -I http://app.lab.example.com
curl -k --resolve app.lab.example.com:443:DOCKER_HOST_IP https://app.lab.example.com/
docker logs traefik --tail=100
```

## Rollback

If the service does not work through Traefik, rollback should be simple.

Options:

```text
restore the previous Compose file
remove the Traefik labels
remove the service from the proxy network
restore the old published port
point DNS back to the pfSense HAProxy path
keep using the existing pfSense reverse proxy route
```

Example rollback using a saved Compose file:

```bash
cp compose.yml.before-traefik.TIMESTAMP compose.yml
docker compose up -d
```

If DNS was changed, point the hostname back to the previous known-good path.

## What to document in Git

For each migrated service, document:

```text
service name
old access method
new Traefik hostname
internal container port
networks used
whether direct host port was removed
validation commands
rollback notes
known issues
```

Avoid committing real secrets, real `.env` files, or full service exports containing private values.

## Example migration note

Example note for a migrated service:

```text
This service was migrated from direct host port access to Traefik routing.

Previous access:
  DOCKER_HOST_IP:3000

New access:
  app.lab.example.com

The service now joins the shared proxy network and uses Traefik labels for routing. The database remains on the private internal network and is not exposed through Traefik.
```

## What this step shows

This step demonstrates practical migration work:

```text
Docker networking
reverse proxy routing
local DNS usage
service-by-service migration
validation before cleanup
rollback planning
reduced direct port exposure
```

This is the part that makes the Traefik project more than a tutorial.

## References

* Traefik Docker provider: https://doc.traefik.io/traefik/reference/install-configuration/providers/docker/
* Traefik routers: https://doc.traefik.io/traefik/routing/routers/
* Docker Compose networking: https://docs.docker.com/compose/how-tos/networking/

