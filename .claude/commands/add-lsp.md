Add full language support (LSP + treesitter + formatter) for a new language.

Language / server: $ARGUMENTS

Steps:
1. Read CLAUDE.md for the complete workflow.
2. Read `lua/plugins/lsp.lua`, `lua/plugins/treesitter.lua`, and `lua/plugins/editor.lua`.
3. In `lua/plugins/lsp.lua`:
   a. Add the mason server name to `mason-lspconfig` `ensure_installed`.
   b. Add `lspconfig.<server>.setup({ capabilities = capabilities })` with any language-specific settings.
4. In `lua/plugins/treesitter.lua`: add the treesitter grammar name to `ensure_installed` (if one exists).
5. In `lua/plugins/editor.lua` (conform): add `your_lang = { "formatter_name" }` to `formatters_by_ft`.
   - If the formatter must be installed via mason, note it for the user.
6. If a DAP debugger is available for this language, offer to add it to `lua/plugins/dap.lua`.
7. List all prerequisites the user must install manually (pip packages, system tools, etc.).
8. Show a diff-style summary of all changes and remind the user to:
   - Run `:Lazy sync` then `:Mason` in nvim.
   - Install any manual prerequisites.
