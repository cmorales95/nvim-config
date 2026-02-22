-- ============================================================
-- Jupyter notebook support via molten-nvim + jupytext
-- Prerequisites:
--   uv pip install pynvim jupyter_client ipykernel jupytext
--   brew install imagemagick && luarocks --lua-version 5.1 install magick
-- Usage:
--   Open any .ipynb → auto-converted to Python with # %% cells
--   <leader>mi  → MoltenInit  (select kernel)
--   <leader>mr  → run current line / visual selection
--   <leader>mo  → show output window
-- ============================================================
return {

  -- Inline image rendering (kitty native protocol)
  {
    "3rd/image.nvim",
    lazy = false,
    opts = {
      backend                      = "kitty",
      max_width_window_percentage  = 50,
      max_height_window_percentage = 30,
      kitty_method                 = "normal",
    },
  },

  {
    "benlubas/molten-nvim",
    version      = "^1.0.0",
    build        = ":UpdateRemotePlugins",
    ft           = { "python", "jupyter" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider        = "image.nvim"
      vim.g.molten_auto_open_output      = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output           = true
      vim.g.molten_virt_text_output      = true
      vim.g.molten_virt_lines_off_by_1   = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
    end,
    config = function()
      -- Find the jupyter kernel whose argv points to the project .venv
      local function venv_kernel_name()
        local venv = vim.fn.finddir(".venv", vim.fn.getcwd() .. ";")
        if venv == "" then return nil end
        local venv_python = vim.fn.fnamemodify(venv, ":p") .. "bin/python"
        local raw  = vim.fn.system("jupyter kernelspec list --json 2>/dev/null")
        local ok, specs = pcall(vim.fn.json_decode, raw)
        if not ok or not specs or not specs.kernelspecs then return nil end
        for name, spec in pairs(specs.kernelspecs) do
          local argv = spec.spec and spec.spec.argv
          if argv and argv[1] and argv[1]:find(venv_python, 1, true) then
            return name
          end
        end
        return nil
      end

      -- Auto-init kernel when opening a jupytext-converted notebook (# %% file)
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern  = "*.py",
        callback = function()
          -- Only act on hydrogen-style notebooks (has at least one # %% marker)
          local has_cell = vim.fn.search("^# %%", "nw") > 0
          if not has_cell then return end
          local kernel = venv_kernel_name()
          if kernel then
            vim.schedule(function()
              pcall(vim.cmd, "MoltenInit " .. kernel)
            end)
          end
        end,
      })

      -- Import outputs after kernel is ready
      vim.api.nvim_create_autocmd("User", {
        pattern  = "MoltenInitPost",
        callback = function()
          local ipynb = vim.fn.expand("%:r") .. ".ipynb"
          if vim.fn.filereadable(ipynb) == 1 then
            pcall(vim.cmd, "MoltenImportOutput")
          end
        end,
      })
    end,
  },

  -- GraniiteLabs/jupytext.nvim: transparently open .ipynb as Python # %% cells
  {
    "GCBallesteros/jupytext.nvim",
    lazy   = false,
    config = function()
      require("jupytext").setup({
        style            = "hydrogen",
        output_extension = "auto",
        force_ft         = "python",
        jupytext         = vim.fn.expand("~/.venvs/nvim/bin/jupytext"),
      })
    end,
  },

  -- Markdown rendering for # %% [markdown] cells in jupytext Python files
  {
    "cmorales95/jupytext-render.nvim",
    main         = "jupytext-render",
    event        = "VeryLazy",
    dependencies = { "MeanderingProgrammer/render-markdown.nvim" },
    opts = {
      keymaps    = { toggle = "<leader>mM" },
      highlights = {
        cell_bg = "JupytextMDCell",
        sep     = "JupytextMDSep",
      },
    },
  },

}
