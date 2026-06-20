# Installing an Ubuntu Server VM on Proxmox VE for Docker Compose

This guide documents how I created an Ubuntu Server VM on Proxmox VE to act as my Docker Compose host.

Docker runs inside the Ubuntu VM, not directly on the Proxmox host.

## Architecture

```text
Proxmox VE host
└── Ubuntu Server VM
    └── Docker Engine + Docker Compose
```

## VM configuration and why I used these settings

These are the values I used for my lab. They are not universal requirements, but they worked well for my Docker Compose host.

| Setting                  | Why I used it                                                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| OVMF (UEFI)              | Modern firmware option and a good default for new Linux VMs.                                                                          |
| q35 machine type         | Newer virtual machine chipset model, suitable for modern Linux guests.                                                                |
| VirtIO SCSI single       | Good performance for Linux VM disks and commonly used with Proxmox.                                                                   |
| 100 GB disk              | Enough space for Docker images, Compose projects, logs, and service data in my lab.                                                   |
| CPU type: host           | Allows the VM to use host CPU features. This can improve performance, but it can make migration to different CPU hosts less portable. |
| 6 vCPU                   | Gives the Docker host enough CPU capacity for several services without assigning the whole Proxmox host to one VM.                    |
| 5120 MiB RAM             | Enough memory for my Docker services while leaving RAM available for Proxmox and other VMs.                                           |
| Ballooning disabled      | Keeps the VM memory allocation predictable for this Docker host.                                                                      |
| VirtIO network           | Efficient virtual network adapter for Linux guests.                                                                                   |
| QEMU Guest Agent         | Helps Proxmox see VM information such as IP address and improves VM management.                                                       |
| DHCP during install      | Simple first setup. A DHCP reservation or static IP can be configured later.                                                          |
| OpenSSH Server enabled   | Allows remote administration after installation.                                                                                      |
| Featured Snaps: none     | Keeps the base server minimal. I install only what I need later.                                                                      |
| Proxmox firewall enabled | Allows firewall rules to be applied at the VM level if needed.                                                                        |
| LVM enabled | Makes it easier to grow the VM storage later if Docker images, logs, volumes, or service data need more space. |

## Step 1: Upload the Ubuntu ISO

In Proxmox:

```text
local → ISO Images → Upload
```

Upload the Ubuntu Server amd64 ISO.

## Step 2: Create the VM

Click:

```text
Create VM
```

### General

```text
VM ID: 100
Name: ubuntu-docker
```

### OS

```text
ISO: Ubuntu Server amd64
Guest OS: Linux
Version: 6.x - 2.6 Kernel
```

### System

```text
Machine: q35
BIOS: OVMF (UEFI)
Add EFI Disk: Yes
SCSI Controller: VirtIO SCSI single
QEMU Agent: Enabled
```

### Disk

```text
Bus: SCSI
Storage: local-lvm
Size: 100 GB
Discard: Enabled
IO Thread: Enabled
```

### CPU

```text
Sockets: 1
Cores: 6
Type: host
```

### Memory

```text
Memory: 5120 MiB
Ballooning: Disabled
```

### Network

```text
Bridge: vmbr0
Model: VirtIO
Firewall: Enabled
```

Click:

```text
Finish
```

## Step 3: Install Ubuntu Server

Start the VM and open the console:

```text
ubuntu-docker → Start
ubuntu-docker → Console
```

Installer choices I used:

```text
Network: DHCP
Storage: Use entire disk
LVM: enabled
OpenSSH Server: Enabled
Featured Snaps: None
Hostname: ubuntu-docker
```
*LVM: Disabled in my original install. To keep it simple, but in a future rebuild, I would enable LVM because it makes storage expansion easier.

After installation, reboot the VM.

If needed, remove the ISO:

```text
Hardware → CD/DVD Drive → Do not use any media
```

## Step 4: Update Ubuntu

```bash
# Update package lists
sudo apt update

# Install available system updates
sudo apt full-upgrade -y

# Reboot after updates
sudo reboot
```

## Step 5: Install QEMU Guest Agent

The QEMU Guest Agent was enabled in the Proxmox VM settings. It also needs to be installed inside Ubuntu.

```bash
# Install the guest agent and useful basic tools
sudo apt install -y qemu-guest-agent htop curl ca-certificates

# Enable and start the guest agent service
sudo systemctl enable --now qemu-guest-agent
```

Verify it is running:

```bash
# Check the guest agent service status
systemctl status qemu-guest-agent
```

After this, the VM IP address should appear in the Proxmox Summary tab.

## Step 6: Connect with SSH

Find the VM IP address:

```bash
# Show network interfaces and IP addresses
ip addr
```

Connect from another machine:

```bash
# Connect to the VM over SSH
ssh <username>@<vm-ip>
```

Example with a sanitized lab IP:

```bash
# Example SSH connection
ssh admin@192.168.33.50
```

## Step 7: Verify VM resources

```bash
# Show number of CPU cores
nproc

# Show memory usage
free -h

# Show disk usage
df -h

# Show block devices
lsblk
```

Expected result in my lab:

```text
CPU: 6 vCPU
RAM: about 5 GiB
Disk: about 100 GB
```

## Final result

```text
Proxmox VE host
└── Ubuntu VM: ubuntu-docker
    ├── 6 vCPU
    ├── 5 GiB RAM
    ├── 100 GB disk
    ├── SSH enabled
    └── QEMU Guest Agent installed
```

The VM is now ready for Docker Engine and Docker Compose installation.

## What I learned

I use Proxmox as the virtualization layer and keep Docker inside an Ubuntu VM.

This keeps the Proxmox host cleaner and makes the Docker host easier to back up, restore, replace, or troubleshoot as a separate VM.


