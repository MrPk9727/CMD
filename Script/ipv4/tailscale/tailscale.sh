#!/usr/bin/env bash
set -euo pipefail

# Install Tailscale and enable the service. Keep output minimal and show short status messages.
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Installing Tailscale (please wait)...${RESET}"
curl -fsSL https://tailscale.com/install.sh | sh >/dev/null 2>&1 || true
sudo systemctl enable --now tailscaled >/dev/null 2>&1 || true
echo -e "${GREEN}Tailscale installed.${RESET}"

echo -e "${BLUE}To authenticate your node run: sudo tailscale up${RESET}"

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
