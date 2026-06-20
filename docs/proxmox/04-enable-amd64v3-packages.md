# Enable amd64v3 Packages on Ubuntu VM

`amd64v3` packages are optional Ubuntu packages optimized for newer x86-64 CPUs.

I enable this only inside the Ubuntu VM, not on the Proxmox host.

Only works on Ubuntu 25.10 or newer.

## 1. Check CPU Support

```bash
ld.so --help | grep '\-v[0-9]'
```

Continue only if the output includes:

```text
x86-64-v3 (supported, searched)
```

## 2. Enable amd64v3

```bash
sudo apt update
sudo apt install -y dpkg

echo 'APT::Architecture-Variants "amd64v3";' | sudo tee /etc/apt/apt.conf.d/99enable-amd64v3

sudo apt update
sudo apt upgrade
sudo reboot
```

## 3. Check Installed amd64v3 Packages

```bash
dpkg-query -W -f='${Package} ${Architecture}\n' | grep amd64v3 | head
```

## Note

After enabling `amd64v3`, the system should stay on hardware that supports `x86-64-v3`.

I use this as an optional optimization and learning step inside the Ubuntu VM.

Reference: https://discourse.ubuntu.com/t/introducing-architecture-variants-amd64v3-now-available-in-ubuntu-25-10/71312
