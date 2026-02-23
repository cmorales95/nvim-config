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
      -- Find the jupyter kernel whose argv points to a .venv near start_dir.
      -- If no registered kernel matches, auto-register the venv's ipykernel.
      local function venv_kernel_name(start_dir)
        local venv = vim.fn.finddir(".venv", start_dir .. ";")
        if venv == "" then return nil end
        local venv_path   = vim.fn.fnamemodify(venv, ":p")
        local venv_python = venv_path .. "bin/python"

        -- Check registered kernels for a match
        local raw  = vim.fn.system("jupyter kernelspec list --json 2>/dev/null")
        local ok, specs = pcall(vim.fn.json_decode, raw)
        if ok and specs and specs.kernelspecs then
          for name, spec in pairs(specs.kernelspecs) do
            local argv = spec.spec and spec.spec.argv
            if argv and argv[1] and argv[1]:find(venv_python, 1, true) then
              return name
            end
          end
        end

        -- No registered kernel — auto-register if ipykernel is installed in venv
        if vim.fn.executable(venv_python) == 0 then return nil end
        vim.fn.system(venv_python .. " -c 'import ipykernel' 2>/dev/null")
        if vim.v.shell_error ~= 0 then return nil end

        local project_name = vim.fn.fnamemodify(venv_path:gsub("/.venv/$", ""), ":t")
        local kernel_name  = project_name:gsub("[^%w_-]", "_")
        vim.fn.system(string.format(
          "%s -m ipykernel install --user --name %s --display-name 'Python (%s)'",
          venv_python, kernel_name, kernel_name
        ))
        if vim.v.shell_error == 0 then
          vim.notify("Registered Jupyter kernel: " .. kernel_name, vim.log.levels.INFO)
          return kernel_name
        end
        return nil
      end

      -- Auto-init kernel for any Python buffer with # %% cells (notebooks)
      -- Uses FileType instead of BufReadPost so it fires for both .py and .ipynb
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = "python",
        callback = function(ev)
          if vim.b[ev.buf].molten_auto_init then return end
          vim.b[ev.buf].molten_auto_init = true

          local has_cell = vim.fn.search("^# %%", "nw") > 0
          if not has_cell then return end

          local buf_dir = vim.fn.expand("%:p:h")
          local kernel  = venv_kernel_name(buf_dir)
          if kernel then
            vim.schedule(function()
              pcall(vim.cmd, "MoltenInit " .. kernel)
            end)
          end
        end,
      })

      -- After kernel init: set CWD to notebook dir + import outputs
      vim.api.nvim_create_autocmd("User", {
        pattern  = "MoltenInitPost",
        callback = function()
          -- Set kernel CWD to notebook directory (matches VSCode behavior)
          -- so relative paths like "../datasets/file.csv" resolve correctly
          local nb_dir = vim.fn.expand("%:p:h")
          if nb_dir ~= "" then
            local chdir_code = "import os; os.chdir(" .. vim.fn.json_encode(nb_dir) .. ")"
            pcall(vim.cmd, "MoltenEvaluateArgument " .. chdir_code)
          end

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

      -- Wrap the BufReadCmd autocmd that jupytext creates so that any failure
      -- (missing file, corrupt notebook, jupytext CLI error) is caught and
      -- turned into a harmless warning instead of crashing session restore.
      -- Capture the original callback, then replace the augroup.
      local orig_cb
      for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "jupytext-nvim", event = "BufReadCmd" })) do
        orig_cb = au.callback
        break
      end
      if orig_cb then
        vim.api.nvim_create_augroup("jupytext-nvim", { clear = true })
        vim.api.nvim_create_autocmd("BufReadCmd", {
          pattern = { "*.ipynb" },
          group   = "jupytext-nvim",
          callback = function(ev)
            local ok, err = pcall(orig_cb, ev)
            if not ok then
              vim.notify(
                "jupytext: failed to open " .. ev.match .. "\n" .. tostring(err),
                vim.log.levels.WARN
              )
              -- Set buffer to empty scratch so session restore can continue
              vim.bo[ev.buf].buftype = "nofile"
              vim.bo[ev.buf].filetype = "python"
            end
          end,
        })
      end
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
