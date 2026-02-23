-- ============================================================
-- DAP VS Code Extension Command Resolver
--
-- Resolves custom ${command:...} and ${input:...} variables in
-- .vscode/launch.json that come from project-local VS Code
-- extensions. nvim-dap only handles pickProcess/pickFile natively;
-- this module adds support for directory-based platform/type
-- pickers and the commandvariable extension's pickStringRemember
-- and remember commands.
--
-- Usage:
--   require("lib.dap-vscode-ext").setup()
--
-- Custom command registration:
--   require("lib.dap-vscode-ext").register("my-ext.cmd", function()
--     return "resolved-value"
--   end)
-- ============================================================

local M = {}

--- Custom command registry: command_name -> handler function
local commands = {}

--- Session state populated by pickers, read by getters (cleared per launch)
local session_state = {}

--- Remembered values for extension.commandvariable.remember (cleared per launch)
local remembered = {}

-- ── Public API ──────────────────────────────────────────────

---@param name string Command name (e.g. "my-extension.myCommand")
---@param handler fun(): string? Handler returning the resolved value
function M.register(name, handler)
  commands[name] = handler
end

-- ── Coroutine-friendly picker ───────────────────────────────

--- Wraps vim.ui.select for use inside nvim-dap's on_config coroutine.
---@param items any[]
---@param opts table Options for vim.ui.select
---@return any|nil Selected item or nil if cancelled
local function co_select(items, opts)
  local co = coroutine.running()
  assert(co, "co_select must be called within a coroutine")
  vim.ui.select(items, opts, function(choice)
    vim.schedule(function()
      coroutine.resume(co, choice)
    end)
  end)
  return coroutine.yield()
end

-- ── Platform file reader ────────────────────────────────────

--- Read JSON platform files from a directory.
--- Each file should have { content: [{type, env}] } structure.
---@param dir string Absolute path
---@return {platform: string, types: {type: string, env: string}[]}[]
local function read_platform_files(dir)
  local platforms = {}
  local handle = vim.uv.fs_scandir(dir)
  if not handle then return platforms end

  while true do
    local name, ftype = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if ftype == "file" and name:match("%.json$") then
      local f = io.open(dir .. "/" .. name, "r")
      if f then
        local ok, data = pcall(vim.json.decode, f:read("*a"))
        f:close()
        if ok and type(data) == "table"
            and type(data.content) == "table"
            and #data.content > 0 then
          table.insert(platforms, {
            platform = name:gsub("%.json$", ""),
            types = data.content,
          })
        end
      end
    end
  end

  table.sort(platforms, function(a, b) return a.platform < b.platform end)
  return platforms
end

-- ── Platform + Type picker ──────────────────────────────────

--- Two-stage picker: platform → type (auto-selects single types).
--- Mirrors the VS Code call-importer-launcher extension behavior.
---@param types_dir string Relative path (e.g. ".vscode/import-types")
---@param mode string "import" or "export"
---@return string|nil Platform name, or nil if cancelled
local function select_platform_and_type(types_dir, mode)
  local full_dir = vim.fn.getcwd() .. "/" .. types_dir
  local platforms = read_platform_files(full_dir)

  if #platforms == 0 then
    vim.notify("No " .. mode .. " configs found in " .. types_dir .. "/", vim.log.levels.ERROR)
    return nil
  end

  -- Stage 1: pick platform
  local selected_platform = co_select(platforms, {
    prompt = "Select " .. mode:sub(1, 1):upper() .. mode:sub(2) .. " Platform",
    format_item = function(p)
      if #p.types > 1 then
        return p.platform .. "  (" .. #p.types .. " types)"
      elseif p.types[1].type ~= "default" then
        return p.platform .. "  [" .. p.types[1].type .. "]"
      end
      return p.platform
    end,
  })
  if not selected_platform then return nil end

  -- Auto-select if only one type
  if #selected_platform.types == 1 then
    session_state.lastPlatform = selected_platform.platform
    session_state.lastType = selected_platform.types[1].type
    session_state.lastEnvFile = selected_platform.types[1].env
    return selected_platform.platform
  end

  -- Stage 2: pick type
  local selected_type = co_select(selected_platform.types, {
    prompt = selected_platform.platform .. " \u{2014} Select Type",
    format_item = function(t) return t.type end,
  })
  if not selected_type then return nil end

  session_state.lastPlatform = selected_platform.platform
  session_state.lastType = selected_type.type
  session_state.lastEnvFile = selected_type.env
  return selected_platform.platform
end

-- ── Extension auto-detection ────────────────────────────────

