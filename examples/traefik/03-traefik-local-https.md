# 03 - Traefik Local HTTPS Setup

This step starts Traefik with local self-signed HTTPS.

The goal is to prove that Traefik can start, listen on ports `80` and `443`, redirect HTTP to HTTPS, and protect the dashboard with basic authentication before adding Cloudflare or Let's Encrypt ACME automation.

At this stage:

```text
Traefik runs on ubuntu-docker
ports 80 and 443 are exposed
HTTP redirects to HTTPS
the dashboard is protected with basic auth
a local self-signed certificate is used
Cloudflare ACME is not enabled yet
```

## Why start with local HTTPS

The existing pfSense ACME setup already handles Let's Encrypt certificates.

For Traefik, I want to validate the basics first:

```text
Docker provider works
Traefik reads Docker labels
dashboard routing works
basic auth works
HTTPS entrypoint works
HTTP redirects to HTTPS
```

Using a self-signed certificate keeps the first test local and avoids changing the working pfSense certificate workflow too early.

## Runtime path

The real deployment runs outside the Git repository:

```text
/srv/docker/traefik
```

This path should already exist from the prerequisites step.

From the repository root, copy the example files into the runtime folder if they are not already there:

```bash
cp examples/traefik/compose.example.yml /srv/docker/traefik/compose.yml
cp examples/traefik/.env.example /srv/docker/traefik/.env
cp examples/traefik/dynamic/tls.example.yml /srv/docker/traefik/dynamic/tls.yml
```

Edit the real `.env` file:

```bash
nano /srv/docker/traefik/.env
```

At minimum, replace:

```text
TRAEFIK_DASHBOARD_HOST=traefik.lab.example.com
TRAEFIK_DASHBOARD_AUTH=admin:CHANGEME_GENERATED_HTPASSWD_HASH
```

Do not commit the real `.env` file.

## Create dashboard credentials

Install `htpasswd` if needed:

```bash
sudo apt update
sudo apt install apache2-utils
```

Generate a dashboard username and password hash:

```bash
htpasswd -nbB admin "CHANGE_THIS_PASSWORD" | sed -e 's/\$/\$\$/g'
```

Copy the full output into `/srv/docker/traefik/.env`.

Example shape:

```text
TRAEFIK_DASHBOARD_AUTH=admin:$$2y$$05$$examplehash
```

Do not commit the real generated value.

## Create the local certificate

Create a local self-signed certificate for testing.

Replace `lab.example.com` with the local lab domain used in DNS:

```bash
cat > /srv/docker/traefik/certs/local-openssl.cnf <<'EOF'
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
x509_extensions    = v3_req
distinguished_name = dn

[dn]
CN = *.lab.example.com

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.lab.example.com
DNS.2 = traefik.lab.example.com
EOF
```

Generate the certificate and key:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /srv/docker/traefik/certs/local.key \
  -out /srv/docker/traefik/certs/local.crt \
  -config /srv/docker/traefik/certs/local-openssl.cnf
```

Check that the files exist:

```bash
ls -l /srv/docker/traefik/certs
```

Expected files:

```text
local.crt
local.key
local-openssl.cnf
```

The browser will still warn about the certificate because it is self-signed. That is expected in this step.

## Check the dynamic TLS config

Check the copied TLS file:

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

The host files are mounted into the container like this:

```text
/srv/docker/traefik/certs
→ /certs
```

## Validate the Compose file

From the runtime folder:

```bash
cd /srv/docker/traefik
docker compose config
```

This checks that the Compose file and `.env` values render correctly.

## Start Traefik

Start Traefik:

```bash
cd /srv/docker/traefik
docker compose up -d
```

Check status:

```bash
docker compose ps
```

Check logs:

```bash
docker logs traefik --tail=100
```

## Verify listening ports

Check that Traefik is listening on ports `80` and `443`:

```bash
ss -tulpn | grep -E ':80|:443'
```

The insecure dashboard port should not be exposed:

```bash
ss -tulpn | grep ':8080'
```

Expected result:

```text
no output
```

## Dashboard access

Make sure local DNS points the dashboard hostname to the Docker host:

```text
traefik.lab.example.com
→ DOCKER_HOST_IP
```

Open:

```text
https://traefik.lab.example.com/dashboard/
```

The trailing slash is important.

Expected result:

```text
browser shows a self-signed certificate warning
dashboard asks for basic auth
dashboard loads after login
```

## Validation commands

Check DNS:

```bash
dig traefik.lab.example.com
```

Check Traefik:

```bash
docker compose ps
docker logs traefik --tail=100
```

Check ports:

```bash
ss -tulpn | grep -E ':80|:443|:8080'
```

Check the dashboard response:

```bash
curl -k -I https://traefik.lab.example.com/dashboard/
```

Expected signs:

```text
Traefik container is running
ports 80 and 443 are listening
port 8080 is not exposed
dashboard route responds over HTTPS
basic auth protects the dashboard
browser warns about the self-signed certificate
```

## Rollback

Stop Traefik:

```bash
cd /srv/docker/traefik
docker compose down
```

Remove the runtime folder only if needed:

```bash
sudo rm -rf /srv/docker/traefik
```

Do not change the existing pfSense HAProxy or pfSense ACME setup during this step. That keeps the existing pfSense path available as the known-good fallback.

## Notes

This step proves that Traefik can start and serve HTTPS locally.

The next step uses the `whoami` container to prove that Traefik can route to a Docker service through labels.

Cloudflare and Let's Encrypt ACME are handled later after local routing works.

## References

* Traefik Docker setup: https://doc.traefik.io/traefik/setup/docker/
* Traefik API and dashboard: https://doc.traefik.io/traefik/reference/install-configuration/api-dashboard/
* Traefik Docker provider: https://doc.traefik.io/traefik/reference/install-configuration/providers/docker/

