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

if [ -d "$BUILD_DIR/neovim" ]; then
  echo "    Updating existing source ..."
  cd "$BUILD_DIR/neovim"
  git fetch --tags
else
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  git clone https://github.com/neovim/neovim.git
  cd neovim
fi

LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
echo "    Building $LATEST_TAG ..."
git checkout "$LATEST_TAG"

make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$INSTALL_DIR"
make install

ln -sf "$INSTALL_DIR/bin/nvim" "$BIN/nvim"
echo "    $("$BIN/nvim" --version | head -1) installed."
