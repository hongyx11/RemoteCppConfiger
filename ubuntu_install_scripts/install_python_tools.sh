#!/bin/bash
# Install Python tools into a venv under $PREFIX/lib using uv.
# Binaries symlinked into $PREFIX/bin.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB" "$PREFIX/cache"
export UV_CACHE_DIR="${UV_CACHE_DIR:-$PREFIX/cache/uv}"

VENV="$LIB/python-tools"

if [ -x "$BIN/black" ] && [ -x "$BIN/autopep8" ] && [ -x "$BIN/gita" ]; then
  echo "  black, autopep8, gita already installed, skipping."
  exit 0
fi

if ! command -v python3 >/dev/null; then
  echo "ERROR: python3 not found."
  exit 1
fi

if [ ! -x "$BIN/uv" ]; then
  echo "ERROR: uv not found at $BIN/uv. Run install_uv.sh first." >&2
  exit 1
fi

echo "==> Creating venv at $VENV"
"$BIN/uv" venv --python python3 "$VENV" >/dev/null

echo "==> Installing black, autopep8, gita with uv"
"$BIN/uv" pip install --python "$VENV/bin/python" black autopep8 gita >/dev/null

for tool in black autopep8 gita; do
  ln -sf "$VENV/bin/$tool" "$BIN/$tool"
done

echo "    $("$BIN/black" --version | head -1)"
echo "    $("$BIN/autopep8" --version 2>&1)"
echo "    gita installed at $BIN/gita"
