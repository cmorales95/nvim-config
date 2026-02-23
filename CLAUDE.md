# nvim-config — Claude Code Project Guide

## Overview
Full VSCode-parity Neovim configuration. Uses **lazy.nvim** as the plugin manager with a
modular file layout. Supports Go, Python, JavaScript/TypeScript, and Jupyter notebooks.

## File Structure

```
~/.config/nvim/
  init.lua                    ← thin entrypoint: bootstrap lazy + require modules
  setup.sh                    ← one-command setup script for all dependencies
  CLAUDE.md                   ← this file
  .claude/commands/           ← custom slash commands for Claude Code
  lua/
    config/
      options.lua             ← vim.opt settings
      keymaps.lua             ← all global keymaps
    plugins/
      ui.lua                  ← colorscheme, statusline, bufferline, neo-tree, indent guides
      editor.lua              ← telescope, gitsigns, toggleterm, trouble, conform
      lsp.lua                 ← mason, lspconfig, nvim-cmp (all languages)
      treesitter.lua          ← syntax highlighting
      dap.lua                 ← debuggers (Go + Python)
      jupyter.lua             ← molten-nvim for Jupyter notebooks
```

---

## How to Add a New Plugin

1. Identify the correct file in `lua/plugins/` by category:
   - UI/appearance → `ui.lua`
   - Editor workflow → `editor.lua`
   - LSP/completion → `lsp.lua`
   - Treesitter grammar → `treesitter.lua`
   - Debugging → `dap.lua`
   - Notebook/data → `jupyter.lua`

2. Add a lazy.nvim spec table to the `return {}` array in that file:

```lua
{
  "author/plugin-name",
  event = "VeryLazy",        -- lazy load trigger (optional)
  dependencies = { ... },    -- other plugins needed
  opts = { ... },            -- passed to require("plugin").setup(opts)
  -- OR --
  config = function()
    require("plugin").setup({ ... })
  end,
},
```

3. Run `:Lazy sync` inside nvim to install.

---

## How to Add a New LSP Server

Edit `lua/plugins/lsp.lua`:

1. **mason-lspconfig** — add the server name to `ensure_installed`:
   ```lua
   ensure_installed = { ..., "your_server" },
   ```

2. **lspconfig** — add setup in the `nvim-lspconfig` config function:
   ```lua
   lspconfig.your_server.setup({ capabilities = capabilities })
   ```

3. **conform.nvim** (optional formatter) — edit `lua/plugins/editor.lua`:
   ```lua
   formatters_by_ft = {
     your_lang = { "your_formatter" },
   }
   ```

4. **treesitter** (optional grammar) — edit `lua/plugins/treesitter.lua`,
   add the language name to `ensure_installed`.

5. Run `:Mason` to verify the server installed, `:LspInfo` to verify it attached.

---

## How to Add a New DAP Debugger

Edit `lua/plugins/dap.lua`:

1. Add the adapter plugin (e.g. `nvim-dap-<lang>`) as a lazy.nvim spec.
2. Call its setup in `config = function() ... end`.
3. If it uses mason, add the mason package to `ensure_installed` in `lsp.lua`
   and call `mason-registry` to auto-install (see the Python example).

---

## Keymap Reference

### File Navigation
| Key | Action |
|-----|--------|
| `<leader>e`  | Toggle neo-tree file explorer |
| `<leader>ff` | Telescope: find files |
| `<leader>fg` | Telescope: live grep |
| `<leader>fb` | Telescope: open buffers |

### Buffer Tabs
| Key | Action |
|-----|--------|
| `]b`         | Next buffer |
| `[b`         | Prev buffer |
| `<leader>bd` | Close buffer |

### Terminal
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle floating terminal |
| `<leader>cc` | Toggle Claude Code (persistent vertical split) |
| `<leader>lg` | Toggle lazygit |

