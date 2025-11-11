#!/usr/bin/env bash
set -euo pipefail

# Telebit installer (previously pinggy)
# Installs telebit via upstream installer: curl https://get.telebit.io/ | bash

echo "Installing Telebit using upstream installer..."

if command -v curl >/dev/null 2>&1; then
	curl -fsSL https://get.telebit.io/ | bash
elif command -v wget >/dev/null 2>&1; then
	wget -qO- https://get.telebit.io/ | bash
else
	echo "Neither curl nor wget is available. Please install one and re-run this script." >&2
	exit 1
fi

echo "Telebit installer finished."

read -n1 -s -r -p $'\e[34mPress any key to return to main menu...\e[0m'
