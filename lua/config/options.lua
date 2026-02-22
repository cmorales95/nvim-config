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
opt.showmode      = false   -- lualine shows mode already
opt.pumheight     = 10      -- completion popup max height

-- Performance
opt.updatetime  = 250
opt.timeoutlen  = 300

-- Files
opt.clipboard   = "unnamedplus"
opt.undofile    = true       -- persistent undo
opt.swapfile    = false
opt.backup      = false

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Folding (treesitter-based, optional)
opt.foldmethod = "indent"
opt.foldlevel  = 99