### LSP / Code
| Key | Action |
|-----|--------|
| `gd`         | Go to definition |
| `gD`         | Go to declaration |
| `gr`         | References |
| `gi`         | Go to implementation |
| `K`          | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d`  | Prev / next diagnostic |
| `<leader>xx` | Toggle trouble diagnostics panel |
| `<leader>fm` | Format file (conform) |

### Debugger
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle DAP UI |

### Jupyter (Molten)
| Key | Action |
|-----|--------|
| `<leader>mi` | MoltenInit — pick a kernel |
| `<leader>mr` | Run current line / visual selection |
| `<leader>mo` | Show cell output |

---

## Prerequisites

Run `./setup.sh` from the repo root to install all dependencies automatically.

### Manual installation (if needed)

| Requirement | Command |
|-------------|---------|
| Homebrew packages | `brew install neovim lazygit ripgrep imagemagick luarocks fd` |
| Lua image binding | `luarocks --lua-version 5.1 install magick` |
| Python venv for nvim | `uv venv ~/.venvs/nvim --python 3.12 && uv pip install --python ~/.venvs/nvim/bin/python pynvim jupyter_client ipykernel cairosvg pnglatex plotly kaleido pyperclip nbformat` |
| Nerd Font | Install a Nerd Font and set it as terminal font |

Mason auto-installs: `gopls`, `pyright`, `ts_ls`, `lua_ls`, `debugpy`.

---

## Git Strategy

### Branching model
- **`main`** — always stable and working. Never push broken config here.
- **`feat/<name>`** — short-lived branches for adding plugins, new LSPs, or experiments.
  Merge to main only after verifying it works inside nvim.
- Example branch names: `feat/rust-lsp`, `feat/obsidian-plugin`, `feat/dap-js`

### When to commit directly to main
- Documentation changes (README, CLAUDE.md)
- Trivial config tweaks (keymaps, options, color changes)
- Hotfixes to a broken plugin config

### When to use a feature branch
- Adding a new language (LSP + treesitter + formatter + DAP)
- Adding a plugin that requires significant config
- Any change that could break existing workflow

### Versioning (semantic)
`v<major>.<minor>.<patch>`

| Bump | When |
|------|------|
| **major** | Breaking restructure of the whole config layout |
| **minor** | New language support, new major feature (e.g. Jupyter, DAP) |
| **patch** | Bug fixes, option tweaks, documentation |

### Creating a release
```sh
# Tag on main after merging
git tag v<version> -m "v<version>: <short description>"
git push origin v<version>

# GitHub release with changelog
gh release create v<version> --title "v<version> — <title>" --notes "<changelog>"
```

### Current version history
| Tag | Description |
|-----|-------------|
| `v1.0.0` | Initial modular VSCode-parity config (Go, Python, JS/TS, R, Lua) |
| `v1.1.0` | VSCode-like Jupyter: kitty inline images, auto-output, dedicated Python venv |
| `v1.2.0` | Neovim 0.11 upgrade, project config files, KEYBINDINGS.md cheatsheet |
| `v1.3.0` | UI overhaul (noice, fidget, dressing, rainbow), 12 new plugins, Catppuccin, VSCode parity |
| `v1.4.0` | neotest-golang test runner, nvim-ufo LSP folding, fix `<leader>db` keymap conflict |
| `v1.5.0` | claudecode.nvim integration for Claude Code |
| `v1.5.1` | setup.sh installer script, README rewrite, tree-sitter-cli dependency fix |
| `v1.5.2` | fix rest.nvim build with tree-sitter-cli and hererocks for Lua 5.1 |

---

## Common Commands

```
:Lazy          → Plugin manager UI
:Lazy sync     → Install/update all plugins
:Mason         → LSP/tool installer UI
:LspInfo       → Show active LSP servers for current buffer
:Telescope     → Open telescope picker
:Neotree       → Open file explorer
:Trouble       → Open diagnostics panel
:MoltenInit    → Start a Jupyter kernel
```
