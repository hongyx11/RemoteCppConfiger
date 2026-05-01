#!/bin/bash
# No-sudo equivalent of setup_sudo.sh: install gcc-12 via Spack.
# Run as:  bash ~/RemoteCppConfiger/install_dependencies/setup_no_sudo.sh
#
# This is the Stage 1 alternative for hosts without sudo. It clones Spack into
# $SPACK_ROOT (default $HOME/spack), builds gcc@12 from source (~30 min), and
# registers it as a Spack compiler so subsequent `spack install <pkg>` uses it.
#
# Override the prefix with: SPACK_ROOT=/path/to/spack ./setup_no_sudo.sh

set -euo pipefail

SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"

if [ ! -d "$SPACK_ROOT" ]; then
  echo "==> Cloning Spack → $SPACK_ROOT"
  git clone --depth=1 https://github.com/spack/spack.git "$SPACK_ROOT"
else
  echo "  Spack already present at $SPACK_ROOT, skipping clone."
fi

# shellcheck disable=SC1091
. "$SPACK_ROOT/share/spack/setup-env.sh"

if spack find --loaded gcc@12 >/dev/null 2>&1 || spack find gcc@12 >/dev/null 2>&1; then
  echo "  gcc@12 already installed via Spack, skipping build."
else
  echo "==> spack install gcc@12 (~30 min, builds from source)"
  spack install gcc@12
fi

GCC_PREFIX="$(spack location -i gcc@12)"
echo "==> Registering Spack compiler at $GCC_PREFIX"
spack compiler find "$GCC_PREFIX" >/dev/null

echo
echo "Compilers Spack now knows about:"
spack compiler list

cat <<EOF

Done. To use Spack in future shells, add to your shell rc:
  . "$SPACK_ROOT/share/spack/setup-env.sh"

Then \`spack install <pkg>\` will build with gcc-12 by default.
EOF
