#!/bin/bash
# Build Neovim from source into $PREFIX (default $HOME/local).
# Skipped if $PREFIX/bin/nvim already exists.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$LIB" "$SRC"

if [ -x "$BIN/nvim" ]; then
  echo "nvim already installed at $BIN/nvim ($("$BIN/nvim" --version | head -1))"
  echo "To rebuild, remove $BIN/nvim and re-run."
  exit 0
fi

# ninja is needed for the nvim build; install_llvm.sh / install_clis.sh provide it
export PATH="$BIN:$PATH"

echo "==> Building Neovim from source ..."

BUILD_DIR="$SRC/neovim-build"
INSTALL_DIR="$LIB/nvim"

# Resolve the latest stable release tag via the GitHub API (no auth, no jq).
LATEST_TAG=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
  | sed -nE 's/.*"tag_name":[[:space:]]*"([^"]+)".*/\1/p' | head -1)
if [ -z "$LATEST_TAG" ]; then
  echo "  error: could not resolve latest neovim release tag from GitHub API." >&2
  exit 1
fi
echo "    Latest release: $LATEST_TAG"

TARBALL_URL="https://github.com/neovim/neovim/archive/refs/tags/${LATEST_TAG}.tar.gz"
SRC_DIR="$BUILD_DIR/neovim-${LATEST_TAG#v}"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
echo "    Downloading $TARBALL_URL"
curl -fL --retry 3 --retry-delay 2 -o neovim.tar.gz "$TARBALL_URL"
tar xf neovim.tar.gz
rm -f neovim.tar.gz

cd "$SRC_DIR"
echo "    Building $LATEST_TAG ..."

make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$INSTALL_DIR"
make install

ln -sf "$INSTALL_DIR/bin/nvim" "$BIN/nvim"

echo "==> Removing build dir ($BUILD_DIR, ~600 MB)"
rm -rf "$BUILD_DIR"

echo "    $("$BIN/nvim" --version | head -1) installed."
