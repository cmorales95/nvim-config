# Keybindings

> **Leader key** = `Space`
>
> Notation: `<leader>` = Space · `<C-x>` = Ctrl+x · `<S-x>` = Shift+x

---

## The essentials

| Key | What it does |
|---|---|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `u` | Undo |
| `<C-r>` | Redo |
| `<Esc>` | Clear search highlight (normal mode) |

---

## Closing things

| What's open | How to close it |
|---|---|
| Floating window (Lazy, Mason, etc.) | `q` |
| Telescope picker | `<Esc>` or `q` |
| Terminal / Claude / lazygit | `<leader>tt` / `<leader>cc` / `<leader>lg` (toggles) |
| File explorer (neo-tree) | `<leader>e` (toggles) |
| Diagnostics panel (Trouble) | `<leader>xx` (toggles) |
| Current buffer/tab | `<leader>bd` |
| Current split | `<leader>q` |
| Exit terminal typing mode | `<Esc><Esc>` |

---

## Finding files & text

| Key | What it does |
|---|---|
| `<leader>ff` | Find files by name |
| `<leader>fg` | Search text inside files (live grep) |
| `<leader>fb` | Switch between open buffers |
| `<leader>fh` | Search help docs |
| `<leader>s` | Flash jump — type a char to jump anywhere on screen |

> Inside Telescope: type to filter · `<CR>` to open · `<Esc>` to cancel · `<C-j/k>` to move up/down

---

## File explorer

| Key | What it does |
|---|---|
| `<leader>e` | Toggle sidebar file explorer |
| `<CR>` | Open file / expand folder |
| `a` | New file or folder (end with `/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `q` | Close explorer |

---

## Terminal

| Key | What it does |
|---|---|
| `<leader>tt` | Open / close floating terminal |
| `<leader>cc` | Open / close Claude Code (vertical split) |
| `<leader>lg` | Open / close lazygit |
| `<Esc><Esc>` | Exit terminal typing mode (go back to normal mode) |
| `<Esc>` | Exit Claude Code terminal mode |

---

## Tabs (buffers)

| Key | What it does |
|---|---|
| `]b` | Next tab |
| `[b` | Previous tab |
| `<leader>bd` | Close current tab |

---

## Splits (windows)

| Key | What it does |
|---|---|
| `<C-h>` | Move to left split |
| `<C-l>` | Move to right split |
| `<C-j>` | Move to bottom split |
| `<C-k>` | Move to top split |
| `<C-Up>` | Increase split height |
| `<C-Down>` | Decrease split height |
| `<C-Left>` | Decrease split width |
| `<C-Right>` | Increase split width |

---

## Code (LSP)

> These only work when an LSP server is attached to the file.

| Key | What it does |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Show all references |
| `gi` | Go to implementation |
| `K` | Show hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions (quick fixes, imports, etc.) |
| `[d` | Previous diagnostic (error/warning) |
| `]d` | Next diagnostic |
| `<leader>xx` | Toggle diagnostics panel |
| `<leader>fm` | Format file |

---

## Editing

| Key | What it does | Mode |
|---|---|---|
| `<` | Indent left (stays selected) | Visual |
| `>` | Indent right (stays selected) | Visual |
| `J` | Move selection down | Visual |
| `K` | Move selection up | Visual |

---

## Debugger

| Key | What it does |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate session |
| `<leader>du` | Toggle debugger UI |

---

## Jupyter (Molten)

| Key | What it does |
|---|---|
| `<leader>mi` | Start a Jupyter kernel |
| `<leader>mr` | Run current line or visual selection |
| `<leader>mo` | Show cell output |
