# nvim-config — Claude Code Project Guide

## Overview
Full VSCode-parity Neovim configuration. Uses **lazy.nvim** as the plugin manager with a
modular file layout. Supports Go, Python, JavaScript/TypeScript, R, and Jupyter notebooks.

## File Structure

```
~/.config/nvim/
  init.lua                    ← thin entrypoint: bootstrap lazy + require modules
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

## Prerequisites (manual steps)

| Requirement | Command |
|-------------|---------|
| R language server | `install.packages("languageserver")` in R console |
| Jupyter support | `pip install pynvim jupyter_client` |
| lazygit | `brew install lazygit` |
| Nerd Font | Install a Nerd Font and set it as terminal font |
| ripgrep (telescope grep) | `brew install ripgrep` |

Mason auto-installs: `gopls`, `pyright`, `ts_ls`, `r_language_server`, `lua_ls`, `debugpy`.

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
