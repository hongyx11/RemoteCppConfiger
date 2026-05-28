#!/bin/bash
# RemoteCppConfiger — install all mac dev dependencies via Homebrew.
#
# Prereqs: Homebrew (https://brew.sh), Xcode Command Line Tools (for git).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

command -v brew >/dev/null || {
  echo "Install Homebrew first: https://brew.sh" >&2
  exit 1
}

echo "============================================"
echo " RemoteCppConfiger mac install"
echo " Brew prefix: $(brew --prefix)"
echo "============================================"

run() {
  local label="$1" script="$2"
  echo
  echo "---- $label ----"
  bash "$SCRIPT_DIR/$script"
}

echo
echo "---- brew update ----"
brew update

echo
echo "---- brew bundle ----"
brew bundle --file="$SCRIPT_DIR/Brewfile"

run "Rust toolchain" install_rust.sh
run "Python (uv)"    install_python.sh
run "Python CLI tools" install_python_tools.sh
run "Spack"          install_spack.sh
run "Tmux (Oh My Tmux)" install_tmux.sh

echo
echo "---- Zellij config ----"
ZELLIJ_CONFIG_SRC="$REPO_ROOT/shared/zellij/config.kdl"
ZELLIJ_CONFIG_DST="$HOME/.config/zellij/config.kdl"
mkdir -p "$(dirname "$ZELLIJ_CONFIG_DST")"
if [ -e "$ZELLIJ_CONFIG_DST" ] || [ -L "$ZELLIJ_CONFIG_DST" ]; then
  bak="$ZELLIJ_CONFIG_DST.bak.$(date +%Y%m%d-%H%M%S)"
  echo "  $ZELLIJ_CONFIG_DST exists; moving to $bak"
  mv "$ZELLIJ_CONFIG_DST" "$bak"
fi
echo "==> Copying $ZELLIJ_CONFIG_SRC → $ZELLIJ_CONFIG_DST"
cp "$ZELLIJ_CONFIG_SRC" "$ZELLIJ_CONFIG_DST"

echo
echo "---- Neovim config ----"
NVIM_CONFIG_SRC="$REPO_ROOT/nvimconfig"
NVIM_CONFIG_DST="$HOME/.config/nvim"
mkdir -p "$(dirname "$NVIM_CONFIG_DST")"
if [ -L "$NVIM_CONFIG_DST" ]; then
  echo "  $NVIM_CONFIG_DST is a symlink; removing it before copy."
  rm "$NVIM_CONFIG_DST"
elif [ -e "$NVIM_CONFIG_DST" ]; then
  bak="$NVIM_CONFIG_DST.bak.$(date +%Y%m%d-%H%M%S)"
  echo "  $NVIM_CONFIG_DST exists; moving to $bak"
  mv "$NVIM_CONFIG_DST" "$bak"
fi
echo "==> Copying $NVIM_CONFIG_SRC → $NVIM_CONFIG_DST"
cp -R "$NVIM_CONFIG_SRC" "$NVIM_CONFIG_DST"

run "Shell rc"       setup_shell_rc.sh

echo
echo "============================================"
echo " Done."
echo
echo " Open a new shell (or 'exec zsh') for shell rc changes to take effect."
echo "============================================"
