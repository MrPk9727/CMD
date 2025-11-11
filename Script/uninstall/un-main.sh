#!/usr/bin/env bash
set -euo pipefail

# Simple uninstaller menu for components installed by this project
RED=$'\e[31m'
GREEN=$'\e[32m'
CYAN=$'\e[36m'
RESET=$'\e[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while true; do
  clear
  echo -e "${CYAN}+---------------- Uninstall ----------------+${RESET}"
  echo
  echo -e "${GREEN}1)${RESET} Remove vps-bot-hosting (directory: vps-bot-hosting)"
  echo -e "${GREEN}2)${RESET} Remove 24 folder (directory: 24)"
  echo -e "${GREEN}3)${RESET} Remove installed python packages (python3/pip) via apt"
  echo
  echo -e "${RED}0)${RESET} Return"
  echo
  read -r -p $'\e[31mChoice [0-3]: \e[0m' choice
  case "$choice" in
    1)
      dir="$ROOT_DIR/vps-bot-hosting"
      if [ -d "$dir" ]; then
        read -r -p "Delete $dir ? [y/N]: " yn
        if [[ "$yn" =~ ^[Yy]$ ]]; then
          sudo rm -rf "$dir"
          echo "Removed $dir"
        else
          echo "Skipped"
        fi
      else
        echo "Directory not found: $dir"
      fi
      read -n1 -s -r -p $'Press any key to continue...'
      ;;
    2)
      dir="$ROOT_DIR/24"
      if [ -d "$dir" ]; then
        read -r -p "Delete $dir ? [y/N]: " yn
        if [[ "$yn" =~ ^[Yy]$ ]]; then
          sudo rm -rf "$dir"
          echo "Removed $dir"
        else
          echo "Skipped"
        fi
      else
        echo "Directory not found: $dir"
      fi
      read -n1 -s -r -p $'Press any key to continue...'
      ;;
    3)
      echo "This will remove python3 and python3-pip via apt (if installed)."
      read -r -p "Continue? [y/N]: " yn
      if [[ "$yn" =~ ^[Yy]$ ]]; then
        if command -v apt-get >/dev/null 2>&1; then
          sudo apt-get remove -y python3 python3-pip || true
          sudo apt-get autoremove -y || true
          echo "Removed python3 and pip (if present)."
        else
          echo "apt-get not available on this system. Skipping.";
        fi
      else
        echo "Skipped"
      fi
      read -n1 -s -r -p $'Press any key to continue...'
      ;;
    0)
      break
      ;;
    *)
      echo -e "${RED}Invalid choice${RESET}"; sleep 1
      ;;
  esac
done
