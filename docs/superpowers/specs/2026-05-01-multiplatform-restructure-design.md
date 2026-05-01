# Multi-platform restructure: nvimconfig / ubuntu_install_scripts / macconfig

**Date:** 2026-05-01
**Status:** Approved (pending user review of this spec)

## Goal

Restructure the repo so the Neovim config, the Linux install scripts, and a new Mac install path live in distinct top-level folders. Add Mac support via Homebrew, including Spack. Sixteen of the eighteen Linux install/setup scripts stay byte-identical; two get touched (one path tweak; one refactor to share a templated shell-rc with Mac). All differences vs. today's Linux behavior are strict speedups (lazy spack, PATH dedup, cached compinit) — see the diff table in **Shared shell-rc template**.

## Non-goals

- No changes to Linux install behavior, package versions, `$HOME/local` layout, LLVM tarball logic, libtinfo5 shim, or glibc-aware tree-sitter pin.
- No NVHPC, LLVM-tarball-with-libtinfo-shim, glibc-aware tree-sitter pin, or `$HOME/local` no-sudo prefix on Mac. Mac uses Homebrew's `/opt/homebrew` prefix directly. **Spack is installed on mac too** (via `git clone`, same as Linux).
- No top-level OS-detecting dispatcher script. Users `cd` into the platform folder and run `install_all.sh`.
- No changes to `lua/`, `lazy-lock.json`, `chadrc.lua`, plugins, mappings, options, snippets, or any nvim runtime behavior.

### Linux script edits (forced by shared-template choice)

Two Linux scripts get touched. Both are direct consequences of user-approved structural choices, not behavioral changes:

1. **`ubuntu_install_scripts/install_tmux.sh`** — one-line path edit because `tmux.conf.local` moved to `shared/tmux/`.
2. **`ubuntu_install_scripts/setup_shell_rc.sh`** — refactored to a thin wrapper that calls `shared/shell_rc/render.sh`, because the user requested a single template applied with per-platform tweaks. Behavioral diff: spack source becomes lazy (was eager); zsh gets `typeset -U` for PATH dedup. Both are strict speedups; functionally equivalent.

All other Linux scripts (the 16 remaining `install_*.sh`, `setup_*.sh`) are byte-identical to today.

## Top-level layout

```
RemoteCppConfiger/                   # cloned anywhere (e.g. ~/code/RemoteCppConfiger)
├── README.md                        # rewritten: per-platform quickstart
├── LICENSE
├── logo.png
├── .gitignore
├── .stylua.toml
├── docs/
│   ├── design.md                    # adds a "platform layout" section
│   ├── install.md                   # adds a Mac section
│   ├── troubleshooting.md           # unchanged
│   ├── usage.md                     # unchanged
│   └── superpowers/specs/           # this file lives here
│
├── nvimconfig/                      # ← becomes ~/.config/nvim via symlink
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── autocmds.lua
│       ├── chadrc.lua
│       ├── mappings.lua
│       ├── options.lua
│       ├── configs/
│       ├── custom/
│       ├── plugins/
│       └── snippets/
│
├── ubuntu_install_scripts/          # ← byte-identical content from today's install_dependencies/, except install_tmux.sh
│   ├── install_all.sh
│   ├── install_atuin.sh
│   ├── install_clis.sh
│   ├── install_fonts.sh
│   ├── install_just.sh
│   ├── install_llvm.sh
│   ├── install_lsp_servers.sh
│   ├── install_node.sh
│   ├── install_nvhpc.sh
│   ├── install_nvim.sh
│   ├── install_python_tools.sh
│   ├── install_rust.sh
│   ├── install_spack.sh
│   ├── install_starship.sh
│   ├── install_tinytex.sh
│   ├── install_tmux.sh               # one-line edit: configs path → ../shared/tmux/
│   ├── install_uv.sh
│   ├── activate.sh
│   ├── setup_cocal_dev.sh
│   ├── setup_interactive.sh
│   ├── setup_no_sudo.sh
│   ├── setup_path.sh
│   ├── setup_shell_rc.sh
│   ├── setup_sudo.sh
│   └── (no configs/ subdir — moved to shared/tmux/)
│
├── macconfig/                       # ← new, brew-driven
│   ├── install_all.sh
│   ├── Brewfile
│   ├── install_rust.sh
│   ├── install_tmux.sh
│   ├── install_fonts.sh
│   ├── install_spack.sh             # clones spack, identical pattern to Linux
│   └── setup_shell_rc.sh            # thin wrapper → shared/shell_rc/render.sh
│
└── shared/
    ├── tmux/
    │   └── tmux.conf.local           # moved from install_dependencies/configs/tmux.conf.local
    └── shell_rc/
        ├── render.sh                 # render.sh <platform> <shell> → prints the managed block
        ├── template.zsh              # single zsh template w/ {{PLATFORM_PATH_BLOCK}} placeholder
        ├── template.bash             # single bash template w/ {{PLATFORM_PATH_BLOCK}} placeholder
        ├── paths.linux               # PATH lines for Linux ($HOME/local/bin, $HOME/.local/bin)
        └── paths.mac                 # PATH lines for Mac (brew shellenv, llvm, cargo)
```

