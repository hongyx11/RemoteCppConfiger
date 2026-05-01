#!/bin/bash
# Install/refresh the RemoteCppConfiger managed block in ~/.bashrc and ~/.zshrc.
# Usage: setup.sh <linux|mac>
#
# Idempotent. Re-running replaces the managed block in place. Legacy bare lines
# from older versions of the Linux installer are stripped before re-write.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <linux|mac>" >&2
  exit 64
fi

PLATFORM="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"

BEGIN_MARK="# >>> RemoteCppConfiger >>>"
END_MARK="# <<< RemoteCppConfiger <<<"

# Patterns that match individual lines from older versions of setup_shell_rc.sh.
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

  # Render first. If render fails (missing template, bad PLATFORM, etc.), the
  # rc file is left untouched.
  local rendered
  rendered=$(bash "$DIR/render.sh" "$PLATFORM" "$shell") || return 1

  [ -f "$rc" ] || : > "$rc"

  # Detect a malformed managed block: an opening marker without a closing one.
  # In that state, the sed range below would delete from BEGIN to EOF and
  # silently drop user content. Refuse to proceed.
  if grep -q "^${BEGIN_MARK}$" "$rc" && ! grep -q "^${END_MARK}$" "$rc"; then
    echo "  WARNING: $rc has an opening managed-block marker (${BEGIN_MARK})" >&2
    echo "  but no matching closing marker. Refusing to proceed to avoid data" >&2
    echo "  loss. Inspect the file, remove or close the orphan, then re-run." >&2
    return 1
  fi

  # Drop any existing managed block. -i.bak form is BSD/GNU portable; we remove
  # the .bak immediately on success.
  sed -i.bak "/^${BEGIN_MARK}$/,/^${END_MARK}$/d" "$rc" && rm -f "$rc.bak"

  # Drop legacy bare lines from older versions of the installer.
  for pat in "${LEGACY_PATTERNS[@]}"; do
    if grep -qE "$pat" "$rc"; then
      grep -vE "$pat" "$rc" > "$rc.tmp" || true
      mv "$rc.tmp" "$rc"
    fi
  done

  # Append the freshly rendered block (already produced before any mutation).
  [ -s "$rc" ] && printf '\n' >> "$rc"
  printf '%s\n' "$rendered" >> "$rc"

  echo "  wrote managed block"
}

wire "$HOME/.bashrc" bash
wire "$HOME/.zshrc"  zsh

if grep -q 'source.*oh-my-zsh\.sh' "$HOME/.zshrc" 2>/dev/null; then
  cat <<'MSG'

NOTE: oh-my-zsh detected. The cached-compinit speedup in our managed block
runs AFTER OMZ's slow compinit, so it has no effect for you. To make it
effective, paste this snippet right BEFORE `source $ZSH/oh-my-zsh.sh` in
~/.zshrc:

  ZSH_DISABLE_COMPFIX=true
  autoload -Uz compinit
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

MSG
fi

echo
echo "Done. Open a new shell (or 'exec bash' / 'exec zsh') for changes to take effect."
