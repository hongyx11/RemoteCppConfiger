#!/bin/bash
# RemoteCppConfiger — install all C++ dev dependencies into one prefix.
#
# Override the prefix with: PREFIX=/path/to/prefix ./install_all.sh
# Default prefix: $HOME/local
# NVIDIA HPC SDK is OFF by default; opt in with: INSTALL_NVHPC=1 ./install_all.sh
# Full TeX Live (LaTeX) is OFF by default; opt in with: INSTALL_LATEX=1 ./install_all.sh
# Lightweight TeX variants are intentionally not installed.
#
# After running, ensure $PREFIX/bin is on PATH:
#   export PATH="$PREFIX/bin:$PATH"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export PREFIX="${PREFIX:-$HOME/local}"
export SPACK_ROOT="${SPACK_ROOT:-$PREFIX/spack}"
export INSTALL_NVHPC="${INSTALL_NVHPC:-0}"
export INSTALL_LATEX="${INSTALL_LATEX:-0}"

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
echo " INSTALL_LATEX: $INSTALL_LATEX"
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
run "Codex CLI"        install_codex.sh
run "Gemini CLI"       install_gemini.sh
run "OpenCode CLI"     install_opencode.sh
run "uv (Python pkg mgr)" install_uv.sh
run "Python tools"     install_python_tools.sh
run "CMake LSP + format" install_cmake_tools.sh
run "Spack"            install_spack.sh
if [ "$INSTALL_LATEX" != "0" ] && [ "$INSTALL_LATEX" != "false" ] && [ "$INSTALL_LATEX" != "no" ]; then
  run "TeX Live (full)"  install_texlive.sh
else
  echo
  echo "---- TeX Live (full) ----"
  echo "  skipped (INSTALL_LATEX=$INSTALL_LATEX)"
fi
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

echo
echo "---- Zellij config ----"
ZELLIJ_CONFIG_SRC="$REPO_ROOT/shared/zellij/config.kdl"
ZELLIJ_CONFIG_DST="$HOME/.config/zellij/config.kdl"
mkdir -p "$(dirname "$ZELLIJ_CONFIG_DST")"
if [ -e "$ZELLIJ_CONFIG_DST" ] || [ -L "$ZELLIJ_CONFIG_DST" ]; then
  bak="$ZELLIJ_CONFIG_DST.bak.$(date +%Y%m%d-%H%M%S)"
  echo "  $ZELLIJ_CONFIG_DST exists; moving to $bak"
  mv "$ZELLIJ_CONFIG_DST" "$bak"
fi
echo "==> Copying $ZELLIJ_CONFIG_SRC → $ZELLIJ_CONFIG_DST"
cp "$ZELLIJ_CONFIG_SRC" "$ZELLIJ_CONFIG_DST"

echo
echo "---- Neovim config ----"
NVIM_CONFIG_SRC="$REPO_ROOT/nvimconfig"
NVIM_CONFIG_DST="$HOME/.config/nvim"
mkdir -p "$(dirname "$NVIM_CONFIG_DST")"
if [ -L "$NVIM_CONFIG_DST" ]; then
  echo "  $NVIM_CONFIG_DST is a symlink; removing it before copy."
  rm "$NVIM_CONFIG_DST"
elif [ -e "$NVIM_CONFIG_DST" ]; then
  bak="$NVIM_CONFIG_DST.bak.$(date +%Y%m%d-%H%M%S)"
  echo "  $NVIM_CONFIG_DST exists; moving to $bak"
  mv "$NVIM_CONFIG_DST" "$bak"
fi
echo "==> Copying $NVIM_CONFIG_SRC → $NVIM_CONFIG_DST"
cp -R "$NVIM_CONFIG_SRC" "$NVIM_CONFIG_DST"

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
