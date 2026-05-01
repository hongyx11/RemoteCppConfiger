#!/bin/bash
# Idempotently wire the RemoteCppConfiger toolchain into bash and zsh rc files:
#   - PATH      : prepend $PREFIX/bin and $HOME/.local/bin (so nvim, clangd, etc. resolve)
#   - starship  : init for an interactive prompt
#   - atuin     : init for shell-history search
#   - spack     : source spack setup-env.sh if $SPACK_ROOT exists
#   - eza       : alias ls/ll/la to eza when available
#
# Adds missing lines to ~/.bashrc and ~/.zshrc; creates ~/.zshrc if absent.
# Never duplicates lines and never touches anything outside those two files.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"

ensure_line() {
  local file="$1" line="$2"
  if [ ! -f "$file" ]; then
    : > "$file"
  fi
  if ! grep -qxF "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
    echo "  + $file: $line"
  fi
}

wire() {
  local rc="$1" shell="$2"
  echo "==> $rc"
  ensure_line "$rc" "export PATH=\"\$HOME/local/bin:\$HOME/.local/bin:\$PATH\""
  ensure_line "$rc" "command -v starship >/dev/null && eval \"\$(starship init $shell)\""
  ensure_line "$rc" "command -v atuin    >/dev/null && eval \"\$(atuin init $shell)\""
  ensure_line "$rc" "[ -f \"$SPACK_ROOT/share/spack/setup-env.sh\" ] && . \"$SPACK_ROOT/share/spack/setup-env.sh\""
  ensure_line "$rc" "command -v eza >/dev/null && alias ls='eza'"
  ensure_line "$rc" "command -v eza >/dev/null && alias ll='eza -l --git'"
  ensure_line "$rc" "command -v eza >/dev/null && alias la='eza -la --git'"
}

wire "$HOME/.bashrc" bash
wire "$HOME/.zshrc"  zsh

echo
echo "Done. Open a new shell (or 'exec bash' / 'exec zsh') for changes to take effect."
