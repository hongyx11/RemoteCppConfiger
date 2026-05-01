#!/bin/bash
# Idempotently wire the RemoteCppConfiger toolchain into bash and zsh rc files:
#   - PATH      : prepend $PREFIX/bin (so nvim, clangd, etc. resolve)
#   - starship  : init for an interactive prompt
#   - atuin     : init for shell-history search
#
# Adds missing lines to ~/.bashrc and ~/.zshrc; creates ~/.zshrc if absent.
# Never duplicates lines and never touches anything outside those two files.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"

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
  ensure_line "$rc" "export PATH=\"\$HOME/local/bin:\$PATH\""
  ensure_line "$rc" "command -v starship >/dev/null && eval \"\$(starship init $shell)\""
  ensure_line "$rc" "command -v atuin    >/dev/null && eval \"\$(atuin init $shell)\""
}

wire "$HOME/.bashrc" bash
wire "$HOME/.zshrc"  zsh

echo
echo "Done. Open a new shell (or 'exec bash' / 'exec zsh') for changes to take effect."
