## Client setup notes

On a Linux client, install Tailscale:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

For first setup, or when I want the client to use lab DNS and lab subnet routes:

```bash
sudo tailscale up --accept-dns=true --accept-routes=true
```

This allows the client to use DNS settings from the Tailnet and accept routes advertised by the lab subnet routers.

For normal day-to-day reconnects, when no setting changes are needed:

```bash
sudo tailscale up
```

This reconnects the client to Tailscale.

## Client exit node usage

When I need to route internet traffic through an exit node:

```bash
sudo tailscale up --exit-node=<exit-node-name-or-ip> --exit-node-allow-lan-access=true
```

I use `--exit-node-allow-lan-access=true` when I still need access to my local LAN while using an exit node.

Example:

```bash
sudo tailscale up --exit-node=pfsense --exit-node-allow-lan-access=true
```

## Client reset commands

If the exit node causes problems, clear the exit node:

```bash
sudo tailscale up --exit-node=
```

If lab DNS causes problems, reconnect without accepting Tailnet DNS:

```bash
sudo tailscale up --accept-dns=false
```

If subnet routes cause problems, reconnect without accepting advertised routes:

```bash
sudo tailscale up --accept-routes=false
```

If I want to reset unspecified Tailscale settings back to defaults:

```bash
sudo tailscale up --reset
```

After resetting, I can return to the normal lab client setup:

```bash
sudo tailscale up --accept-dns=true --accept-routes=true
```

Quick recovery examples:

```text
Problem: exit node breaks internet access
Fix:     sudo tailscale up --exit-node=

Problem: lab DNS is not resolving
Fix:     sudo tailscale up --accept-dns=false

Problem: subnet routes cause routing issues
Fix:     sudo tailscale up --accept-routes=false

Problem: I want to go back to default settings
Fix:     sudo tailscale up --reset
```

## Start Tailscale on boot

On Linux clients, Tailscale runs through the `tailscaled` systemd service.

Enable and start it:

```bash
sudo systemctl enable --now tailscaled
```

Check the service:

```bash
systemctl status tailscaled --no-pager -l
```

Expected result:

```text
Active: active (running)
```

This makes Tailscale start automatically after a reboot.

The client still needs to be authenticated at least once with `tailscale up`. After that, normal reconnects should happen automatically when the service starts.

