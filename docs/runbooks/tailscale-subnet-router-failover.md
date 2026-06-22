# Tailscale Subnet Router Failover

This runbook documents adding `ubuntu-docker` as a second Tailscale subnet router.

pfSense already runs Tailscale and advertises the lab LAN. I added `ubuntu-docker` as a backup path in case the Tailscale service on pfSense fails.

```text
Primary subnet router:   pfSense
Failover subnet router:  ubuntu-docker
Advertised subnet:       192.168.33.0/24
```

## Why `ubuntu-docker`

I used `ubuntu-docker` instead of `ubuntu-dns` because the DNS VM should stay focused on Pi-hole and Unbound.

```text
ubuntu-dns    = DNS only, keep it simple and stable
ubuntu-docker = better place for extra admin tooling
```

This keeps remote access separate from DNS.

## Check IP forwarding

A Linux subnet router needs IPv4 forwarding enabled.

```bash
sysctl net.ipv4.ip_forward
```

On this VM it was already enabled:

```text
net.ipv4.ip_forward = 1
```

If it was disabled, I would enable it with:

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

## Advertise the LAN subnet

On `ubuntu-docker`:

```bash
sudo tailscale up --advertise-routes=192.168.33.0/24 --hostname=ubuntu-docker-subnet-router
```

I did not use `--accept-routes` because this VM is advertising the LAN route, not learning routes from another subnet router.

## Approve the route

Advertising the subnet from the Linux VM is not enough by itself.

After running `tailscale up --advertise-routes=192.168.33.0/24`, the route is only requested. It still needs to be approved in the Tailscale admin console before clients can use it.

I went to:

```text
https://login.tailscale.com/admin/machines
```

Then:

```text
ubuntu-docker-subnet-router
→ Options
→ Edit route settings
→ Enable 192.168.33.0/24
```

This allows `ubuntu-docker` to actually advertise the LAN subnet to the Tailnet.

I also disabled key expiry for this machine because it is infrastructure and should not unexpectedly require re-authentication.

## Verify

On `ubuntu-docker`:

```bash
tailscale status
tailscale ip -4
systemctl status tailscaled --no-pager -l
tailscale debug prefs | grep -i advertise
sysctl net.ipv4.ip_forward
```

Expected forwarding result:

```text
net.ipv4.ip_forward = 1
```

## Test from a remote Tailscale client

From a remote device connected to Tailscale:

```bash
ping 192.168.33.1
ping 192.168.33.101
ssh mr-robot@192.168.33.101
```

If ping is blocked, test with SSH or another known allowed service.

## Failover test

To test failover, temporarily stop or disable Tailscale on pfSense.

Then test LAN access again from a remote Tailscale client:

```bash
ping 192.168.33.1
ping 192.168.33.101
ssh mr-robot@192.168.33.101
```

If access still works, `ubuntu-docker` is working as the failover subnet router.

After testing, re-enable Tailscale on pfSense.

## Final design

```text
pfSense:
  Primary Tailscale subnet router
  Advertises 192.168.33.0/24

ubuntu-docker:
  Secondary Tailscale subnet router
  Advertises 192.168.33.0/24

ubuntu-dns:
  DNS only
  Not used as a Tailscale subnet router
```

## Lesson learned

Remote access should not depend on only one service.

Adding `ubuntu-docker` as a second subnet router gives the lab another path into the LAN if the Tailscale service on pfSense fails.

