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
echo "System packages updated sucessfully"

# Show the updating sign setting set off and on to not show the echo part
set +x
echo "============================================"
echo "========== UPDATED SUCESSFULLY ============="
echo "============================================"
#set -x