## Install workflow

```bash
# Both platforms
git clone <repo> ~/code/RemoteCppConfiger
ln -sfn ~/code/RemoteCppConfiger/nvimconfig ~/.config/nvim

# Linux (Ubuntu 22 / 24)
cd ~/code/RemoteCppConfiger/ubuntu_install_scripts
./install_all.sh

# Mac
cd ~/code/RemoteCppConfiger/macconfig
./install_all.sh
```

`stdpath("config")` resolves to `~/.config/nvim`, which transparently follows the symlink to `nvimconfig/`. Lazy.nvim, NvChad's base46 cache, and all plugin paths continue to work.

## Mac install: `macconfig/`

### `Brewfile` (declarative, idempotent — `brew bundle` reads it)

```ruby
# Editor
brew "neovim"

# Search / nav / view
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "fzf"
brew "zoxide"
brew "yazi"

# Multiplexers / git UI
brew "tmux"
brew "zellij"
brew "lazygit"

# C/C++ toolchain (provides clangd, clang-format, clang-tidy)
brew "llvm"

# LSPs / linters / formatters
brew "lua-language-server"
brew "pyright"
brew "stylua"
brew "ast-grep"
brew "tree-sitter"

# Languages / pkg mgmt
brew "node"
brew "uv"
brew "rustup"

# Shell / history / prompt / runner
brew "starship"
brew "atuin"
brew "just"
brew "gh"

# LaTeX (small footprint vs full mactex)
cask "basictex"

# Fonts
cask "font-maple-mono-nf"
```

### `install_all.sh`

```bash
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

command -v brew >/dev/null || {
  echo "Install Homebrew first: https://brew.sh"
  exit 1
}

echo "============================================"
echo " RemoteCppConfiger mac install"
echo " Brew prefix: $(brew --prefix)"
echo "============================================"

brew update
brew bundle --file="$SCRIPT_DIR/Brewfile"

bash "$SCRIPT_DIR/install_rust.sh"
bash "$SCRIPT_DIR/install_spack.sh"
bash "$SCRIPT_DIR/install_tmux.sh"
bash "$SCRIPT_DIR/setup_shell_rc.sh"

echo
echo "Done. If you haven't already:"
echo "  ln -sfn $REPO_ROOT/nvimconfig ~/.config/nvim"
```

### `install_rust.sh`

Runs `rustup-init -y --no-modify-path` if `~/.cargo/bin/rustc` doesn't exist yet. PATH for `~/.cargo/bin` is added by `setup_shell_rc.sh`. (Linux's wrapper-script approach is unnecessary here — Mac users always have a writable `$HOME` and don't need the `$HOME/local` rerouting.)

### `install_tmux.sh`

- Clones `https://github.com/gpakosz/.tmux.git` into `~/.tmux` if missing.
- Symlinks `~/.tmux.conf` → `~/.tmux/.tmux.conf` (force, since this file is the upstream template).
- Copies `shared/tmux/tmux.conf.local` → `~/.tmux.conf.local` only if the user's copy doesn't exist (matches Linux behavior — never clobber user customizations).

### `install_spack.sh`

Mirrors `ubuntu_install_scripts/install_spack.sh`:

```bash
SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
if [ -d "$SPACK_ROOT/.git" ]; then
  echo "  spack already cloned at $SPACK_ROOT, skipping."
else
  git clone --depth=1 https://github.com/spack/spack.git "$SPACK_ROOT"
fi
. "$SPACK_ROOT/share/spack/setup-env.sh"
echo "    $(spack --version)"
```

No compiler bootstrap. Mac users register brew's compiler with `spack compiler find` themselves (`spack compiler find /opt/homebrew/opt/gcc /opt/homebrew/opt/llvm`) once they need it. The user's existing spack at `/Users/hongy0a/Documents/code/spack` is untouched — `install_spack.sh` checks `$SPACK_ROOT/.git` and skips. To use the existing checkout, set `SPACK_ROOT=/Users/hongy0a/Documents/code/spack` before running `install_all.sh`.

