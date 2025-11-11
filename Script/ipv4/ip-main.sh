#!/usr/bin/env bash
set -euo pipefail

# Small IPv4/tools menu that dispatches to sub-scripts in Script/ipv4/
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; BLUE="\e[34m"; RESET="\e[0m"
else
  GREEN=""; YELLOW=""; CYAN=""; BLUE=""; RESET=""
fi

clear

base="Script/ipv4"

echo -e "${CYAN}IPv4 / Tunneling menu${RESET}"
echo -e "${YELLOW}1)${RESET} tailscale"
echo -e "${YELLOW}2)${RESET} tailscale (docker)"
echo -e "${YELLOW}3)${RESET} ngrok"
echo -e "${YELLOW}4)${RESET} telebit"
echo -e "${YELLOW}5)${RESET} playit.gg"
echo -e "${YELLOW}0)${RESET} Return to main menu"

read -r -p "$(echo -e "${YELLOW}Choice [0-5]: ${RESET}")" c
case "$c" in
  1) bash "${base}/tailscale/tailscale.sh" ;;
  2) bash "${base}/tailscale-docker/tailscale-docker.sh" ;;
  3) bash "${base}/ngrok/ngrok.sh" ;;
  4) bash "${base}/telebit/telebit.sh" ;;
  5) bash "${base}/playitgg/playitgg.sh" ;;
  0) ;; # return
  *) echo -e "${GREEN}Invalid choice${RESET}" ;;
esac

echo
read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
echo
