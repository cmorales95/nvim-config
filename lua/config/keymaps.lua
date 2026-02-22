-- ============================================================
-- Keymaps
-- ============================================================
local map = vim.keymap.set

-- ----------------------------------------------------------
-- General
-- ----------------------------------------------------------
map("n", "<Esc>",       "<cmd>nohlsearch<cr>",   { desc = "Clear search highlight" })
map("n", "<leader>w",   "<cmd>w<cr>",             { desc = "Save file" })
map("n", "<leader>q",   "<cmd>q<cr>",             { desc = "Quit" })

-- ----------------------------------------------------------
-- Window navigation
-- ----------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })

-- Window resize
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

-- ----------------------------------------------------------
-- Visual mode
-- ----------------------------------------------------------
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ----------------------------------------------------------
-- Buffer tabs (bufferline)
-- ----------------------------------------------------------
map("n", "]b",          "<cmd>BufferLineCycleNext<cr>",  { desc = "Next buffer" })
map("n", "[b",          "<cmd>BufferLineCyclePrev<cr>",  { desc = "Prev buffer" })
map("n", "<leader>bd",  "<cmd>bdelete<cr>",              { desc = "Close buffer" })

-- ----------------------------------------------------------
-- File explorer (neo-tree)
-- ----------------------------------------------------------
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

-- ----------------------------------------------------------
-- Telescope
-- ----------------------------------------------------------
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",  { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",    { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",  { desc = "Help tags" })

-- ----------------------------------------------------------
-- Diagnostics / code (LSP keymaps live in plugins/lsp.lua
-- via LspAttach autocmd; global ones here)
-- ----------------------------------------------------------
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics panel" })
map("n", "<leader>fm", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format file" })

-- ----------------------------------------------------------
-- Debugger
-- ----------------------------------------------------------
map("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" })
map("n", "<leader>dc", "<cmd>lua require('dap').continue()<cr>",          { desc = "Continue" })
map("n", "<leader>di", "<cmd>lua require('dap').step_into()<cr>",         { desc = "Step into" })
map("n", "<leader>do", "<cmd>lua require('dap').step_over()<cr>",         { desc = "Step over" })
map("n", "<leader>dO", "<cmd>lua require('dap').step_out()<cr>",          { desc = "Step out" })
map("n", "<leader>dt", "<cmd>lua require('dap').terminate()<cr>",         { desc = "Terminate" })
map("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>",          { desc = "Toggle DAP UI" })

-- ----------------------------------------------------------
-- Jupyter / Molten
-- ----------------------------------------------------------
map("n", "<leader>mi", "<cmd>MoltenInit<cr>",              { desc = "Molten: init kernel" })
map("n", "<leader>mr", "<cmd>MoltenEvaluateLine<cr>",      { desc = "Molten: run cell" })
map("n", "<leader>mo", "<cmd>MoltenShowOutput<cr>",        { desc = "Molten: show output" })
map("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<cr>",   { desc = "Molten: run selection" })
