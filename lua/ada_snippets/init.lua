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

--- Register snippets with blink.cmp by adding our path to its config.
local function register_blink()
  local ok = pcall(require, "blink.cmp")
  if not ok then
    return false
  end

  local paths = vim.api.nvim_get_runtime_file("snippets", false)
  if #paths == 0 then
    return false
  end
  local our_snippets_dir = vim.fs.normalize(paths[1])

  local cfg = require("blink.cmp.config")

  -- Add our path to the snippets provider opts so future
  -- provider init picks it up automatically.
  if cfg.sources and cfg.sources.providers and cfg.sources.providers.snippets then
    local snippet_provider_cfg = cfg.sources.providers.snippets
    snippet_provider_cfg.opts = snippet_provider_cfg.opts or {}
    snippet_provider_cfg.opts.search_paths = snippet_provider_cfg.opts.search_paths or {}
    local already = false
    for _, p in ipairs(snippet_provider_cfg.opts.search_paths) do
      if vim.fs.normalize(p) == our_snippets_dir then
        already = true
        break
      end
    end
    if not already then
      table.insert(snippet_provider_cfg.opts.search_paths, our_snippets_dir)
    end
  end

  -- If the snippets provider is already initialized, we need to inject
  -- our files into its internal registry and clear the completion cache.
  local ok_lib, blink_sources = pcall(require, "blink.cmp.sources.lib")
  if ok_lib then
    local snippets_provider = blink_sources.providers["snippets"]
    if snippets_provider and snippets_provider.module and snippets_provider.module.registry then
      local reg = snippets_provider.module.registry
      local ok_scan, scan = pcall(require, "blink.cmp.sources.snippets.default.scan")
      if ok_scan then
        local our_files = scan.register_snippets({ our_snippets_dir })
        for ft, files in pairs(our_files) do
          reg.registry[ft] = reg.registry[ft] or {}
          vim.list_extend(reg.registry[ft], files)
        end
      end
      if snippets_provider.module.reload then
        snippets_provider.module:reload()
      end
    end
  end

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