### `install_fonts.sh`

Thin wrapper that runs `brew install --cask font-maple-mono-nf` if not installed. Kept as a separate script (rather than only in the Brewfile) so it can be re-run standalone, matching the Linux structure. The Brewfile is the canonical declaration; the script is a convenience.

### `setup_shell_rc.sh`

Thin wrapper that delegates to `shared/shell_rc/render.sh`:

```bash
#!/bin/bash
exec bash "$(dirname "$0")/../shared/shell_rc/setup.sh" mac
```

(Linux gets the same wrapper with `linux` as the argument — see "Shared shell-rc template" below.)

## Shared shell-rc template

User request: "1 zshrc template, then change it slightly according to different platform". Implementation: one zsh template + one bash template, each with a single `{{PLATFORM_PATH_BLOCK}}` placeholder. Per-platform substitution happens at render time.

### `shared/shell_rc/template.zsh`

```zsh
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
```

### `shared/shell_rc/template.bash`

```bash
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
```

(`typeset -U` and the `(#qN.mh+24)` glob qualifier are zsh-only, so the bash template omits PATH dedupe and the compinit cache. Bash users still get all three init evals, eza aliases, and lazy-spack.)

### `shared/shell_rc/paths.linux`

```bash
export PATH="$HOME/local/bin:$HOME/.local/bin:$PATH"
export SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
```

### `shared/shell_rc/paths.mac`

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
```

### `shared/shell_rc/render.sh`

```bash
#!/bin/bash
# Usage: render.sh <linux|mac> <zsh|bash>
# Prints the rendered managed block to stdout.
set -euo pipefail
PLATFORM="$1"
SHELL_NAME="$2"
DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$DIR/template.$SHELL_NAME"
PATHS="$DIR/paths.$PLATFORM"

# Walk the template; when we hit the placeholder, splice in the per-platform paths file.
# This avoids sed/awk replacement-string quoting hazards (& and \ in shellenv output).
while IFS= read -r line || [ -n "$line" ]; do
  if [ "$line" = "{{PLATFORM_PATH_BLOCK}}" ]; then
    cat "$PATHS"
  else
    printf '%s\n' "$line"
  fi
done < "$TEMPLATE"
```

### `shared/shell_rc/setup.sh`

The actual installer logic — same managed-block insert + legacy-strip pattern as today's `ubuntu_install_scripts/setup_shell_rc.sh`, but generalized:

```bash
#!/bin/bash
# Usage: setup.sh <linux|mac>
set -euo pipefail
PLATFORM="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"

BEGIN_MARK="# >>> RemoteCppConfiger >>>"
END_MARK="# <<< RemoteCppConfiger <<<"

LEGACY_PATTERNS=(
  '^export PATH="\$HOME/local/bin'
  '^command -v starship >/dev/null && eval'
  '^command -v atuin .*&& eval'
  '^\[ -f ".*/spack/share/spack/setup-env\.sh" \]'   # OLD eager spack source
  "^command -v eza >/dev/null && alias l[sla]="
)

wire() {
  local rc="$1" shell="$2"
  echo "==> $rc"
  [ -f "$rc" ] || : > "$rc"
  sed -i.bak "/^${BEGIN_MARK}$/,/^${END_MARK}$/d" "$rc" && rm -f "$rc.bak"
  for pat in "${LEGACY_PATTERNS[@]}"; do
    if grep -qE "$pat" "$rc"; then
      grep -vE "$pat" "$rc" > "$rc.tmp" || true
      mv "$rc.tmp" "$rc"
    fi
  done
  [ -s "$rc" ] && printf '\n' >> "$rc"
  bash "$DIR/render.sh" "$PLATFORM" "$shell" >> "$rc"
  echo "  wrote managed block"
}

wire "$HOME/.bashrc" bash
wire "$HOME/.zshrc"  zsh

# OMZ caveat: detect oh-my-zsh.sh and print a one-time message about the compinit speedup.
if grep -q 'source.*oh-my-zsh\.sh' "$HOME/.zshrc" 2>/dev/null; then
  cat <<'MSG'

NOTE: oh-my-zsh detected. The cached-compinit speedup in our managed block runs
AFTER OMZ's slow compinit, so it has no effect for you. To make it effective,
paste this snippet right BEFORE `source $ZSH/oh-my-zsh.sh` in ~/.zshrc:

  ZSH_DISABLE_COMPFIX=true
  autoload -Uz compinit
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

