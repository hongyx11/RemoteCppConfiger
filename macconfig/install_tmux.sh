#!/bin/bash
# Install Oh My Tmux (gpakosz/.tmux), symlink ~/.tmux.conf, and seed
# ~/.tmux.conf.local from shared/tmux/. Mirrors the Linux tmux installer.
# Tmux itself is provided by brew (declared in Brewfile).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMUX_DIR="$HOME/.tmux"
LOCAL_SRC="$REPO_ROOT/shared/tmux/tmux.conf.local"
LOCAL_DST="$HOME/.tmux.conf.local"
TPM_DIR="$TMUX_DIR/plugins/tpm"

if ! command -v tmux >/dev/null 2>&1; then
  echo "  warning: 'tmux' not found on PATH. Install it via brew, then re-run."
fi

if [ -d "$TMUX_DIR/.git" ]; then
  echo "  $TMUX_DIR already a git repo, skipping clone."
else
  echo "==> Cloning Oh My Tmux → $TMUX_DIR"
  if [ -e "$TMUX_DIR" ]; then
    echo "  $TMUX_DIR exists but is not a git repo; moving aside to $TMUX_DIR.bak.$$"
    mv "$TMUX_DIR" "$TMUX_DIR.bak.$$"
  fi
  git clone --depth 1 https://github.com/gpakosz/.tmux.git "$TMUX_DIR"
fi

echo "==> Linking ~/.tmux.conf → $TMUX_DIR/.tmux.conf"
if [ -L "$HOME/.tmux.conf" ]; then
  ln -snf "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
elif [ -e "$HOME/.tmux.conf" ]; then
  echo "  ~/.tmux.conf is a regular file; backing up to ~/.tmux.conf.bak.$$"
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$$"
  ln -s "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
else
  ln -s "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

if [ -e "$LOCAL_DST" ]; then
  echo "  $LOCAL_DST already exists, leaving it untouched."
else
  echo "==> Writing bundled customizations to $LOCAL_DST"
  cp "$LOCAL_SRC" "$LOCAL_DST"
fi

if [ -d "$TPM_DIR/.git" ]; then
  echo "  TPM already installed at $TPM_DIR, skipping clone."
else
  echo "==> Cloning TPM → $TPM_DIR"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  echo "==> Installing TPM plugins"
  "$TPM_DIR/bin/install_plugins" || echo "  (TPM install_plugins exited non-zero; usually safe to ignore)"
fi

echo "    tmux config ready. Reload inside tmux with: prefix + r"
