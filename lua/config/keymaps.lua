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
map("n", "qq",          "<cmd>qa<cr>",            { desc = "Quit all" })

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
map("n", "<leader>bd", function()
  pcall(vim.cmd, "MoltenDeinit") -- safely deinit kernel if active
  vim.cmd("bdelete")
end, { desc = "Close buffer" })

-- ----------------------------------------------------------
-- File explorer (neo-tree)
-- ----------------------------------------------------------
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

-- ----------------------------------------------------------
-- Telescope
-- ----------------------------------------------------------
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",          { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",           { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",             { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",           { desc = "Help tags" })
map("n", "<leader>fs", "<cmd>Telescope session-lens<cr>",        { desc = "Search sessions" })

-- ----------------------------------------------------------
-- Commenting (VSCode-style Ctrl+/)
-- Built-in `gcc` / `gc` still work — these are aliases for migration
-- ----------------------------------------------------------
map("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<C-/>", "gc",  { desc = "Toggle comment", remap = true })

-- ----------------------------------------------------------
-- Aerial (symbols outline)
-- ----------------------------------------------------------
map("n", "<leader>o", "<cmd>AerialToggle<cr>", { desc = "Toggle symbols outline" })

-- ----------------------------------------------------------
-- Harpoon (pinned files)
-- ----------------------------------------------------------
map("n", "<leader>ha", function() require("harpoon"):list():add() end,                                      { desc = "Harpoon: add file" })
map("n", "<leader>hh", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end,        { desc = "Harpoon: menu" })
map("n", "<leader>h1", function() require("harpoon"):list():select(1) end,                                   { desc = "Harpoon: file 1" })
map("n", "<leader>h2", function() require("harpoon"):list():select(2) end,                                   { desc = "Harpoon: file 2" })
map("n", "<leader>h3", function() require("harpoon"):list():select(3) end,                                   { desc = "Harpoon: file 3" })
map("n", "<leader>h4", function() require("harpoon"):list():select(4) end,                                   { desc = "Harpoon: file 4" })

-- ----------------------------------------------------------
-- LSPSaga (enhanced LSP UI)
-- ----------------------------------------------------------
map("n", "gh",         "<cmd>Lspsaga finder<cr>",           { desc = "LSP finder" })
map("n", "<leader>pd", "<cmd>Lspsaga peek_definition<cr>",  { desc = "Peek definition" })
map("n", "<leader>rn", "<cmd>Lspsaga rename<cr>",           { desc = "Rename symbol" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>",      { desc = "Code action" })

-- ----------------------------------------------------------
-- Diagnostics / code (LSP keymaps live in plugins/lsp.lua
-- via LspAttach autocmd; global ones here)
-- ----------------------------------------------------------
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics panel" })
map("n", "<leader>fm", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format file" })

-- ----------------------------------------------------------
-- Git (diffview)
-- ----------------------------------------------------------
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>",        { desc = "Open diffview" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File history" })
map("n", "<leader>gx", "<cmd>DiffviewClose<cr>",       { desc = "Close diffview" })

-- ----------------------------------------------------------
-- TODO comments
-- ----------------------------------------------------------
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Search TODOs" })

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
-- Filetype tools
-- ----------------------------------------------------------
map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle markdown preview" })
map("n", "<leader>db", "<cmd>DBUIToggle<cr>",            { desc = "Toggle database UI" })

-- ----------------------------------------------------------
-- Jupyter / Molten
-- ----------------------------------------------------------
map("n", "<leader>mi", "<cmd>MoltenInit<cr>",              { desc = "Molten: init kernel" })
map("n", "<leader>mr", function()
  -- Find cell boundaries (# %% markers) and evaluate the block
  local start_line = vim.fn.search("^# %%", "bcnW")
  local end_line   = vim.fn.search("^# %%", "nW")
  if start_line == 0 then start_line = 1 end
  if end_line   == 0 then end_line   = vim.fn.line("$") else end_line = end_line - 1 end
  -- Strip the marker line itself
  if vim.fn.getline(start_line):match("^# %%") then start_line = start_line + 1 end
  vim.fn.setpos("'<", { 0, start_line, 1, 0 })
  vim.fn.setpos("'>", { 0, end_line,   1, 0 })
  vim.cmd("MoltenEvaluateVisual")
end, { desc = "Molten: run cell block" })
map("n", "<leader>ml", "<cmd>MoltenEvaluateLine<cr>",      { desc = "Molten: run line" })
map("n", "<leader>mo", "<cmd>MoltenShowOutput<cr>",        { desc = "Molten: show output" })
map("n", "<leader>mR", "<cmd>MoltenReevaluateAll<cr>",     { desc = "Molten: re-run all cells" })
map("n", "<leader>mA", function()
  local function run_all()
    local total = vim.fn.line("$")
    local markers = {}
    for lnum = 1, total do
      if vim.fn.getline(lnum):match("^# %%") then
        table.insert(markers, lnum)
      end
    end
    table.insert(markers, total + 1) -- sentinel

    local saved = vim.fn.getpos(".")
    for i = 1, #markers - 1 do
      local s = markers[i] + 1
      local e = markers[i + 1] - 1
      if s <= e then
        vim.api.nvim_win_set_cursor(0, { s, 0 })
        vim.cmd("normal! V" .. (e - s) .. "j")
        vim.cmd("MoltenEvaluateVisual")
      end
    end
    vim.fn.setpos(".", saved)
  end

  -- If kernel not ready, init with MoltenInit (will prompt) then run
  local ok = pcall(run_all)
  if not ok then
    vim.notify("Molten: no kernel — run <leader>mi to init first", vim.log.levels.WARN)
  end
end, { desc = "Molten: run all cells" })
map("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<cr>",   { desc = "Molten: run selection" })
