#!/usr/bin/env bash
set -euo pipefail

# Top-level panel menu
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
CYAN=$'\e[36m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

while true; do
  clear
  echo -e "${CYAN}+---------------- Panel Menu ----------------+${RESET}"
  echo
  echo -e "${GREEN}1)${RESET} Pterodactyl"
  echo -e "${GREEN}2)${RESET} Puffer"
  echo -e "${GREEN}3)${RESET} Tery Panel"
  echo -e "${GREEN}4)${RESET} Draco Panel"
  echo -e "${GREEN}5)${RESET} Hydra Panel"
  echo
  echo -e "${RED}0)${RESET} Back"
  echo
  read -r -p $'\e[31mChoice [0-5]: \e[0m' choice
  case "$choice" in
    1)
      if [ -f "Script/game-panel/pterodactyl/pt-main.sh" ]; then
        bash "Script/game-panel/pterodactyl/pt-main.sh"
      else
        echo "Pterodactyl menu not found: Script/game-panel/pterodactyl/pt-main.sh"
        sleep 2
      fi
      ;;
    2)
      if [ -f "Script/game-panel/puffer/under-dev.sh" ]; then
        bash "Script/game-panel/puffer/under-dev.sh"
      else
        echo "Puffer script not found: Script/game-panel/puffer/under-dev.sh"
        sleep 2
      fi
      ;;
    3)
      if [ -f "Script/game-panel/tery/under.dev.sh" ]; then
        bash "Script/game-panel/tery/under.dev.sh"
      else
        echo "Tery script not found: Script/game-panel/tery/under.dev.sh"
        sleep 2
      fi
      ;;
    4)
      if [ -f "Script/game-panel/draco/under-dev.sh" ]; then
        bash "Script/game-panel/draco/under-dev.sh"
      else
        echo "Draco script not found: Script/game-panel/draco/under-dev.sh"
        sleep 2
      fi
      ;;
    5)
      if [ -f "Script/game-panel/hydra/under-dev.sh" ]; then
        bash "Script/game-panel/hydra/under-dev.sh"
      else
        echo "Hydra script not found: Script/game-panel/hydra/under-dev.sh"
        sleep 2
      fi
      ;;
    0)
      break
      ;;
    *)
      echo -e "${RED}Invalid choice${RESET}"
      sleep 1
      ;;
  esac
done
