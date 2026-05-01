#!/bin/bash
# Install Maple Mono Nerd Font on mac via brew cask.
# Convenience standalone runner — same effect as `brew bundle` over the Brewfile.

set -euo pipefail

CASK="font-maple-mono-nf"

if brew list --cask "$CASK" >/dev/null 2>&1; then
  echo "  $CASK already installed, skipping."
else
  echo "==> brew install --cask $CASK"
  brew install --cask "$CASK"
fi
