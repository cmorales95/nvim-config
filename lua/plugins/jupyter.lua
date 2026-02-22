-- ============================================================
-- Jupyter notebook support via molten-nvim
-- Prerequisites: uv venv ~/.venvs/nvim && uv pip install pynvim jupyter_client ipykernel
-- Image rendering: kitty terminal + imagemagick + luarocks magick
-- Usage:
--   <leader>mi  → MoltenInit  (select kernel)
--   <leader>mr  → run current line / visual selection
--   <leader>mo  → show output window
-- ============================================================
return {

  -- Inline image rendering (kitty native protocol)
  {
    "3rd/image.nvim",
    lazy = false,   -- must load before molten
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
      -- Image rendering via image.nvim + kitty
      vim.g.molten_image_provider        = "image.nvim"

      -- Output behaviour (VSCode-style: auto-show on run)
      vim.g.molten_auto_open_output      = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output           = true

      -- Virtual text shows condensed output inline
      vim.g.molten_virt_text_output      = true
      vim.g.molten_virt_lines_off_by_1   = true

      -- Enter output window automatically after run
      vim.g.molten_enter_output_behavior = "open_and_enter"
    end,
  },

}
