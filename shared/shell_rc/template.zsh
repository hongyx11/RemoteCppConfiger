# >>> RemoteCppConfiger >>>
typeset -U path PATH fpath FPATH
{{PLATFORM_PATH_BLOCK}}
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v atuin    >/dev/null && eval "$(atuin init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v eza >/dev/null && alias ls='eza'
command -v eza >/dev/null && alias ll='eza -l --git'
command -v eza >/dev/null && alias la='eza -la --git'
if [ -n "${SPACK_ROOT:-}" ] && [ -f "$SPACK_ROOT/share/spack/setup-env.sh" ]; then
  spack() { unfunction spack; source "$SPACK_ROOT/share/spack/setup-env.sh"; spack "$@"; }
fi
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
# <<< RemoteCppConfiger <<<
