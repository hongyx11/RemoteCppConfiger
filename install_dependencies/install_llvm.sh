#!/bin/bash
# Install a *minimal* slice of prebuilt LLVM into $PREFIX (default $HOME/local):
# only clangd + clang-format + the clang resource dir (~143 MB on disk vs ~7 GB
# for the full toolchain). We compile with gcc/g++, so the rest is dead weight.
#
# Auto-picks the LLVM release based on host glibc:
#   glibc < 2.38   → LLVM 18.1.8 ubuntu-18.04 prebuilt (Ubuntu 22.04 et al.)
#                    libtinfo.so.5 is shimmed in from libtinfo5 .deb
#   glibc >= 2.38  → LLVM 19.1.7 generic Linux build (Ubuntu 24.04+)
#                    no libtinfo5 needed
#
# Override with: LLVM_VERSION=X.Y.Z LLVM_ASSET=... ./install_llvm.sh
# See docs/design.md for trade-offs.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$LIB" "$SRC"

# ── glibc detection ───────────────────────────────────
glibc_ver=$(ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$' || echo "0.0")

# returns 0 if current glibc >= $1
glibc_ge() {
  [ "$(printf '%s\n%s\n' "$1" "$glibc_ver" | sort -V | head -1)" = "$1" ]
}

# ── pick LLVM release ─────────────────────────────────
if [ -z "${LLVM_VERSION:-}" ]; then
  if glibc_ge 2.38; then
    LLVM_VERSION="19.1.7"
    LLVM_ASSET="LLVM-${LLVM_VERSION}-Linux-X64.tar.xz"
    NEED_LIBTINFO5=0
  else
    LLVM_VERSION="18.1.8"
    LLVM_ASSET="clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
    NEED_LIBTINFO5=1
  fi
fi
LLVM_ASSET="${LLVM_ASSET:-clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-18.04.tar.xz}"
NEED_LIBTINFO5="${NEED_LIBTINFO5:-1}"

URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/${LLVM_ASSET}"
DEST="$LIB/llvm-${LLVM_VERSION}"

echo "host glibc: $glibc_ver"
echo "LLVM:       $LLVM_VERSION ($LLVM_ASSET)"

if [ -x "$BIN/clangd" ] && [ -x "$BIN/clang-format" ]; then
  echo "LLVM tools already present at $BIN, skipping."
  exit 0
fi

# ── download + selective extract ──────────────────────
echo "==> Downloading (~1 GB)"
cd "$SRC"
curl -fL --retry 3 --retry-delay 2 -o "$LLVM_ASSET" "$URL"

echo "==> Extracting clangd + clang-format + resource dir to $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
tar xf "$LLVM_ASSET" -C "$DEST" --strip-components=1 --wildcards \
    '*/bin/clangd' \
    '*/bin/clang-format' \
    '*/lib/clang/*'
rm -f "$LLVM_ASSET"

# ── symlink binaries ──────────────────────────────────
for t in clangd clang-format; do
  if [ -x "$DEST/bin/$t" ]; then
    ln -sf "$DEST/bin/$t" "$BIN/$t"
  fi
done

# ── libtinfo5 shim (only for the LLVM 18 ubuntu-18.04 prebuilt) ───
if [ "$NEED_LIBTINFO5" = "1" ] && [ ! -e "$DEST/lib/libtinfo.so.5" ]; then
  echo "==> Fetching libtinfo5 (LLVM 18 prebuilt links the older soname)"
  DEB_URL="http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb"
  cd "$SRC"
  curl -fL -o libtinfo5.deb "$DEB_URL"
  rm -rf libtinfo5-extract
  mkdir libtinfo5-extract
  if command -v dpkg-deb >/dev/null; then
    dpkg-deb -x libtinfo5.deb libtinfo5-extract
  else
    # ar + tar fallback
    cd libtinfo5-extract
    ar x ../libtinfo5.deb
    tar xf data.tar.zst 2>/dev/null || tar xf data.tar.xz
    cd ..
  fi
  cp -P libtinfo5-extract/lib/x86_64-linux-gnu/libtinfo.so.5* "$DEST/lib/"
  rm -rf libtinfo5.deb libtinfo5-extract
fi

echo "    clangd: $($BIN/clangd --version | head -1)"
echo "    clang:  $($BIN/clang --version | head -1)"
