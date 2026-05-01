# Design

## Goals

1. Bootstrap a C++ dev environment on a raw Linux box without forcing sudo.
2. Pin tool versions deterministically.
3. Keep everything under `$HOME/local/`, `$HOME/.config/nvim/`, and `$HOME/spack/` — uninstall is `rm -rf`.
4. Identical Neovim/LSP/tooling layer regardless of compiler-install path; the only thing that branches is gcc-12 acquisition.

## Two install paths

| Concern | sudo path | no-sudo path |
|---|---|---|
| C++ compiler | `apt install build-essential gcc-12 g++-12` | `spack install gcc@12` |
| System libraries (MPI, BLAS, …) | apt and/or Spack | Spack |
| Dev tools (LLVM, rust, node, LSPs) | `$HOME/local/bin` | `$HOME/local/bin` |
| Editor & config | `~/.config/nvim` | `~/.config/nvim` |

Only Stage 1 (the compiler) differs. Everything downstream installs the same way regardless. This keeps the install script testable on both paths and minimizes documentation drift.

## Why Spack on both paths

Even with sudo, projects often need specific MPI implementations, library variants, or coexistent toolchains. Spack solves that:

- **Reproducible**: every package + version + variant pinned via concretization.
- **Coexistence**: multiple GCC versions or MPI builds side by side.
- **External compiler**: `spack compiler find` registers an apt-installed gcc-12 the same way as a Spack-built one. Downstream `spack install` commands are identical on both paths.

## Why prebuilt LLVM (not source build)

|  | prebuilt | source build |
|---|---|---|
| time | ~1.5 min | 1–3 hours on 8 cores |
| OpenMP runtime (`libomp.so`, `libomptarget*`) | included | requires `LLVM_ENABLE_PROJECTS=openmp` |
| size | ~7 GB extracted | similar |
| customization | none | full CMake control |

`install_llvm.sh` auto-picks the right prebuilt based on host glibc:

| Host | glibc | LLVM | Asset | libtinfo5 shim |
|---|---|---|---|---|
| Ubuntu 22.04 | 2.35 | 18.1.8 | `clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04.tar.xz` | yes |
| Ubuntu 24.04 | 2.39 | 19.1.7 | `LLVM-19.1.7-Linux-X64.tar.xz` | no |

The split exists because LLVM 19+ ships only a generic Linux prebuilt that requires glibc ≥ 2.38. Ubuntu 22.04 (glibc 2.35) needs the older Ubuntu-18.04-tagged build, which links `libtinfo.so.5` — gone from 22.04 — so the install script extracts it from the Ubuntu archive.

Override via env vars: `LLVM_VERSION=X.Y.Z LLVM_ASSET=foo.tar.xz NEED_LIBTINFO5=0 ./install_llvm.sh`.

Trade-offs:

- ✅ OpenMP works on both paths (compiler frontend + `libomp.so` + offload bitcode).
- ✅ Same `clangd`/`clang-format`/`clang-tidy` binaries the LLVM team produces.
- ⚠️ Bleeding-edge LLVM (>19) needs a from-source build (not in this script).

## `$HOME/local` layout

```
$HOME/local/
├── bin/                      # first thing on PATH; small wrappers + symlinks
├── lib/
│   ├── cargo/                # CARGO_HOME (registry + cached crates)
│   ├── rustup/               # RUSTUP_HOME (toolchains)
│   ├── node-v22.../
│   ├── llvm-18.1.8/          # full LLVM tree, RUNPATH=$ORIGIN/../lib
│   ├── lua-language-server/
│   ├── pyright/              # node_modules vendored
│   └── libtinfo.so.5*        # extracted from libtinfo5 .deb (LLVM 18 needs it)
├── src/                      # download cache; safe to delete
└── share/                    # man pages, completions
```

`bin/cargo`, `bin/rustc`, `bin/rustup` are wrapper scripts that export `RUSTUP_HOME` / `CARGO_HOME` before exec — no shell rc edits required.

## `$HOME/local/bin` first on PATH

```bash
# in ~/.zshrc
export PATH="$HOME/local/bin:$HOME/.local/bin:$PATH"
```

Tools installed here intentionally **shadow** any system versions of the same name — that's the point. We pin specific clangd, tree-sitter, and Rust versions because Neovim plugins assume them.

## tree-sitter auto-pin

| Host | tree-sitter |
|---|---|
| Ubuntu 22.04 (glibc 2.35) | v0.22.6 (last release that runs on 2.35) |
| Ubuntu 24.04 (glibc ≥ 2.39) | latest |

`install_clis.sh` reads glibc and chooses automatically. Override with `TREE_SITTER_VER=vX.Y.Z`.

## What we deliberately don't do

- **Don't modify `/etc` or `/usr` on no-sudo paths.** Everything lives under `$HOME`.
- **Don't bundle our own glibc.** Manually swapping system glibc bricks the host. If you need newer glibc, upgrade the OS or use a container.
- **Don't manage Python or virtualenvs.** The user's choice; pyright works against any interpreter via `pyright` config.
- **Don't ship a system-wide MPI.** Use Spack for MPI builds tied to gcc-12.

## Platform layout

```
RemoteCppConfiger/
├── nvimconfig/                # → ~/.config/nvim (symlink)
├── ubuntu_install_scripts/    # Linux installer (16 byte-identical from pre-restructure + 2 touched)
├── macconfig/                 # Mac installer (Brewfile + tmux/rust/spack/fonts/setup_shell_rc)
└── shared/
    ├── tmux/tmux.conf.local         # one copy, both platforms reference it
    └── shell_rc/
        ├── template.{zsh,bash}      # single managed-block template per shell, w/ {{PLATFORM_PATH_BLOCK}}
        ├── paths.{linux,mac}        # per-platform PATH lines
        ├── render.sh                # splice paths into template
        └── setup.sh                 # idempotent rc-file installer
```

The Mac installer deliberately skips the LLVM-tarball-with-libtinfo logic, the glibc-aware tree-sitter pin, and the `$HOME/local` no-sudo prefix. Mac uses Homebrew's `/opt/homebrew` prefix for binaries; Spack still installs at `$HOME/spack` (mirrors Linux). The shell-rc template is shared across platforms and substitutes only the PATH block at render time, so changes to the rest of the managed block (initializers, aliases, lazy spack, cached compinit) land on both platforms in one edit.
