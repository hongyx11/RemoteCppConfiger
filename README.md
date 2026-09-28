# RemoteCppConfiger

Development environment installers for Ubuntu 22.04/24.04 and macOS with Homebrew.
Installs Neovim, LLVM and language servers, Rust, Node, Python tools, Spack,
terminal tools, fonts, and shell initialization.

## Setup

Use [configmgr](https://github.com/hongyx11/configmgr) to clone the independent
repositories into `${XDG_CONFIG_HOME:-$HOME/.config}`:

```sh
# From the configmgr checkout:
./configmgr clone remotecppconfiger tmuxconfig nvimconfig zellijconfig
cd "${XDG_CONFIG_HOME:-$HOME/.config}/remotecppconfiger"
```

The tmux checkout is required by the installers. Neovim, Zellij, and tmux
customizations live in their own repositories. Existing Neovim and Zellij
configs are left untouched. The tmux installer links `~/.tmux.conf.local` to
`tmux/tmux.conf.local` in the config directory only when that path is absent;
existing files and symlinks are preserved.

### Ubuntu

Install GCC using one of these paths, then run the tool installer:

```sh
bash ubuntu_install_scripts/setup_sudo.sh       # with sudo
# OR:
bash ubuntu_install_scripts/setup_no_sudo.sh    # build GCC through Spack

bash ubuntu_install_scripts/install_all.sh
```

Tools install under `$HOME/local` by default. Set `PREFIX` consistently for a
custom location. Optional Linux packages are enabled with `INSTALL_LATEX=1`
(full TeX Live) and `INSTALL_NVHPC=1` (NVIDIA HPC SDK):

```sh
PREFIX="$HOME/local" INSTALL_LATEX=1 bash ubuntu_install_scripts/install_all.sh
```

### macOS

Install Homebrew and Xcode Command Line Tools first, then run:

```sh
bash macconfig/install_all.sh
```

Uses Homebrew, including full MacTeX. Spack defaults to `$HOME/spack`; override
with `SPACK_ROOT` if needed.

## Files

- `ubuntu_install_scripts/`: Linux installation and environment helpers.
- `macconfig/`: Homebrew package list and macOS installers.
- `shared/shell_rc/`: shared Bash/Zsh setup and platform paths.
- `clangdconfig/`: C++ language-server and formatting templates.

Installers modify shell startup files and install tools; run them deliberately.
After installation, open a new shell. On Linux, verify `$PREFIX/bin` (default
`$HOME/local/bin`) is on PATH. Individual installers can be rerun as needed;
check each script for its skip/overwrite behavior.
