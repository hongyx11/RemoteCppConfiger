# Multiplatform Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the repo into `nvimconfig/`, `ubuntu_install_scripts/`, `macconfig/`, `shared/` with a single shared shell-rc template, and add a Homebrew-driven Mac install path that mirrors Linux's tooling (including Spack).

**Architecture:** A single `shared/shell_rc/template.{zsh,bash}` with a `{{PLATFORM_PATH_BLOCK}}` placeholder is rendered by `shared/shell_rc/render.sh` against `paths.linux` or `paths.mac`. Both `ubuntu_install_scripts/setup_shell_rc.sh` and `macconfig/setup_shell_rc.sh` are 2-line wrappers that delegate to `shared/shell_rc/setup.sh`. The Linux script set is otherwise byte-identical except `install_tmux.sh` (one-line path edit). Mac packages come from a `Brewfile` plus a few per-tool scripts (rust, spack, tmux, fonts).

**Tech Stack:** Bash, zsh, Homebrew (`brew bundle`), git, Lua (Neovim config — touched once).

---

## Reference: spec

`docs/superpowers/specs/2026-05-01-multiplatform-restructure-design.md` is the authoritative design. This plan implements it section-by-section.

## File Structure

**Created:**
- `nvimconfig/` — receives existing `init.lua`, `lazy-lock.json`, `lua/`
- `ubuntu_install_scripts/` — receives existing `install_dependencies/*.sh` (minus `configs/`)
- `shared/tmux/tmux.conf.local` — moved from `install_dependencies/configs/tmux.conf.local`
- `shared/shell_rc/template.zsh` — single zsh template w/ placeholder
- `shared/shell_rc/template.bash` — single bash template w/ placeholder
- `shared/shell_rc/paths.linux` — Linux PATH lines
- `shared/shell_rc/paths.mac` — Mac PATH lines (brew shellenv etc.)
- `shared/shell_rc/render.sh` — renders template against platform paths
- `shared/shell_rc/setup.sh` — managed-block install logic; called by both wrappers
- `macconfig/Brewfile`
- `macconfig/install_all.sh`
- `macconfig/install_rust.sh`
- `macconfig/install_spack.sh`
- `macconfig/install_tmux.sh`
- `macconfig/install_fonts.sh`
- `macconfig/setup_shell_rc.sh` — 2-line wrapper

**Modified:**
- `ubuntu_install_scripts/install_tmux.sh` — one-line path tweak
- `ubuntu_install_scripts/setup_shell_rc.sh` — replaced by 2-line wrapper
- `nvimconfig/init.lua` — drop line 1 (no-op PATH prepend)
- `README.md` — rewrite quickstart and Layout sections
- `docs/install.md` — add Mac section
- `docs/design.md` — add platform-layout section

**Removed:**
- `install_dependencies/configs/` — emptied (file moved to `shared/tmux/`)

---

## Task 1: Move repo into new top-level layout

**Files:**
- Move: `init.lua`, `lazy-lock.json`, `lua/` → `nvimconfig/`
- Move: `install_dependencies/*.sh` → `ubuntu_install_scripts/`
- Move: `install_dependencies/configs/tmux.conf.local` → `shared/tmux/tmux.conf.local`
- Remove: `install_dependencies/` (now empty)

- [ ] **Step 1: Create new top-level directories**

```bash
cd /Users/hongy0a/code/RemoteCppConfiger
mkdir -p nvimconfig ubuntu_install_scripts shared/tmux shared/shell_rc macconfig
```

Expected: directories exist with no errors.

- [ ] **Step 2: Move nvim config files into `nvimconfig/`**

```bash
git mv init.lua nvimconfig/init.lua
git mv lazy-lock.json nvimconfig/lazy-lock.json
git mv lua nvimconfig/lua
```

Expected: `git status` shows three renames (`R` mode).

- [ ] **Step 3: Move Linux install scripts**

```bash
git mv install_dependencies/install_all.sh        ubuntu_install_scripts/install_all.sh
git mv install_dependencies/install_atuin.sh      ubuntu_install_scripts/install_atuin.sh
git mv install_dependencies/install_clis.sh       ubuntu_install_scripts/install_clis.sh
git mv install_dependencies/install_fonts.sh      ubuntu_install_scripts/install_fonts.sh
git mv install_dependencies/install_just.sh       ubuntu_install_scripts/install_just.sh
git mv install_dependencies/install_llvm.sh       ubuntu_install_scripts/install_llvm.sh
git mv install_dependencies/install_lsp_servers.sh ubuntu_install_scripts/install_lsp_servers.sh
git mv install_dependencies/install_node.sh       ubuntu_install_scripts/install_node.sh
git mv install_dependencies/install_nvhpc.sh      ubuntu_install_scripts/install_nvhpc.sh
git mv install_dependencies/install_nvim.sh       ubuntu_install_scripts/install_nvim.sh
git mv install_dependencies/install_python_tools.sh ubuntu_install_scripts/install_python_tools.sh
git mv install_dependencies/install_rust.sh       ubuntu_install_scripts/install_rust.sh
git mv install_dependencies/install_spack.sh      ubuntu_install_scripts/install_spack.sh
git mv install_dependencies/install_starship.sh   ubuntu_install_scripts/install_starship.sh
git mv install_dependencies/install_tinytex.sh    ubuntu_install_scripts/install_tinytex.sh
git mv install_dependencies/install_tmux.sh       ubuntu_install_scripts/install_tmux.sh
git mv install_dependencies/install_uv.sh         ubuntu_install_scripts/install_uv.sh
git mv install_dependencies/activate.sh           ubuntu_install_scripts/activate.sh
git mv install_dependencies/setup_cocal_dev.sh    ubuntu_install_scripts/setup_cocal_dev.sh
git mv install_dependencies/setup_interactive.sh  ubuntu_install_scripts/setup_interactive.sh
git mv install_dependencies/setup_no_sudo.sh      ubuntu_install_scripts/setup_no_sudo.sh
git mv install_dependencies/setup_path.sh         ubuntu_install_scripts/setup_path.sh
git mv install_dependencies/setup_shell_rc.sh     ubuntu_install_scripts/setup_shell_rc.sh
git mv install_dependencies/setup_sudo.sh         ubuntu_install_scripts/setup_sudo.sh
```