--- Detect a project-local VS Code extension and register its commands.
--- Looks for .vscode/<ext>/package.json, then maps commands to handlers
--- based on naming patterns (select* → picker, get*Type → cached type, etc.)
---@param ext_name string Extension name (e.g. "call-importer-launcher")
---@return boolean
local function auto_detect_extension(ext_name)
  local cwd = vim.fn.getcwd()
  local pkg_path = cwd .. "/.vscode/" .. ext_name .. "/package.json"
  local f = io.open(pkg_path, "r")
  if not f then return false end
  local ok, pkg = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if not ok or type(pkg) ~= "table" then return false end

  local cmds = pkg.contributes and pkg.contributes.commands
  if not cmds then return false end

  local prefix = vim.pesc(ext_name) .. "%."
  for _, cmd in ipairs(cmds) do
    local full = cmd.command
    local short = full:match("^" .. prefix .. "(.+)$")
    if short then
      if short:match("^select") or short:match("^pick") then
        -- Interactive picker: selectImport → "import", selectExport → "export"
        local mode = (short:match("^select(%u%l+)") or short:match("^pick(%u%l+)") or ""):lower()
        if mode ~= "" then
          local dir = ".vscode/" .. mode .. "-types"
          if vim.uv.fs_stat(cwd .. "/" .. dir) then
            commands[full] = function()
              return select_platform_and_type(dir, mode)
            end
          end
        end
      elseif short:match("[Tt]ype$") or short == "getType" then
        commands[full] = function() return session_state.lastType or "" end
      elseif short:match("[Ee]nv") then
        commands[full] = function() return session_state.lastEnvFile or "" end
      end
    end
  end
  return true
end

-- ── launch.json input resolver ──────────────────────────────

--- Read the inputs section from .vscode/launch.json
---@return table[]
local function get_launch_inputs()
  local path = vim.fn.getcwd() .. "/.vscode/launch.json"
  local f = io.open(path, "r")
  if not f then return {} end
  local raw = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, raw, { skip_comments = true })
  if not ok or type(data) ~= "table" then return {} end
  return data.inputs or {}
end

--- Resolve a single command-type input definition.
--- Supports pickStringRemember (interactive picker) and remember (cached lookup).
---@param input_def table Input definition from launch.json
---@return string|nil
local function resolve_command_input(input_def)
  local cmd = input_def.command or ""
  local args = input_def.args or {}

  if cmd:match("pickStringRemember$") then
    local options = args.options or {}
    local key = args.key
    local items = {}
    local data_map = {}

    for _, opt in ipairs(options) do
      if type(opt) == "table" and type(opt[1]) == "string" then
        -- Format: ["label", {key: "value", ...}]
        table.insert(items, opt[1])
        data_map[opt[1]] = opt[2]
      elseif type(opt) == "string" then
        -- Plain string option
        table.insert(items, opt)
      end
    end

    local selected = co_select(items, {
      prompt = args.description or input_def.description or "Select",
    })
    if not selected then return args.default or "" end

    local data = data_map[selected]
    if type(data) == "table" then
      for k, v in pairs(data) do
        remembered[k] = v
      end
      return data[key] or selected
    end
    remembered[key] = selected
    return selected

  elseif cmd:match("%.remember$") then
    return remembered[args.key] or ""
  end

  return nil
end

-- ── Pattern collection and substitution ─────────────────────

--- Recursively collect all ${command:...} and ${input:...} patterns in a config.
---@param value any
---@param result {commands: table<string,true>, inputs: table<string,true>}
local function collect_patterns(value, result)
  if type(value) == "string" then
    for cmd in value:gmatch("%${command:([^}]+)}") do
      result.commands[cmd] = true
    end
    for id in value:gmatch("%${input:([%w_]+)}") do
      result.inputs[id] = true
    end
  elseif type(value) == "table" then
    for _, v in pairs(value) do
      collect_patterns(v, result)
    end
  end
end

--- Recursively substitute resolved patterns in a value tree.
---@param value any
---@param map table<string, string> pattern → replacement
---@return any
local function substitute(value, map)
  if type(value) == "string" then
    for pattern, replacement in pairs(map) do
      -- Use function replacement to avoid %-escaping issues in gsub
      value = value:gsub(vim.pesc(pattern), function() return replacement end)
    end
    return value
  elseif type(value) == "table" then
    local result = {}
    for k, v in pairs(value) do
      result[k] = substitute(v, map)
    end
    return result
  end
  return value
end

-- ── on_config handler ───────────────────────────────────────

