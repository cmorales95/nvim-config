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
      -- Auto-load kernel when opening a jupytext-converted notebook
      vim.api.nvim_create_autocmd("User", {
        pattern  = "MoltenInitPost",
        callback = function()
          -- Import outputs if a .ipynb companion exists
          local ipynb = vim.fn.expand("%:r") .. ".ipynb"
          if vim.fn.filereadable(ipynb) == 1 then
            vim.cmd("MoltenImportOutput")
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

}
