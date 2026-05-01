# >>> RemoteCppConfiger >>>
{{PLATFORM_PATH_BLOCK}}
command -v starship >/dev/null && eval "$(starship init bash)"
command -v atuin    >/dev/null && eval "$(atuin init bash)"
command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
command -v eza >/dev/null && alias ls='eza'
command -v eza >/dev/null && alias ll='eza -l --git'
command -v eza >/dev/null && alias la='eza -la --git'
if [ -n "${SPACK_ROOT:-}" ] && [ -f "$SPACK_ROOT/share/spack/setup-env.sh" ]; then
  spack() { unset -f spack; source "$SPACK_ROOT/share/spack/setup-env.sh"; spack "$@"; }
fi
# <<< RemoteCppConfiger <<<