Expected: 24 renames in `git status`.

- [ ] **Step 4: Move tmux.conf.local to shared/**

```bash
git mv install_dependencies/configs/tmux.conf.local shared/tmux/tmux.conf.local
rmdir install_dependencies/configs install_dependencies
```

Expected: `install_dependencies/` no longer exists. `git status` shows the move.

- [ ] **Step 5: Verify rename is content-preserving**

```bash
git diff --cached --stat | tail -5
git diff --cached --find-renames=100% | grep -E '^(rename|diff)' | head -30
```

Expected: all entries are `rename ...` lines with no `diff --git` body (pure renames).

- [ ] **Step 6: Commit**

```bash
git commit -m "$(cat <<'EOF'
Reorganize repo: nvimconfig/, ubuntu_install_scripts/, shared/

Pure rename. Splits the monorepo into platform-neutral and
Linux-specific halves. tmux.conf.local moves to shared/tmux/ so
mac and linux can both reference it. The Linux installer is
temporarily broken — install_tmux.sh references the old configs
path; fixed in the next commit.
EOF
)"
```

Expected: commit succeeds; `git log --stat -1` shows ~25 file renames.

---

## Task 2: Fix Linux `install_tmux.sh` to point at `shared/tmux/`

**Files:**
- Modify: `ubuntu_install_scripts/install_tmux.sh:13`

- [ ] **Step 1: Edit the LOCAL_SRC line**

In `ubuntu_install_scripts/install_tmux.sh`, the existing line is:

```bash
LOCAL_SRC="$SCRIPT_DIR/configs/tmux.conf.local"
```

Change it to:

```bash
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_SRC="$REPO_ROOT/shared/tmux/tmux.conf.local"
```

(Insert the `REPO_ROOT=` line on its own line *above* `LOCAL_SRC=`. Keep all other lines unchanged.)

- [ ] **Step 2: Verify the file parses**

```bash
bash -n ubuntu_install_scripts/install_tmux.sh
echo $?
```

Expected: `0` (no syntax errors).

- [ ] **Step 3: Verify the path resolves correctly**

```bash
bash -c '
  SCRIPT_DIR="$(cd ubuntu_install_scripts && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  LOCAL_SRC="$REPO_ROOT/shared/tmux/tmux.conf.local"
  test -f "$LOCAL_SRC" && echo OK || echo MISSING
'
```

Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add ubuntu_install_scripts/install_tmux.sh
git commit -m "Fix Linux install_tmux.sh path after configs/ → shared/tmux/ move"
```

---

## Task 3: Drop the no-op PATH prepend in `nvimconfig/init.lua`

**Files:**
- Modify: `nvimconfig/init.lua:1` (delete)

- [ ] **Step 1: Delete the first line**

The current file starts with:

```lua
vim.env.PATH = vim.fn.stdpath("config") .. "/install_dependencies/bin:" .. vim.env.PATH
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
```

After the edit it should start with:

```lua
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
```

(Just delete the first line. Don't touch anything else.)

- [ ] **Step 2: Verify it parses with luac (optional — only if luac available)**

```bash
command -v luac >/dev/null && luac -p nvimconfig/init.lua && echo OK
```

Expected: `OK`, or skip if `luac` not installed.

- [ ] **Step 3: Verify with neovim (if available)**

```bash
command -v nvim >/dev/null && nvim --headless -c "luafile nvimconfig/init.lua" -c qa 2>&1 | head -5
```

Expected: minimal output, exit code 0. (May warn about lazy.nvim path; safe to ignore for syntax purposes.)

- [ ] **Step 4: Commit**

```bash
git add nvimconfig/init.lua
git commit -m "Drop no-op PATH prepend from init.lua"
```

---

## Task 4: Add `shared/shell_rc/template.zsh` and `template.bash`

**Files:**
- Create: `shared/shell_rc/template.zsh`
- Create: `shared/shell_rc/template.bash`

- [ ] **Step 1: Write the zsh template**

Create `shared/shell_rc/template.zsh` with exactly this content:

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

- [ ] **Step 2: Write the bash template**

Create `shared/shell_rc/template.bash` with exactly this content:

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

- [ ] **Step 3: Verify each template has exactly one placeholder**

```bash
grep -c '{{PLATFORM_PATH_BLOCK}}' shared/shell_rc/template.zsh
grep -c '{{PLATFORM_PATH_BLOCK}}' shared/shell_rc/template.bash
```

Expected: `1` and `1`.

- [ ] **Step 4: Commit**

```bash
git add shared/shell_rc/template.zsh shared/shell_rc/template.bash
git commit -m "Add shared zsh+bash shell-rc templates with PATH placeholder"
```

---

## Task 5: Add per-platform path files

**Files:**
- Create: `shared/shell_rc/paths.linux`
- Create: `shared/shell_rc/paths.mac`

- [ ] **Step 1: Write the Linux paths file**

Create `shared/shell_rc/paths.linux` with exactly this content:

```bash
export PATH="$HOME/local/bin:$HOME/.local/bin:$PATH"
export SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
```

- [ ] **Step 2: Write the Mac paths file**

Create `shared/shell_rc/paths.mac` with exactly this content:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
```

- [ ] **Step 3: Sanity-check the files contain no placeholders**

```bash
grep -l '{{' shared/shell_rc/paths.linux shared/shell_rc/paths.mac
```

Expected: empty output (no matches).

- [ ] **Step 4: Commit**

```bash
git add shared/shell_rc/paths.linux shared/shell_rc/paths.mac
git commit -m "Add per-platform paths files for shell-rc rendering"
```

---

## Task 6: Add `shared/shell_rc/render.sh`

**Files:**
- Create: `shared/shell_rc/render.sh`

- [ ] **Step 1: Write render.sh**

Create `shared/shell_rc/render.sh` with this content:

```bash
#!/bin/bash
# Render a managed shell-rc block for the given platform and shell.
# Usage: render.sh <linux|mac> <zsh|bash>
#
# Splices the contents of paths.<platform> into the {{PLATFORM_PATH_BLOCK}}
# placeholder in template.<shell>. Done in pure shell to avoid sed/awk
# replacement-string quoting hazards (brew shellenv output contains $ and ").

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <linux|mac> <zsh|bash>" >&2
  exit 64
fi

PLATFORM="$1"
SHELL_NAME="$2"
DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$DIR/template.$SHELL_NAME"
PATHS="$DIR/paths.$PLATFORM"

[ -f "$TEMPLATE" ] || { echo "missing template: $TEMPLATE" >&2; exit 1; }
[ -f "$PATHS" ]    || { echo "missing paths file: $PATHS" >&2; exit 1; }

while IFS= read -r line || [ -n "$line" ]; do
  if [ "$line" = "{{PLATFORM_PATH_BLOCK}}" ]; then
    cat "$PATHS"
  else
    printf '%s\n' "$line"
  fi
done < "$TEMPLATE"
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x shared/shell_rc/render.sh
bash -n shared/shell_rc/render.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Render Linux+zsh and verify content**

```bash
bash shared/shell_rc/render.sh linux zsh
```

Expected output (exact):

```zsh
# >>> RemoteCppConfiger >>>
typeset -U path PATH fpath FPATH
export PATH="$HOME/local/bin:$HOME/.local/bin:$PATH"
export SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
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

- [ ] **Step 4: Render Mac+zsh and verify the brew shellenv line is present**

```bash
bash shared/shell_rc/render.sh mac zsh | grep 'brew shellenv'
```

Expected: `eval "$(/opt/homebrew/bin/brew shellenv)"`

- [ ] **Step 5: Render bash variants and verify no zsh-only lines leak in**

```bash
bash shared/shell_rc/render.sh linux bash | grep -E 'typeset -U|compinit|zcompdump' || echo "no zsh-only lines (expected)"
```

Expected: `no zsh-only lines (expected)`.

- [ ] **Step 6: Render syntax-checks under each target shell (if installed)**

```bash
command -v zsh  >/dev/null && bash shared/shell_rc/render.sh linux zsh  | zsh -n  && echo "linux/zsh OK"
command -v zsh  >/dev/null && bash shared/shell_rc/render.sh mac   zsh  | zsh -n  && echo "mac/zsh OK"
bash shared/shell_rc/render.sh linux bash | bash -n && echo "linux/bash OK"
bash shared/shell_rc/render.sh mac   bash | bash -n && echo "mac/bash OK"
```

Expected: four "... OK" lines (zsh ones skip if zsh missing).

- [ ] **Step 7: Commit**

```bash
git add shared/shell_rc/render.sh
git commit -m "Add shared/shell_rc/render.sh for templated managed-block rendering"
```

---

## Task 7: Add `shared/shell_rc/setup.sh`

**Files:**
- Create: `shared/shell_rc/setup.sh`

- [ ] **Step 1: Write setup.sh**

Create `shared/shell_rc/setup.sh` with this content:

```bash
#!/bin/bash
# Install/refresh the RemoteCppConfiger managed block in ~/.bashrc and ~/.zshrc.
# Usage: setup.sh <linux|mac>
#
# Idempotent. Re-running replaces the managed block in place. Legacy bare lines
# from older versions of the Linux installer are stripped before re-write.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <linux|mac>" >&2
  exit 64
fi

PLATFORM="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"

BEGIN_MARK="# >>> RemoteCppConfiger >>>"
END_MARK="# <<< RemoteCppConfiger <<<"

# Patterns that match individual lines from older versions of setup_shell_rc.sh.
# We delete matches before writing the fresh block to avoid duplicates.
LEGACY_PATTERNS=(
  '^export PATH="\$HOME/local/bin'
  '^command -v starship >/dev/null && eval'
  '^command -v atuin .*&& eval'
  '^\[ -f ".*/spack/share/spack/setup-env\.sh" \]'
  "^command -v eza >/dev/null && alias l[sla]="
)

