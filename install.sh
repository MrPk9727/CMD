#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO="MrPk9727/CMD"
BRANCH="main" # The branch to scan (e.g., main, master)
API_URL="https://api.github.com/repos/$REPO/contents"
RAW_URL_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

err() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

# Check for curl
command -v curl >/dev/null || err "curl command required."
command -v jq >/dev/null || err "jq command required to parse API response. Please install it (e.g., sudo apt install jq)."

printf "🔍 Scanning repository %s on branch %s for .sh files...\n\n" "$REPO" "$BRANCH"

# --- Fetch and Parse File Paths ---
# Use the GitHub Contents API (recursive call is needed to find all files)
# We fetch the entire tree of files for the specified branch/SHA
API_TREE_URL="https://api.github.com/repos/$REPO/git/trees/$BRANCH?recursive=1"

# 1. Fetch the file tree structure from the API.
# 2. Use jq to filter objects where:
#    a) 'type' is 'blob' (a file).
#    b) 'path' ends with '.sh'.
# 3. Print the 'path' for each match.
FILE_PATHS=$(curl -fsSL "$API_TREE_URL" | \
  jq -r '.tree[] | select(.type=="blob" and (.path | endswith(".sh"))) | .path'
)

# --- Output Raw Links ---
if [ -z "$FILE_PATHS" ]; then
    printf "No .sh files found in the '%s' branch of %s.\n" "$BRANCH" "$REPO"
    exit 0
fi

printf "🔗 Found the following raw links:\n"
printf "%s\n" "$FILE_PATHS" | while read -r PATH_TO_FILE; do
    printf "%s/%s\n" "$RAW_URL_BASE" "$PATH_TO_FILE"
done

printf "\n✅ Link generation complete.\n"