#!/usr/bin/env bash
set -euo pipefail

REPO="MrPk9727/CMD"
BINARY_NAME="MRPK"   # binary name inside released archive
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

err() { printf '%s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || err "curl required"
TMPDIR="$(mktemp -d)"
cleanup(){ rm -rf "$TMPDIR"; }
trap cleanup EXIT

# detect os/arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARCH="x86_64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) err "unsupported arch: $ARCH" ;;
esac

# pick asset from latest release
ASSET_URL="$(curl -fsSL "$GITHUB_API" | \
  grep -E 'browser_download_url' | \
  sed -E 's/.*"([^"]+)".*/\1/' | \
  grep "$OS" | grep "$ARCH" | head -n1)"

[ -n "$ASSET_URL" ] || err "no release asset found for $OS-$ARCH"

cd "$TMPDIR"
curl -fsSL -o asset.tar.gz "$ASSET_URL"
tar -xzf asset.tar.gz || { # try zip fallback
  unzip -q asset.tar.gz || err "failed to extract"
}
# adjust path if archive contains folder
if [ -f "$BINARY_NAME" ]; then
  BIN_PATH="$BINARY_NAME"
else
  BIN_PATH="$(find . -maxdepth 2 -type f -name "$BINARY_NAME" | head -n1)"
fi
[ -f "$BIN_PATH" ] || err "binary $BINARY_NAME not found in archive"

sudo install -m 0755 "$BIN_PATH" /usr/local/bin/"$BINARY_NAME"
printf 'Installed %s to /usr/local/bin/%s\n' "$BINARY_NAME" "$BINARY_NAME"