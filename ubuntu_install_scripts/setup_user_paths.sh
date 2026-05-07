#!/bin/bash
# Move user-level config/data owned by this dev environment under $PREFIX and
# leave symlinks at the conventional locations tools expect.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BACKUP_ROOT="${BACKUP_ROOT:-$PREFIX/backups/user-config-$(date +%Y%m%d-%H%M%S)}"

mkdir -p \
  "$PREFIX/etc" \
  "$PREFIX/share" \
  "$PREFIX/state" \
  "$PREFIX/cache"

link_path() {
  local home_path="$1" prefix_path="$2" kind="$3"
  local parent
  parent="$(dirname "$home_path")"
  mkdir -p "$parent" "$(dirname "$prefix_path")"

  if [ "$kind" != "dir" ] && [ "$kind" != "file" ]; then
    echo "ERROR: unknown link kind '$kind' for $home_path" >&2
    exit 64
  fi

  if [ -L "$home_path" ]; then
    local current
    current="$(readlink "$home_path")"
    if [ "$current" = "$prefix_path" ]; then
      echo "  $home_path -> $prefix_path"
      if [ "$kind" = "dir" ]; then
        mkdir -p "$prefix_path"
      fi
      return
    fi
    echo "  $home_path is a symlink to $current; replacing with $prefix_path"
    rm "$home_path"
  elif [ -e "$home_path" ]; then
    local rel backup
    rel="${home_path#$HOME/}"
    backup="$BACKUP_ROOT/$rel"
    mkdir -p "$(dirname "$backup")"
    echo "  backing up $home_path -> $backup"
    mv "$home_path" "$backup"
  fi

  if [ "$kind" = "dir" ]; then
    mkdir -p "$prefix_path"
  elif [ ! -e "$prefix_path" ]; then
    : > "$prefix_path"
  fi

  ln -s "$prefix_path" "$home_path"
  echo "  $home_path -> $prefix_path"
}

echo "==> Linking user config/data into $PREFIX"
echo "    backup root: $BACKUP_ROOT"

# Neovim config itself is intentionally controlled by the repo symlink
# (~/.config/nvim -> <repo>/nvimconfig). Runtime data can live under PREFIX.
link_path "$HOME/.local/share/nvim" "$PREFIX/share/nvim" dir
link_path "$HOME/.local/state/nvim" "$PREFIX/state/nvim" dir
link_path "$HOME/.cache/nvim"       "$PREFIX/cache/nvim" dir

link_path "$HOME/.local/share/fonts/MapleMono-NF" "$PREFIX/share/fonts/MapleMono-NF" dir

# True if the path exists OR is a (possibly dangling) symlink.
exists_or_link() { [ -e "$1" ] || [ -L "$1" ]; }

# Tools this repo always installs on Linux: link unconditionally so $HOME stays
# clean even before the tool has been run for the first time.
link_path "$HOME/.cache/zellij"        "$PREFIX/cache/zellij"     dir
link_path "$HOME/.local/share/zoxide"  "$PREFIX/share/zoxide"     dir
link_path "$HOME/.spack"               "$PREFIX/state/spack-user" dir

if exists_or_link "$PREFIX/cache/uv" || exists_or_link "$HOME/.cache/uv"; then
  link_path "$HOME/.cache/uv" "$PREFIX/cache/uv" dir
fi
if exists_or_link "$PREFIX/cache/npm" || exists_or_link "$HOME/.npm"; then
  link_path "$HOME/.npm" "$PREFIX/cache/npm" dir
fi
if exists_or_link "$PREFIX/share/nvm" || exists_or_link "$HOME/.nvm"; then
  link_path "$HOME/.nvm" "$PREFIX/share/nvm" dir
fi

if exists_or_link "$PREFIX/etc/starship.toml" || exists_or_link "$HOME/.config/starship.toml"; then
  link_path "$HOME/.config/starship.toml" "$PREFIX/etc/starship.toml" file
fi

# Optional config dirs — lazy-linked so we don't litter $PREFIX/etc with empty
# dirs for tools whose config the user hasn't created.
if exists_or_link "$PREFIX/etc/zellij" || exists_or_link "$HOME/.config/zellij"; then
  link_path "$HOME/.config/zellij" "$PREFIX/etc/zellij" dir
fi
if exists_or_link "$PREFIX/share/yazi" || exists_or_link "$HOME/.local/share/yazi"; then
  link_path "$HOME/.local/share/yazi" "$PREFIX/share/yazi" dir
fi
if exists_or_link "$PREFIX/etc/yazi" || exists_or_link "$HOME/.config/yazi"; then
  link_path "$HOME/.config/yazi" "$PREFIX/etc/yazi" dir
fi
if exists_or_link "$PREFIX/etc/lazygit" || exists_or_link "$HOME/.config/lazygit"; then
  link_path "$HOME/.config/lazygit" "$PREFIX/etc/lazygit" dir
fi

if exists_or_link "$PREFIX/share/tmux/oh-my-tmux" || exists_or_link "$HOME/.tmux"; then
  link_path "$HOME/.tmux" "$PREFIX/share/tmux/oh-my-tmux" dir
fi
if exists_or_link "$PREFIX/etc/tmux.conf.local" || exists_or_link "$HOME/.tmux.conf.local"; then
  link_path "$HOME/.tmux.conf.local" "$PREFIX/etc/tmux.conf.local" file
fi

if [ -d "$PREFIX/share/tmux/oh-my-tmux" ]; then
  ln -sfn "$PREFIX/share/tmux/oh-my-tmux/.tmux.conf" "$HOME/.tmux.conf"
  echo "  $HOME/.tmux.conf -> $PREFIX/share/tmux/oh-my-tmux/.tmux.conf"
fi
