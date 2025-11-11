#!/usr/bin/env bash
set -euo pipefail

# MVM launcher (Powered by MrPk)
# - centered ASCII banner
# - centered boxed menu with left-aligned text
# - option numbers in blue, prompt in red
# - local-first execution of scripts under Script/ then fallback to GitHub raw

GITHUB_RAW_BASE="${GITHUB_RAW_BASE:-https://raw.githubusercontent.com/MrPk9727/CMD/main}"
MVM_DIR_LOCAL="Script"

# Color definitions (only enable in interactive TTY unless NO_COLOR=1)
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

strip_ansi() {
  # remove ANSI sequences for width calculations
  printf '%s' "$1" | sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

run_local_or_remote() {
  # $1 = path relative to repo root (e.g. Script/sys-info.sh)
  local relpath="$1"
  local localpath="$relpath"

  if [ -f "$localpath" ]; then
    # prefer local script
    bash "$localpath"
    return $?
  fi

  # fallback to remote
  url="$GITHUB_RAW_BASE/$relpath"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" | bash -s --
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url" | bash -s --
  else
    echo -e "${RED}Neither curl nor wget is available to fetch $url${RESET}"
    return 1
  fi
}

print_banner() {
  # Banner lines (content only, no side borders)
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

  if [ ! -t 1 ]; then
    for l in "${raw_lines[@]}"; do
      printf '%s\n' "| $l |"
    done
    return
  fi

  # compute max visible width (left-aligned)
  max=0
  for l in "${raw_lines[@]}"; do
    if [ ${#l} -gt $max ]; then max=${#l}; fi
  done
  inner_width=$((max + 2))

  for l in "${raw_lines[@]}"; do
    # choose color for content
    if [[ "$l" == *"MVM Menu"* ]]; then
      content="$BOLD$RED$l$RESET"
    elif [[ "$l" == *"Menu-based VPS helper"* ]]; then
      content="$YELLOW$l$RESET"
    elif [[ "$l" == *"Powered by MrPk"* ]]; then
      content="$BOLD$MAGENTA$l$RESET"
    else
      content="$CYAN$l$RESET"
    fi

    # compute visible length and right padding
    vis=$(strip_ansi "$l")
    vis_len=${#vis}
    pad_right=$((inner_width - vis_len - 1))

    printf '%b' "${CYAN}| ${RESET}"
    printf '%b' "$content"
    for _ in $(seq 1 $pad_right); do printf ' '; done
    printf '%b\n' " ${CYAN}|${RESET}"
  done
}

show_menu_boxed() {
  # Build menu lines (with ANSI for display)
  menu_lines=(
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

  # include a small header line
  header="${YELLOW}Select an option (1-14):${RESET}"

  # compute inner width (based on visible characters)
  max=0
  # check header
  s=$(strip_ansi "$header")
  if [ ${#s} -gt $max ]; then max=${#s}; fi
  for l in "${menu_lines[@]}"; do
    s=$(strip_ansi "$l")
    if [ ${#s} -gt $max ]; then max=${#s}; fi
  done

  pad_left=1
  pad_right=1
  inner_width=$((max + pad_left + pad_right))

  # Left-aligned box (no centering)
  offset=0

  # print top border (left-aligned)
  printf '%b' "${CYAN}+"
  for _ in $(seq 1 $inner_width); do printf '%b' "${CYAN}-"; done
  printf '%b\n' "${CYAN}+${RESET}"

  # print header line (use visible length for padding, but print with colors)
  visible_header=$(strip_ansi "$header")
  vis_len=${#visible_header}
  pad_right=$((inner_width - vis_len - 1))
  printf '%b' "${CYAN}| ${RESET}"
  printf '%b' "$header"
  for _ in $(seq 1 $pad_right); do printf ' '; done
  printf '%b\n' " ${CYAN}|${RESET}"

  # print each menu line left-aligned (print ANSI via %b, pad using visible length)
  for l in "${menu_lines[@]}"; do
    visible=$(strip_ansi "$l")
    vis_len=${#visible}
    pad_right=$((inner_width - vis_len - 1))
    printf '%b' "${CYAN}| ${RESET}"
    printf '%b' "$l"
    for _ in $(seq 1 $pad_right); do printf ' '; done
    printf '%b\n' " ${CYAN}|${RESET}"
  done

  # bottom border
  printf '%b' "${CYAN}+"
  for _ in $(seq 1 $inner_width); do printf '%b' "${CYAN}-"; done
  printf '%b\n' "${CYAN}+${RESET}"
}

main() {
  while true; do
    clear
    print_banner
    echo
    show_menu_boxed
    echo
    # red prompt
    read -r -p $'\e[31mChoice [1-14]: \e[0m' choice

    case "$choice" in
      1) run_local_or_remote "Script/setup.sh" ;;
      2) run_local_or_remote "Script/game-panel/panel-menu.sh" ;;
      3) run_local_or_remote "Script/Web-server/web-main.sh" ;;
      4) run_local_or_remote "Script/24-7.sh" ;;
      5) run_local_or_remote "Script/ipv4/ip-main.sh" ;;
      6) run_local_or_remote "Script/migrate/mag-main.sh" ;;
      7) run_local_or_remote "Script/cloudflare.sh" ;;
      8) run_local_or_remote "Script/sshx.sh" ;;
      9) run_local_or_remote "Script/rdp/rdp.sh" ;;
      10) run_local_or_remote "Script/Backup/dackup-main.sh" ;;
      11) run_local_or_remote "Script/sys-info.sh" ;;
      12) run_local_or_remote "Script/vps-hosting/vm-hosting-main.sh" ;;
      13) run_local_or_remote "Script/uninstall/un-main.sh" ;;
      14) echo -e "${CYAN}Goodbye.${RESET}"; exit 0 ;;
      *) echo -e "${RED}Invalid choice${RESET}"; sleep 1 ;;
    esac

    # small pause + press-any-key to return
    echo
    read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
  done
}

