#!/usr/bin/env bash
# Fixed and cleaned MVM launcher (Powered by MrPk)

set -euo pipefail

# --- Configuration ---
GITHUB_RAW_BASE="${GITHUB_RAW_BASE:-https://raw.githubusercontent.com/MrPk9727/CMD/main}"
MVM_DIR_LOCAL="Script" # Directory for local scripts

# --- Color Definitions ---
# Only enable in interactive TTY unless NO_COLOR=1
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  RED=$'\e[31m'
  GREEN=$'\e[32m'
  YELLOW=$'\e[33m'
  BLUE=$'\e[34m'
  MAGENTA=$'\e[35m'
  CYAN=$'\e[36m'
  BOLD=$'\e[1m'
  RESET=$'\e[0m'
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  MAGENTA=""
  CYAN=""
  BOLD=""
  RESET=""
fi

# --- Helper Functions ---

strip_ansi() {
  # Remove ANSI sequences for visible width calculations
  printf '%s' "$1" | sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

run_local_or_remote() {
  # $1 = path relative to repo root (e.g. Script/sys-info.sh)
  local relpath="$1"
  local localpath="$relpath"

  echo -e "${CYAN}Attempting to run $localpath...${RESET}"

  if [ -f "$localpath" ]; then
    # Prefer local script
    bash "$localpath"
    return $?
  fi

  # Fallback to remote
  local url="$GITHUB_RAW_BASE/$relpath"
  if command -v curl >/dev/null 2>&1; then
    echo -e "${YELLOW}Local script not found. Fetching from remote (curl): $url${RESET}"
    curl -fsSL "$url" | bash -s --
  elif command -v wget >/dev/null 2>&1; then
    echo -e "${YELLOW}Local script not found. Fetching from remote (wget): $url${RESET}"
    wget -qO- "$url" | bash -s --
  else
    echo -e "${RED}Error: Neither curl nor wget is available to fetch $url${RESET}"
    return 1
  fi
}

print_banner() {
  # Banner lines (content only, no side borders)
  # Max length of content is 39 characters
  raw_lines=(
    "========================================="
    "               MVM Menu                  "
    "                                         "
    "   Menu-based VPS helper / installer     "
    "                                         "
    "                       — Powered by MrPk "
    "                                         "
    "========================================="
  )

  # Compute terminal width for centering
  cols=$(tput cols 2>/dev/null || echo 80)
  max_line_width=39 # Based on the raw content
  offset=$(( (cols - max_line_width - 4) / 2 )) # 4 for "| " and " |"
  if [ $offset -lt 0 ]; then offset=0; fi

  for l in "${raw_lines[@]}"; do
    # Apply color for content
    if [[ "$l" == *"MVM Menu"* ]]; then
      content="$BOLD$RED$l$RESET"
    elif [[ "$l" == *"Menu-based VPS helper"* ]]; then
      content="$YELLOW$l$RESET"
    elif [[ "$l" == *"Powered by MrPk"* ]]; then
      content="$BOLD$MAGENTA$l$RESET"
    else
      content="$CYAN$l$RESET"
    fi

    # Compute visible length and right padding
    vis_len=${#l} # Raw length for padding
    pad_right=$((max_line_width - vis_len))

    printf '%*s' $offset '' # Centering offset
    printf '%b' "${CYAN}| ${RESET}" # Left border
    printf '%b' "$content"
    for _ in $(seq 1 $pad_right); do printf ' '; done
    printf '%b\n' " ${CYAN}|${RESET}" # Right border
  done
}

show_menu_boxed() {
  # Build menu lines (with ANSI for display)
  menu_lines=(
    "${YELLOW}Select an option (1-14):${RESET}"
    "${BLUE}1)${RESET} ${GREEN}Setup${RESET}"
    "${BLUE}2)${RESET} ${GREEN}Game Panel${RESET}"
    "${BLUE}3)${RESET} ${GREEN}Web Server${RESET}"
    "${BLUE}4)${RESET} ${GREEN}24/7 Uptime${RESET}"
    "${BLUE}5)${RESET} ${GREEN}ipv4${RESET}"
    "${BLUE}6)${RESET} ${GREEN}Migration${RESET}"
    "${BLUE}7)${RESET} ${GREEN}cloudflare${RESET}"
    "${BLUE}8)${RESET} ${GREEN}SSHX SSH${RESET}"
    "${BLUE}9)${RESET} ${GREEN}RDP${RESET}"
    "${BLUE}10)${RESET} ${GREEN}Backup${RESET}"
    "${BLUE}11)${RESET} ${GREEN}System Info${RESET}"
    "${BLUE}12)${RESET} ${GREEN}VPS Hosting${RESET}"
    "${BLUE}13)${RESET} ${RED}Uninstall${RESET}"
    "${BLUE}14)${RESET} ${RED}Exit${RESET}"
  )

  # compute inner width (based on maximum visible characters)
  max=0
  for l in "${menu_lines[@]}"; do
    s=$(strip_ansi "$l")
    if [ ${#s} -gt $max ]; then max=${#s}; fi
  done

  pad_left=1
  pad_right=1
  inner_width=$((max + pad_left + pad_right))

  # Compute terminal width for centering
  cols=$(tput cols 2>/dev/null || echo 80)
  total_box_width=$((inner_width + 2)) # +2 for the side borders
  offset=$(( (cols - total_box_width) / 2 ))
  if [ $offset -lt 0 ]; then offset=0; fi

  # print top border
  printf '%*s' $offset ''
  printf '%b' "${CYAN}+"
  for _ in $(seq 1 $inner_width); do printf '%b' "${CYAN}-"; done
  printf '%b\n' "${CYAN}+${RESET}"

  # print each menu line centered
  for l in "${menu_lines[@]}"; do
    visible=$(strip_ansi "$l")
    vis_len=${#visible}
    pad_right_calc=$((inner_width - vis_len - pad_left)) # pad_left is 1

    printf '%*s' $offset '' # Centering offset
    printf '%b' "${CYAN}|${RESET}" # Left border
    printf ' ' # Left padding space
    printf '%b' "$l"
    for _ in $(seq 1 $pad_right_calc); do printf ' '; done
    printf '%b\n' "${CYAN}|${RESET}" # Right border
  done

  # bottom border
  printf '%*s' $offset ''
  printf '%b' "${CYAN}+"
  for _ in $(seq 1 $inner_width); do printf '%b' "${CYAN}-"; done
  printf '%b\n' "${CYAN}+${RESET}"
}

# --- Main Logic ---
main() {
  while true; do
    clear
    print_banner
    echo
    show_menu_boxed
    echo

    # Read choice with red prompt
    # Note: Using $'\e[31m...\e[0m' instead of variables in read -p is more reliable in some shells
    read -r -p $'\e[31mChoice [1-14]: \e[0m' choice

    # Define script paths to run based on choice
    local script_path=""
    case "$choice" in
      1) script_path="Script/setup.sh" ;;
      2) script_path="Script/game-panel/panel-menu.sh" ;;
      3) script_path="Script/Web-server/web-main.sh" ;;
      4) script_path="Script/24-7.sh" ;;
      5) script_path="Script/ipv4/ip-main.sh" ;;
      6) script_path="Script/migrate/mag-main.sh" ;;
      7) script_path="Script/cloudflare.sh" ;;
      8) script_path="Script/sshx.sh" ;;
      9) script_path="Script/rdp/rdp.sh" ;;
      10) script_path="Script/Backup/dackup-main.sh" ;;
      11) script_path="Script/sys-info.sh" ;;
      12) script_path="Script/vps-hosting/vm-hosting-main.sh" ;;
      13) script_path="Script/uninstall/un-main.sh" ;;
      14) echo -e "${CYAN}Goodbye.${RESET}"; exit 0 ;;
      *) echo -e "${RED}Invalid choice: $choice${RESET}"; sleep 1; continue ;;
    esac

    # Execute the selected script
    run_local_or_remote "$script_path"

    # Small pause + press-any-key to return, in blue
    echo
    # Using $'\e[34m...\e[0m' for blue color in prompt
    read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
  done
}

if [ "${BASH_SOURCE[0]:-}" = "$0" ]; then
  main "$@"
fi