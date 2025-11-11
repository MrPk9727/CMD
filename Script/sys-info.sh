#!/usr/bin/env bash
set -euo pipefail

# Minimal system-info helper — installs neofetch quietly, runs it, then returns to menu
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Please wait — installing neofetch...${RESET}"
sudo apt-get update -qq >/dev/null 2>&1 || true
sudo apt-get install -y neofetch >/dev/null 2>&1
echo -e "${GREEN}neofetch installed.${RESET}"

# Show system info
neofetch || true

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