wire() {
  local rc="$1" shell="$2"
  echo "==> $rc"
  [ -f "$rc" ] || : > "$rc"

  # Drop any existing managed block. -i.bak form is BSD/GNU portable.
  sed -i.bak "/^${BEGIN_MARK}$/,/^${END_MARK}$/d" "$rc" && rm -f "$rc.bak"

  # Drop legacy bare lines from older versions of the installer.
  for pat in "${LEGACY_PATTERNS[@]}"; do
    if grep -qE "$pat" "$rc"; then
      grep -vE "$pat" "$rc" > "$rc.tmp" || true
      mv "$rc.tmp" "$rc"
    fi
  done

  # Append the freshly rendered block.
  [ -s "$rc" ] && printf '\n' >> "$rc"
  bash "$DIR/render.sh" "$PLATFORM" "$shell" >> "$rc"

  echo "  wrote managed block"
}

wire "$HOME/.bashrc" bash
wire "$HOME/.zshrc"  zsh

if grep -q 'source.*oh-my-zsh\.sh' "$HOME/.zshrc" 2>/dev/null; then
  cat <<'MSG'

NOTE: oh-my-zsh detected. The cached-compinit speedup in our managed block
runs AFTER OMZ's slow compinit, so it has no effect for you. To make it
effective, paste this snippet right BEFORE `source $ZSH/oh-my-zsh.sh` in
~/.zshrc:

  ZSH_DISABLE_COMPFIX=true
  autoload -Uz compinit
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

