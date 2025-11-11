#!/usr/bin/env bash
set -euo pipefail

# Install cloudflared and prompt about service token
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Installing cloudflared (please wait)...${RESET}"
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
sudo apt-get update -qq >/dev/null 2>&1 || true
sudo apt-get install -y cloudflared >/dev/null 2>&1 || true

echo -e "${GREEN}cloudflared installed.${RESET}"
echo -e "${BLUE}Run Cloudflare Service Token to create credentials for tunnel or follow Cloudflare docs.${RESET}"

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
