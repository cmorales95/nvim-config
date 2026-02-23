-- ============================================================
-- Editor options
-- ============================================================
local opt = vim.opt

-- Line numbers
opt.number         = true
opt.relativenumber = true

-- Tabs / indentation
opt.expandtab   = true
opt.shiftwidth  = 2
opt.tabstop     = 2
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true

-- Appearance
opt.termguicolors = true
opt.signcolumn    = "yes"
opt.cursorline    = true
opt.wrap          = false
opt.scrolloff     = 8
opt.sidescrolloff = 8
opt.mouse         = "a"
opt.showmode      = false   -- lualine shows mode already
opt.pumheight     = 10      -- completion popup max height

-- Performance
opt.updatetime  = 250
opt.timeoutlen  = 300

-- Files
opt.undofile    = true       -- persistent undo
opt.swapfile    = false
opt.backup      = false

-- Clipboard: share with macOS system clipboard (pbcopy/pbpaste)
-- Explicit provider so Kitty terminal doesn't interfere
vim.g.clipboard = {
  name  = "macOS",
  copy  = { ["+"] = "pbcopy",  ["*"] = "pbcopy"  },
  paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
  cache_enabled = 0,
}
opt.clipboard = "unnamedplus"

-- Auto-save: write on focus lost and when leaving insert mode (VSCode-style)
vim.api.nvim_create_autocmd({ "FocusLost", "InsertLeave", "TextChanged" }, {
  pattern  = "*",
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})

-- Soft-wrap for code files (wrap at word boundaries, preserve indentation)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "python", "javascript", "typescript", "javascriptreact", "typescriptreact", "jupyter", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true      -- wrap at word boundaries, not mid-word
    vim.opt_local.breakindent = true    -- preserve indentation on wrapped lines
  end,
})

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Folding (treesitter-based, optional)
opt.foldmethod = "indent"
opt.foldlevel  = 99

-- Python provider (dedicated venv so system Python stays clean)
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

-- Add nvim venv bin to PATH so tools like jupytext are found by plugins
vim.env.PATH = vim.fn.expand("~/.venvs/nvim/bin") .. ":" .. vim.env.PATH
