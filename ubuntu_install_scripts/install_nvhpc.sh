#!/bin/bash
# Install NVIDIA HPC SDK (nvhpc) single-CUDA tarball into $PREFIX/nvhpc.
# Skipped if $PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/compilers/bin/nvfortran exists.
#
# Override defaults:
#   PREFIX=/path/to/prefix       (default: $HOME/local)
#   NVHPC_VERSION=25.7           (default: 25.7)
#   NVHPC_CUDA=12.9              (default: 12.9, the bundled CUDA in the 25.7 single-CUDA tarball)

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
NVHPC_VERSION="${NVHPC_VERSION:-25.7}"
NVHPC_CUDA="${NVHPC_CUDA:-12.9}"
NVHPC_PREFIX="$PREFIX/nvhpc"
NVHPC_BIN="$NVHPC_PREFIX/Linux_x86_64/$NVHPC_VERSION/compilers/bin"

if [ -x "$NVHPC_BIN/nvfortran" ]; then
  echo "nvhpc $NVHPC_VERSION already installed at $NVHPC_PREFIX"
  echo "  $("$NVHPC_BIN/nvfortran" --version | head -2 | tail -1)"
  echo "To reinstall, remove $NVHPC_PREFIX and re-run."
  exit 0
fi

# Build URL: 25.7 -> nvhpc_2025_257_Linux_x86_64_cuda_12.9.tar.gz
YEAR="20${NVHPC_VERSION%%.*}"
SHORT="${NVHPC_VERSION//./}"
TARBALL="nvhpc_${YEAR}_${SHORT}_Linux_x86_64_cuda_${NVHPC_CUDA}.tar.gz"
URL="https://developer.download.nvidia.com/hpc-sdk/$NVHPC_VERSION/$TARBALL"

# Disk-space pre-check: need ~20 GB free for download + extract + install transient.
NEED_KB=$((20 * 1024 * 1024))
HAVE_KB=$(df -P "$HOME" | awk 'NR==2 {print $4}')
if [ "$HAVE_KB" -lt "$NEED_KB" ]; then
  HAVE_GB=$((HAVE_KB / 1024 / 1024))
  echo "ERROR: need ~20 GB free in \$HOME's filesystem; only $HAVE_GB GB available." >&2
  exit 1
fi

STAGE="$PREFIX/nvhpc_install"
mkdir -p "$STAGE"
cd "$STAGE"

echo "==> Downloading $TARBALL ..."
curl -fL --retry 3 -o "$TARBALL" "$URL"

echo "==> Extracting ..."
tar -xzf "$TARBALL"

# Delete the tarball before install to free disk for the install copy.
rm -f "$TARBALL"

EXTRACT_DIR="$STAGE/${TARBALL%.tar.gz}"
if [ ! -x "$EXTRACT_DIR/install" ]; then
  echo "ERROR: extracted installer not found at $EXTRACT_DIR/install" >&2
  exit 1
fi

echo "==> Running silent install to $NVHPC_PREFIX ..."
NVHPC_SILENT=true \
  NVHPC_INSTALL_DIR="$NVHPC_PREFIX" \
  NVHPC_INSTALL_TYPE=single \
  "$EXTRACT_DIR/install" || true   # installer's final post-step can exit non-zero; verify below

echo "==> Cleaning up staging dir ..."
rm -rf "$EXTRACT_DIR"
rmdir "$STAGE" 2>/dev/null || true

if [ ! -x "$NVHPC_BIN/nvfortran" ]; then
  echo "ERROR: install did not produce $NVHPC_BIN/nvfortran" >&2
  exit 1
fi

echo "    $("$NVHPC_BIN/nvfortran" --version | head -2 | tail -1) installed."
