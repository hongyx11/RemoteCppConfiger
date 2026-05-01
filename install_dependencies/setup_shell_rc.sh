#!/bin/bash
# Idempotently wire the RemoteCppConfiger toolchain into bash and zsh rc files:
#   - PATH      : prepend $PREFIX/bin and $HOME/.local/bin (so nvim, clangd, etc. resolve)
#   - starship  : init for an interactive prompt
#   - atuin     : init for shell-history search
#   - spack     : source spack setup-env.sh if $SPACK_ROOT exists
#   - eza       : alias ls/ll/la to eza when available
#
# Writes a managed block bracketed by markers; on re-run the block is replaced
# in place so order is always: PATH → starship → atuin → spack → aliases.
# Legacy bare lines from older versions are also stripped to avoid duplicates.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"

BEGIN_MARK="# >>> RemoteCppConfiger >>>"
END_MARK="# <<< RemoteCppConfiger <<<"

block() {
  local shell="$1"
  cat <<EOF
$BEGIN_MARK
export PATH="\$HOME/local/bin:\$HOME/.local/bin:\$PATH"
command -v starship >/dev/null && eval "\$(starship init $shell)"
command -v atuin    >/dev/null && eval "\$(atuin init $shell)"
[ -f "$SPACK_ROOT/share/spack/setup-env.sh" ] && . "$SPACK_ROOT/share/spack/setup-env.sh"
command -v eza >/dev/null && alias ls='eza'
command -v eza >/dev/null && alias ll='eza -l --git'
command -v eza >/dev/null && alias la='eza -la --git'
$END_MARK
EOF
}

# Patterns that match individual lines from older versions of this script.
# We delete matches before writing the fresh block to avoid duplicates.
LEGACY_PATTERNS=(
  '^export PATH="\$HOME/local/bin'
  '^command -v starship >/dev/null && eval'
  '^command -v atuin .*&& eval'
  '^\[ -f ".*/spack/share/spack/setup-env\.sh" \]'
  "^command -v eza >/dev/null && alias l[sla]="
)

wire() {
  local rc="$1" shell="$2"
  echo "==> $rc"
  [ -f "$rc" ] || : > "$rc"

  # Drop any existing managed block.
  sed -i "/^${BEGIN_MARK}$/,/^${END_MARK}$/d" "$rc"

  # Drop legacy bare lines from older versions of this script.
  # `grep -v` exits 1 if every line matched (output empty); ignore that and
  # always replace the file so the deletion still happens in that case.
  for pat in "${LEGACY_PATTERNS[@]}"; do
    if grep -qE "$pat" "$rc"; then
      grep -vE "$pat" "$rc" > "$rc.tmp" || true
      mv "$rc.tmp" "$rc"
    fi
  done

  # Append the fresh block (separated from prior content by a blank line).
  [ -s "$rc" ] && printf '\n' >> "$rc"
  block "$shell" >> "$rc"

  echo "  wrote managed block"
}

wire "$HOME/.bashrc" bash
wire "$HOME/.zshrc"  zsh

echo
echo "Done. Open a new shell (or 'exec bash' / 'exec zsh') for changes to take effect."
