-- ============================================================
-- Jupyter notebook support via molten-nvim
-- Prerequisites: pip install pynvim jupyter_client
-- Usage:
--   <leader>mi  → MoltenInit  (select kernel)
--   <leader>mr  → run current line / visual selection
--   <leader>mo  → show output window
-- ============================================================
return {

  {
    "benlubas/molten-nvim",
    version      = "^1.0.0",
    build        = ":UpdateRemotePlugins",
    ft           = { "python", "jupyter" },
    dependencies = { "3rd/image.nvim" },  -- optional inline images
    init = function()
      -- Display settings
      vim.g.molten_image_provider         = "none"   -- set to "image.nvim" if you install it
      vim.g.molten_output_win_max_height  = 20
      vim.g.molten_auto_open_output       = false    -- manual with <leader>mo
      vim.g.molten_wrap_output            = true
      vim.g.molten_virt_text_output       = true
      vim.g.molten_virt_lines_off_by_1    = true
    end,
  },

  -- Optional: inline image rendering (requires ImageMagick + ueberzugpp or kitty)
  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend                = "ueberzug",  -- or "kitty" in kitty terminal
      max_width_window_percentage  = 50,
      max_height_window_percentage = 30,
    },
  },

}
