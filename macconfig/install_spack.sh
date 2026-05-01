#!/bin/bash
# Clone Spack into $SPACK_ROOT (default $HOME/spack) on mac.
# Mirrors ubuntu_install_scripts/install_spack.sh. No compiler bootstrap;
# users register brew compilers themselves with `spack compiler find`.

set -euo pipefail

SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"

if [ -d "$SPACK_ROOT/.git" ]; then
  echo "  spack already cloned at $SPACK_ROOT, skipping."
else
  echo "==> Cloning spack → $SPACK_ROOT"
  git clone --depth=1 https://github.com/spack/spack.git "$SPACK_ROOT"
fi

# shellcheck disable=SC1091
. "$SPACK_ROOT/share/spack/setup-env.sh"
echo "    $(spack --version)"
echo
echo "    To use in a new shell:"
echo "      . $SPACK_ROOT/share/spack/setup-env.sh"
