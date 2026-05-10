# >>> RemoteCppConfiger >>>
{{PLATFORM_PATH_BLOCK}}
command -v starship >/dev/null && eval "$(starship init bash)"
command -v fzf      >/dev/null && eval "$(fzf --bash)"
command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
command -v eza >/dev/null && alias ls='eza'
command -v eza >/dev/null && alias ll='eza -l --git'
command -v eza >/dev/null && alias la='eza -la --git'
alias cc='clear'
alias cl='clear'
alias hn='hostname'
alias rp='realpath'
alias lz='lazygit'
alias zi='zellij'
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
command -v nvim >/dev/null && alias vi='nvim'
if [ -n "${SPACK_ROOT:-}" ] && [ -f "$SPACK_ROOT/share/spack/setup-env.sh" ]; then
  spack() { unset -f spack; source "$SPACK_ROOT/share/spack/setup-env.sh"; spack "$@"; }
fi
# <<< RemoteCppConfiger <<<
