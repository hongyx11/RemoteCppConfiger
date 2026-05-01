#!/bin/bash
# Interactive setup for RemoteCppConfiger (prompts for your login password).
# Run as:    bash ~/setup_interactive.sh
#
# Why interactive: chsh authenticates via PAM and reads your password from a
# terminal, so it can't be driven by a non-interactive agent.

set -euo pipefail

ZSH=/usr/bin/zsh

current=$(getent passwd "$USER" | cut -d: -f7)
if [ "$current" = "$ZSH" ]; then
  echo "Login shell is already $ZSH. Nothing to do."
  exit 0
fi

echo "==> Changing login shell from $current to $ZSH"
echo "    (you'll be prompted for your login password)"
chsh -s "$ZSH"

echo
echo "Done. New login shell takes effect on next login."
echo "To switch in this terminal now, run: exec zsh"
