#!/bin/bash
# Install Node.js LTS prebuilt into $PREFIX (default $HOME/local).
# Used by install_lsp_servers.sh (pyright, html/css LSPs).

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$LIB" "$SRC"

NODE_VER="${NODE_VER:-v22.11.0}"
TARBALL="node-${NODE_VER}-linux-x64.tar.xz"
URL="https://nodejs.org/dist/${NODE_VER}/${TARBALL}"
DEST="$LIB/node-${NODE_VER}-linux-x64"

if [ -x "$BIN/node" ] && [ -x "$BIN/npm" ]; then
  echo "Node already installed: $($BIN/node --version), npm $($BIN/npm --version)"
  exit 0
fi

echo "==> Downloading Node.js ${NODE_VER}"
cd "$SRC"
curl -fL -o "$TARBALL" "$URL"

echo "==> Extracting"
tar xf "$TARBALL" -C "$LIB"
rm -f "$TARBALL"

for b in node npm npx; do
  ln -sf "$DEST/bin/$b" "$BIN/$b"
done

echo "    node $($BIN/node --version), npm $($BIN/npm --version)"
