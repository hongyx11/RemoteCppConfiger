#!/bin/bash
# Install Maple Mono NF into $HOME/.local/share/fonts and refresh the cache.
# No sudo. The font is rendered by the local terminal emulator, so the host
# this script runs on is the host that needs it.
#
# Override the version with: MAPLE_MONO_VER=v7.9 ./install_fonts.sh

set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts/MapleMono-NF"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if fc-list 2>/dev/null | grep -qi "Maple Mono NF"; then
  echo "  Maple Mono NF already registered with fontconfig, skipping."
  exit 0
fi

ver="${MAPLE_MONO_VER:-}"
if [ -z "$ver" ]; then
  json=$(curl -fsSL "https://api.github.com/repos/subframe7536/maple-font/releases/latest")
  ver=$(printf '%s\n' "$json" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
fi
if [ -z "$ver" ]; then
  echo "ERROR: could not resolve Maple Mono release tag." >&2
  exit 1
fi

echo "==> Downloading MapleMono-NF $ver"
curl -fL --retry 3 -o "$TMP/MapleMono-NF.zip" \
  "https://github.com/subframe7536/maple-font/releases/download/$ver/MapleMono-NF.zip"

echo "==> Extracting → $FONT_DIR"
mkdir -p "$FONT_DIR"
unzip -o -q "$TMP/MapleMono-NF.zip" -d "$FONT_DIR"

echo "==> Rebuilding font cache"
fc-cache -f "$HOME/.local/share/fonts"

faces=$(fc-list | grep -ci "maple mono nf" || true)
echo "    $faces Maple Mono NF face(s) registered"
