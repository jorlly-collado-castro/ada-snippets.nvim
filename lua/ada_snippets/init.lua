local config = require("ada_snippets.config")
local registry = require("ada_snippets.registry")
local indicator = require("ada_snippets.indicator")
local autowith = require("ada_snippets.autowith")

local M = {}

local active_standard = config.defaults.standard
local has_blink = false

--- Locate snippets/ada.json on the runtimepath.
---@return string
local function find_snippets_json()
  local files = vim.api.nvim_get_runtime_file("snippets/ada.json", false)
  if #files > 0 then
    return files[1]
  end
  error("ada_snippets: snippets/ada.json not found on runtimepath")
end

--- Return the directory containing our ada.json.
---@return string
local function our_snippets_dir()
  local files = vim.api.nvim_get_runtime_file("snippets/ada.json", false)
  if #files == 0 then return nil end
  return vim.fs.normalize(vim.fn.fnamemodify(files[1], ":h"))
end

--- Read and cache the raw JSON string.
local json_cache = nil
local function read_snippets_json()
  if json_cache then
    return json_cache
  end
  local path = find_snippets_json()
  local f = io.open(path, "r")
  if not f then
    error("ada_snippets: cannot open " .. path)
  end
  json_cache = f:read("*a")
  f:close()
  return json_cache
end

--- Omni-completion function for snippet triggers.
--- Use via `<C-x><C-o>` or by configuring your completion plugin to
--- source from the omnifunc.
local function omnifunc(findstart, base)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local start = col
    while start > 0 and line:sub(start, start):match("[%w_]") do
      start = start - 1
    end
    return start
  end

  local snippets = registry.filter(active_standard)
  local matches = {}
  for _, snip in pairs(snippets) do
    local prefix = snip.prefix
    if type(prefix) == "table" then
      prefix = prefix[1]
    end
    if prefix then
      if base == "" or prefix:lower():find(base:lower(), 1, true) == 1 then
        table.insert(matches, {
          word = prefix,
          abbr = snip.description,
          menu = "[ada]",
          info = snip.description,
          icase = 1,
          dup = 1,
        })
      end
    end
  end
  return matches
end

--- Set omnifunc for Ada buffers so `<C-x><C-o>` shows snippet completions.
local function set_omnifunc()
  local group = vim.api.nvim_create_augroup("ada_snippets_omnifunc", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "ada",
    callback = function(args)
      vim.bo[args.buf].omnifunc = "v:lua.require('ada_snippets')._omnifunc"
    end,
  })
end

--- Register snippets with LuaSnip.
local function register_luasnip()
  local ok, loader = pcall(require, "luasnip.loaders.from_vscode")
  if not ok then
    return false
  end
  local paths = vim.api.nvim_get_runtime_file("snippets", false)
  if #paths > 0 then
    loader.load({ paths = paths })
  end
  return true
end

--- Register snippets with blink.cmp.
local function register_blink()
  local ok = pcall(require, "blink.cmp")
  if not ok then return false end

  local our_dir = our_snippets_dir()
  if not our_dir then return false end

  local ok_lib, src_lib = pcall(require, "blink.cmp.sources.lib")
  if not ok_lib then return false end

  -- Inject into the registry of the snippets provider.
  -- If the provider hasn't been initialized yet, force-init it.
  local prov = src_lib.providers["snippets"]
      or src_lib.get_provider_by_id("snippets")
  if not prov or not prov.module then return false end

  local reg = prov.module.registry
  -- reg is the blink.cmp.sources.snippets.default.registry instance

  -- Add our path to the registry's config so rescans pick it up.
  if reg.config then
    reg.config.search_paths = reg.config.search_paths or {}
    local found = false
    for _, p in ipairs(reg.config.search_paths) do
      if vim.fs.normalize(p) == our_dir then found = true; break end
    end
    if not found then table.insert(reg.config.search_paths, 1, our_dir) end
  end

  -- Scan our dir and merge into the filetype -> file list mapping.
  local ok_scan, scan = pcall(require, "blink.cmp.sources.snippets.default.scan")
  if ok_scan then
    local our_files = scan.register_snippets({ our_dir })
    for ft, files in pairs(our_files) do
      reg.registry[ft] = reg.registry[ft] or {}
      vim.list_extend(reg.registry[ft], files)
    end
  end

  -- Clear the completion cache so the new snippets are served next time.
  if prov.module.reload then prov.module:reload() end

  has_blink = true
  return true