MSG
fi

echo
echo "Done. Open a new shell (or 'exec bash' / 'exec zsh') for changes to take effect."
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x shared/shell_rc/setup.sh
bash -n shared/shell_rc/setup.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Idempotency dry-run against a temp HOME**

```bash
TMP_HOME="$(mktemp -d)"
HOME="$TMP_HOME" bash shared/shell_rc/setup.sh linux
HOME="$TMP_HOME" bash shared/shell_rc/setup.sh linux  # second run

# Count managed blocks — should be exactly 1 each
grep -c '^# >>> RemoteCppConfiger >>>$' "$TMP_HOME/.zshrc"
grep -c '^# >>> RemoteCppConfiger >>>$' "$TMP_HOME/.bashrc"

rm -rf "$TMP_HOME"
```

Expected: `1` and `1`.

- [ ] **Step 4: Verify legacy-strip works**

Seed a temp `.zshrc` with old bare lines from a pre-restructure installer run, run setup, then confirm the legacy lines are gone (only in-block fresh content remains):

```bash
TMP_HOME="$(mktemp -d)"
cat > "$TMP_HOME/.zshrc" <<'EOF'
# user content
export PATH="$HOME/local/bin:$HOME/.local/bin:$PATH"
command -v starship >/dev/null && eval "$(starship init zsh)"
[ -f "/home/old/spack/share/spack/setup-env.sh" ] && . "/home/old/spack/share/spack/setup-env.sh"
# more user content
EOF
HOME="$TMP_HOME" bash shared/shell_rc/setup.sh linux >/dev/null

# Old eager-style spack source line should be stripped (count 0).
grep -cE '^\[ -f ".*/spack/share/spack/setup-env\.sh" \]' "$TMP_HOME/.zshrc"

# Exactly one PATH-prepend should remain (the new in-block one), not the bare legacy line.
grep -cE '^export PATH="\$HOME/local/bin' "$TMP_HOME/.zshrc"

rm -rf "$TMP_HOME"
```

Expected: `0` (eager spack legacy line stripped) and `1` (only the new in-block PATH line remains).

- [ ] **Step 5: Commit**

```bash
git add shared/shell_rc/setup.sh
git commit -m "Add shared/shell_rc/setup.sh: managed-block installer with legacy-strip"
```

---

## Task 8: Replace `ubuntu_install_scripts/setup_shell_rc.sh` with thin wrapper

**Files:**
- Modify: `ubuntu_install_scripts/setup_shell_rc.sh` (full replace)

- [ ] **Step 1: Replace contents**

The new contents of `ubuntu_install_scripts/setup_shell_rc.sh` should be exactly:

```bash
#!/bin/bash
exec bash "$(dirname "$0")/../shared/shell_rc/setup.sh" linux
```

(Two functional lines. Replace the entire existing file with these.)

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x ubuntu_install_scripts/setup_shell_rc.sh
bash -n ubuntu_install_scripts/setup_shell_rc.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Smoke test against temp HOME**

```bash
TMP_HOME="$(mktemp -d)"
HOME="$TMP_HOME" bash ubuntu_install_scripts/setup_shell_rc.sh
grep '^typeset -U' "$TMP_HOME/.zshrc"   # should be present (zsh template applied)
grep 'brew shellenv' "$TMP_HOME/.zshrc" || echo "(no brew line — correct for linux)"
rm -rf "$TMP_HOME"
```

