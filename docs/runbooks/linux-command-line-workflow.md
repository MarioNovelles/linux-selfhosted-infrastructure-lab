# Linux Command-Line Workflow

This runbook documents command-line workflows I commonly use in my infrastructure lab.

It is based on real terminal usage across several lab machines, but the examples are sanitized. I do not publish raw shell history because it can contain private paths, internal IP addresses, hostnames, usernames, tokens, temporary commands, mistakes, and other details that do not belong in a public repository.

The purpose of this file is to keep a practical reference for myself while showing the kind of Linux, Docker, Git, SSH, and troubleshooting work I practice regularly.

## What I Use the Terminal For

Most of my lab work happens in the terminal.

The main areas are:

* Docker and Docker Compose service management
* Git-based documentation workflow
* SSH remote administration
* Linux package updates
* service troubleshooting and log review
* storage, DNS, and network checks
* editing Markdown, scripts, and configuration files
* permissions, users, and small automation scripts

This is not meant to be a full Linux command reference. It is a practical overview of the workflows I actually use most often.

## Daily Navigation and Inspection

```bash
pwd                  # Show the current working directory
ls                   # List files in the current directory
ls -lah              # List files with details, hidden files, and readable sizes
cd /path/to/dir      # Change into a specific directory
cd ..                # Move one directory up
cd -                 # Return to the previous directory
cat file.txt         # Print a small file to the terminal
less file.txt        # Open a longer file in a scrollable viewer
tail -n 100 file.txt # Show the last 100 lines of a file
clear                # Clear the terminal screen
history              # Show recent shell command history
date                 # Show the current date and time
```

Useful habits:

* I use `pwd` before running commands that modify or delete files.
* I use `ls -lah` to check permissions, ownership, hidden files, and sizes.
* I use `less` for long files and `tail` when I only need recent log output.

## Shell Aliases for `ls`

I use a small Bash alias setup inside `~/.bashrc` to make file listing more useful during daily terminal work.

```bash
alias ls='ls --color=auto --classify --almost-all'
alias ll='ls -lh --color=auto --classify --all'
```

The normal `ls` stays clean while still showing hidden files, colors, and file-type indicators.

The `ll` alias is for deeper inspection. It shows permissions, ownership, human-readable sizes, hidden files, and also includes `./` and `../`, which can be useful when checking or repairing directory permissions.

This keeps everyday navigation simple while still giving me a detailed view when troubleshooting files, folders, or Docker bind mounts.

## Docker and Container Management

Docker is one of the tools I use most in the lab. I use it for self-hosted services, local testing, monitoring, AI tools, and troubleshooting.

```bash
docker ps                          # Show running containers
docker ps -a                       # Show all containers, including stopped ones
docker images                      # List downloaded Docker images
docker volume ls                   # List Docker volumes
docker network ls                  # List Docker networks
docker inspect <container>         # Show detailed container configuration and metadata
docker logs <container>            # Show container logs
docker logs -f <container>         # Follow container logs live
docker logs --tail 50 <container>  # Show the last 50 log lines
docker start <container>           # Start a stopped container
docker stop <container>            # Stop a running container
docker restart <container>         # Restart a container
docker rm <container>              # Remove a stopped container
docker pull <image>                # Download or update an image
docker image prune                 # Remove unused images
```

Cleaner container overview:

```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
```

Safety notes:

* I check volumes before removing containers.
* I avoid `docker volume prune` unless I am sure the data is disposable.
* I avoid storing secrets directly in `docker run` commands.
* I prefer Docker Compose for long-term service definitions.

## Docker Compose Workflow

Docker Compose is preferred for long-term service management because the service definition lives in files instead of only in shell history or a GUI.

```bash
docker compose up -d       # Start the Compose project in the background
docker compose up          # Start in the foreground, useful for troubleshooting
docker compose down        # Stop and remove containers and default network
docker compose ps          # Show containers in the current Compose project
docker compose logs        # Show logs for the Compose project
docker compose logs -f     # Follow Compose logs live
docker compose pull        # Pull newer images
docker compose restart     # Restart services
docker compose config      # Validate and render the Compose configuration
```

Typical update flow:

```bash
cd /srv/docker/service-name # Enter the service's Compose project folder
docker compose pull         # Pull updated images
docker compose up -d        # Recreate containers if needed
docker compose logs -f      # Watch logs after starting
```

