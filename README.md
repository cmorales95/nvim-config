# nvim config

VSCode-parity Neovim setup. Plugin manager: **lazy.nvim**. Leader key: `<Space>`.

## What's installed

| Category | Plugins |
|---|---|
| **Theme / UI** | tokyonight-night, lualine, bufferline, which-key |
| **File nav** | neo-tree (sidebar), telescope (fuzzy finder) |
| **Editor** | flash.nvim (jump motion), autopairs, indent guides, colorizer |
| **Git** | gitsigns (gutter), lazygit (in-terminal UI) |
| **LSP** | mason + mason-lspconfig auto-installs servers; nvim-cmp for completion |
| **Formatters** | conform.nvim — format on save |
| **Diagnostics** | trouble.nvim (Problems panel) |
| **Terminal** | toggleterm — floating terminal, Claude Code split, lazygit |
| **Debugger** | nvim-dap + dap-ui; delve (Go), debugpy (Python) |
| **Jupyter** | molten-nvim — run cells inside `.ipynb` / Python files |

## Languages supported out of the box

| Language | LSP | Formatter | Debugger |
|---|---|---|---|
| Go | `gopls` | `goimports` + `gofmt` | delve |
| Python | `pyright` | `isort` + `black` | debugpy |
| JS / TS | `ts_ls` | `prettier` | — |
| R | `r_language_server` | `formatR` | — |
| Lua | `lua_ls` | `stylua` | — |

## File layout

```
init.lua                 ← bootstraps lazy.nvim, loads modules
lua/
  config/
    options.lua          ← vim.opt settings
    keymaps.lua          ← global keymaps
  plugins/
    ui.lua               ← theme, statusline, bufferline, neo-tree, indent guides
    editor.lua           ← telescope, gitsigns, autopairs, toggleterm, trouble, conform
    lsp.lua              ← mason, lspconfig, nvim-cmp + completion sources
    treesitter.lua       ← syntax highlighting grammars
    dap.lua              ← debuggers (Go + Python)
    jupyter.lua          ← molten-nvim for Jupyter notebooks
```

## Prerequisites

Run these once before first launch:

```sh
# macOS
brew install lazygit ripgrep imagemagick luarocks

# Lua binding for image rendering (used by image.nvim)
luarocks --lua-version 5.1 install magick

# Dedicated Python venv for Neovim (keeps system Python clean)
uv venv ~/.venvs/nvim --python 3.12
uv pip install --python ~/.venvs/nvim/bin/python pynvim jupyter_client ipykernel

# R language server (in R console)
install.packages("languageserver")
```

Also install a [Nerd Font](https://www.nerdfonts.com/) and set it as your terminal font (icons won't render without it).

**For inline plot/image output:** requires Kitty terminal (used by default). The config uses Kitty's native image protocol via `image.nvim`.

Mason auto-installs everything else (`gopls`, `pyright`, `ts_ls`, etc.) on first launch.

## Key bindings

### Navigation

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer (neo-tree) |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Open buffers |
| `<leader>fh` | Help tags |
| `<leader>s` | Flash jump (type chars to jump anywhere) |
| `]b` / `[b` | Next / prev buffer tab |
| `<leader>bd` | Close buffer |
| `<C-h/j/k/l>` | Move between splits |

### LSP (active when a server is attached)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>xx` | Toggle diagnostics panel (trouble) |
| `<leader>fm` | Format file |

### Completion (insert mode)

| Key | Action |
|---|---|
| `<C-Space>` | Trigger completion |
| `<Tab>` / `<S-Tab>` | Next / prev item |
| `<CR>` | Confirm selection |
| `<C-e>` | Dismiss |

### Debugger

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle DAP UI |

### Terminal & tools

| Key | Action |
|---|---|
| `<leader>tt` | Floating terminal |
| `<leader>cc` | Claude Code (vertical split, persistent) |
| `<leader>lg` | lazygit |
| `<Esc><Esc>` | Exit terminal mode |

### Jupyter (molten)

| Key | Action |
|---|---|
| `<leader>mi` | MoltenInit — pick a kernel |
| `<leader>mr` | Run line / visual selection |
| `<leader>mo` | Show cell output |

### General

| Key | Action |
|---|---|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlight |
| `<` / `>` (visual) | Indent left / right (stays selected) |
| `J` / `K` (visual) | Move selection down / up |

## Common commands

```
:Lazy          plugin manager UI
:Lazy sync     install / update all plugins
:Mason         LSP/tool installer
:LspInfo       show active servers for current buffer
:Telescope     open any telescope picker
:Neotree       file explorer
:Trouble       diagnostics panel
:MoltenInit    start a Jupyter kernel
```

## Adding things

- **New plugin** → add a lazy.nvim spec to the appropriate file in `lua/plugins/`
- **New LSP** → see `CLAUDE.md` for the step-by-step
- **New language** → use the `/add-lsp` slash command inside Claude Code (`<leader>cc`)
