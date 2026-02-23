# nvim-config

VSCode-parity Neovim configuration for macOS. Uses **lazy.nvim** as the plugin manager.

## Requirements

- **macOS** (setup script is macOS-only; Linux users can adapt manually)
- **Neovim 0.10+** (tested on 0.11.5)
- **Homebrew** (for dependency installation)
- **Nerd Font** (required for icons)
- **Kitty terminal** (optional, required for inline Jupyter images)

## Installation

### Quick setup (recommended)

```sh
# Backup existing config if you have one
mv ~/.config/nvim ~/.config/nvim.bak

# Clone and install
git clone https://github.com/cmorales95/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
./setup.sh
```

The setup script installs:
- Homebrew packages: `neovim`, `lazygit`, `ripgrep`, `imagemagick`, `luarocks`, `tree-sitter-cli`, `fd`
- Lua rocks: `magick` (for image rendering)
- Python venv at `~/.venvs/nvim` with Jupyter dependencies

### First launch

1. Open Neovim: `nvim`
2. Wait for lazy.nvim to auto-install all plugins (progress shown at bottom)
3. Mason will auto-install LSP servers on first use
4. Restart Neovim after initial setup completes

### Verify installation

```
:checkhealth              # Full health check
:Lazy                     # Plugin manager (all should be green)
:Mason                    # LSP installer (servers should be installed)
:LspInfo                  # Check LSP attached to current file
```

## What's included

### Theme & UI

| Plugin | Description |
|---|---|
| catppuccin | Mocha color scheme |
| lualine | Status line |
| bufferline | Buffer tabs |
| neo-tree | File explorer sidebar |
| alpha-nvim | Dashboard / start screen |
| which-key | Keybinding hints |
| noice.nvim | Command line, messages, notifications UI |
| fidget.nvim | LSP progress indicator |
| dressing.nvim | Improved vim.ui.select/input |
| nvim-ufo | LSP-powered code folding |
| aerial.nvim | Code outline / symbols sidebar |

### Editor

| Plugin | Description |
|---|---|
| telescope | Fuzzy finder (files, grep, buffers) |
| flash.nvim | Jump motion (type chars to jump) |
| gitsigns | Git gutter signs |
| toggleterm | Floating terminal, lazygit, Claude Code |
| trouble.nvim | Diagnostics panel |
| conform.nvim | Format on save |
| autopairs | Auto-close brackets/quotes |
| indent-blankline | Indent guides |
| rainbow-delimiters | Rainbow brackets |
| nvim-colorizer | Hex color previews |

### LSP & Completion

| Plugin | Description |
|---|---|
| mason | LSP/tool installer |
| nvim-lspconfig | LSP configuration |
| nvim-cmp | Autocompletion |
| SchemaStore | JSON/YAML schema validation |

### Debugging

| Plugin | Description |
|---|---|
| nvim-dap | Debug Adapter Protocol |
| nvim-dap-ui | Debugger UI |
| nvim-dap-go | Go debugger (delve) |
| nvim-dap-python | Python debugger (debugpy) |

### Filetype-specific

| Plugin | Description |
|---|---|
| molten-nvim | Jupyter notebook support |
| render-markdown | Inline markdown rendering |
| markdown-preview | Live preview in browser |
| rest.nvim | HTTP REST client (.http files) |
| vim-dadbod | SQL database client |

## Languages supported

| Language | LSP | Formatter | Debugger |
|---|---|---|---|
| Go | gopls | goimports + gofmt | delve |
| Python | pyright | isort + black | debugpy |
| JS / TS | ts_ls | prettier | - |
| R | r_language_server | formatR | - |
| Lua | lua_ls | stylua | - |

Mason auto-installs these on first use.

## File layout

```
~/.config/nvim/
  init.lua              <- bootstraps lazy.nvim, loads modules
  setup.sh              <- one-command dependency installer
  README.md             <- this file
  CLAUDE.md             <- AI assistant instructions
  lua/
    config/
      options.lua       <- vim.opt settings
      keymaps.lua       <- global keymaps
    plugins/
      ui.lua            <- theme, statusline, bufferline, neo-tree
      editor.lua        <- telescope, gitsigns, toggleterm, trouble, conform
      lsp.lua           <- mason, lspconfig, nvim-cmp
      treesitter.lua    <- syntax highlighting
      dap.lua           <- debuggers (Go + Python)
      jupyter.lua       <- molten-nvim for Jupyter notebooks
      filetypes.lua     <- markdown, REST, SQL, schemas
```

## Key bindings

Leader key: `<Space>`

### Navigation

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Open buffers |
| `<leader>fh` | Help tags |
| `<leader>s` | Flash jump |
| `]b` / `[b` | Next / prev buffer |
| `<leader>bd` | Close buffer |
| `<C-h/j/k/l>` | Move between splits |

### LSP

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
| `<leader>xx` | Toggle diagnostics panel |
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
| `<leader>cc` | Claude Code (vertical split) |
| `<leader>lg` | lazygit |
| `<Esc><Esc>` | Exit terminal mode |

### Jupyter (molten)

| Key | Action |
|---|---|
| `<leader>mi` | MoltenInit (pick kernel) |
| `<leader>mr` | Run line / selection |
| `<leader>mo` | Show cell output |

### HTTP (rest.nvim)

| Key | Action |
|---|---|
| `<leader>rr` | Run HTTP request |
| `<leader>rl` | Re-run last request |

### General

| Key | Action |
|---|---|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlight |
| `<` / `>` (visual) | Indent left / right |
| `J` / `K` (visual) | Move selection up / down |

## Common commands

```
:Lazy              Plugin manager UI
:Lazy sync         Install / update plugins
:Mason             LSP/tool installer
:LspInfo           Show active LSP servers
:Telescope         Fuzzy finder
:Neotree           File explorer
:Trouble           Diagnostics panel
:MoltenInit        Start Jupyter kernel
:MarkdownPreview   Preview markdown in browser
:DBUI              SQL database UI
:Rest run          Run HTTP request
```

## Troubleshooting

### Plugin failed to install

```sh
# Clear plugin cache and reinstall
rm -rf ~/.local/share/nvim/lazy
nvim  # plugins will reinstall
```

### rest.nvim fails with tree-sitter-cli error

Install tree-sitter-cli CLI:
```sh
brew install tree-sitter-cli
```

### LSP not attaching

1. Check `:LspInfo` for errors
2. Run `:Mason` and verify server is installed
3. Check `:checkhealth lsp`

### Jupyter images not showing

- Requires Kitty terminal
- Run `:checkhealth` and look for image.nvim section

### Icons not rendering

Install a Nerd Font and set it as your terminal font.

## Customization

- **Add plugin**: Edit the appropriate file in `lua/plugins/`, run `:Lazy sync`
- **Add LSP**: See `CLAUDE.md` for step-by-step
- **Add language**: Use `/add-lsp` command in Claude Code (`<leader>cc`)

## License

MIT
