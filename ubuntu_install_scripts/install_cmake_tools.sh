#!/bin/bash
# Install CMake formatter/linter via `uv tool install`.
#   cmakelang               — cmake-format, cmake-lint, cmake-annotate
#
# The LSP itself (neocmakelsp) is installed from install_lsp_servers.sh.
#
# Each tool gets its own isolated venv under $PREFIX/lib/uv-tools/,
# with command shims placed in $PREFIX/bin.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB" "$PREFIX/cache"
export PATH="$BIN:$PATH"
export UV_CACHE_DIR="${UV_CACHE_DIR:-$PREFIX/cache/uv}"
export UV_TOOL_DIR="${UV_TOOL_DIR:-$LIB/uv-tools}"
export UV_TOOL_BIN_DIR="${UV_TOOL_BIN_DIR:-$BIN}"

if [ ! -x "$BIN/uv" ]; then
  echo "ERROR: uv not found at $BIN/uv. Run install_uv.sh first." >&2
  exit 1
fi

install_tool() {
  local pkg="$1" probe="$2"
  if [ -x "$BIN/$probe" ]; then
    echo "  $pkg already installed ($probe present), skipping."
    return 0
  fi
  echo "==> uv tool install $pkg"
  "$BIN/uv" tool install --force "$pkg" >/dev/null
}

install_tool cmakelang cmake-format

echo
echo "    $("$BIN/cmake-format" --version 2>&1 | head -1 || true)"
