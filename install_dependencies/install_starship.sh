#!/bin/bash
# Install starship prompt into $PREFIX/bin and apply the gruvbox-rainbow preset.
# No sudo, no interactive input.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

if [ -x "$BIN/starship" ]; then
  echo "  starship already installed, skipping binary install."
else
  echo "==> Installing starship → $BIN"
  curl -sS https://starship.rs/install.sh | sh -s -- -b "$BIN" -y
fi

CONFIG="$HOME/.config/starship.toml"
mkdir -p "$(dirname "$CONFIG")"
if [ -f "$CONFIG" ]; then
  echo "  $CONFIG already exists, leaving it untouched."
else
  echo "==> Writing gruvbox-rainbow preset to $CONFIG"
  "$BIN/starship" preset gruvbox-rainbow -o "$CONFIG"
fi

echo "    $("$BIN/starship" --version | head -1)"