My favorite troubleshooting commands for container logs are:

```bash
docker logs --tail 50 <container-name>
docker compose logs --tail 50 <service-name>
docker compose logs --tail 50 -f <service-name>
```

I use `--tail 50` because it usually shows enough recent output to catch startup errors, permission problems, failed connections, or crashes without flooding the terminal.

Good practice:

* one Compose project per service or logical stack
* private `.env` files
* consistent `compose.yml` naming
* documented ports and volumes
* sanitized examples in the public repo
* real production files kept private

## Git and Documentation Workflow

Git is used heavily because this lab is also a documentation project.

```bash
git status              # Show changed, staged, and untracked files
git diff                # Review unstaged changes
git add <file>          # Stage a file for the next commit
git diff --staged       # Review staged changes before committing
git commit -m "Message" # Create a local commit with a clear message
git push                # Upload local commits to GitHub
git log --oneline -5    # Show the last five commits in compact form
git remote -v           # Show configured Git remotes
git pull --ff-only      # Pull only if Git can fast-forward cleanly
```

Important difference:

```text
git diff           = unstaged changes
git diff --staged  = staged changes
git log            = committed changes
```

Good commit messages:

```text
Document DNS filtering approach
Add sanitized firewall policy notes
Document Docker Compose architecture plan
Add Proxmox installation notes
Add Linux command-line workflow runbook
```

Good habits:

* review `git diff` before staging
* review `git diff --staged` before committing
* keep commits small and focused
* avoid committing secrets, real `.env` files, or production configuration

## SSH and Remote Administration

SSH is used to connect to Linux systems and manage them remotely.

```bash
ssh user@host-ip
# Connect to a remote Linux system over SSH

ssh-copy-id user@host-ip
# Install the local public SSH key on a remote host

ssh-keygen -t ed25519
# Generate a new Ed25519 SSH key pair
```

## File Transfer

```bash
scp file.txt user@host-ip:/path/to/destination/
# Copy a local file to a remote host

scp user@host-ip:/path/to/file.txt .
# Copy a file from a remote host to the current local directory
```

SSH troubleshooting:

```bash
systemctl status ssh       # Check whether the SSH service is running
sudo systemctl restart ssh # Restart the SSH service
ss -tulpn | grep :22       # Check whether something is listening on SSH port 22
```

Security notes:

* I prefer SSH keys over password-only access.
* I keep private keys out of repositories.
* I avoid publishing real usernames, hostnames, or IP addresses.
* I prefer VPN-style access for private lab administration.

## Package and System Maintenance

```bash
sudo apt update            # Refresh package lists
sudo apt upgrade           # Upgrade installed packages
sudo apt full-upgrade      # Upgrade packages and handle dependency changes
sudo apt autoremove        # Remove packages that are no longer needed
sudo apt install <package> # Install a package
sudo reboot                # Reboot the system
```

Useful system checks:

```bash
hostnamectl # Show hostname and system information
timedatectl # Show time, timezone, and NTP status
uname -r    # Show the running kernel version
whoami      # Show the current user
id          # Show current user ID and group membership
groups      # Show groups for the current user
```

Good habits:

* I review major updates before applying them on important systems.
* I check whether a reboot is required.
* I avoid updating critical systems without a backup or rollback plan.

## Service Troubleshooting

Linux services are checked with `systemctl`, logs, and listening-port checks.

```bash
systemctl status <service>        # Check service status
sudo systemctl restart <service>  # Restart a service
sudo systemctl enable <service>   # Enable a service at boot
sudo systemctl disable <service>  # Disable a service at boot
journalctl -u <service>           # Show logs for one service
journalctl -b                     # Show logs from the current boot
journalctl -xe                    # Show recent high-priority log messages
journalctl -b | tail -n 100       # Show recent boot logs
ss -tulpn                         # Show listening TCP/UDP sockets and processes
ss -tulpn | grep :80              # Check whether something is listening on port 80
ss -tulpn | grep :22              # Check whether SSH is listening on port 22
```

Typical troubleshooting flow:

1. check service status
2. check recent logs
3. confirm configuration changes
4. restart the service if appropriate
5. verify that the service is listening
6. test from another machine if needed
7. document what fixed the issue