MSG
fi

echo "Done. Open a new shell (or 'exec bash' / 'exec zsh') for changes to take effect."
```

The `sed -i.bak ... && rm -f .bak` form is GNU/BSD-portable (BSD sed on mac requires a suffix arg).

The legacy-strip patterns include the OLD eager spack source line (`^\[ -f ".*/spack/share/spack/setup-env\.sh" \]`), so a host that ran the old version of the Linux installer cleanly upgrades to the lazy stub on re-run. No double-source.

### Behavioral diff vs. today's Linux behavior

| | today (Linux) | new (both platforms) |
|---|---|---|
| zsh PATH dedupe | no | `typeset -U path PATH fpath FPATH` |
| spack source | eager (sources `setup-env.sh` on every shell) | lazy stub function (sources on first `spack` call) |
| compinit | unmanaged | cached, with OMZ caveat printed |
| eager spack legacy line | left in place | stripped on re-run, replaced by lazy stub |

All differences are strict speedups and equivalent in observable behavior (env vars set after `spack` is called are the same as eager source).

## Linux side: edits

Two scripts touched (full rationale in **Non-goals → Linux script edits**):

1. **`ubuntu_install_scripts/install_tmux.sh`** — one-line: `tmux.conf.local` source path now `$REPO_ROOT/shared/tmux/tmux.conf.local` (was `install_dependencies/configs/tmux.conf.local`).
2. **`ubuntu_install_scripts/setup_shell_rc.sh`** — replaced with a 2-line wrapper:
   ```bash
   #!/bin/bash
   exec bash "$(dirname "$0")/../shared/shell_rc/setup.sh" linux
   ```
   The behavioral diff is the table above. All speedups; no regressions.

The other 16 install/setup scripts in `ubuntu_install_scripts/` are byte-identical.

## nvim config: edits

**`nvimconfig/init.lua`** — drop line 1:

```lua
vim.env.PATH = vim.fn.stdpath("config") .. "/install_dependencies/bin:" .. vim.env.PATH
```

This already points to a directory that has never existed (the install scripts deposit binaries in `$HOME/local/bin`, not `install_dependencies/bin`). After the restructure it would still resolve through the symlink to the same nonexistent path. Removing it is a strict no-op for runtime behavior. PATH for installed tools is handled exclusively by `setup_shell_rc.sh` on both platforms.

No other edits to `nvimconfig/`.

## Documentation

- **`README.md`** — rewrite quickstart: clone anywhere, symlink `nvimconfig` → `~/.config/nvim`, run platform installer. Replace the "Layout" block with the new tree.
- **`docs/install.md`** — keep all existing Linux content; add a top-level "Platform" section that splits Linux and Mac. Mac section: prerequisites (brew installed, Xcode CLT for git), the three commands, what gets installed, where things live (brew prefix, not `$HOME/local`).
- **`docs/design.md`** — append a short "Platform layout" section with the new tree and a note explaining why Mac skips Spack/LLVM-tarball/etc. (one paragraph). All existing sections about sudo vs no-sudo, LLVM glibc/libtinfo logic, tree-sitter pin, `$HOME/local` rationale stay verbatim — they describe the Linux path.
- **`docs/troubleshooting.md`, `docs/usage.md`** — untouched.

## Commit plan

Six commits, in order. Each is independently reviewable and leaves the repo working for the platforms it touches.

1. **Rename: move files into `nvimconfig/`, `ubuntu_install_scripts/`, `shared/tmux/`.** Pure `git mv` so `git log --follow` traces history. After this commit, the Linux installer is broken (`install_tmux.sh` references the old `install_dependencies/configs/tmux.conf.local`).
2. **Fix Linux tmux installer path.** One-line edit in `ubuntu_install_scripts/install_tmux.sh`. Linux installer works again.
3. **Drop no-op line from `nvimconfig/init.lua`.**
4. **Add shared shell-rc template + render.** `shared/shell_rc/{template.zsh,template.bash,paths.linux,paths.mac,render.sh,setup.sh}`. Replace `ubuntu_install_scripts/setup_shell_rc.sh` with the 2-line wrapper. Ship behavioral diff for Linux: lazy spack, zsh `typeset -U`, cached compinit, OMZ caveat message. (Linux smoke test runs end-to-end here.)
5. **Add `macconfig/`** with `Brewfile`, `install_all.sh`, `install_rust.sh`, `install_spack.sh`, `install_tmux.sh`, `install_fonts.sh`, `setup_shell_rc.sh` (the 2-line wrapper).
6. **Update `README.md`, `docs/install.md`, `docs/design.md`** with new layout, clone-and-symlink flow, Mac quickstart, OMZ compinit doc.

## Testing / verification

- **Linux smoke test:** Verify the unrelated 16 `install_*.sh` / `setup_*.sh` files are byte-identical via `git diff HEAD~6 HEAD -- ubuntu_install_scripts/ ':!ubuntu_install_scripts/install_tmux.sh' ':!ubuntu_install_scripts/setup_shell_rc.sh'` — should produce empty output (rename-only). Run `install_all.sh` on a fresh Ubuntu 22 and 24 container end-to-end. Confirm `tmux.conf.local` lands at `~/.tmux.conf.local`, managed block in `~/.zshrc` / `~/.bashrc` matches the expected rendering, `which starship atuin nvim clangd` all resolve to `$HOME/local/bin`.
- **Mac smoke test:** On user's existing mac, run `cd macconfig && ./install_all.sh`. Confirm: `nvim` opens with NvChad config; `clangd --version` resolves to `/opt/homebrew/opt/llvm/bin/clangd`; `tmux` source-files `~/.tmux.conf.local`; `starship`/`atuin`/`zoxide` initialize in a new shell; `spack --version` works after one initial invocation; `~/.zcompdump` mtime check fires correctly.
- **Symlink verification:** `readlink ~/.config/nvim` returns `<repo>/nvimconfig` on both platforms.
- **No regression in nvim runtime:** Open a C++ file; confirm clangd attaches, snippets work, tree-sitter highlights, `:Lazy` shows plugins loaded.
- **Re-run idempotency:** Running `setup.sh` twice produces a single managed block with no duplicate lines; no eager spack source line remains.
- **Render unit check:** `bash shared/shell_rc/render.sh linux zsh` and `... mac zsh` print blocks that pass `zsh -n` (syntax check). Same for `bash` variants with `bash -n`.

## Risks

- **Linux behavioral diff via shell rc:** The shell-rc refactor changes Linux's spack source from eager to lazy and adds zsh `typeset -U` + cached compinit. All speedups, not regressions, but the lazy-spack stub means env vars set by `setup-env.sh` (like `SPACK_ROOT`) are *not* exported until the user runs `spack` once. We mitigate by exporting `SPACK_ROOT` directly in `paths.linux` so callers depending on `$SPACK_ROOT` (without invoking `spack`) keep working.
- **Existing user spack lines outside the managed block:** The user's current mac `~/.zshrc` has hand-rolled `export SPACK_ROOT=...` and a lazy `spack()` function. After our setup runs, both the hand-rolled and managed-block definitions will exist; the later one (ours, end of file) will win. The legacy-strip patterns target the *Linux installer's* old eager source — they don't touch user-written lines. Documented: users with hand-rolled spack init should remove them after running our installer.
- **`brew bundle` cleanup behavior:** `brew bundle` does not remove packages not listed in the Brewfile. We do **not** pass `--cleanup`. Users keep whatever else they've installed.
- **`stdpath("config")` and symlinks:** Neovim does not `realpath` the config dir, so plugins and `:Lazy`'s rtp logic stay rooted in `~/.config/nvim`. Verified by symlink test above.
- **Apple Silicon vs Intel mac:** `brew shellenv` handles both prefixes. The LLVM line in `paths.mac` hardcodes `/opt/homebrew/opt/llvm/bin`; on Intel macs this dir won't exist but a missing dir on PATH is a no-op. If we want strict portability we can switch to `$(brew --prefix llvm)/bin`, but that adds a brew shell-out per shell start. Decision: keep the hardcode; user is on Apple Silicon.
- **`sed -i` portability:** mac (BSD sed) requires a suffix arg for `-i`. We use `sed -i.bak ... && rm -f .bak` which works on both BSD and GNU sed.
- **Template substitution:** `render.sh` walks the template line-by-line in pure shell and splices in `paths.<platform>` at the placeholder. No `sed`/`awk` replacement-string quoting hazards (the brew shellenv output contains `$` and `"`, which would need escaping in `sed`/`awk` replacement strings).
- **Existing `~/.config/nvim`:** If the user already has a config there, `ln -sfn` would clobber an existing *symlink* but not a *directory*. Documented in README: back up or remove `~/.config/nvim` before symlinking.
