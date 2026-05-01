#!/bin/bash
# Install uv (Astral's Python package/project manager) into $PREFIX/bin.
# No sudo, no interactive input.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

if [ -x "$BIN/uv" ]; then
  echo "  uv already installed, skipping."
  echo "    $("$BIN/uv" --version)"
  exit 0
fi

echo "==> Installing uv → $BIN"
curl -LsSf https://astral.sh/uv/install.sh \
  | env UV_INSTALL_DIR="$BIN" UV_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1 sh

echo "    $("$BIN/uv" --version)"
