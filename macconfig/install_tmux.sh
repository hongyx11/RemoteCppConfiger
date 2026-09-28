#!/bin/bash
# Install Oh My Tmux (gpakosz/.tmux), copy ~/.tmux.conf, and link
# ~/.tmux.conf.local from the independent tmuxconfig checkout. Mirrors the Linux tmux installer.
# Tmux itself is provided by brew (declared in Brewfile).

set -euo pipefail

TMUX_DIR="$HOME/.tmux"
LOCAL_SRC="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf.local"
LOCAL_DST="$HOME/.tmux.conf.local"
TPM_DIR="$TMUX_DIR/plugins/tpm"

if [ ! -f "$LOCAL_SRC" ]; then
  echo "Missing tmuxconfig checkout: $LOCAL_SRC" >&2
  echo "Run ./configmgr clone tmuxconfig from the config manager first." >&2
  exit 1
fi

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

echo "==> Copying .tmux.conf → $HOME/.tmux.conf"
if [ -L "$HOME/.tmux.conf" ]; then
  rm "$HOME/.tmux.conf"
elif [ -e "$HOME/.tmux.conf" ]; then
  echo "  ~/.tmux.conf is a regular file; backing up to ~/.tmux.conf.bak.$$"
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$$"
fi
cp "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"

if [ -e "$LOCAL_DST" ] || [ -L "$LOCAL_DST" ]; then
  echo "  $LOCAL_DST already exists, leaving it untouched."
  echo "  Canonical customizations: $LOCAL_SRC"
else
  echo "==> Linking customizations from $LOCAL_SRC to $LOCAL_DST"
  ln -s "$LOCAL_SRC" "$LOCAL_DST"
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
