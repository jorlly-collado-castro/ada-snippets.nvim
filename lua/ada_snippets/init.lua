local config = require("ada_snippets.config")
local registry = require("ada_snippets.registry")
local indicator = require("ada_snippets.indicator")
local autowith = require("ada_snippets.autowith")

local M = {}

local active_standard = config.defaults.standard

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

---@param opts? { standard: string }
function M.setup(opts)
  opts = opts or {}
  active_standard = config.validate(opts.standard or config.defaults.standard)

  registry.set_json_loader(read_snippets_json)
  indicator.setup(active_standard)
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
  indicator.set_indicator(vim.api.nvim_get_current_buf(), active_standard)
end

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
