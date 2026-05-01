#!/bin/bash
# Source this before opening nvim to load the RemoteCppConfiger environment.
# Usage:
#   source ~/.config/nvim/install_dependencies/activate.sh
#   source ~/.config/nvim/install_dependencies/activate.sh && nvim

_PREFIX="${PREFIX:-$HOME/local}"

# ── PATH ────────────────────────────────────────────────
case ":$PATH:" in
  *":$_PREFIX/bin:"*) ;;
  *) export PATH="$_PREFIX/bin:$PATH" ;;
esac

# ── tool-specific env ───────────────────────────────────
export BAT_THEME="${BAT_THEME:-ansi}"
export EZA_COLORS="${EZA_COLORS:-da=36}"

# ── interactive aliases ─────────────────────────────────
if [[ $- == *i* ]]; then
  alias cat='bat --paging=never'
  alias ls='eza'
  alias ll='eza -l --git'
  alias la='eza -la --git'
  alias tree='eza --tree'
  alias lg='lazygit'
fi

unset _PREFIX
echo "RemoteCppConfiger environment activated."