Expected: `typeset -U path PATH fpath FPATH` present; `(no brew line — correct for linux)` printed.

- [ ] **Step 4: Verify the rest of `ubuntu_install_scripts/install_all.sh` still references `setup_shell_rc.sh` correctly**

```bash
grep -n setup_shell_rc ubuntu_install_scripts/install_all.sh
```

Expected: line `run "Shell rc"         setup_shell_rc.sh` (unchanged from before).

- [ ] **Step 5: Commit**

```bash
git add ubuntu_install_scripts/setup_shell_rc.sh
git commit -m "Convert ubuntu setup_shell_rc.sh to thin wrapper over shared/shell_rc/setup.sh

Behavioral diff (all speedups, no regressions):
- spack source becomes lazy (was eager source on every shell start)
- zsh adds typeset -U for PATH dedup
- zsh adds cached compinit (full rebuild only if zcompdump older than 24h)
- OMZ users get a one-time hint about positioning the compinit snippet"
```

---

## Task 9: Add `macconfig/Brewfile`

**Files:**
- Create: `macconfig/Brewfile`

- [ ] **Step 1: Write Brewfile**

Create `macconfig/Brewfile` with exactly this content:

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

- [ ] **Step 2: Validate the Brewfile**

```bash
brew bundle check --file=macconfig/Brewfile --no-upgrade || echo "(some packages missing — expected on first run)"
```

Expected: either "The Brewfile's dependencies are satisfied." or a list of missing items. Either is a valid result; this just confirms the file parses.

- [ ] **Step 3: Commit**

```bash
git add macconfig/Brewfile
git commit -m "Add macconfig/Brewfile declaring all mac dev tools"
```

---

## Task 10: Add `macconfig/install_rust.sh`

**Files:**
- Create: `macconfig/install_rust.sh`

- [ ] **Step 1: Write the script**

Create `macconfig/install_rust.sh`:

```bash
#!/bin/bash
# Bootstrap rust on mac via brew's rustup-init.
# PATH for ~/.cargo/bin is added by setup_shell_rc.sh, so we don't modify PATH here.

set -euo pipefail

if [ -x "$HOME/.cargo/bin/rustc" ]; then
  echo "  rustc already installed at $HOME/.cargo/bin/rustc, skipping."
  "$HOME/.cargo/bin/rustc" --version
  exit 0
fi

if ! command -v rustup-init >/dev/null 2>&1; then
  echo "  rustup-init not found — make sure 'brew install rustup' has run."
  exit 1
fi

echo "==> Running rustup-init -y --no-modify-path"
rustup-init -y --no-modify-path
"$HOME/.cargo/bin/rustc" --version
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x macconfig/install_rust.sh
bash -n macconfig/install_rust.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Commit**

```bash
git add macconfig/install_rust.sh
git commit -m "Add macconfig/install_rust.sh"
```

---

## Task 11: Add `macconfig/install_spack.sh`

**Files:**
- Create: `macconfig/install_spack.sh`

- [ ] **Step 1: Write the script**

Create `macconfig/install_spack.sh`:

```bash
#!/bin/bash
# Clone Spack into $SPACK_ROOT (default $HOME/spack) on mac.
# Mirrors ubuntu_install_scripts/install_spack.sh. No compiler bootstrap;
# users register brew compilers themselves with `spack compiler find`.

set -euo pipefail

SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"

if [ -d "$SPACK_ROOT/.git" ]; then
  echo "  spack already cloned at $SPACK_ROOT, skipping."
else
  echo "==> Cloning spack → $SPACK_ROOT"
  git clone --depth=1 https://github.com/spack/spack.git "$SPACK_ROOT"
fi

# shellcheck disable=SC1091
. "$SPACK_ROOT/share/spack/setup-env.sh"
echo "    $(spack --version)"
echo
echo "    To use in a new shell:"
echo "      . $SPACK_ROOT/share/spack/setup-env.sh"
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x macconfig/install_spack.sh
bash -n macconfig/install_spack.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Commit**

```bash
git add macconfig/install_spack.sh
git commit -m "Add macconfig/install_spack.sh (mirrors Linux pattern)"
```

---

## Task 12: Add `macconfig/install_tmux.sh`

**Files:**
- Create: `macconfig/install_tmux.sh`

- [ ] **Step 1: Write the script**

Create `macconfig/install_tmux.sh`:

