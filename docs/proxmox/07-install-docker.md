# Install Docker on Ubuntu Server

This note documents how I install Docker Engine on my Ubuntu Server VM.

I use Docker's official apt repository instead of the Ubuntu `docker.io` package, because this follows the official Docker installation method and gives me the Docker Compose plugin.

## Goal

Install Docker Engine, enable the Docker service, and verify that Docker works.

## 1. Remove conflicting packages

```bash
# Remove older or conflicting Docker-related packages if they exist
sudo apt remove docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc
```

It is okay if `apt` says some of these packages are not installed.

## 2. Add Docker's official apt repository

```bash
# Update package information
sudo apt update

# Install packages needed for HTTPS repositories and GPG keys
sudo apt install ca-certificates curl

# Create the keyrings directory if it does not already exist
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Allow apt to read the Docker GPG key
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

```bash
# Add Docker's official apt repository
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

```bash
# Update package information again after adding the Docker repository
sudo apt update
```

## 3. Install Docker Engine and Compose plugin

```bash
# Install Docker Engine, CLI, containerd, Buildx, and Docker Compose plugin
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 4. Check Docker service

```bash
# Check whether the Docker service is running
sudo systemctl status docker

# Start Docker if it is not running
sudo systemctl start docker

# Enable Docker so it starts automatically after reboot
sudo systemctl enable docker
```

## 5. Verify Docker works

```bash
# Run Docker's test container
sudo docker run hello-world

# Check Docker version
sudo docker --version

# Check Docker Compose plugin version
sudo docker compose version
```

If `hello-world` runs successfully, Docker is installed correctly.

## Optional: run Docker without sudo

```bash
# Add my user to the docker group
sudo usermod -aG docker "$USER"
```

After this, I need to log out and log back in for the group change to apply.

I only do this on systems where I understand the security tradeoff. Users in the `docker` group can effectively control containers on the host.

## Firewall note

Docker can publish container ports directly on the host. I need to be careful when exposing ports, because Docker networking can interact with firewall rules in ways that are easy to misunderstand.

Before exposing a service, I should check:

```bash
# Show running containers and published ports
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'

# Show listening ports on the host
sudo ss -tulpn
```

## Notes

For my lab, Docker is the base for Compose-managed services.

Before running important services, I should also document:

* where service data is stored
* whether the service uses a database
* how the service is backed up
* how the service can be restored
* which ports are exposed
* whether the service should be private or public

Reference: https://docs.docker.com/engine/install/ubuntu/
