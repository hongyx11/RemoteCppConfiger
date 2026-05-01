# Usage

Reference for the editor once it's installed. Leader is `<space>`.

## Basic navigation

| Key | Description |
|-----|-------------|
| `;` | Enter command mode (instead of `:`) |
| `jk` | Exit insert mode (in insert mode) |
| `[f` | Go to previous/current function start |
| `]f` | Go to next function start |

## LSP

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Show references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<space>rn` | Rename symbol |
| `<space>ca` | Code actions |
| `<space>bf` | Format buffer/selection |
| `<space>q` | Diagnostic list |

## Telescope (files / symbols / git)

| Key | Description |
|-----|-------------|
| `<space>ff` | Find files |
| `<space>fr` | Recent files / search-and-replace |
| `<space>fw` | Live grep |
| `<space>Fb` | Open buffers |
| `<space>fh` | Help tags |
| `<space>fs` | Document symbols / incremental search |
| `<space>fS` | Workspace symbols / search all matches |
| `<space>ft` | Treesitter symbols |
| `<space>gs` | Git status |
| `<space>gc` | Git commits |
| `<space>gb` | Git branches |
| `<space>bi` | Telescope builtin pickers |

## File tree (NvimTree)

| Key | Description |
|-----|-------------|
| `<space>e` | Toggle NvimTree |
| `<space>v` | Focus NvimTree |

## Buffers

| Key | Description |
|-----|-------------|
| `<space>x` | Smart buffer delete |

## CMake build & errors

| Key | Description |
|-----|-------------|
| `<space>cb` | Build specific target (with prompt) |
| `<space>ca` | Build all targets |
| `<space>cm` | Configure CMake / list all commands |
| `<space>co` | Open quickfix list |
| `<space>cq` | Close quickfix list |
| `]q` / `[q` | Next / previous error |
| `<space>cf` / `<space>cl` | First / last error |

Default build directory: `cmake-build-vscpp/release`.

## Clangd-specific (C++)

| Key | Description |
|-----|-------------|
| `<space>ch` | Switch source / header |
| `<space>ct` | Type hierarchy |
| `<space>cs` | Symbol info |

## Snippets (LuaSnip)

| Key | Description |
|-----|-------------|
| `<C-l>` | Expand snippet or jump forward |
| `<C-h>` | Jump backward in snippet |
| `<space>sr` | Edit snippet files |

Trigger + `Tab` or `Ctrl-L` to expand.

### C++ snippet triggers

**Structure**: `main`, `class`, `func`, `ns`
**Control flow**: `for`, `forr` (range-based), `while`, `if`, `ife`, `switch`, `try`
**Containers**: `vec`, `map`
**Memory**: `unique`, `shared`
**Includes**: `inc` (with header choices), `guard` (include guards), `lambda`

### MPI snippet triggers

`mpiinit`, `mpifinalize`, `mpibarrier`, `mpirank`, `mpisize`, `mpisend`, `mpirecv`, `mpibcast`, `mpireduce`, `mpiallreduce`, `mpigather`, `mpiallgather`, `mpiscatter`, `mpimain` (full template), `mpiwtime`, `mpiif` (rank-conditional)

## Aerial (code outline)

| Key | Description |
|-----|-------------|
| `<space>a` | Toggle Aerial outline |
| `<space>o` | Toggle Aerial navigation |

## Misc

| Key | Description |
|-----|-------------|
| `<space>km` | List all keymaps |

## Lua functions

- `vim.g.hide_whitespace()` — hide whitespace characters
- `vim.g.show_whitespace()` — show whitespace characters
- `vim.g.toggle_whitespace()` — toggle visibility
