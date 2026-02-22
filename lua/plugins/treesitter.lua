-- ============================================================
-- Treesitter — syntax highlighting & text objects
-- ============================================================
return {

  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "go",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "r",
        "lua",
        "bash",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "html",
        "css",
      },
      auto_install = true,
      highlight    = { enable = true },
      indent       = { enable = true },
    },
  },

}
