-- ============================================================
-- Debugging (DAP)
-- Languages: Go (delve), Python (debugpy)
-- launch.json: drop a .vscode/launch.json in your project —
--              it will be loaded automatically on debug start
-- ============================================================
return {

  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },

  -- Inline variable values while stepping (like VSCode inline values)
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    opts = {
      enabled                = true,
      enabled_commands       = true,
      highlight_changed_variables = true,
      highlight_new_as_changed    = true,
      show_stop_reason       = true,
      commented              = false,
      virt_text_pos          = "eol",   -- show at end of line
    },
  },

  -- DAP UI (Variables, Call Stack, Breakpoints, Console panels)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size     = 40,
            position = "left",
          },
          {
            elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
            size     = 10,
            position = "bottom",
          },
        },
      })

      -- Auto open/close UI with session
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      -- Load .vscode/launch.json automatically when it exists
      require("dap.ext.vscode").load_launchjs(nil, {
        -- map vscode type names → nvim-dap adapter names
        ["go"]         = { "go" },
        ["python"]     = { "python" },
        ["node"]       = { "node" },
        ["pwa-node"]   = { "node" },
        ["chrome"]     = { "chrome" },
        ["pwa-chrome"] = { "chrome" },
      })
    end,
  },

  -- Go debugger (delve)
  {
    "leoluz/nvim-dap-go",
    ft           = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config       = function()
      require("dap-go").setup()
    end,
  },

  -- Python debugger (debugpy via mason)
  {
    "mfussenegger/nvim-dap-python",
    ft           = "python",
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(mason_path)
      require("mason-registry").refresh(function()
        local pkg = require("mason-registry").get_package("debugpy")
        if not pkg:is_installed() then pkg:install() end
      end)
    end,
  },

}
