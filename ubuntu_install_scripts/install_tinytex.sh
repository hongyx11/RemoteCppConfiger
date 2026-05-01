#!/bin/bash
# Install TinyTeX (lightweight LaTeX) and point its symlinks at $PREFIX/bin.
# TinyTeX itself always installs into $HOME/.TinyTeX (its installer doesn't
# support relocation); we only manage the symlink directory.
# No sudo, no interactive input.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

TINYTEX_DIR="$HOME/.TinyTeX"

if [ -x "$BIN/pdflatex" ] && [ -x "$BIN/tlmgr" ]; then
  echo "  TinyTeX already linked into $BIN, skipping."
  echo "    $("$BIN/pdflatex" --version | head -1)"
  exit 0
fi

if [ ! -d "$TINYTEX_DIR" ]; then
  echo "==> Installing TinyTeX → $TINYTEX_DIR"
  curl -sSL "https://yihui.org/tinytex/install-bin-unix.sh" | sh
fi

TT_BIN="$(find "$TINYTEX_DIR/bin" -mindepth 1 -maxdepth 1 -type d | head -1)"
if [ -z "${TT_BIN:-}" ] || [ ! -x "$TT_BIN/tlmgr" ]; then
  echo "ERROR: could not locate tlmgr under $TINYTEX_DIR/bin"
  exit 1
fi

echo "==> Repointing TinyTeX symlinks → $BIN"
"$TT_BIN/tlmgr" path remove >/dev/null 2>&1 || true
"$TT_BIN/tlmgr" option sys_bin "$BIN" >/dev/null
"$TT_BIN/tlmgr" path add >/dev/null

echo "    $("$BIN/pdflatex" --version | head -1)"
echo
echo "    Add packages on demand with:  tlmgr install <pkg>"
