# RemoteCppConfiger

Out-of-the-box C++ development environment for a raw Linux box. One install script lays down a Neovim-based editor, an LLVM toolchain, gcc-12 (apt or Spack), Rust, Node, and a curated set of CLI tools — all under `$HOME/local`.

Designed to work on hosts with **or without** sudo. The only thing that branches is how gcc-12 is acquired; everything else installs identically.

## What you get

- **Editor**: Neovim (latest) + an NvChad-derived config tuned for C++, MPI, CMake.
- **C++ toolchain**: gcc/g++ 12 (apt or `spack install gcc@12`), plus prebuilt LLVM 18.1.8 (clangd, clang-format, clang-tidy, libomp).
- **Package manager**: Spack, with gcc-12 registered as the external compiler.
- **LSPs**: clangd, pyright, lua-language-server, html, css.
- **CLI**: ripgrep, fd, bat, eza, zellij, ast-grep, stylua, tree-sitter, lazygit, yazi.
- **Languages**: Rust (rustup), Node 22, Python 3 (system).

## Quick start

```bash
git clone <this repo> ~/.config/nvim
cd ~/.config/nvim/install_dependencies
./install_all.sh
```

Add to `~/.zshrc` if not already present:

```bash
export PATH="$HOME/local/bin:$PATH"
```

Then launch:

```bash
nvim
```

For the no-sudo path, see [`docs/install.md`](docs/install.md).

## Documentation

- [`docs/install.md`](docs/install.md) — full install walkthrough (sudo and no-sudo paths)
- [`docs/design.md`](docs/design.md) — architecture and trade-offs
- [`docs/troubleshooting.md`](docs/troubleshooting.md) — known issues and fixes
- [`docs/usage.md`](docs/usage.md) — keymap and snippet reference

## Layout

```
~/.config/nvim/                # editor config (this repo)
  init.lua                     # entry point
  lua/                         # plugins, configs, snippets
  install_dependencies/        # install scripts
  docs/                        # documentation

$HOME/local/                   # all installed binaries and libs
  bin/                         # first on PATH
  lib/                         # rustup, cargo, node, llvm-18.1.8, lua-ls, ...

$HOME/spack/                   # Spack checkout (compiler + libraries)
```

## Credits

Built on [NvChad](https://github.com/NvChad/NvChad). Inspired by the [LazyVim starter](https://github.com/LazyVim/starter).
