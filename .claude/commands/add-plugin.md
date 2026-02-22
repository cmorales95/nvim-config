Add a new Neovim plugin to this config.

Plugin to add: $ARGUMENTS

Steps:
1. Read CLAUDE.md to understand the file structure and which `lua/plugins/*.lua` file is the right home for this plugin.
2. Read that target plugin file in full.
3. Add a proper lazy.nvim spec table for the plugin:
   - Use `opts = {}` when a simple `require("plugin").setup(opts)` suffices.
   - Use `config = function() ... end` when custom setup logic is needed.
   - Set an appropriate `event`, `ft`, `cmd`, or `keys` lazy-load trigger.
   - List all `dependencies`.
4. If the plugin adds keymaps, also add them to `lua/config/keymaps.lua` with a `desc`.
5. If the plugin is an LSP server, follow the "How to Add a New LSP Server" section in CLAUDE.md instead.
6. Show a summary of every change made and remind the user to run `:Lazy sync` in nvim.
