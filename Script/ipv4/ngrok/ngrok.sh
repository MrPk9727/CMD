#!/usr/bin/env bash
set -euo pipefail

# Install ngrok and add authtoken (minimal output)
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Installing ngrok (please wait)...${RESET}"
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null \
  && sudo apt update -qq >/dev/null 2>&1 \
  && sudo apt install -y ngrok >/dev/null 2>&1 || true

echo -e "${GREEN}ngrok installed.${RESET}"

read -r -p "Enter your ngrok authtoken (leave empty to skip): " token
if [ -n "$token" ]; then
  ngrok config add-authtoken "$token" >/dev/null 2>&1 || true
  echo -e "${GREEN}ngrok authtoken configured.${RESET}"
else
  echo "Skipped authtoken configuration. You can run: ngrok config add-authtoken <token>"
fi

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