## File Searching and Text Processing

Searching files is useful for documentation, configuration, scripts, logs, and troubleshooting.

```bash
grep -Rni "pattern" file.txt    # Search one file and show matching line numbers
grep -Rni "pattern" .           # Search recursively, case-insensitive, with line numbers
find . -name "*.md"             # Find Markdown files by name
diff file1 file2                # Compare two files
```

Before committing public documentation, useful searches include:

```bash
grep -RniE "password|token|secret|api_key|PRIVATE" .
# Search for possible secrets before committing

grep -RniE "192\.168|10\.|172\.16|172\.17|172\.18|172\.19|172\.2|172\.3" .
# Search for private IP address ranges before committing
```

## LazyVim / Neovim Workflow

I use LazyVim as my main terminal editor for Markdown documentation, shell scripts, Docker Compose files, and configuration notes.

I like Vim-style keybindings and shortcuts because they make text editing feel fast and interactive. Once the basic motions start to make sense, editing feels less like clicking through menus and more like a small keyboard-based game: searching, jumping, deleting, copying, moving blocks, and fixing text quickly without leaving the keyboard.

```bash
nvim <file-name> # Edit a Markdown file, config file, script, or Compose file
```

My most used movement and editing keys:

```vim
h        " Move left
j        " Move down
k        " Move up
l        " Move right
gg       " Go to the top of the file
G        " Go to the bottom of the file
0        " Go to the beginning of the line
$        " Go to the end of the line
i        " Insert before the cursor
a        " Insert after the cursor
o        " Open a new line below
v        " Select text
u        " Undo
Ctrl-r   " Redo
dd       " Delete the current line
yy       " Copy the current line
p        " Paste after the cursor
gg0vG$   " Select everything
```

Saving, quitting, and searching:

```vim
:w             " Save the current file
:q             " Quit
:wq            " Save and quit
:q!            " Quit without saving
/search-term   " Search inside the current file
n              " Jump to the next search result
N              " Jump to the previous search result
```

Useful workflow after editing documentation:

```bash
git diff
git add docs/runbooks/example.md
git diff --staged
git commit -m "Add example runbook"
git push
```

For scripts and Compose files, I try to review and validate before running anything:

```bash
cat script.sh
chmod +x script.sh
./script.sh

docker compose config
docker compose up -d
docker compose logs --tail 50 -f
```

Good habits:

* review scripts before executing them
* validate Compose files before starting services
* keep real `.env` files private
* check `git diff` before committing

## Storage and Disk Checks

```bash
lsblk               # Show block devices
lsblk -f            # Show block devices with filesystems and labels
lsblk -a            # Show all block devices
df -h               # Show filesystem disk usage
du -h --max-depth=1 # Show folder sizes one level deep
findmnt             # Show mounted filesystems
mount               # Show mounted filesystems
umount /path        # Unmount a filesystem
```

Useful disk usage check:

```bash
du -h --max-depth=1 2>/dev/null | sort -hr
# Show largest folders first, hiding permission errors
```

Safety notes:

* verify disk names before running destructive commands
* be careful with `umount`, `fsck`, formatting, and partitioning
* check backups before changing storage layouts

## Networking, DNS, and Remote Access

```bash
ip addr                      # Show network interfaces and IP addresses
ip route                     # Show routing table
ping example.com             # Test reachability by hostname
dig example.com              # Query DNS records
nslookup example.com         # Query DNS using nslookup
resolvectl status            # Show systemd-resolved DNS status
sudo resolvectl flush-caches # Flush local DNS cache
getent hosts example.com     # Resolve a hostname using system resolver behavior
```

Useful checks:

```bash
ping -c 4 1.1.1.1     # Test IP connectivity without DNS
ping -c 4 example.com # Test connectivity with DNS resolution
dig example.com       # Check DNS resolution directly
ip route              # Confirm default route and gateways
```

Troubleshooting logic:

* if IP ping works but domain lookup fails, suspect DNS
* if local access works but remote access fails, check routing, firewall, VPN, or exposed ports
* if a service is reachable by IP but not name, check DNS records and resolver path
* if a VPN client cannot reach services, check routes, allowed IPs, firewall rules, and DNS

VPN checks:

