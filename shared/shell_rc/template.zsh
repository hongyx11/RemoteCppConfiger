# >>> RemoteCppConfiger >>>
typeset -U path PATH fpath FPATH
{{PLATFORM_PATH_BLOCK}}
export CMAKE_GENERATOR=Ninja
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v fzf      >/dev/null && eval "$(fzf --zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v eza >/dev/null && alias ls='eza'
command -v eza >/dev/null && alias ll='eza -l --git'
command -v eza >/dev/null && alias la='eza -la --git'
alias cc='clear'
alias cl='clear'
alias hn='hostname'
alias rp='realpath'
alias lz='lazygit'
alias zellij='zellij --layout compact'
alias zi='zellij'
alias za='zellij attach'
alias zl='zellij list-sessions'
alias zd='zellij delete-session'
alias zs='zellij -s'
alias fm='yazi'
alias sqme='squeue --me'
alias ta='tmux a'
alias tb='tmux load-buffer -'
alias gwl='git worktree list'
alias gwr='git worktree remove'
alias gwa='git worktree add'
alias gwm='git worktree merge'
alias ca='conda activate'
alias cda='conda deactivate'
alias cb='cat > /tmp/clipboard_$USER'
alias pb='cat /tmp/clipboard_$USER'
alias sp_env_list='spack env list'
alias sp_env_activate='spack env activate -p'
alias sp_env_deactivate='spack env deactivate'
alias sp_install='spack install'
mrg() {
  if [ "$#" -lt 2 ]; then
    echo "usage: mrg <group> <mr-action> [args...]" >&2
    return 2
  fi
  local group="$1"
  shift
  local real_home="$HOME"
  local src="$real_home/workspace/documents/myconfig/mr/groups/$group.mrconfig"
  if [ ! -f "$src" ]; then
    echo "mrg: unknown group: $group" >&2
    return 1
  fi
  local tmp_home="${TMPDIR:-/tmp}/mrg-home-$USER-$$"
  local tmp_config="$tmp_home/$group.mrconfig"
  mkdir -p "$tmp_home"
  sed "s|[$]HOME|$real_home|g" "$src" > "$tmp_config"
  HOME="$tmp_home" mr --trust-all -c "$tmp_config" "$@"
  local ret=$?
  rm -rf "$tmp_home"
  return "$ret"
}
mrg-list() {
  find "$HOME/workspace/documents/myconfig/mr/groups" -name '*.mrconfig' -printf '%f\n' | sed 's/\.mrconfig$//' | sort
}
command -v nvim >/dev/null && alias vi='nvim'
if [ -n "${SPACK_ROOT:-}" ] && [ -f "$SPACK_ROOT/share/spack/setup-env.sh" ]; then
  spack() { unfunction spack; source "$SPACK_ROOT/share/spack/setup-env.sh"; spack "$@"; }
fi
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
# <<< RemoteCppConfiger <<<
