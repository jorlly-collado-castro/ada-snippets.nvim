local M = {}

local snippets = nil
local json_loader = nil

--- Allow init.lua to inject the JSON loading function (breaks circular dep).
function M.set_json_loader(fn)
  json_loader = fn
end

local function load_json()
  if snippets then
    return snippets
  end

  local raw = json_loader and json_loader()
  if not raw then
    vim.notify("ada_snippets: no JSON loader set", vim.log.levels.ERROR)
    return {}
  end

  local ok, json = pcall(vim.json.decode, raw)
  if not ok then
    vim.notify("ada_snippets: failed to parse snippets/ada.json", vim.log.levels.ERROR)
    return {}
  end
  snippets = json
  return snippets
end

--- Filter snippets matching the active standard.
---@param standard string
---@return table
function M.filter(standard)
  local all = load_json()
  local result = {}
  for key, snippet in pairs(all) do
    local match = false
    for _, s in ipairs(snippet.standards or {}) do
      if s == standard then
        match = true
        break
      end
    end
    if match then
      result[key] = snippet
    end
  end
  return result
end

--- Get the with_units for a given snippet key.
---@param snippet_key string
---@return string[]
function M.get_with_units(snippet_key)
  local all = load_json()
  local snippet = all[snippet_key]
  if snippet and snippet.with_units then
    return snippet.with_units
  end
  return {}
end

--- Reset cache (useful for testing or reload).
function M.reset()
  snippets = nil
end

return M
