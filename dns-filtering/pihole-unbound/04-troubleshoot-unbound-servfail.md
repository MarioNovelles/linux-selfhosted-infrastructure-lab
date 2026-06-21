# Troubleshooting Unbound SERVFAIL

This document explains how I diagnosed and fixed a problem where Pi-hole was reachable, but DNS resolution still failed because Unbound returned `SERVFAIL`.

## Problem

Clients could reach Pi-hole, but DNS queries returned:

```text
SERVFAIL
```

Pi-hole logs showed:

```text
query[A] cloudflare.com from 192.168.33.23
forwarded cloudflare.com to 127.0.0.1#5335
reply error is SERVFAIL
```

This meant:

```text
Client → Pi-hole ✅
Pi-hole → Unbound ✅
Unbound → recursive DNS ❌
```

So the problem was not client access to Pi-hole.

The problem was behind Pi-hole.

## Intended DNS design

```text
Client
→ Pi-hole
→ Unbound
→ root / TLD / authoritative DNS servers
```

Fallback path:

```text
Client
→ pfSense DNS Resolver
→ pfBlockerNG DNSBL
```

In my lab:

```text
Pi-hole DNS:  192.168.33.101
pfSense DNS: 192.168.33.1
```

Clients receive both DNS servers through DHCP:

```text
DNS server 1: 192.168.33.101
DNS server 2: 192.168.33.1
```

Pi-hole is the preferred DNS path.

pfSense remains the fallback DNS path.

## Important lesson

pfSense DNS redirect rules do not provide automatic resolver failover.

They only rewrite matching DNS traffic.

If a DNS redirect rule catches the DNS VM itself, Unbound recursion can break.

The DNS VM must be excluded from the pfSense DNS redirect NAT rule.

## Step 1: check what DNS servers the client received

On a Linux client:

```bash
# Show DNS servers received by the client.
resolvectl status
```

Expected idea:

```text
DNS Servers: 192.168.33.101 192.168.33.1
```

Meaning:

```text
192.168.33.101 = Pi-hole
192.168.33.1   = pfSense fallback
```

If the client only receives pfSense, fix DHCP first.

## Step 2: test Pi-hole directly from a client

From a client:

```bash
# Query Pi-hole directly.
dig @192.168.33.101 cloudflare.com
```

On the Pi-hole VM:

```bash
# Watch Pi-hole DNS logs.
sudo tail -f /var/log/pihole/pihole.log
```

If Pi-hole logs the query, clients can reach Pi-hole.

Example log:

```text
query[A] cloudflare.com from 192.168.33.23
forwarded cloudflare.com to 127.0.0.1#5335
reply error is SERVFAIL
```

This means Pi-hole is receiving the query and forwarding it to Unbound.

If the result is still `SERVFAIL`, continue troubleshooting Unbound.

## Step 3: test Unbound directly

On the DNS VM:

```bash
# Test Unbound directly, bypassing Pi-hole.
dig cloudflare.com @127.0.0.1 -p 5335
```

If this returns `SERVFAIL`, Unbound is failing.

That means the problem is not Pi-hole anymore.

## Step 4: test access to root DNS servers

On the DNS VM:

```bash
# Test UDP access to a root DNS server.
dig @198.41.0.4 . NS +norec +time=3

# Test TCP access to a root DNS server.
dig @198.41.0.4 . NS +norec +tcp +time=3
```

Expected healthy behavior:

```text
status: NOERROR
flags include: aa
```

Bad behavior I saw:

```text
status: REFUSED
flags include: ra
query time: 1 msec
```

Why this was suspicious:

```text
A real root DNS server should not look like my local recursive resolver.
The instant response and ra flag suggested pfSense was intercepting the query.
```

This pointed to the pfSense DNS redirect rule.

## Cause

The DNS VM was still included in the pfSense DNS redirect NAT rule.

Unbound's recursive DNS queries were redirected back to pfSense instead of reaching root, TLD, and authoritative DNS servers.

That caused Unbound to fail and Pi-hole to return `SERVFAIL`.

## Fix

In pfSense:

```text
Firewall → NAT → Port Forward
```

Edit the DNS redirect rule.

The rule should redirect rogue client DNS, but not DNS from the DNS VM.

Important source logic:

```text
Source invert match: checked
Source: ubuntu_dns
```

Meaning:

```text
Match everyone except the DNS VM.
```

Important destination logic:

```text
Destination invert match: checked
Destination: Allowed_DNS_Servers
Destination port: DNS 53
```

Meaning:

```text
Only redirect DNS when the destination is not Pi-hole or pfSense.
```

Redirect target:

```text
Redirect target IP: 127.0.0.1
Redirect target port: DNS 53
```

Final meaning:

```text
Client → Pi-hole        allowed
Client → pfSense        allowed
Client → external DNS   redirected to pfSense
DNS VM → external DNS   allowed, not redirected
```

## Clear old states if needed

If tests still behave strangely after changing firewall or NAT rules, clear old states for the DNS VM.

In pfSense:

```text
Diagnostics → States
```

Filter:

```text
192.168.33.101
```

Then kill matching states.

This avoids testing with old firewall or NAT states.

## Retest after the fix

On the DNS VM:

```bash
# Root DNS should answer directly now.
dig @198.41.0.4 . NS +norec +time=3

# TCP root DNS test.
dig @198.41.0.4 . NS +norec +tcp +time=3

# Unbound should now resolve.
dig cloudflare.com @127.0.0.1 -p 5335
```

Expected:

```text
Unbound returns NOERROR.
```

From a client:

```bash
# Pi-hole should now resolve normally.
dig @192.168.33.101 cloudflare.com
```

Expected:

```text
status: NOERROR
SERVER: 192.168.33.101#53
```

## Symptom checklist

| Symptom                                                             | Meaning                                                                   | Fix                                                  |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------- |
| Pi-hole dashboard shows no client queries                           | Clients are not using Pi-hole or traffic is redirected before reaching it | Check DHCP DNS settings and NAT redirect destination |
| `dig @Pi-hole domain` appears in Pi-hole logs                       | Client can reach Pi-hole                                                  | Continue troubleshooting Pi-hole to Unbound          |
| Pi-hole logs `forwarded ... to 127.0.0.1#5335`                      | Pi-hole is forwarding to Unbound                                          | Test Unbound directly                                |
| `dig @127.0.0.1 -p 5335 domain` returns `SERVFAIL`                  | Unbound is failing                                                        | Test root DNS access                                 |
| Root DNS test returns `REFUSED` with `ra` flag and very low latency | DNS VM traffic is probably being redirected to pfSense                    | Exclude `ubuntu_dns` from NAT redirect               |
| Root DNS test works and Unbound returns `NOERROR`                   | Recursive DNS works                                                       | Retest Pi-hole from a client                         |

## Final summary

The fix was not in Pi-hole.

The fix was in pfSense DNS enforcement.

I had to exclude the DNS VM from the DNS redirect NAT rule.

Without that exception, Unbound's recursive DNS queries were redirected back to pfSense instead of reaching root, TLD, and authoritative DNS servers.

After excluding the DNS VM, Unbound recursion worked and Pi-hole could resolve domains normally.