```bash
#!/bin/bash
# Install Oh My Tmux (gpakosz/.tmux), symlink ~/.tmux.conf, and seed
# ~/.tmux.conf.local from shared/tmux/. Mirrors the Linux tmux installer.
# Tmux itself is provided by brew (declared in Brewfile).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMUX_DIR="$HOME/.tmux"
LOCAL_SRC="$REPO_ROOT/shared/tmux/tmux.conf.local"
LOCAL_DST="$HOME/.tmux.conf.local"
TPM_DIR="$TMUX_DIR/plugins/tpm"

if ! command -v tmux >/dev/null 2>&1; then
  echo "  warning: 'tmux' not found on PATH. Install it via brew, then re-run."
fi

if [ -d "$TMUX_DIR/.git" ]; then
  echo "  $TMUX_DIR already a git repo, skipping clone."
else
  echo "==> Cloning Oh My Tmux → $TMUX_DIR"
  if [ -e "$TMUX_DIR" ]; then
    echo "  $TMUX_DIR exists but is not a git repo; moving aside to $TMUX_DIR.bak.$$"
    mv "$TMUX_DIR" "$TMUX_DIR.bak.$$"
  fi
  git clone --depth 1 https://github.com/gpakosz/.tmux.git "$TMUX_DIR"
fi

echo "==> Linking ~/.tmux.conf → $TMUX_DIR/.tmux.conf"
if [ -L "$HOME/.tmux.conf" ]; then
  ln -snf "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
elif [ -e "$HOME/.tmux.conf" ]; then
  echo "  ~/.tmux.conf is a regular file; backing up to ~/.tmux.conf.bak.$$"
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$$"
  ln -s "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
else
  ln -s "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

if [ -e "$LOCAL_DST" ]; then
  echo "  $LOCAL_DST already exists, leaving it untouched."
else
  echo "==> Writing bundled customizations to $LOCAL_DST"
  cp "$LOCAL_SRC" "$LOCAL_DST"
fi

if [ -d "$TPM_DIR/.git" ]; then
  echo "  TPM already installed at $TPM_DIR, skipping clone."
else
  echo "==> Cloning TPM → $TPM_DIR"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  echo "==> Installing TPM plugins"
  "$TPM_DIR/bin/install_plugins" || echo "  (TPM install_plugins exited non-zero; usually safe to ignore)"
fi

echo "    tmux config ready. Reload inside tmux with: prefix + r"
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x macconfig/install_tmux.sh
bash -n macconfig/install_tmux.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Commit**

```bash
git add macconfig/install_tmux.sh
git commit -m "Add macconfig/install_tmux.sh"
```

---

## Task 13: Add `macconfig/install_fonts.sh`

**Files:**
- Create: `macconfig/install_fonts.sh`

- [ ] **Step 1: Write the script**

Create `macconfig/install_fonts.sh`:

```bash
#!/bin/bash
# Install Maple Mono Nerd Font on mac via brew cask.
# Convenience standalone runner — same effect as `brew bundle` over the Brewfile.

set -euo pipefail

CASK="font-maple-mono-nf"

if brew list --cask "$CASK" >/dev/null 2>&1; then
  echo "  $CASK already installed, skipping."
else
  echo "==> brew install --cask $CASK"
  brew install --cask "$CASK"
fi
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x macconfig/install_fonts.sh
bash -n macconfig/install_fonts.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Commit**

```bash
git add macconfig/install_fonts.sh
git commit -m "Add macconfig/install_fonts.sh"
```

---

## Task 14: Add `macconfig/setup_shell_rc.sh` wrapper

**Files:**
- Create: `macconfig/setup_shell_rc.sh`

- [ ] **Step 1: Write the wrapper**

Create `macconfig/setup_shell_rc.sh`:

```bash
#!/bin/bash
exec bash "$(dirname "$0")/../shared/shell_rc/setup.sh" mac
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x macconfig/setup_shell_rc.sh
bash -n macconfig/setup_shell_rc.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Smoke test against temp HOME**

```bash
TMP_HOME="$(mktemp -d)"
HOME="$TMP_HOME" bash macconfig/setup_shell_rc.sh
grep 'brew shellenv' "$TMP_HOME/.zshrc"
grep '^typeset -U'   "$TMP_HOME/.zshrc"
rm -rf "$TMP_HOME"
```

Expected: both greps print one matching line each.

- [ ] **Step 4: Commit**

```bash
git add macconfig/setup_shell_rc.sh
git commit -m "Add macconfig/setup_shell_rc.sh wrapper"
```

---

## Task 15: Add `macconfig/install_all.sh`

**Files:**
- Create: `macconfig/install_all.sh`

- [ ] **Step 1: Write the orchestrator**

Create `macconfig/install_all.sh`:

```bash
#!/bin/bash
# RemoteCppConfiger — install all mac dev dependencies via Homebrew.
#
# Prereqs: Homebrew (https://brew.sh), Xcode Command Line Tools (for git).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

command -v brew >/dev/null || {
  echo "Install Homebrew first: https://brew.sh" >&2
  exit 1
}

echo "============================================"
echo " RemoteCppConfiger mac install"
echo " Brew prefix: $(brew --prefix)"
echo "============================================"

run() {
  local label="$1" script="$2"
  echo
  echo "---- $label ----"
  bash "$SCRIPT_DIR/$script"
}

echo
echo "---- brew update ----"
brew update

echo
echo "---- brew bundle ----"
brew bundle --file="$SCRIPT_DIR/Brewfile"

run "Rust toolchain" install_rust.sh
run "Spack"          install_spack.sh
run "Tmux (Oh My Tmux)" install_tmux.sh
run "Shell rc"       setup_shell_rc.sh

echo
echo "============================================"
echo " Done."
echo
echo " If you haven't already:"
echo "   ln -sfn $REPO_ROOT/nvimconfig ~/.config/nvim"
echo
echo " Open a new shell (or 'exec zsh') for shell rc changes to take effect."
echo "============================================"
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x macconfig/install_all.sh
bash -n macconfig/install_all.sh
echo $?
```

Expected: `0`.

- [ ] **Step 3: Verify each referenced script exists**

```bash
for s in install_rust.sh install_spack.sh install_tmux.sh setup_shell_rc.sh Brewfile; do
  test -e "macconfig/$s" && echo "  OK $s" || echo "  MISSING $s"