end

--- Register snippets with vim.snippet (Neovim 0.11+).
local function register_vim_snippet()
  if not vim.snippet.snippets then
    return false
  end
  local snippets = registry.filter(active_standard)
  vim.snippet.snippets = vim.snippet.snippets or {}
  vim.snippet.snippets.ada = vim.snippet.snippets.ada or {}
  for _, snip in pairs(snippets) do
    local prefix = snip.prefix
    if type(prefix) == "table" then
      prefix = prefix[1]
    end
    if prefix then
      vim.snippet.snippets.ada[prefix] = {
        prefix = snip.prefix,
        body = snip.body,
        description = snip.description,
      }
    end
  end
  return true
end

--- Auto-register snippets by trying engines in priority order.
local function auto_register()
  if register_luasnip() then return end
  if register_blink() then return end
  if register_vim_snippet() then return end
  set_omnifunc()
end

---@param opts? { standard: string }
function M.setup(opts)
  opts = opts or {}
  active_standard = config.validate(opts.standard or config.defaults.standard)

  registry.set_json_loader(read_snippets_json)
  indicator.setup(active_standard)
  auto_register()
end

--- Return filtered snippet table for the active standard.
---@return table<string, table>
function M.get_filtered_snippets()
  return registry.filter(active_standard)
end

--- Return the active standard string (e.g. "ada-2022").
---@return string
function M.get_standard()
  return active_standard
end

--- Manually re-read ada.json and refilter (e.g. after changing standard at runtime).
---@param standard string
function M.set_standard(standard)
  active_standard = config.validate(standard)
  registry.reset()
  indicator.set_indicator(active_standard)
end

--- Run blink.cmp injection interactively (for debugging).
function M.test_blink_inject()
  local our_dir = our_snippets_dir()
  if not our_dir then print("snippets/ada.json NOT FOUND on runtimepath"); return end
  print("our snippets dir:", our_dir)

  local ok = pcall(require, "blink.cmp")
  print("blink.cmp loaded:", ok)
  if not ok then return end

  local ok_lib, src_lib = pcall(require, "blink.cmp.sources.lib")
  print("sources.lib loaded:", ok_lib)
  if not ok_lib then return end

  local provider = src_lib.providers["snippets"]
  print("provider exists:", provider ~= nil)
  if not provider then
    provider = src_lib.get_provider_by_id("snippets")
    print("provider after force-init:", provider ~= nil)
  end

  if not provider then print("FAILED to get provider"); return end

  local mod = provider.module
  print("module:", mod ~= nil)
  if not mod then return end

  local reg = mod.registry
  print("registry:", reg ~= nil)
  if not reg then return end

  print("reg.config:", reg.config ~= nil)
  if reg.config then
    print("reg.search_paths:", reg.config.search_paths and table.concat(reg.config.search_paths, ", ") or "nil")
  end

  print("reg.registry.ada before:", reg.registry and reg.registry["ada"] or "nil")

  -- Try injecting
  if reg.config then
    reg.config.search_paths = reg.config.search_paths or {}
    local found = false
    for _, p in ipairs(reg.config.search_paths) do
      if vim.fs.normalize(p) == our_dir then found = true; break end
    end
    if not found then table.insert(reg.config.search_paths, 1, our_dir) end
    print("after injection, search_paths:", table.concat(reg.config.search_paths, ", "))
  end

  local ok_scan, scan = pcall(require, "blink.cmp.sources.snippets.default.scan")
  print("scan loaded:", ok_scan)
  if ok_scan then
    local our_files = scan.register_snippets({ our_dir })
    print("our_files keys:", table.concat(vim.tbl_keys(our_files), ", "))
    for ft, files in pairs(our_files) do
      reg.registry[ft] = reg.registry[ft] or {}
      vim.list_extend(reg.registry[ft], files)
      print(string.format("  %s: %s", ft, table.concat(files, ", ")))
    end
  end

  print("reg.registry.ada after:", reg.registry and vim.inspect(reg.registry["ada"]))
  if mod.reload then mod:reload(); print("cache cleared") end
