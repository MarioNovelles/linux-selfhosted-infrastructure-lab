#!/usr/bin/env bash

# Exit immediately if a command fails, treat unset variables as errors,
# and make pipeline failures propagate properly.
set -euo pipefail

# Send all output to both the terminal and a log file so you can review it later.
#exec > >(tee -a ~/update-script.log) 2>&1

# If something fails, print the line number and the command that failed.
trap 'echo "FAILED at line $LINENO: $BASH_COMMAND"' ERR

# Show the updating sign
echo "============================================"
echo "============ UPDATING SYSTEM ==============="
echo "============================================"

# Print each command before running it, which makes debugging much easier.
set -x

# Update system packages
sudo apt update
sudo apt full-upgrade -y
sudo apt --fix-broken install -y
sudo dpkg --configure -a
sudo apt autoremove --purge -y
sudo apt autoclean -y
echo "System packages updated sucessfully."

# Show the updating sign setting set off and on to not show the echo part
set +x
echo "============================================"
echo "=========== UPDATING FLATPAKS =============="
echo "============================================"
set -x

# Update Flatpaks
flatpak update -y
flatpak uninstall --unused -y
flatpak repair
echo "Flatpaks updated sucessfully."

# Show the updating sign setting set off and on to not show the echo part
set +x
echo "============================================"
echo "========== UPDATING CONTAINERS ============="
echo "============================================"
set -x

# To update the templates and services of the searxng docker compose to their latest versions
cd ~/searxng
sudo docker compose down
curl -fsSLO \
  https://raw.githubusercontent.com/searxng/searxng/master/container/docker-compose.yml \
  https://raw.githubusercontent.com/searxng/searxng/master/container/.env.example
sudo docker compose pull
sudo docker compose up -d

# update opencode
# ghcr.io sometimes has connections timeouts when pulling an image
# this curl is a workaround to establish a successful IPv4 route first, before pulling the image
#curl -4 -v --connect-timeout 10 https://ghcr.io/v2/
#docker pull ghcr.io/anomalyco/opencode:latest

# Removes obsolete image
sudo docker image prune --force
echo "Containers updated sucessfully."

# Show the updating sign setting set off and on to not show the echo part
set +x
echo "============================================"
echo "======== UPDATING NVIM & LAZYVIM ==========="
echo "============================================"
set -x

# Update neovim and lazyvim
if pgrep -x nvim >/dev/null; then
  echo "Neovim is running, skipping update. Close it first."
  exit 1
fi
echo "Checking Neovim version..."
INSTALLED=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')
LATEST=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" |
  grep '"tag_name"' | grep -oP '\d+\.\d+\.\d+')

if [[ "$INSTALLED" == "$LATEST" ]]; then
  echo "Neovim is already up to date (v${INSTALLED})"
else
  echo "Updating Neovim: v${INSTALLED} → v${LATEST}"
  curl -L --progress-bar \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage" \
    -o /tmp/nvim.appimage
  chmod +x /tmp/nvim.appimage
  sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
  echo "Neovim updated!"
fi

echo "Updating plugins..."
nvim --headless "+Lazy! sync" +qa
echo "Neovim and Lazyvim updated sucessfully."

# Update opencode at the end, because it fails sometimes, and here doest stop the rest of the update
# and when i see it fails i can run it manually afterwards
docker pull ghcr.io/anomalyco/opencode:latest
# Show the updating sign setting set off and on to not show the echo part
set +x
echo "============================================"
echo "========== UPDATED SUCESSFULLY ============="
echo "============================================"
#set -x
