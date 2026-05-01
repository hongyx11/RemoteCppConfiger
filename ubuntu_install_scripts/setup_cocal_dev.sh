#!/bin/bash
# Set up the cocal dev environment from a clean machine that already has:
#   - apt: build-essential, git, curl, gcc-12, g++-12, gfortran-12
#   - working nvidia-smi
#   - SSH keys in ~/.ssh/: githubreadonly, spackenv, cocalkey
#   - spack cloned at $SPACK_ROOT (default $HOME/spack)
#
# Idempotent: re-running skips work that's already done.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${PREFIX:-$HOME/local}"
SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
NVHPC_VERSION="${NVHPC_VERSION:-25.7}"
ENV_NAME="${ENV_NAME:-exouser-cocal-dev}"

echo "============================================"
echo " cocal dev setup"
echo " PREFIX:        $PREFIX"
echo " SPACK_ROOT:    $SPACK_ROOT"
echo " NVHPC_VERSION: $NVHPC_VERSION"
echo " ENV_NAME:      $ENV_NAME"
echo "============================================"

# --- 1. Pre-flight: SSH keys ---
need_keys=(githubreadonly spackenv cocalkey)
for k in "${need_keys[@]}"; do
  if [ ! -f "$HOME/.ssh/$k" ]; then
    echo "ERROR: missing ~/.ssh/$k" >&2
    exit 1
  fi
done

# --- 2. Clone repos with their respective keys ---
clone_with_key() {
  local key="$1" url="$2" dest="$3"
  if [ -d "$dest/.git" ]; then
    echo "    $dest already cloned, skipping."
    return
  fi
  echo "    cloning $url -> $dest"
  GIT_SSH_COMMAND="ssh -i $HOME/.ssh/$key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" \
    git clone "$url" "$dest"
}

echo
echo "---- Cloning cocal-related repos ----"
clone_with_key githubreadonly  git@github.com:hongyx11/spack_packages    "$HOME/spack_packages"
clone_with_key spackenv        git@github.com:hongyx11/spack-envs.git    "$HOME/spack-envs"
clone_with_key cocalkey        git@bitbucket.org:atsok/pcocal_illinois.git "$HOME/pcocal_illinois"

# --- 3. Install nvhpc ---
echo
echo "---- Installing nvhpc ----"
PREFIX="$PREFIX" NVHPC_VERSION="$NVHPC_VERSION" bash "$SCRIPT_DIR/install_nvhpc.sh"

# --- 4. Write the spack env (skip if it already exists) ---
ENV_DIR="$HOME/spack-envs/envs/$ENV_NAME"
SPACK_YAML="$ENV_DIR/spack.yaml"

if [ -f "$SPACK_YAML" ]; then
  echo
  echo "---- Spack env $ENV_NAME already exists at $ENV_DIR, skipping ----"
else
  echo
  echo "---- Writing spack env $ENV_NAME ----"
  mkdir -p "$ENV_DIR"
  CUDA_DETECTED=$("$PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/cuda/bin/nvcc" --version \
    | awk '/release/ {gsub(",","",$6); print $6}')
  cat > "$SPACK_YAML" <<EOF
spack:
  specs: []

  concretizer:
    unify: true
    reuse: true

  view: true

  packages:
    c:
      buildable: false
    cxx:
      buildable: false
    fortran:
      buildable: false

    gcc:
      externals:
        - spec: gcc@12.3.0 languages=c,c++,fortran
          prefix: /usr
          extra_attributes:
            compilers:
              c: /usr/bin/gcc-12
              cxx: /usr/bin/g++-12
              fortran: /usr/bin/gfortran-12
      buildable: false

    nvhpc:
      externals:
        - spec: nvhpc@$NVHPC_VERSION
          prefix: $PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION
          extra_attributes:
            compilers:
              c: $PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/compilers/bin/nvc
              cxx: $PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/compilers/bin/nvc++
              fortran: $PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/compilers/bin/nvfortran
      buildable: false

    cuda:
      externals:
        - spec: cuda@$CUDA_DETECTED
          prefix: $PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/cuda
      buildable: false
EOF
fi

# --- 5. Verify ---
echo
echo "---- Verifying ----"
"$PREFIX/nvhpc/Linux_x86_64/$NVHPC_VERSION/compilers/bin/nvfortran" --version | head -2 | tail -1

if [ -d "$SPACK_ROOT" ]; then
  set +e
  source "$SPACK_ROOT/share/spack/setup-env.sh" >/dev/null 2>&1
  spack -D "$ENV_DIR" spec -I "zlib %nvhpc@$NVHPC_VERSION" 2>&1 \
    | grep -E "^\[e\]\s+\^?nvhpc" \
    && echo "    spack sees nvhpc as external [e] OK"
  set -e
else
  echo "    SPACK_ROOT=$SPACK_ROOT not found; skipping spack verification."
fi

echo
echo "============================================"
echo " Done. To use the env:"
echo "   source $SPACK_ROOT/share/spack/setup-env.sh"
echo "   spack -D $ENV_DIR install"
echo "============================================"
