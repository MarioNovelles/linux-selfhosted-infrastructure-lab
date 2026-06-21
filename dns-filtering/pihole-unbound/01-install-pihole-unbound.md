# Pi-hole + Unbound Recursive DNS Setup

This runbook documents how I installed Pi-hole together with Unbound on a dedicated Ubuntu DNS VM.

Pi-hole is used for DNS filtering, local DNS records, and query visibility.

Unbound is used as a local recursive DNS resolver, so DNS queries are not forwarded to public upstream resolvers like Cloudflare, Google, or Quad9.

## VM sizing

This service runs on a dedicated Ubuntu Server VM.

The base VM setup follows my existing Proxmox Ubuntu VM notes. The main difference is that this VM needs fewer resources than the Docker host.

```text
vCPU:    2
RAM:     2 GB
Storage: 16 GB
```

Why:

DNS is important infrastructure, but Pi-hole and Unbound do not need the same resources as the Docker host VM.

## Lab values

* The IP addresses shown here are example private lab values(not real ip values).
```text
DNS VM hostname: ubuntu-dns
DNS VM IP:       192.168.67.53
Gateway:         192.168.67.1
```

Final DNS path:

```text
LAN client
→ Pi-hole
→ Unbound
→ root / TLD / authoritative DNS servers
```

## Why I chose this design

I installed Pi-hole and Unbound on a dedicated DNS VM instead of the Docker VM.

Reason:

```text
If the Docker VM is down, DNS should still work.
```

Pi-hole listens on normal DNS port `53`.

Unbound listens only locally on:

```text
127.0.0.1:5335
```

Pi-hole sends allowed DNS queries to Unbound using:

```text
127.0.0.1#5335
```

---

## 1. Check basic network connectivity

Run these commands on the DNS VM.

```bash
# Show the current hostname.
hostname

# Show IP addresses in a short format.
ip -br addr

# Show the default route / gateway.
ip route
```

Test LAN and internet access:

```bash
# Test the pfSense gateway.
ping -c 3 192.168.67.1

# Test internet access without using DNS.
ping -c 3 1.1.1.1

# Test that DNS currently works before changing anything.
getent ahosts cloudflare.com
```

Why:

Before installing DNS services, I want to confirm that the VM itself has working network access.

---

## 2. Install DNS tools

```bash
# Update package lists.
sudo apt update

# Install dig, which is useful for DNS testing.
sudo apt install dnsutils
```

Why:

`dig` is one of the most useful tools for testing DNS servers.

---

## 3. Test access to DNS root servers

```bash
# Test UDP access to a root DNS server.
dig @198.41.0.4 . NS +norec +time=3
```

Look for this in the output:

```text
flags: qr aa
```

Then test TCP:

```bash
# Test TCP access to a root DNS server.
dig @198.41.0.4 . NS +norec +tcp +time=3
```

Why:

Unbound needs to contact root DNS servers directly. If this does not work, recursive DNS may fail or behave strangely.

---

## 4. Install Unbound

```bash
# Install Unbound from Ubuntu packages.
sudo apt install unbound
```

Why:

Unbound will be the local recursive DNS resolver.

---

## 5. Configure Unbound for Pi-hole

Create a Pi-hole-specific Unbound configuration file:

```bash
# Open a new Unbound config file.
sudo nano /etc/unbound/unbound.conf.d/pi-hole.conf
```

Paste this configuration:

```conf
server:
    # Keep normal logging quiet.
    verbosity: 0

    # Listen only on localhost.
    # Pi-hole runs on the same VM, so Unbound does not need to listen on the LAN.
    interface: 127.0.0.1

    # Use port 5335 so Unbound does not conflict with Pi-hole on port 53.
    port: 5335

    # Enable IPv4 DNS.
    do-ip4: yes

    # DNS normally uses UDP, but TCP is also needed for larger replies.
    do-udp: yes
    do-tcp: yes

    # IPv6 is disabled because this lab is currently IPv4-focused.
    do-ip6: no
    prefer-ip6: no

    # DNSSEC hardening.
    harden-glue: yes
    harden-dnssec-stripped: yes

    # Disabled because capitalization randomization can cause DNSSEC problems.
    use-caps-for-id: no

    # Reduces DNS fragmentation problems.
    edns-buffer-size: 1232

    # Prefetch popular cache entries before they expire.
    prefetch: yes

    # One thread is enough for a small home lab DNS resolver.
    num-threads: 1

    # Recommended receive buffer setting.
    so-rcvbuf: 1m

    # Keep private IP ranges private.
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10

    # No forward-zone is configured.
    # This is intentional because Unbound should work as a recursive resolver,
    # not as a forwarder to Cloudflare, Google, Quad9, etc.
```

Restart Unbound:

```bash
# Restart Unbound so it loads the new configuration.
sudo systemctl restart unbound

# Check whether Unbound is running.
sudo systemctl status unbound --no-pager
```

---

## 6. Test Unbound

```bash
# Ask Unbound directly to resolve pi-hole.net.
dig pi-hole.net @127.0.0.1 -p 5335
```

Why:

This confirms that Unbound is listening on `127.0.0.1:5335`.

The first query can be slower because Unbound has to resolve it recursively. Later queries should be faster because of caching.

Test DNSSEC:

```bash
# This should fail because the domain is intentionally broken.
dig fail01.dnssec.works @127.0.0.1 -p 5335

# This should succeed and include the "ad" flag.
dig +ad dnssec.works @127.0.0.1 -p 5335
```

Expected result:

```text
fail01.dnssec.works → SERVFAIL
dnssec.works        → NOERROR with ad flag
```

---

## 7. Install Pi-hole

I used the manual installer download method so I could inspect the installer before running it.

```bash
# Move to a temporary directory.
cd /tmp

# Download the official Pi-hole installer.
wget -O basic-install.sh https://install.pi-hole.net

# Optional: inspect the installer before running it.
less basic-install.sh

# Run the installer.
sudo bash basic-install.sh
```

Installer choices:

```text
Static IP:
- Confirm the DNS VM uses 192.168.67.53.

Interface:
- Select the main LAN interface.

Upstream DNS:
- Select Custom if available.
- Use 127.0.0.1#5335.

Web admin interface:
- Install it.

Web server:
- Install it.

Query logging:
- Enable it for the lab.

Privacy mode:
- Default is fine for this lab.
```

Why:

Pi-hole should listen for LAN DNS queries on port `53` and forward allowed queries to Unbound on `127.0.0.1#5335`.

---

## 8. Configure Pi-hole to use Unbound

Open the Pi-hole web UI:

```text
http://192.168.67.53/admin/
```

Go to:

```text
Settings → DNS
```

Set the custom DNS server to:

```text
127.0.0.1#5335
```

Untick all other upstream DNS providers.

Click:

```text
Save & Apply
```

Why:

Pi-hole should use only the local Unbound resolver. This avoids external DNS forwarders.

---

## 9. Verify Pi-hole is forwarding to Unbound

Run this on the DNS VM:

```bash
# Query Pi-hole directly.
dig en.wikipedia.org @127.0.0.1
```

Then check the Pi-hole log:

```bash
# Check whether Pi-hole forwarded the query to Unbound.
sudo tail -n 50 /var/log/pihole/pihole.log
```

Expected idea:

```text
forwarded en.wikipedia.org to 127.0.0.1#5335
```

Why:

This confirms that Pi-hole is using Unbound as its upstream resolver.

---

## 10. Test from another LAN machine

Run this from a laptop or another LAN client:

```bash
# Ask the DNS VM to resolve a domain.
dig @192.168.67.53 cloudflare.com
```

Expected:

```text
SERVER: 192.168.67.53#53
```

Also open the Pi-hole web UI:

```text
http://192.168.67.53/admin/
```

---

## 11. Add local DNS records later

After Pi-hole is working, I can add local DNS records in Pi-hole.

Examples:

```text
pihole.lab.local    → 192.168.67.53
uptime.lab.local    → 192.168.67.100
traefik.lab.local   → 192.168.67.100
whoami.lab.local    → 192.168.67.100
nextcloud.lab.local → 192.168.67.100
```

Why:

Pi-hole handles local DNS names.

Traefik handles routing for Docker services on the Docker VM.

Final architecture:

```text
pfSense
→ router, firewall, DHCP, secondary/fallback DNS for redundancy

ubuntu-dns
→ Pi-hole, Unbound, local DNS records, primary DNS

ubuntu-docker
→ Traefik, Uptime Kuma, Nextcloud, other Docker services
```

## Next steps

After Pi-hole and Unbound are working locally, continue with the pfSense DNS configuration:

1. [`02-configure-pfsense-dhcp-dns.md`](./02-configure-pfsense-dhcp-dns.md)
2. [`03-firewall-dns-enforcement-rules.md`](./03-firewall-dns-enforcement-rules.md)

Troubleshooting notes:

1. [`04-troubleshoot-unbound-servfail.md`](./04-troubleshoot-unbound-servfail.md)
2. [`05-troubleshoot-dns-vm-static-ip.md`](./05-troubleshoot-dns-vm-static-ip.md)

## References:

Official pi-hole installation documentation
https://docs.pi-hole.net/main/basic-install/
https://docs.pi-hole.net/main/post-install/
https://docs.pi-hole.net/main/update/

Official pi-hole unbound documentation
https://docs.pi-hole.net/guides/dns/unbound/
