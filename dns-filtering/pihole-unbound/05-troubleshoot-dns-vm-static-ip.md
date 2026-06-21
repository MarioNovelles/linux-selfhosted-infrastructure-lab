# Troubleshooting DNS VM Static IP

This document explains why I moved the DNS VM from DHCP reservation attempts to a static IP configured inside Ubuntu.

## Problem

After rebooting the Proxmox host and restarting the VMs, the DNS VM received an address from the DHCP pool instead of the address I expected.

Expected:

```text
ubuntu-dns → 192.168.33.101
```

Actual:

```text
ubuntu-dns → DHCP pool address
```

The VM MAC address stayed the same, so this was not a Proxmox virtual NIC issue.

## Why this mattered

DNS is infrastructure.

If the DNS server address changes, several things can break:

```text
DHCP DNS settings
pfSense firewall aliases
Pi-hole access
Unbound testing
monitoring
local DNS records
other services that depend on DNS
```

Because of that, the DNS VM needs a predictable IP address.

## What I tried first

I first tried to fix this with a pfSense DHCP static mapping.

The mapping existed, and the MAC address was correct, but the VM still received an address from the DHCP pool.

At that point, I decided that a static IP inside Ubuntu was simpler and more reliable for this VM.

## Decision

For normal clients, DHCP is fine.

For infrastructure services like DNS, I prefer a static IP inside the server.

This avoids the DNS server moving to a different DHCP pool address after a reboot.

## Check the interface name

On the DNS VM:

```bash
# Show network interface names.
ip -br link
```

Example interface:

```text
ens18
```

If the interface name is different, use the real interface name in the netplan config.

## Check existing netplan files

```bash
# Show existing netplan files.
ls -lah /etc/netplan/

# Show current netplan configuration.
sudo cat /etc/netplan/*.yaml
```

This helps confirm whether another netplan file is still enabling DHCP.

## Edit netplan

```bash
# Edit the netplan configuration.
sudo nano /etc/netplan/*.yaml
```

Example configuration:

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - 192.168.33.101/24
      routes:
        - to: default
          via: 192.168.33.1
      nameservers:
        addresses:
          - 192.168.33.101
          - 192.168.33.1
        search:
          - novelles.xyz
```

I use the DNS VM address itself as the first nameserver because Pi-hole listens on that VM.

pfSense remains the fallback DNS server.

## Test the netplan configuration

```bash
# Check netplan syntax.
sudo netplan generate --debug

# Apply with rollback protection.
sudo netplan try
```

`netplan try` is useful because it can roll back if the network configuration breaks the connection.

## Validate after applying

```bash
# Confirm IP address.
ip -br addr

# Confirm default route.
ip route

# Test DNS resolution.
dig cloudflare.com
```

Expected result:

```text
192.168.33.101/24
default via 192.168.33.1
DNS resolution works
```

## Retest after reboot

```bash
# Reboot the DNS VM.
sudo reboot
```

After the VM comes back:

```bash
# Confirm the IP stayed static.
ip -br addr

# Confirm DNS still works.
dig cloudflare.com

# Confirm Unbound still works.
dig cloudflare.com @127.0.0.1 -p 5335
```

Expected:

```text
ubuntu-dns still uses 192.168.33.101
DNS resolution works
Unbound resolution works
```

## Lesson

For normal clients, DHCP is fine.

For infrastructure VMs, predictable addressing is more important than forcing everything through DHCP.

The DNS VM should not unexpectedly move to a different DHCP pool address after a reboot.

