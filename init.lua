-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key must be set before plugins load
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Core config
require("config.options")
require("config.keymaps")

-- Plugins (lazy.nvim spec files)
require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.lsp" },
  { import = "plugins.treesitter" },
  { import = "plugins.dap" },
  { import = "plugins.jupyter" },
  { import = "plugins.filetypes" },
}, {
  change_detection = { notify = false },
})
