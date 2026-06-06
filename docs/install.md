# Install

RemoteCppConfiger supports Ubuntu 22.04 / 24.04 (with or without sudo) and macOS (Apple Silicon, Homebrew). The macOS install is single-step via `brew bundle`; the Linux install is staged.

## macOS

### Prerequisites

- [Homebrew](https://brew.sh) installed and on PATH.
- Xcode Command Line Tools (`xcode-select --install`) — provides `git`.

### One-liner

```bash
git clone <this repo> ~/code/RemoteCppConfiger
cd ~/code/RemoteCppConfiger/macconfig && ./install_all.sh
```

`install_all.sh` copies `nvimconfig/` into `~/.config/nvim`; an existing config at that path is moved aside to `~/.config/nvim.bak.<timestamp>` first.

### What gets installed

- All editor and CLI tools listed in `macconfig/Brewfile` (nvim, ripgrep, fd, bat, eza, zellij, lazygit, mr/myrepos, opencode, llvm, lua-language-server, pyright, ast-grep, stylua, tree-sitter, node, uv, rustup, starship, just, gh, fzf, zoxide, yazi, tmux, mactex, font-maple-mono-nf), plus Python CLI tools such as gita.
- Rust via `rustup-init`.
- Spack at `$HOME/spack` (mirrors the Linux layout). To use a different location, set `SPACK_ROOT` before running `install_all.sh`.
- Oh My Tmux into `~/.tmux`, with our customizations seeded into `~/.tmux.conf.local` (only if absent).
- A managed block in `~/.zshrc` and `~/.bashrc` that sets PATH for brew + LLVM + cargo, initializes starship/fzf/zoxide, defines a lazy `spack()` stub, and (zsh-only) caches `compinit`.

### Where things live

- Brew packages: `/opt/homebrew/...` (Apple Silicon) or `/usr/local/...` (Intel).
- Spack: `$HOME/spack` (override with `SPACK_ROOT=...`).
- Cargo / rustup: `$HOME/.cargo`, `$HOME/.rustup`.
- nvim config: `~/.config/nvim` (copied from `<repo>/nvimconfig` by `install_all.sh`).

### OMZ compinit speedup

If you use Oh My Zsh, the cached-compinit speedup in our managed block runs *after* OMZ's slow path, so it has no effect by default. To activate it, paste this snippet into `~/.zshrc` immediately *before* `source $ZSH/oh-my-zsh.sh`:

```zsh
ZSH_DISABLE_COMPFIX=true
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
```

`setup_shell_rc.sh` detects OMZ and prints this snippet at install time as a reminder.

## Ubuntu (Linux)

Two paths depending on whether you have sudo. Stages 0, 2, 3 are identical; only Stage 1 (the C++ compiler) differs.

## Stage 0 — terminal stack

Required regardless of sudo. These are not strictly needed by Neovim but make the shell environment match the rest of the config.

| Tool | Purpose |
|---|---|
| `zsh` | interactive shell |
| `tmux` | terminal multiplexer |
| `starship` | prompt |

Install via the distro package manager (sudo) or as static binaries dropped into `$PREFIX/bin` (no sudo). Starship ships a one-shot installer that respects `--bin-dir`:

```bash
curl -sS https://starship.rs/install.sh | sh -s -- -b "${PREFIX:-$HOME/local}/bin" -y
```

## Stage 1 — C++ compiler (gcc/g++ 12)

The default compiler target is **gcc-12 / g++-12**.

### With sudo (apt)

```bash
sudo apt update
sudo apt install -y build-essential gcc-12 g++-12
```

### Without sudo (Spack)

Install Spack first (see Stage 2), then:

```bash
spack install gcc@12
```

Either way, you end with a working `gcc-12` / `g++-12` toolchain on disk.

## Stage 2 — Spack

Spack is the package manager for libraries (MPI, BLAS, HDF5, …) on both paths. On no-sudo systems it is also where the compiler comes from.

```bash
PREFIX="${PREFIX:-$HOME/local}"
git clone --depth=1 https://github.com/spack/spack.git "$PREFIX/spack"
. "$PREFIX/spack/share/spack/setup-env.sh"   # add to ~/.zshrc to persist
```

Register gcc-12 as the external compiler so Spack uses it for everything else it builds:

```bash
# apt path: /usr/bin/gcc-12
spack compiler find /usr

# spack-built path
spack compiler find "$(spack location -i gcc@12)"

spack compiler list   # should show gcc@12.x.x
```

From here on, `spack install <pkg>` uses gcc-12 by default.

## Stage 3 — Neovim config + dev tools

```bash
git clone <repo> ~/.config/nvim
cd ~/.config/nvim/install_dependencies
./install_all.sh
```

All package payloads land under one prefix: `$PREFIX` (`$HOME/local` by default). Spack lands in `$PREFIX/spack`, full TeX Live in `$PREFIX/texlive` (only when `INSTALL_LATEX=1`), Rust/Python tool environments and Node land under `$PREFIX/lib`, and command shims/symlinks land in `$PREFIX/bin`.

When LaTeX is requested, the installer uses full TeX Live only. Lightweight alternatives such as TinyTeX or BasicTeX are intentionally not installed.

User-facing config (Neovim, tmux, starship, fonts) is installed directly into the conventional `$HOME` paths. Pre-existing files at those paths are moved aside with a `.bak.<timestamp>` suffix.

`install_all.sh` skips the NVIDIA HPC SDK by default (the tarball is ~8.5 GB). To opt in:

```bash
INSTALL_NVHPC=1 ./install_all.sh
```

| Tool | Source | Notes |
|---|---|---|
| `nvim` | source build | latest stable tag |
| `ninja` | github prebuilt | `ninja-linux.zip` |
| `clang`, `clang++`, `clangd`, `clang-format`, `clang-tidy` | github prebuilt | LLVM 18 on Ubuntu 22.04, LLVM 19 on Ubuntu 24.04 (auto-detected; see [design.md](design.md)) |
| `cargo`, `rustc`, `rustup` | rustup | `RUSTUP_HOME` / `CARGO_HOME` under `$PREFIX/lib`, wrapped in `$PREFIX/bin` |
| `node`, `npm` | nodejs.org tarball | v22 LTS |
| `pyright`, `pyright-langserver` | npm | Python LSP |
| `bash-language-server`, `yaml-language-server` | npm | Shell/YAML LSPs |
| `lua-language-server` | github prebuilt | Lua LSP |
| `tree-sitter` | github prebuilt | latest on Ubuntu 24.04; pinned to v0.22.6 on Ubuntu 22.04 (auto-detected) |
| `rg`, `fd`, `bat`, `eza`, `zellij`, `stylua`, `ast-grep`/`sg` | github prebuilts | rust-based CLIs |
| `lazygit`, `yazi` | github prebuilts | TUI helpers |
| `mr` | myrepos source checkout | multi-repository manager |
| `gita` | PyPI via uv | multi-repository Git dashboard/runner |
| `opencode` | npm package `opencode-ai` | AI coding agent; deploys saved config from `myconfig` when present |

## Stage 4 — verify

```bash
nvim --headless "+checkhealth" "+qa" 2>&1 | less
```

Open a `.cpp` file and confirm clangd attaches:

```vim
:LspInfo
```

You should see `clangd` running, with the resource dir pointing inside `$HOME/local/lib/llvm-18.1.8`.

## Uninstall

Everything is contained:

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim
rm -rf "${PREFIX:-$HOME/local}"
```

No system files were modified (sudo path aside, where `apt` installs are subject to normal `apt remove`).
