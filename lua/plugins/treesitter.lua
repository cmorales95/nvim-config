-- ============================================================
-- Treesitter — syntax highlighting, text objects, context
-- ============================================================
return {

  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "go", "python", "javascript", "typescript", "tsx",
        "r", "lua", "bash", "json", "yaml",
        "markdown", "markdown_inline", "html", "css",
      },
      auto_install = true,
      highlight    = { enable = true },
      indent       = { enable = true },
    },
  },

  -- Shows current function/class context pinned at top while scrolling
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts  = {
      enable        = true,
      max_lines     = 3,
      trim_scope    = "outer",
      mode          = "cursor",
    },
  },

}