```bash
tailscale status  # Show Tailscale connection and peers
sudo tailscale up # Bring Tailscale up or configure it
wg show           # Show WireGuard interface and peer status
ip route          # Check routes used for VPN or remote access
```

Netplan checks on Ubuntu Server:

```bash
sudo netplan generate # Validate and generate Netplan configuration
sudo netplan try      # Test Netplan changes with rollback protection
sudo netplan apply    # Apply Netplan configuration
```

## Permissions, Users, and Groups

```bash
chmod +x script.sh           # Make a script executable
chown user:group file        # Change file owner and group
sudo chown -R user:group dir # Recursively change ownership of a directory
sudo usermod -aG docker user # Add a user to the docker group
passwd user                  # Change a user's password
ls -lah                      # Check permissions and ownership
id user                      # Show user ID and groups
groups user                  # Show groups for a user
stat file                    # Show detailed file metadata
getent passwd user           # Check whether a user exists
```

Safety notes:

* be careful with recursive `chmod -R` and `chown -R`
* check the current directory before running recursive commands
* avoid making sensitive files world-readable
* keep SSH private keys restricted

## Scripts and Automation

```bash
chmod +x script.sh # Make a script executable
./script.sh        # Run a script from the current directory
bash script.sh     # Run a script with Bash
cat script.sh      # Review a script before running it
```

Cron terminology:

```text
cron      = the scheduler service
crontab   = the table of scheduled commands
cron job  = one scheduled command inside a crontab
```

Example sanitized cron job:

```cron
*/5 * * * * /opt/scripts/example-task.sh >> /var/log/example-task.log 2>&1
# Run the script every five minutes and append output/errors to a log file
```

Good habits:

* review scripts before running them
* log scheduled jobs when useful
* avoid hard-coding secrets into scripts
* keep production scripts private if they contain sensitive values

## Hardware and Performance Checks

```bash
free -h                  # Show memory usage in human-readable format
swapon --show            # Show active swap devices/files
vmstat 1                 # Show system performance stats every second
htop                     # Interactive process and resource viewer
ps                       # Show running processes
uname -r                 # Show kernel version
nvidia-smi               # Show NVIDIA GPU status
lsmod | grep -i nvidia   # Check whether NVIDIA kernel modules are loaded
sudo rpi-eeprom-update   # Check Raspberry Pi EEPROM/bootloader update status
sudo rpi-eeprom-update -a # Apply Raspberry Pi EEPROM updates
```

## Safety Habits

Some commands can be destructive or disruptive.

```bash
rm -rf               # Recursively delete files/directories; dangerous if path is wrong
mv                   # Move or rename files; can overwrite if used carelessly
chown -R             # Recursively change ownership
chmod -R             # Recursively change permissions
docker compose down  # Stop and remove Compose containers/networks
docker rm            # Remove a container
docker volume rm     # Remove a Docker volume and its data
docker volume prune  # Remove unused Docker volumes; can destroy data
docker network prune # Remove unused Docker networks
umount               # Unmount a filesystem
fsck                 # Check/repair a filesystem; verify with lsblk and always unmount first
reboot               # Reboot the system
shutdown             # Shut down the system
```

Good safety habits:

* Always confirm the target disk with `lsblk` before using `fsck`.
* Do not run `fsck` on a mounted filesystem.
* Be especially careful when working with external drives, VM disks, or backup disks.
* check the current directory with `pwd`
* inspect files with `ls -lah`
* review scripts before running them
* confirm disk names with `lsblk`
* check service names before stopping containers
* avoid pruning Docker volumes unless data is known to be disposable
* create backups before migrations
* prefer one careful change at a time
* test after each change

## Commands I Want to Keep Improving

Areas for continued practice:

* `journalctl` for deeper log analysis
* `dig` for DNS troubleshooting
* `find` and `grep` for faster searching
* `systemctl` for service management
* `docker inspect` for container debugging
* `docker compose config` for Compose validation
* `ip` commands for routing and interface checks
* `netplan try` for safer remote network changes

## Notes

This document is a sanitized operational reference. It does not include raw shell history, credentials, tokens, SSH keys, private IPs, production paths, real `.env` values, or one-off personal commands.

The purpose is to show practical Linux command-line workflows in a safe and reusable way.

