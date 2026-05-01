#!/bin/bash
# Install CLI tools as prebuilt binaries into $PREFIX/bin (default $HOME/local/bin).
# All from official GitHub releases — no compilation.
#
# tree-sitter is pinned to v0.22.6: latest releases require glibc 2.39 (Ubuntu 24.04),
# v0.22.6 is the last that runs on Ubuntu 22.04 (glibc 2.35). Remove the pin once
# the host glibc moves to 2.39+.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$SRC"

ARCH="$(uname -m)"
OS="$(uname -s)"
if [ "$OS" != "Linux" ] || [ "$ARCH" != "x86_64" ]; then
  echo "WARNING: this script targets Linux x86_64. Got $OS-$ARCH; some downloads may fail."
fi

dl() { curl -fL --retry 3 --retry-delay 2 -o "$2" "$1"; }

gh_latest() {
  local json
  json=$(curl -fsSL "https://api.github.com/repos/$1/releases/latest")
  if [[ "$json" =~ \"tag_name\":[[:space:]]*\"([^\"]+)\" ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  fi
}

skip_if_present() {
  [ -x "$BIN/$1" ] && { echo "  $1 already installed, skipping."; return 0; } || return 1
}

cd "$SRC"

# ── ninja ─────────────────────────────────────────────
install_ninja() {
  skip_if_present ninja && return
  echo "==> ninja"
  dl "https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip" ninja-linux.zip
  unzip -o ninja-linux.zip -d "$BIN" >/dev/null
  chmod +x "$BIN/ninja"
  rm ninja-linux.zip
}

# ── ripgrep ───────────────────────────────────────────
install_rg() {
  skip_if_present rg && return
  echo "==> ripgrep"
  local tag; tag=$(gh_latest BurntSushi/ripgrep)
  dl "https://github.com/BurntSushi/ripgrep/releases/download/$tag/ripgrep-$tag-x86_64-unknown-linux-musl.tar.gz" rg.tar.gz
  tar xf rg.tar.gz
  install -m755 "ripgrep-$tag-x86_64-unknown-linux-musl/rg" "$BIN/rg"
  rm -rf rg.tar.gz "ripgrep-$tag-x86_64-unknown-linux-musl"
}

# ── fd ────────────────────────────────────────────────
install_fd() {
  skip_if_present fd && return
  echo "==> fd"
  local tag; tag=$(gh_latest sharkdp/fd)
  dl "https://github.com/sharkdp/fd/releases/download/$tag/fd-$tag-x86_64-unknown-linux-musl.tar.gz" fd.tar.gz
  tar xf fd.tar.gz
  install -m755 "fd-$tag-x86_64-unknown-linux-musl/fd" "$BIN/fd"
  rm -rf fd.tar.gz "fd-$tag-x86_64-unknown-linux-musl"
}

# ── bat ───────────────────────────────────────────────
install_bat() {
  skip_if_present bat && return
  echo "==> bat"
  local tag; tag=$(gh_latest sharkdp/bat)
  dl "https://github.com/sharkdp/bat/releases/download/$tag/bat-$tag-x86_64-unknown-linux-musl.tar.gz" bat.tar.gz
  tar xf bat.tar.gz
  install -m755 "bat-$tag-x86_64-unknown-linux-musl/bat" "$BIN/bat"
  rm -rf bat.tar.gz "bat-$tag-x86_64-unknown-linux-musl"
}

# ── eza ───────────────────────────────────────────────
install_eza() {
  skip_if_present eza && return
  echo "==> eza"
  dl "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz" eza.tar.gz
  tar xf eza.tar.gz
  install -m755 "./eza" "$BIN/eza"
  rm -rf eza.tar.gz "./eza"
}

# ── zellij ────────────────────────────────────────────
install_zellij() {
  skip_if_present zellij && return
  echo "==> zellij"
  dl "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" zellij.tar.gz
  tar xf zellij.tar.gz
  install -m755 "./zellij" "$BIN/zellij"
  rm -rf zellij.tar.gz "./zellij"
}

# ── stylua ────────────────────────────────────────────
install_stylua() {
  skip_if_present stylua && return
  echo "==> stylua"
  local tag; tag=$(gh_latest JohnnyMorganz/StyLua)
  dl "https://github.com/JohnnyMorganz/StyLua/releases/download/$tag/stylua-linux-x86_64.zip" stylua.zip
  unzip -o stylua.zip -d "$BIN" >/dev/null
  chmod +x "$BIN/stylua"
  rm stylua.zip
}

# ── tree-sitter (auto-pin for glibc) ──────────────────
# Latest releases need glibc 2.39 (Ubuntu 24.04). On glibc < 2.39 we pin to v0.22.6.
install_treesitter() {
  skip_if_present tree-sitter && return
  local glibc; glibc=$(ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$' || echo "0.0")
  local ver="${TREE_SITTER_VER:-}"
  if [ -z "$ver" ]; then
    if [ "$(printf '2.39\n%s\n' "$glibc" | sort -V | head -1)" = "2.39" ]; then
      ver="latest"  # glibc >= 2.39, latest release
    else
      ver="v0.22.6" # last release that runs on glibc 2.35
    fi
  fi
  echo "==> tree-sitter ($ver, glibc $glibc)"
  if [ "$ver" = "latest" ]; then
    dl "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz" tree-sitter.gz
  else
    dl "https://github.com/tree-sitter/tree-sitter/releases/download/$ver/tree-sitter-linux-x64.gz" tree-sitter.gz
  fi
  gunzip -f tree-sitter.gz
  install -m755 tree-sitter "$BIN/tree-sitter"
  rm -f tree-sitter
}

# ── ast-grep ──────────────────────────────────────────
install_astgrep() {
  skip_if_present ast-grep && return
  echo "==> ast-grep"
  dl "https://github.com/ast-grep/ast-grep/releases/latest/download/app-x86_64-unknown-linux-gnu.zip" ast-grep.zip
  rm -rf ast-grep-tmp
  unzip -o ast-grep.zip -d ast-grep-tmp >/dev/null
  install -m755 ast-grep-tmp/ast-grep "$BIN/ast-grep"
  ln -sf ast-grep "$BIN/sg"
  rm -rf ast-grep.zip ast-grep-tmp
}

# ── lazygit ───────────────────────────────────────────
install_lazygit() {
  skip_if_present lazygit && return
  echo "==> lazygit"
  local tag; tag=$(gh_latest jesseduffield/lazygit)
  local stripped="${tag#v}"
  dl "https://github.com/jesseduffield/lazygit/releases/download/$tag/lazygit_${stripped}_Linux_x86_64.tar.gz" lazygit.tar.gz
  rm -rf lazygit-tmp
  mkdir lazygit-tmp
  tar xf lazygit.tar.gz -C lazygit-tmp
  install -m755 lazygit-tmp/lazygit "$BIN/lazygit"
  rm -rf lazygit.tar.gz lazygit-tmp
}

# ── yazi ──────────────────────────────────────────────
install_yazi() {
  skip_if_present yazi && return
  echo "==> yazi"
  local tag; tag=$(gh_latest sxyazi/yazi)
  local target="yazi-x86_64-unknown-linux-gnu"
  dl "https://github.com/sxyazi/yazi/releases/download/$tag/$target.zip" yazi.zip
  unzip -o yazi.zip >/dev/null
  install -m755 "$target/yazi" "$BIN/yazi"
  install -m755 "$target/ya"   "$BIN/ya"
  rm -rf yazi.zip "$target"
}

install_ninja
install_rg
install_fd
install_bat
install_eza
install_zellij
install_stylua
install_treesitter
install_astgrep
install_lazygit
install_yazi

echo
echo "    Installed CLI tools to $BIN"