end

--- Deep diagnostic: traces the full blink.cmp snippet pipeline.
function M.debug_completions()
  local lines = {}
  local function add(fmt, ...) table.insert(lines, string.format(fmt, ...)) end

  add("─ ada_snippets debug ──────────────────────")
  add("standard: %s", active_standard)

  -- 1. Our JSON
  local json_paths = vim.api.nvim_get_runtime_file("snippets/ada.json", false)
  if #json_paths == 0 then
    add("ada.json: NOT FOUND on runtimepath")
    add("Diagnosis: plugin install broken — add 'ada-snippets.nvim' to lazy.nvim")
    print(table.concat(lines, "\n"))
    return
  end
  add("ada.json: %s", json_paths[1])
  local f = io.open(json_paths[1], "r")
  if not f then
    add("  ERROR: cannot read file")
    print(table.concat(lines, "\n"))
    return
  end
  local raw = f:read("*a")
  f:close()
  local ok, parsed = pcall(vim.json.decode, raw)
  if not ok then
    add("  ERROR: invalid JSON — %s", tostring(parsed))
    print(table.concat(lines, "\n"))
    return
  end
  add("  snippet count: %d", #vim.tbl_keys(parsed))

  -- 2. blink.cmp
  local blink_ok = pcall(require, "blink.cmp")
  if not blink_ok then
    add("blink.cmp: not installed")
    add("Diagnosis: install blink.cmp or add LuaSnip")
    print(table.concat(lines, "\n"))
    return
  end
  add("blink.cmp: loaded")

  -- 3. Config
  local cfg_ok, cfg = pcall(require, "blink.cmp.config")
  if not cfg_ok then
    add("  WARN: blink.cmp.config unavailable")
  else
    local prov = cfg.sources and cfg.sources.providers
    if prov and prov.snippets then
      local opts = prov.snippets.opts
      if opts and opts.search_paths then
        add("  search_paths: %s", table.concat(opts.search_paths, ", "))
      else
        add("  search_paths: (not set)")
      end
    end
    local enabled_sources = cfg.sources and cfg.sources.default
    add("  default sources: %s", type(enabled_sources) == "table" and table.concat(enabled_sources, ", ") or tostring(enabled_sources))
  end

  -- 4. Snippets provider
  local lib_ok, blink_sources = pcall(require, "blink.cmp.sources.lib")
  if not lib_ok then
    add("  sources.lib: not available (old blink.cmp version?)")
    print(table.concat(lines, "\n"))
    return
  end
  local provider = blink_sources.providers["snippets"]
  if not provider then
    add("  snippets provider: NOT INITIALIZED")
    add("  Diagnosis: open an ada file and trigger completion once")
    print(table.concat(lines, "\n"))
    return
  end
  add("  snippets provider: initialized")

  -- 5. Registry internals
  local mod = provider.module
  if not mod or not mod.registry then
    add("  registry: NOT ACCESSIBLE")
    print(table.concat(lines, "\n"))
    return
  end
  local reg = mod.registry
  add("  registry.search_paths: %s", table.concat(reg.config and reg.config.search_paths or {}, ", "))
  add("  registry.filetypes: %s", table.concat(vim.tbl_keys(reg.registry or {}), ", "))

  local ada_files = reg.registry and reg.registry["ada"]
  if not ada_files then
    add("  ada in registry: NO FILES")
    add("  Diagnosis: scan didn't find ada.json — check that search_paths includes our snippets/ dir")
    print(table.concat(lines, "\n"))
    return
  end
  add("  ada files: %s", table.concat(ada_files, ", "))

  -- 6. Try loading them
  local utils_ok, utils = pcall(require, "blink.cmp.sources.snippets.utils")
  for _, fp in ipairs(ada_files) do
    local stat = vim.uv.fs_stat(fp)
    if not stat then
      add("  FILE MISSING: %s", fp)
    else
      local contents = utils_ok and utils.read_file(fp)
      if contents then
        local snips = utils.parse_json_with_error_msg(fp, contents)
        add("  loaded %d snips from %s", #vim.tbl_keys(snips or {}), vim.fn.fnamemodify(fp, ":t"))
      end
    end
  end

  -- 7. Cache
  if mod.cache then
    local ada_cache = mod.cache["ada"]
    if ada_cache then
      add("  cached completions (ada): %d items", #ada_cache)
      for _, item in ipairs(ada_cache) do
        add("    %s → %s", item.label, item.description or "(no desc)")
      end
    else
      add("  cached completions (ada): EMPTY (not yet populated)")
      add("  Diagnosis: open an ada file and type a few chars to trigger completion")
    end
  end

  -- 8. Omnifunc fallback
  if vim.bo.filetype == "ada" then
    add("  omnifunc: %s", vim.bo.omnifunc or "(not set)")
  end

  print(table.concat(lines, "\n"))
end

--- Print diagnostic info about the plugin state.
function M.status()
  local lines = {}
  table.insert(lines, "ada_snippets status:")
  table.insert(lines, "  standard: " .. active_standard)

  local path = vim.api.nvim_get_runtime_file("snippets/ada.json", false)
  if #path > 0 then
    table.insert(lines, "  ada.json: " .. path[1])
  else
    table.insert(lines, "  ada.json: NOT FOUND on runtimepath")
  end

  local ok_luasnip = pcall(require, "luasnip")
  if ok_luasnip then
    table.insert(lines, "  luasnip: loaded")
    local snips = require("luasnip").get_snippets("ada")
    if snips and next(snips) ~= nil then
      local count = 0
      for _ in pairs(snips) do
        count = count + 1
      end
      table.insert(lines, "  luasnip ada snippets: " .. count .. " (auto-registered)")
    else
      table.insert(lines, "  luasnip ada snippets: NONE")
    end
  else
    table.insert(lines, "  luasnip: not installed")
  end

  local ok_blink = pcall(require, "blink.cmp")
  if ok_blink then
    table.insert(lines, "  blink.cmp: loaded" .. (has_blink and " (our path configured)" or ""))
  else
    table.insert(lines, "  blink.cmp: not installed")
  end

  if vim.snippet.snippets then
    local count = 0
    if vim.snippet.snippets.ada then
      for _ in pairs(vim.snippet.snippets.ada) do
        count = count + 1
      end
    end
    table.insert(lines, "  vim.snippet ada snippets: " .. count)
  else
    table.insert(lines, "  vim.snippet: not available")
  end

  local ft = vim.bo.filetype
  if ft == "ada" then
    table.insert(lines, "")
    table.insert(lines, "  omnifunc: " .. (vim.bo.omnifunc or "(not set)"))
    table.insert(lines, "    <C-x><C-o> shows snippet completions")
  end

  if not ok_luasnip then
    table.insert(lines, "")
    table.insert(lines, "  Tip: Install LuaSnip for automatic snippet completions.")
    table.insert(lines, "    { 'L3MON4D3/LuaSnip', version = 'v2.*' }")
  end

  print(table.concat(lines, "\n"))
end

-- Expose omnifunc for v:lua.require('ada_snippets')._omnifunc
M._omnifunc = omnifunc

--- Expand a snippet by key and auto-insert missing with clauses.
---@param key string  The snippet description key (also used as snippet key)
function M.expand(key)
  local snippets = registry.filter(active_standard)
  local snippet = snippets[key]
  if not snippet then
    vim.notify("ada_snippets: snippet '" .. key .. "' not found for standard "
      .. active_standard, vim.log.levels.WARN)
    return
  end

  local body = snippet.body
  if type(body) == "table" then
    body = table.concat(body, "\n")
  end

  vim.snippet.expand(body)

  local units = registry.get_with_units(key)
  if #units > 0 then
    vim.schedule(function()
      autowith.ensure_withs(vim.api.nvim_get_current_buf(), units)
    end)
  end
end

return M
