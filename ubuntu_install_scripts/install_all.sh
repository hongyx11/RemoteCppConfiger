#!/bin/bash
# RemoteCppConfiger — install all C++ dev dependencies into one prefix.
#
# Override the prefix with: PREFIX=/path/to/prefix ./install_all.sh
# Default prefix: $HOME/local
# Skip NVIDIA HPC SDK with: INSTALL_NVHPC=0 ./install_all.sh
#
# After running, ensure $PREFIX/bin is on PATH:
#   export PATH="$PREFIX/bin:$PATH"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PREFIX="${PREFIX:-$HOME/local}"
export SPACK_ROOT="${SPACK_ROOT:-$PREFIX/spack}"
export INSTALL_NVHPC="${INSTALL_NVHPC:-1}"

mkdir -p "$PREFIX/bin" "$PREFIX/lib" "$PREFIX/src" "$PREFIX/share" "$PREFIX/cache"

# Make $PREFIX/bin available to sub-scripts during the run
export PATH="$PREFIX/bin:$PATH"
export UV_CACHE_DIR="${UV_CACHE_DIR:-$PREFIX/cache/uv}"
export npm_config_cache="${npm_config_cache:-$PREFIX/cache/npm}"

echo "============================================"
echo " RemoteCppConfiger install"
echo " PREFIX: $PREFIX"
echo " SPACK_ROOT: $SPACK_ROOT"
echo " INSTALL_NVHPC: $INSTALL_NVHPC"
echo "============================================"

run() {
  local label="$1" script="$2"
  echo
  echo "---- $label ----"
  bash "$SCRIPT_DIR/$script"
}

run "Neovim"           install_nvim.sh
run "LLVM (prebuilt)"  install_llvm.sh
run "Node.js"          install_node.sh
run "Rust toolchain"   install_rust.sh
run "CLI tools"        install_clis.sh
run "LSP servers"      install_lsp_servers.sh
run "uv (Python pkg mgr)" install_uv.sh
run "Python tools"     install_python_tools.sh
run "Spack"            install_spack.sh
run "TinyTeX (LaTeX)"  install_tinytex.sh
if [ "$INSTALL_NVHPC" != "0" ] && [ "$INSTALL_NVHPC" != "false" ] && [ "$INSTALL_NVHPC" != "no" ]; then
  run "NVIDIA HPC SDK"  install_nvhpc.sh
else
  echo
  echo "---- NVIDIA HPC SDK ----"
  echo "  skipped (INSTALL_NVHPC=$INSTALL_NVHPC)"
fi
run "just (cmd runner)" install_just.sh
run "Starship prompt"  install_starship.sh
run "Fonts (Maple Mono NF)" install_fonts.sh
run "Tmux (Oh My Tmux)" install_tmux.sh
run "User config/data links" setup_user_paths.sh
run "Shell rc"         setup_shell_rc.sh

echo
echo "============================================"
echo " Done."
echo
echo " Add to your shell rc:"
echo "   export PATH=\"$PREFIX/bin:\$PATH\""
echo
echo " Or source the helper:"
echo "   source $SCRIPT_DIR/setup_path.sh"
echo "============================================"
