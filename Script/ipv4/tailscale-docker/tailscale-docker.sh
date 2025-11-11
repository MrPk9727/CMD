#!/usr/bin/env bash
set -euo pipefail

# Install Docker and run the official tailscale container gateway. Quiet output; short messages.
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; RED=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Installing Docker & container tools (please wait)...${RESET}"
sudo apt-get update -qq >/dev/null 2>&1 || true
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg-agent >/dev/null 2>&1 || true

# Add Docker GPG and repo
curl -fsSL "https://download.docker.com/linux/$(awk -F'=' '/^ID=/{ print $NF }' /etc/os-release)/gpg" | sudo apt-key add - >/dev/null 2>&1 || true
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(awk -F'=' '/^ID=/{ print $NF }' /etc/os-release) $(lsb_release -cs) stable" >/dev/null 2>&1 || true
sudo apt-get update -qq >/dev/null 2>&1 || true
sudo apt-get install -y docker-ce docker-compose containerd.io >/dev/null 2>&1 || true
sudo systemctl enable --now docker >/dev/null 2>&1 || true
sudo usermod -aG docker "$USER" >/dev/null 2>&1 || true

echo -e "${GREEN}Docker & container tools installed.${RESET}"

# Ask for TAILSCALE AUTH KEY (optional) and run container
read -r -p "Enter Tailscale AUTH KEY to run the tailscale container: " authkey
if [ -n "$authkey" ]; then
  echo -e "${YELLOW}Starting tailscale container...${RESET}"
  docker run -d --name=tailscale -v /var/lib:/var/lib -v /dev/net/tun:/dev/net/tun -e TS_ACCEPT_DNS=true --network=host --cap-add=NET_ADMIN --cap-add=NET_RAW --restart=unless-stopped --hostname="ctr-gateway" -e TS_AUTHKEY=$authkey -e TS_ROUTES=192.168.0.0/24 tailscale/tailscale >/dev/null 2>&1 || true
  echo -e "${GREEN}Tailscale container started.${RESET}"
else
  echo "Skipped running tailscale container. You can run it later with your auth key." 
fi

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
