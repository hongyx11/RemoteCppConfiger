# Install

RemoteCppConfiger targets a freshly provisioned Linux box. Two paths depending on whether you have sudo. Stages 0, 2, 3 are identical; only Stage 1 (the C++ compiler) differs.

## Stage 0 — terminal stack

Required regardless of sudo. These are not strictly needed by Neovim but make the shell environment match the rest of the config.

| Tool | Purpose |
|---|---|
| `zsh` | interactive shell |
| `tmux` | terminal multiplexer |
| `starship` | prompt |

Install via the distro package manager (sudo) or as static binaries dropped into `$HOME/local/bin` (no sudo). Starship ships a one-shot installer that respects `--bin-dir`:

```bash
curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/local/bin" -y
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
git clone --depth=1 https://github.com/spack/spack.git "$HOME/spack"
. "$HOME/spack/share/spack/setup-env.sh"   # add to ~/.zshrc to persist
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

All binaries land in `$HOME/local/bin` (already on `PATH` if `.zshrc` has `export PATH="$HOME/local/bin:$PATH"`).

| Tool | Source | Notes |
|---|---|---|
| `nvim` | source build | latest stable tag |
| `ninja` | github prebuilt | `ninja-linux.zip` |
| `clang`, `clang++`, `clangd`, `clang-format`, `clang-tidy` | github prebuilt | LLVM 18 on Ubuntu 22.04, LLVM 19 on Ubuntu 24.04 (auto-detected; see [design.md](design.md)) |
| `cargo`, `rustc`, `rustup` | rustup | `RUSTUP_HOME` / `CARGO_HOME` under `$HOME/local/lib`, wrapped in `$HOME/local/bin` |
| `node`, `npm` | nodejs.org tarball | v22 LTS |
| `pyright`, `pyright-langserver` | npm | Python LSP |
| `lua-language-server` | github prebuilt | Lua LSP |
| `tree-sitter` | github prebuilt | latest on Ubuntu 24.04; pinned to v0.22.6 on Ubuntu 22.04 (auto-detected) |
| `rg`, `fd`, `bat`, `eza`, `zellij`, `stylua`, `ast-grep`/`sg` | github prebuilts | rust-based CLIs |
| `lazygit`, `yazi` | github prebuilts | TUI helpers |

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
rm -rf $HOME/local $HOME/spack
```

No system files were modified (sudo path aside, where `apt` installs are subject to normal `apt remove`).