if [ "${BASH_SOURCE[0]:-}" = "$0" ]; then
  main "$@"
fi
#!/usr/bin/env bash
set -euo pipefail

# Main launcher for MVM (Powered by MrPk)
# Supports running local scripts in Script/mvm/ or fetching them from the repo raw URL via curl.

GITHUB_RAW_BASE="${GITHUB_RAW_BASE:-https://raw.githubusercontent.com/MrPk9727/CMD/main}"
MVM_DIR_LOCAL="Script/mvm"

# Color definitions (enabled only for interactive TTYs; disable with NO_COLOR=1)
if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ] 2>/dev/null; then
  RED="\e[31m"
  GREEN="\e[32m"
  YELLOW="\e[33m"
  BLUE="\e[34m"
  MAGENTA="\e[35m"
  CYAN="\e[36m"
  BOLD="\e[1m"
  RESET="\e[0m"
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

print_banner() {
  # Center the whole ASCII banner in the terminal and colorize the title in red
  raw_lines=(
    "=========================================|"
    "               MVM Menu                  |"
    "                                         |"
    "   Menu-based VPS helper / installer     |"
    "                                         |"
    "                       — Powered by MrPk |"
    "                                         |"
    "=========================================|"
  )

  # When not a TTY, print plain block
  if [ ! -t 1 ]; then
    for l in "${raw_lines[@]}"; do
      printf '%s\n' "$l"
    done
    return
  fi

  # compute the width and center offset
  cols=$(tput cols 2>/dev/null || echo 80)
  # printable max length (all lines same len here)
  max=0
  for l in "${raw_lines[@]}"; do
    if [ ${#l} -gt $max ]; then max=${#l}; fi
  done
  offset=$(( (cols - max) / 2 ))
  if [ $offset -lt 0 ]; then offset=0; fi

  # print each line with colors applied where desired
  for l in "${raw_lines[@]}"; do
    # apply color to specific lines
    if [[ "$l" == "               MVM Menu                  |" ]]; then
      colored="$BOLD$RED${l%|}$RESET |"
    elif [[ "$l" == "   Menu-based VPS helper / installer     |" ]]; then
      colored="$YELLOW${l%|}$RESET |"
    elif [[ "$l" == "                       — Powered by MrPk |" ]]; then
      colored="$BOLD$MAGENTA${l%|}$RESET |"
    else
      colored="$CYAN${l%|}$RESET |"
    fi
    # print offset spaces then the colored line
    printf '%*s' $offset ''
    # use printf with %b to expand color escapes
    printf '%b\n' "$colored"
  done
}

show_menu() {
  # Boxed menu: build array of lines to display inside the box
  print_banner

  lines=(
    "${YELLOW}Select an option (1-14):${RESET}"
    "${BLUE}1)${RESET} Setup"
    "${BLUE}2)${RESET} Game Panel"
    "${BLUE}3)${RESET} Web Server"
    "${BLUE}4)${RESET} 24/7 Uptime"
    "${BLUE}5)${RESET} ipv4"
    "${BLUE}6)${RESET} Migration"
    "${BLUE}7)${RESET} cloudflare"
    "${BLUE}8)${RESET} SSHX SSH"
    "${BLUE}9)${RESET} RDP"
    "${BLUE}10)${RESET} Backup"
    "${BLUE}11)${RESET} System Info"
    "${BLUE}12)${RESET} VPS Hosting"
    "${BLUE}13)${RESET} Uninstall"
    "${BLUE}14)${RESET} Exit"
  )

  # Compute the printable length of each line (strip ANSI for width calculation)
  strip_ansi() { printf '%s' "$1" | sed -r 's/\x1B\[[0-9;]*[mK]//g'; }

  max=0
  for l in "${lines[@]}"; do
    s=$(strip_ansi "$l")
    # length in characters
    len=${#s}
    if [ "$len" -gt "$max" ]; then
      max=$len
    fi
  done

  # Add padding (2 spaces each side)
  pad=4
  inner_width=$((max + pad))

  # Print top border
  # center the entire box horizontally when running in a TTY
  cols=$(tput cols 2>/dev/null || echo 80)
  total_box_width=$((inner_width + 2))
  offset=$(( (cols - total_box_width) / 2 ))
  if [ $offset -lt 0 ]; then offset=0; fi

  print_banner() {
    # Print a fixed ASCII-style banner (matches requested layout). Use colors in a TTY.
    if [ -t 1 ]; then
      echo -e "${CYAN}=========================================|${RESET}"
      echo -e "${BOLD}${GREEN}               MVM Menu                  |${RESET}"
      echo -e "${CYAN}                                         |${RESET}"
      echo -e "${YELLOW}   Menu-based VPS helper / installer     |${RESET}"
      echo -e "${CYAN}                                         |${RESET}"
      echo -e "${BOLD}${MAGENTA}                       — Powered by MrPk |${RESET}"
      echo -e "${CYAN}                                         |${RESET}"
      echo -e "${CYAN}=========================================|${RESET}"
    else
      cat <<'BANNER'
  =========================================|
                 MVM Menu                  |
                                           |
     Menu-based VPS helper / installer     |
                                           |
                         — Powered by MrPk |
                                           |
  =========================================|
  BANNER
    fi
  }
    clear
    show_menu
  # Prompt (red) — literal escape sequence used for exact color
  read -r -p $'\e[31mChoice [1-14]: \e[0m' choice

    case "$choice" in
      1) run_local_or_remote "Script/setup.sh" ;;
      2) run_local_or_remote "Script/game-panel/panel-menu.sh" ;;
      3) run_local_or_remote "Script/Web-server/web-main.sh" ;;
  4) run_local_or_remote "Script/24-7.sh" ;;
      5) run_local_or_remote "Script/ipv4/ip-main.sh" ;;
      6) run_local_or_remote "Script/migrate/mag-main.sh" ;;
      7) run_local_or_remote "Script/cloudflare.sh" ;;
      8) run_local_or_remote "Script/sshx.sh" ;;
      9) run_local_or_remote "Script/rdp/rdp.sh" ;;
      10) run_local_or_remote "Script/Backup/dackup-main.sh" ;;
      11) run_local_or_remote "Script/sys-info.sh" ;;
      12) run_local_or_remote "Script/vps-hosting/vm-hosting-main.sh" ;;
      13) run_local_or_remote "Script/uninstall/un-main.sh" ;;
      14) echo -e "${CYAN}Goodbye.${RESET}"; exit 0 ;;
      *) echo -e "${RED}Invalid choice${RESET}"; sleep 1 ;;
    esac
    # after an action, small pause so user sees message before menu redraws
    sleep 1
  done
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
