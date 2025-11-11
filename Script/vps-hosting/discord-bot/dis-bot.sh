#!/usr/bin/env bash
set -euo pipefail

# Simple Discord bot installer/runner for vps-bot-hosting
REPO_URL="https://github.com/MrPk9727/vps-bot-hosting.git"
CLONE_DIR="vps-bot-hosting"

echo "Cloning/updating repository..."
if [ -d "$CLONE_DIR/.git" ]; then
  git -C "$CLONE_DIR" pull --ff-only || true
else
  git clone "$REPO_URL" "$CLONE_DIR"
fi

cd "$CLONE_DIR"

if [ -f requirements.txt ]; then
  echo "installing python"
  python3 -m pip install --upgrade pip setuptools wheel
  echo "adding bot"
  python3 -m pip install -r requirements.txt
else
  echo "installing python"
  # still attempt to upgrade pip; if python3 missing this will fail
  python3 -m pip install --upgrade pip setuptools wheel || true
  echo "adding bot (no requirements.txt found, skipping pip install)"
fi

echo "Provide Your Details"
echo "Now please provide values for the bot .env file. Press Enter to leave blank."
read -r -p "Discord bot Token: " DISCORD_TOKEN
read -r -p "Owner User ID: " ADMIN_IDS
read -r -p "Admin role ID: " ADMIN_ROLE_ID

ENV_FILE=".env"
touch "$ENV_FILE"

set_kv() {
  key="$1"; val="$2"
  if grep -qE "^${key}=" "$ENV_FILE" 2>/dev/null; then
    sed -i -E "s/^${key}=.*/${key}=${val}/" "$ENV_FILE"
  else
    printf "%s=%s\n" "$key" "$val" >> "$ENV_FILE"
  fi
}

if [ -n "$DISCORD_TOKEN" ]; then
  set_kv "DISCORD_TOKEN" "$DISCORD_TOKEN"
fi
if [ -n "$ADMIN_IDS" ]; then
  set_kv "ADMIN_IDS" "$ADMIN_IDS"
fi
if [ -n "$ADMIN_ROLE_ID" ]; then
  set_kv "ADMIN_ROLE_ID" "$ADMIN_ROLE_ID"
fi

echo "Starting bot (foreground). Use Ctrl-C to stop."
python3 bot.py
