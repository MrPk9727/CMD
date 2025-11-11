#!/usr/bin/env bash
set -euo pipefail

# Install playit.gg client and run it (minimal output)
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

echo -e "${YELLOW}Installing playit (please wait)...${RESET}"
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list >/dev/null
sudo apt update -qq >/dev/null 2>&1 || true
sudo apt install -y playit >/dev/null 2>&1 || true

echo -e "${GREEN}playit installed.${RESET}"

read -r -p "Run 'playit' now? [y/N]: " runit
case "${runit,,}" in
  y|yes)
    echo -e "${BLUE}Starting playit...${RESET}"
    playit  || true
    ;;
  *) echo "Skipped starting playit." ;;
esac

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