done
```

Expected: five `OK ...` lines.

- [ ] **Step 4: Commit**

```bash
git add macconfig/install_all.sh
git commit -m "Add macconfig/install_all.sh orchestrator"
```

---

## Task 16: End-to-end mac smoke test

**Files:** none (verification only)

- [ ] **Step 1: Symlink nvim config**

```bash
mkdir -p ~/.config
[ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ] && {
  echo "WARN: ~/.config/nvim is a real dir; back it up first:"
  echo "  mv ~/.config/nvim ~/.config/nvim.bak.\$(date +%s)"
  exit 1
}
ln -sfn /Users/hongy0a/code/RemoteCppConfiger/nvimconfig ~/.config/nvim
readlink ~/.config/nvim
```

Expected: prints `/Users/hongy0a/code/RemoteCppConfiger/nvimconfig`.

- [ ] **Step 2: Run install_all.sh**

```bash
cd /Users/hongy0a/code/RemoteCppConfiger/macconfig
./install_all.sh
```

Expected: completes without errors. `brew bundle` reports installed/up-to-date for each formula.

- [ ] **Step 3: Verify key tools resolve correctly**

```bash
exec zsh -i -c '
  which nvim
  which clangd | grep -q "/opt/homebrew/opt/llvm/bin" && echo "clangd OK" || echo "clangd WRONG"
  which starship && which atuin && which zoxide
  test -f ~/.tmux.conf.local && echo "tmux.conf.local OK"
'
```

Expected: nvim resolves to brew prefix; "clangd OK"; starship/atuin/zoxide all printed; "tmux.conf.local OK".

- [ ] **Step 4: Verify managed block written correctly**

```bash
grep -A 1 '^# >>> RemoteCppConfiger >>>' ~/.zshrc | head -3
```

Expected: shows the BEGIN_MARK followed by `typeset -U path PATH fpath FPATH`.

- [ ] **Step 5: Open nvim, confirm NvChad loads**

Manual test: run `nvim`, verify the dashboard renders, run `:Lazy` and verify plugins are loaded, open a `.cpp` file and verify clangd attaches (`:LspInfo`).

- [ ] **Step 6: No commit — this task is verification only.**

If anything fails, file an issue or fix in a follow-up task. Do not declare the work done if any of the above fail.

---

## Task 17: Update `README.md`

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace the "Quick start" section (lines 21–41 of the current README)**

Replace from `## Quick start` (line 21) up to and including the line `For the no-sudo path, see [\`docs/install.md\`](docs/install.md).` (line 41), but **stop before** `## Documentation` (line 43). Leave the `## Documentation` section unchanged.

The new content (note: this README literal block uses 4-backticks at the outer fence so the inner 3-backtick blocks render correctly):

````markdown
## Quick start

Clone anywhere and symlink the editor config into `~/.config/nvim`:

```bash
git clone <this repo> ~/code/RemoteCppConfiger
ln -sfn ~/code/RemoteCppConfiger/nvimconfig ~/.config/nvim
```

(If `~/.config/nvim` already exists, back it up first: `mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)`.)

### Linux (Ubuntu 22 / 24)

```bash
cd ~/code/RemoteCppConfiger/ubuntu_install_scripts
./install_all.sh
```

For the no-sudo path, see [`docs/install.md`](docs/install.md).

### Mac (Apple Silicon, Homebrew)

```bash
cd ~/code/RemoteCppConfiger/macconfig
./install_all.sh
```

