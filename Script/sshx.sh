#!/usr/bin/env bash
set -euo pipefail

# Install sshx quietly and offer to run it
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; RED=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Please wait — installing sshx...${RESET}"
if curl -sSf https://sshx.io/get | sh >/dev/null 2>&1; then
  echo -e "${GREEN}sshx installed.${RESET}"
else
  echo -e "${RED}sshx installation failed.${RESET}"
fi

read -r -p "Run sshx now? [y/N]: " run_now
case "${run_now,,}" in
  y|yes)
    echo -e "${BLUE}Starting sshx...${RESET}"
    sshx || true
    ;;
  *) echo "Skipping run." ;;
esac

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
