#!/usr/bin/env bash
set -euo pipefail

# VPS hosting menu
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
CYAN=$'\e[36m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

while true; do
  clear
  echo -e "${BLUE}+------------------------------+${RESET}"
  echo -e "${BLUE}|${RESET} ${BOLD}VPS Hosting${RESET}               ${BLUE}|${RESET}"
  echo -e "${BLUE}+------------------------------+${RESET}"
  echo
  echo -e "${GREEN}1)${RESET} hvm"
  echo -e "${GREEN}2)${RESET} Discord Bot"
  echo
  echo -e "${RED}0)${RESET} Exit"
  echo
  read -r -p $'\e[31mChoice [0-2]: \e[0m' choice
  case "$choice" in
    1)
      if [ -f "Script/vps-hosting/hvm/hvm.sh" ]; then
        bash "Script/vps-hosting/hvm/hvm.sh"
      else
        echo "hvm script not found: Script/vps-hosting/hvm/hvm.sh"
        sleep 2
      fi
      ;;
    2)
      if [ -f "Script/vps-hosting/discord-bot/dis-bot.sh" ]; then
        bash "Script/vps-hosting/discord-bot/dis-bot.sh"
      else
        echo "discord bot installer not found: Script/vps-hosting/discord-bot/dis-bot.sh"
        sleep 2
      fi
      ;;
    0)
      echo -e "${CYAN}Returning...${RESET}"
      break
      ;;
    *)
      echo -e "${RED}Invalid choice${RESET}"
      sleep 1
      ;;
  esac
done