--- nvim-dap on_config listener. Runs inside a coroutine (supports async pickers).
--- Scans the config for unresolved ${command:...} and ${input:...} patterns,
--- resolves them via registered handlers or auto-detected extension commands.
---@param config table dap.Configuration
---@return table Modified config
local function on_config_handler(config)
  config = vim.deepcopy(config)

  local patterns = { commands = {}, inputs = {} }
  collect_patterns(config, patterns)

  local has_custom_patterns = next(patterns.commands) or next(patterns.inputs)

  local resolved = {}

  if has_custom_patterns then
  -- Fresh state for this debug launch
  session_state = {}
  remembered = {}

  -- Auto-detect extensions for unknown commands
  local detected = {}
  for cmd_name in pairs(patterns.commands) do
    if not commands[cmd_name] then
      local ext = cmd_name:match("^(.+)%.[^.]+$")
      if ext and not detected[ext] then
        auto_detect_extension(ext)
        detected[ext] = true
      end
    end
  end

  -- Resolve ${command:...}: pickers first, then getters
  local picker_cmds, getter_cmds = {}, {}
  for cmd_name in pairs(patterns.commands) do
    local short = cmd_name:match("%.([^.]+)$") or ""
    if short:match("^select") or short:match("^pick") then
      table.insert(picker_cmds, cmd_name)
    else
      table.insert(getter_cmds, cmd_name)
    end
  end

  for _, name in ipairs(picker_cmds) do
    if commands[name] then
      local val = commands[name]()
      if val then resolved["${command:" .. name .. "}"] = val end
    end
  end

  for _, name in ipairs(getter_cmds) do
    if commands[name] then
      local val = commands[name]()
      if val then resolved["${command:" .. name .. "}"] = val end
    end
  end

  -- Resolve ${input:...} with type:"command" (unsupported by nvim-dap natively)
  if next(patterns.inputs) then
    local inputs = get_launch_inputs()
    local input_map = {}
    for _, inp in ipairs(inputs) do
      if inp.id then input_map[inp.id] = inp end
    end

    -- Interactive inputs first (pickStringRemember, etc.)
    for id in pairs(patterns.inputs) do
      local def = input_map[id]
      if def and def.type == "command"
          and not (def.command or ""):match("%.remember$") then
        local val = resolve_command_input(def)
        if val then resolved["${input:" .. id .. "}"] = val end
      end
    end

    -- Then cached lookups (remember)
    for id in pairs(patterns.inputs) do
      local def = input_map[id]
      if def and def.type == "command"
          and (def.command or ""):match("%.remember$") then
        local val = resolve_command_input(def)
        if val then resolved["${input:" .. id .. "}"] = val end
      end
    end
  end

  end -- has_custom_patterns

  if next(resolved) then
    config = substitute(config, resolved)
  end

  -- Resolve envFile: Delve/DAP doesn't support envFile natively — the VS Code
  -- Go extension reads the file and injects vars. We do the same here.
  if config.envFile then
    local env_path = config.envFile
    local f = io.open(env_path, "r")
    if f then
      local env = config.env or {}
      for line in f:lines() do
        local key, value = line:match("^([%w_]+)%s*=%s*(.*)$")
        if key then
          -- Strip surrounding quotes if present
          value = value:gsub("^[\"'](.-)[\"']$", "%1")
          env[key] = value
        end
      end
      f:close()
      config.env = env
      config.envFile = nil
    end
  end

  -- Go adapter: translate VS Code's "auto" mode to Delve-compatible mode
  if config.type == "go" and config.mode == "auto" then
    local program = config.program or ""
    if program:match("_test%.go$") then
      config.mode = "test"
    else
      config.mode = "debug"
    end
  end

  return config
end

-- ── Setup ───────────────────────────────────────────────────

--- Initialize the extension resolver. Registers an on_config listener
--- with nvim-dap that intercepts and resolves custom variables.
function M.setup()
  local dap = require("dap")
  dap.listeners.on_config["dap-vscode-ext"] = on_config_handler

  -- Wrap _load_json to strip type:"command" inputs before nvim-dap sees them.
  -- nvim-dap only supports promptString/pickString and warns on type:"command".
  -- We handle these ourselves in the on_config handler, so remove them here
  -- to suppress the "Unsupported input type" warning.
  local vscode = require("dap.ext.vscode")
  local orig_load_json = vscode._load_json
  vscode._load_json = function(jsonstr)
    local ok, data = pcall(vim.json.decode, jsonstr, { skip_comments = true })
    if ok and type(data) == "table" and data.inputs then
      data.inputs = vim.tbl_filter(function(input)
        return input.type ~= "command"
      end, data.inputs)
      jsonstr = vim.json.encode(data)
    end
    return orig_load_json(jsonstr)
  end
end

return M