Prerequisites: [Homebrew](https://brew.sh), Xcode Command Line Tools (for `git`).

Then launch:

```bash
nvim
```
````

- [ ] **Step 2: Replace the "Layout" section (lines 50–64 of the current README)**

Replace from `## Layout` (line 50) up to and including the line `$HOME/spack/                   # Spack checkout (compiler + libraries)` (line 64). Leave `## Credits` (line 65 onward) unchanged.

The new content:

````markdown
## Layout

```
RemoteCppConfiger/                 # cloned anywhere
├── nvimconfig/                    # → ~/.config/nvim (via symlink)
├── ubuntu_install_scripts/        # Linux installer (Ubuntu 22 / 24)
├── macconfig/                     # Mac installer (Brewfile + scripts)
├── shared/
│   ├── tmux/                      # tmux.conf.local (both platforms)
│   └── shell_rc/                  # one zsh+bash template, per-platform paths
└── docs/
```

Linux installs into `$HOME/local/` and `$HOME/spack/`. Mac uses Homebrew's prefix (`/opt/homebrew`) plus `$HOME/spack/`.
````

- [ ] **Step 3: Verify markdown renders sensibly**

```bash
head -80 README.md
grep -c '^## Documentation' README.md
```

Expected: well-formed markdown; quickstart shows both Linux and Mac. The grep returns `1` (Documentation section preserved).

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "Rewrite README quickstart and Layout for multiplatform structure"
```

---

## Task 18: Update `docs/install.md` with Mac section

**Files:**
- Modify: `docs/install.md`

- [ ] **Step 1: Read the current file and identify the top of the existing Linux content**

```bash
head -30 docs/install.md
```

Expected: shows whatever the existing top-of-file is (likely a `# Install` header followed by Linux sudo/no-sudo split).

- [ ] **Step 2: Add a "Platforms" preamble + Mac section**

Insert this content immediately after the top-level `# Install` header (before the existing Linux content). After this insert, take whatever Linux content was previously the body of the file and wrap it under a new `## Ubuntu (Linux)` subheader. Don't duplicate or remove existing Linux instructions — just nest them.

The new content (using 4-backtick outer fence so inner 3-backtick blocks render correctly):

````markdown
## Platforms

This repo supports Ubuntu 22.04 / 24.04 (with or without sudo) and macOS (Apple Silicon, Homebrew). Pick the section below that matches your host.

## macOS

### Prerequisites

- [Homebrew](https://brew.sh) installed and on PATH.
- Xcode Command Line Tools (`xcode-select --install`) — provides `git`.

### One-liner

```bash
git clone <this repo> ~/code/RemoteCppConfiger
ln -sfn ~/code/RemoteCppConfiger/nvimconfig ~/.config/nvim
cd ~/code/RemoteCppConfiger/macconfig && ./install_all.sh
```

### What gets installed

- All editor and CLI tools listed in `macconfig/Brewfile` (nvim, ripgrep, fd, bat, eza, zellij, lazygit, llvm, lua-language-server, pyright, ast-grep, stylua, tree-sitter, node, uv, rustup, starship, atuin, just, gh, fzf, zoxide, yazi, tmux, basictex, font-maple-mono-nf).
- Rust via `rustup-init`.
- Spack at `$HOME/spack` (mirrors the Linux layout). To use a different location, set `SPACK_ROOT` before running `install_all.sh`.
- Oh My Tmux into `~/.tmux`, with our customizations seeded into `~/.tmux.conf.local` (only if absent).
- A managed block in `~/.zshrc` and `~/.bashrc` that sets PATH for brew + LLVM + cargo, initializes starship/atuin/zoxide, defines a lazy `spack()` stub, and (zsh-only) caches `compinit`.

### Where things live

- Brew packages: `/opt/homebrew/...` (Apple Silicon) or `/usr/local/...` (Intel).
- Spack: `$HOME/spack` (override with `SPACK_ROOT=...`).
- Cargo / rustup: `$HOME/.cargo`, `$HOME/.rustup`.
- nvim config: `~/.config/nvim` → symlink to `<repo>/nvimconfig`.

### OMZ compinit speedup

If you use Oh My Zsh, the cached-compinit speedup in our managed block runs *after* OMZ's slow path, so it has no effect by default. To activate it, paste this snippet into `~/.zshrc` immediately *before* `source $ZSH/oh-my-zsh.sh`:

```zsh
ZSH_DISABLE_COMPFIX=true
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
```

`setup_shell_rc.sh` detects OMZ and prints this snippet at install time as a reminder.

## Ubuntu (Linux)

(existing Linux content goes here — preserved verbatim from the previous version of this file)
````

- [ ] **Step 3: Verify the file still parses and reads sensibly**

```bash
head -60 docs/install.md
grep -c '^## ' docs/install.md
```

Expected: top of file shows the new platforms preamble; section count includes "Platforms", "macOS", "Ubuntu (Linux)" plus whatever sub-sections existed.

- [ ] **Step 4: Commit**

```bash
git add docs/install.md
git commit -m "Add macOS install section to docs/install.md"
```

---

## Task 19: Update `docs/design.md` with platform-layout note

**Files:**
- Modify: `docs/design.md`

- [ ] **Step 1: Append a "Platform layout" section to the END of `docs/design.md`**

Add this content at the end of the file, after all existing sections (using 4-backtick outer fence to allow the inner 3-backtick directory tree to render):

````markdown
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
````

- [ ] **Step 2: Verify**

```bash
tail -25 docs/design.md
```

Expected: the new section is at the bottom of the file.

- [ ] **Step 3: Commit**

```bash
git add docs/design.md
git commit -m "Document platform layout in docs/design.md"
```

---

## Final verification

After all tasks complete:

- [ ] `git log --oneline | head -20` shows ~16 new commits in the order of the task numbers.
- [ ] `git ls-files | grep -E '^(install_dependencies|init\.lua|lua/)' ` returns empty (everything moved).
- [ ] `git diff <commit-before-Task-1> HEAD -- ubuntu_install_scripts/ ':!ubuntu_install_scripts/install_tmux.sh' ':!ubuntu_install_scripts/setup_shell_rc.sh' --stat` shows zero changes (16 byte-identical scripts confirmed).
- [ ] On the user's mac: `nvim` opens NvChad, `clangd --version` resolves under `/opt/homebrew/opt/llvm/bin/`, `tmux new -s s` source-files `~/.tmux.conf.local`, `spack --version` works after one initial `spack` invocation in a fresh shell.
- [ ] On a fresh Ubuntu 22 or 24 container: `cd ubuntu_install_scripts && ./install_all.sh` completes; `which clangd` resolves under `$HOME/local/lib/llvm-18.1.8/bin/`; `~/.tmux.conf.local` is in place.
