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

CONFIG="$PREFIX/etc/starship.toml"
HOME_CONFIG="$HOME/.config/starship.toml"
mkdir -p "$(dirname "$CONFIG")" "$(dirname "$HOME_CONFIG")"

if [ -f "$CONFIG" ]; then
  echo "  $CONFIG already exists, leaving it untouched."
else
  echo "==> Writing gruvbox-rainbow preset to $CONFIG"
  "$BIN/starship" preset gruvbox-rainbow -o "$CONFIG"
fi

if [ -L "$HOME_CONFIG" ]; then
  ln -sfn "$CONFIG" "$HOME_CONFIG"
elif [ -e "$HOME_CONFIG" ]; then
  echo "  $HOME_CONFIG exists; setup_user_paths.sh will back it up and link $CONFIG."
else
  ln -s "$CONFIG" "$HOME_CONFIG"
fi

echo "    $("$BIN/starship" --version | head -1)"
