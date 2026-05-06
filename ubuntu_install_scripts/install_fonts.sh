#!/bin/bash
# Install Maple Mono NF into $PREFIX/share/fonts and symlink it into
# $HOME/.local/share/fonts for fontconfig.
# No sudo. The font is rendered by the local terminal emulator, so the host
# this script runs on is the host that needs it.
#
# Override the version with: MAPLE_MONO_VER=v7.9 ./install_fonts.sh

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
FONT_DIR="$PREFIX/share/fonts/MapleMono-NF"
HOME_FONT_DIR="$HOME/.local/share/fonts/MapleMono-NF"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

FONT_LIST="$TMP/font-list.txt"
fc-list > "$FONT_LIST" 2>/dev/null || : > "$FONT_LIST"

if grep -qi "Maple Mono NF" "$FONT_LIST"; then
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

mkdir -p "$(dirname "$HOME_FONT_DIR")"
if [ -L "$HOME_FONT_DIR" ]; then
  ln -sfn "$FONT_DIR" "$HOME_FONT_DIR"
elif [ -e "$HOME_FONT_DIR" ] && [ "$HOME_FONT_DIR" != "$FONT_DIR" ]; then
  mv "$HOME_FONT_DIR" "$HOME_FONT_DIR.bak.$$"
  ln -s "$FONT_DIR" "$HOME_FONT_DIR"
else
  ln -s "$FONT_DIR" "$HOME_FONT_DIR"
fi

echo "==> Rebuilding font cache"
fc-cache -f "$HOME/.local/share/fonts"

fc-list > "$FONT_LIST" 2>/dev/null || : > "$FONT_LIST"
faces=$(grep -ci "maple mono nf" "$FONT_LIST" || true)
echo "    $faces Maple Mono NF face(s) registered"
