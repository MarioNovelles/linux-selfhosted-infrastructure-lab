# Install QEMU Guest Agent

This note documents how I install and check the QEMU guest agent inside an Ubuntu Server VM running on Proxmox.

## Goal

Allow Proxmox to communicate better with the VM and show guest information such as IP address and guest status.

## Install

```bash id="nqtwcx"
# Install the QEMU guest agent inside the Ubuntu VM
sudo apt install qemu-guest-agent
```

## Start and check the service

```bash id="7l7pdw"
# Start the QEMU guest agent
sudo systemctl start qemu-guest-agent

# Check that the service is running
systemctl status qemu-guest-agent
```

The service may show as `static` instead of `enabled`. That is okay.

The important result is:

```text id="6xfhyj"
Active: active (running)
```

## Reboot check

After rebooting the VM, I checked the service again:

```bash id="tcpxxj"
# Check the guest agent after reboot
systemctl status qemu-guest-agent
```

Result: the service was still `active (running)`.

## Proxmox setting

I also checked the VM settings in the Proxmox web UI:

```text id="n7abfo"
VM → Options → QEMU Guest Agent → Enabled
```

## Notes

I do not rely on `systemctl enable` for this service because it can appear as a `static` unit.

For this VM, the working checks are:

```text id="xj47hm"
QEMU Guest Agent enabled in Proxmox
qemu-guest-agent installed in Ubuntu
systemctl status shows active (running)
active after reboot
```

