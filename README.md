<p align="center">
  <img src="logo.png" alt="RemoteCppConfiger" width="420">
</p>

# RemoteCppConfiger

Out-of-the-box C++ development environment for a raw Linux box. One install script lays down a Neovim-based editor, an LLVM toolchain, gcc-12 (apt or Spack), Rust, Node, and a curated set of CLI tools — all under one install prefix (`$HOME/local` by default).

Designed to work on hosts with **or without** sudo. The only thing that branches is how gcc-12 is acquired; everything else installs identically.

## What you get

- **Editor**: Neovim (latest) + an NvChad-derived config tuned for C++, MPI, CMake.
- **C++ toolchain**: gcc/g++ 12 (apt or `spack install gcc@12`), plus prebuilt LLVM 18.1.8 (clangd, clang-format, clang-tidy, libomp).
- **Package manager**: Spack, with gcc-12 registered as the external compiler.
- **LSPs**: clangd, pyright, lua-language-server, neocmakelsp, bash-language-server, yaml-language-server, html, css.
- **CMake helpers**: cmake-format, cmake-lint (via `cmakelang`).
- **CLI**: ripgrep, fd, bat, fzf, zoxide, eza, zellij, ast-grep, stylua, tree-sitter, lazygit, yazi, myrepos (`mr`), gita, opencode.
- **Terminal multiplexer**: Oh My Tmux config (Nord theme, mouse on, TPM with `tmux-sensible` and `tmux-pomodoro-plus`).
- **Languages**: Rust (rustup), Node 22, Python 3 (system).

## Quick start

Clone anywhere; the platform installer copies the editor config into `~/.config/nvim` for you:

```bash
git clone <this repo> ~/code/RemoteCppConfiger
```

(If `~/.config/nvim` already exists, the installer moves it aside to `~/.config/nvim.bak.<timestamp>` before copying.)

### Linux (Ubuntu 22 / 24)

```bash
cd ~/code/RemoteCppConfiger/ubuntu_install_scripts
./install_all.sh
```

One-liner with a custom install prefix:

```bash
cd ~/code/RemoteCppConfiger && PREFIX=/media/volume/workspace bash ubuntu_install_scripts/install_all.sh
```

The NVIDIA HPC SDK is **off by default** (the tarball is ~8.5 GB). Opt in with:

```bash
cd ~/code/RemoteCppConfiger && PREFIX=/media/volume/workspace INSTALL_NVHPC=1 bash ubuntu_install_scripts/install_all.sh
```

Full LaTeX means full TeX Live only; lightweight variants such as TinyTeX/BasicTeX are not installed. It is **off by default** (~7 GB on Linux). Opt in with `INSTALL_LATEX=1`.

The installer keeps tool payloads under the prefix, including Spack at `$PREFIX/spack`, TeX Live at `$PREFIX/texlive` (when enabled), Rust and Python tool environments under `$PREFIX/lib`, Node under `$PREFIX/lib`, and command shims in `$PREFIX/bin`. User-facing config (Neovim, tmux, starship, fonts) is installed directly into the conventional `$HOME` paths; pre-existing files are moved aside with a `.bak.<timestamp>` suffix.

For the no-sudo path, see [`docs/install.md`](docs/install.md).

### Mac (Apple Silicon, Homebrew)

```bash
cd ~/code/RemoteCppConfiger/macconfig
./install_all.sh
```

Prerequisites: [Homebrew](https://brew.sh), Xcode Command Line Tools (for `git`). The macOS installer uses full MacTeX, not BasicTeX.

Then launch:

```bash
nvim
```

## Documentation

- [`docs/install.md`](docs/install.md) — full install walkthrough (sudo and no-sudo paths)
- [`docs/design.md`](docs/design.md) — architecture and trade-offs
- [`docs/troubleshooting.md`](docs/troubleshooting.md) — known issues and fixes
- [`docs/usage.md`](docs/usage.md) — keymap and snippet reference

## Layout

```
RemoteCppConfiger/                 # cloned anywhere
├── nvimconfig/                    # copied to ~/.config/nvim by installer
├── ubuntu_install_scripts/        # Linux installer (Ubuntu 22 / 24)
├── macconfig/                     # Mac installer (Brewfile + scripts)
├── shared/
│   ├── tmux/                      # tmux.conf.local (both platforms)
│   └── shell_rc/                  # one zsh+bash template, per-platform paths
└── docs/
```

Linux installs into one prefix: `$HOME/local/` by default, with Spack at `$HOME/local/spack/`. Mac uses Homebrew's prefix (`/opt/homebrew`) plus `$HOME/spack/`.

## Credits

Built on [NvChad](https://github.com/NvChad/NvChad). Inspired by the [LazyVim starter](https://github.com/LazyVim/starter).
