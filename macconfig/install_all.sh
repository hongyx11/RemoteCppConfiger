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
run "OpenCode CLI"   install_opencode.sh
run "Spack"          install_spack.sh
run "Tmux (Oh My Tmux)" install_tmux.sh

echo
echo "Neovim and Zellij configs are managed separately:"
echo "  https://github.com/hongyx11/nvimconfig"
echo "  https://github.com/hongyx11/zellijconfig"
echo "Use configmgr to clone them into your config directory."

run "Shell rc"       setup_shell_rc.sh

echo
echo "============================================"
echo " Done."
echo
echo " Open a new shell (or 'exec zsh') for shell rc changes to take effect."
echo "============================================"
