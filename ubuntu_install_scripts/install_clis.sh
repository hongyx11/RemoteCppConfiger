#!/bin/bash
# Install CLI tools as prebuilt binaries into $PREFIX/bin (default $HOME/local/bin).
# All from official GitHub releases — no compilation.
#
# tree-sitter and yazi are glibc-aware: latest GNU prebuilts can require
# glibc 2.39 (Ubuntu 24.04), while Ubuntu 22.04 has glibc 2.35.
# On old glibc tree-sitter is built from source via cargo (needs Rust toolchain
# from install_rust.sh, which runs earlier in install_all.sh).

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

host_glibc() {
  ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$' || echo "0.0"
}

glibc_ge() {
  local want="$1" have="${2:-$(host_glibc)}"
  [ "$(printf '%s\n%s\n' "$want" "$have" | sort -V | head -1)" = "$want" ]
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

# ── fzf ───────────────────────────────────────────────
install_fzf() {
  skip_if_present fzf && return
  echo "==> fzf"
  local tag; tag=$(gh_latest junegunn/fzf)
  local stripped="${tag#v}"
  dl "https://github.com/junegunn/fzf/releases/download/$tag/fzf-${stripped}-linux_amd64.tar.gz" fzf.tar.gz
  rm -rf fzf-tmp
  mkdir fzf-tmp
  tar xf fzf.tar.gz -C fzf-tmp
  install -m755 fzf-tmp/fzf "$BIN/fzf"
  rm -rf fzf.tar.gz fzf-tmp
}

# ── zoxide ────────────────────────────────────────────
install_zoxide() {
  skip_if_present zoxide && return
  echo "==> zoxide"
  local tag; tag=$(gh_latest ajeetdsouza/zoxide)
  local stripped="${tag#v}"
  dl "https://github.com/ajeetdsouza/zoxide/releases/download/$tag/zoxide-${stripped}-x86_64-unknown-linux-musl.tar.gz" zoxide.tar.gz
  rm -rf zoxide-tmp
  mkdir zoxide-tmp
  tar xf zoxide.tar.gz -C zoxide-tmp
  install -m755 zoxide-tmp/zoxide "$BIN/zoxide"
  rm -rf zoxide.tar.gz zoxide-tmp
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

# ── myrepos ───────────────────────────────────────────
install_myrepos() {
  skip_if_present mr && return
  echo "==> myrepos"
  command -v git >/dev/null || {
    echo "ERROR: git is required to install myrepos." >&2
    return 1
  }
  rm -rf myrepos
  git clone --depth 1 git://myrepos.branchable.com/ myrepos
  install -m755 myrepos/mr "$BIN/mr"
  rm -rf myrepos
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
# nvim-treesitter (main branch) requires tree-sitter-cli >= 0.26. Latest GNU
# prebuilts need glibc 2.39 (Ubuntu 24.04); on older glibc we build from source
# via cargo with --no-default-features to skip the WASM runtime (which pulls in
# libclang via bindgen). The WASM feature is only needed for `tree-sitter build
# --wasm` and `tree-sitter playground` — nvim-treesitter uses neither.
install_treesitter() {
  skip_if_present tree-sitter && return
  local glibc; glibc=$(host_glibc)
  local ver="${TREE_SITTER_VER:-}"
  if [ -z "$ver" ]; then
    if glibc_ge 2.39 "$glibc"; then
      ver="latest"  # glibc >= 2.39, prebuilt latest release
    else
      ver="cargo"   # old glibc: build from source
    fi
  fi
  echo "==> tree-sitter ($ver, glibc $glibc)"
  if [ "$ver" = "cargo" ]; then
    if ! command -v cargo >/dev/null 2>&1; then
      echo "  cargo not on PATH; run install_rust.sh first." >&2
      return 1
    fi
    cargo install tree-sitter-cli --no-default-features
    ln -sf "${CARGO_HOME:-$PREFIX/lib/cargo}/bin/tree-sitter" "$BIN/tree-sitter"
  elif [ "$ver" = "latest" ]; then
    dl "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz" tree-sitter.gz
    gunzip -f tree-sitter.gz
    install -m755 tree-sitter "$BIN/tree-sitter"
    rm -f tree-sitter
  else
    dl "https://github.com/tree-sitter/tree-sitter/releases/download/$ver/tree-sitter-linux-x64.gz" tree-sitter.gz
    gunzip -f tree-sitter.gz
    install -m755 tree-sitter "$BIN/tree-sitter"
    rm -f tree-sitter
  fi
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

# ── btop ──────────────────────────────────────────────
install_btop() {
  skip_if_present btop && return
  echo "==> btop"
  local tag; tag=$(gh_latest aristocratos/btop)
  dl "https://github.com/aristocratos/btop/releases/download/$tag/btop-x86_64-unknown-linux-musl.tar.gz" btop.tar.gz
  rm -rf btop-tmp
  mkdir btop-tmp
  tar xf btop.tar.gz -C btop-tmp
  install -m755 btop-tmp/btop/bin/btop "$BIN/btop"
  mkdir -p "$PREFIX/share/btop/themes"
  cp -f btop-tmp/btop/themes/*.theme "$PREFIX/share/btop/themes/" 2>/dev/null || true
  rm -rf btop.tar.gz btop-tmp
}

# ── yazi ──────────────────────────────────────────────
install_yazi() {
  if [ -x "$BIN/yazi" ] && [ -x "$BIN/ya" ]; then
    if "$BIN/yazi" --version >/dev/null 2>&1; then
      echo "  yazi already installed, skipping."
      return
    fi
    echo "  existing yazi cannot run on this host; reinstalling."
  fi
  echo "==> yazi"
  local tag; tag=$(gh_latest sxyazi/yazi)
  local glibc; glibc=$(host_glibc)
  local target
  if glibc_ge 2.39 "$glibc"; then
    target="yazi-x86_64-unknown-linux-gnu"
  else
    target="yazi-x86_64-unknown-linux-musl"
  fi
  echo "    target: $target (glibc $glibc)"
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
install_fzf
install_zoxide
install_eza
install_zellij
install_myrepos
install_stylua
install_treesitter
install_astgrep
install_lazygit
install_btop
install_yazi

echo
echo "    Installed CLI tools to $BIN"
