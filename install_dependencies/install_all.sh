#!/bin/bash
# RemoteCppConfiger — install all C++ dev dependencies into $HOME/local.
#
# Override the prefix with: PREFIX=/path/to/prefix ./install_all.sh
# Default prefix: $HOME/local
#
# After running, ensure $HOME/local/bin is on PATH:
#   export PATH="$HOME/local/bin:$PATH"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PREFIX="${PREFIX:-$HOME/local}"

mkdir -p "$PREFIX/bin" "$PREFIX/lib" "$PREFIX/src" "$PREFIX/share"

# Make $PREFIX/bin available to sub-scripts during the run
export PATH="$PREFIX/bin:$PATH"

echo "============================================"
echo " RemoteCppConfiger install"
echo " PREFIX: $PREFIX"
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
run "Python tools"     install_python_tools.sh
run "uv (Python pkg mgr)" install_uv.sh
run "Spack"            install_spack.sh
run "Starship prompt"  install_starship.sh
run "atuin (history)"  install_atuin.sh
run "Fonts (Maple Mono NF)" install_fonts.sh
run "Tmux (Oh My Tmux)" install_tmux.sh
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
