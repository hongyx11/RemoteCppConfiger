#!/bin/bash
# Install Python formatters into a venv under $PREFIX/lib.
# Binaries symlinked into $PREFIX/bin.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB"

VENV="$LIB/python-tools"

if [ -x "$BIN/black" ] && [ -x "$BIN/autopep8" ]; then
  echo "  black, autopep8 already installed, skipping."
  exit 0
fi

if ! command -v python3 >/dev/null; then
  echo "ERROR: python3 not found."
  exit 1
fi

echo "==> Creating venv at $VENV"
python3 -m venv "$VENV"

echo "==> Installing black, autopep8"
"$VENV/bin/pip" install --upgrade pip >/dev/null
"$VENV/bin/pip" install black autopep8 >/dev/null

for tool in black autopep8; do
  ln -sf "$VENV/bin/$tool" "$BIN/$tool"
done

echo "    $("$BIN/black" --version | head -1)"
echo "    $("$BIN/autopep8" --version 2>&1)"
