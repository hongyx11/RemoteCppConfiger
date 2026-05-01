# Troubleshooting

## `libtinfo.so.5: cannot open shared object file`

Symptom — running clangd or clang from `$HOME/local/bin`:

```
clangd: error while loading shared libraries: libtinfo.so.5
```

Cause: Ubuntu 22.04 ships only `libtinfo.so.6`. The LLVM 18.1.8 prebuilt was compiled on ubuntu-18.04 and links the older soname. A symlink from `.so.6` → `.so.5` will not work — the symbol versions differ.

Fix (no sudo) — extract `libtinfo5_*.deb` from the Ubuntu archive:

```bash
cd /tmp
curl -O http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb
dpkg-deb -x libtinfo5_*.deb /tmp/extract
cp -P /tmp/extract/lib/x86_64-linux-gnu/libtinfo.so.5* "$HOME/local/lib/llvm-18.1.8/lib/"
```

Why this works: clangd's `RUNPATH` is `$ORIGIN/../lib`, which resolves to `$HOME/local/lib/llvm-18.1.8/lib/`. Dropping `libtinfo.so.5` there is enough — no `LD_LIBRARY_PATH` needed.

The install script does this automatically.

## `tree-sitter: GLIBC_2.39 not found`

```
tree-sitter: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
```

Cause: the latest tree-sitter CLI prebuilts target glibc 2.39 (Ubuntu 24.04). Ubuntu 22.04 has glibc 2.35.

Fix: pin to **v0.22.6** — the last release that runs on glibc 2.35.

```bash
curl -fL -o ts.gz https://github.com/tree-sitter/tree-sitter/releases/download/v0.22.6/tree-sitter-linux-x64.gz
gunzip ts.gz && install -m755 ts "$HOME/local/bin/tree-sitter"
```

The install script applies this pin automatically.

## `libomp.so: cannot open shared object file`

```
./a.out: error while loading shared libraries: libomp.so
```

Cause: `clang -fopenmp foo.c` compiles and links fine because the linker found `libomp.so` in `~/local/lib/llvm-18.1.8/lib`, but the *resulting binary* doesn't have that path baked into its rpath.

Fixes, in order of cleanliness:

1. **Bake the rpath at link time** (recommended):
   ```bash
   clang -fopenmp -Wl,-rpath,"$HOME/local/lib/llvm-18.1.8/lib" foo.c -o foo
   ```
2. Symlink into a path the linker already searches and add it to a project-local `LD_LIBRARY_PATH`:
   ```bash
   ln -s "$HOME/local/lib/llvm-18.1.8/lib/libomp.so" "$HOME/local/lib/libomp.so"
   ```
3. Set `LD_LIBRARY_PATH` in the shell rc (last resort — pollutes everything).

For CMake, `find_package(OpenMP REQUIRED)` + `target_link_libraries(... OpenMP::CXX)` produces correct rpath automatically.

## `rustup could not choose a version of cargo to run`

```
error: rustup could not choose a version of cargo to run, because one wasn't specified explicitly, and no default is configured
```

Cause: rustup was installed but no default toolchain was set.

Fix (one-shot):

```bash
"$HOME/local/bin/rustup" default stable
```

The `cargo`/`rustc`/`rustup` wrappers in `$HOME/local/bin` already set `RUSTUP_HOME` and `CARGO_HOME`, but the toolchain default is per-install state and must be set once.

## clangd doesn't see `-fopenmp`

If you have `#pragma omp parallel` and clangd is silent about it (no completions on `omp_get_thread_num`, no diagnostics on bad `reduction(...)` clauses), `-fopenmp` is missing from your `compile_commands.json`.

Fix in CMake:

```cmake
find_package(OpenMP REQUIRED)
target_link_libraries(mytarget PRIVATE OpenMP::CXX)
```

CMake injects `-fopenmp` into the compile DB; clangd picks it up on next reload.

Alternatively, force it via `.clangd` at the project root:

```yaml
CompileFlags:
  Add: [-fopenmp]
```

## `nvim-treesitter.info` module not found

```
~/.config/nvim/lua/plugins/init.lua:105: module 'nvim-treesitter.info' not found
```

Cause: `nvim-treesitter` `main` branch reorganized its modules; `info` no longer exists. The plugin's auto-install logic in this repo predates the change.

Fix: replace the call with the new API, or pin `nvim-treesitter` to a pre-rewrite commit in `lazy-lock.json`. lazy.nvim isolates plugin config errors, so this doesn't break other plugins, but it does suppress auto-install of parsers — they install on first `:TSInstall <lang>`.

## Should I upgrade glibc to escape these caps?

No — manually swapping the system glibc bricks the host (it's the loader for `bash`, `sudo`, `apt`, everything). Three sane alternatives:

| | effort | risk | when |
|---|---|---|---|
| `do-release-upgrade` 22.04 → 24.04 | low | low | best — 24.04 ships glibc 2.39, both pins (LLVM 19+, tree-sitter latest) drop |
| distrobox / podman 24.04 image | low | none | run a 24.04 shell on top of 22.04 host |
| build glibc into `$HOME/local`, run binaries with explicit `--ldso ... --library-path` | high | medium | one-off binaries only |
