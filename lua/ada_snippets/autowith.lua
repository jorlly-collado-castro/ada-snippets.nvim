--- Automatically insert missing `with` clauses after snippet expansion.
local M = {}

--- Check if a unit is already withed in the buffer.
---@param bufnr number
---@param unit string
---@return boolean
local function has_with(bufnr, unit)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 30, false)
  local pattern = "^with%s+" .. vim.pesc(unit) .. "%s*;"
  for _, line in ipairs(lines) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

--- Find the best line to insert a new `with` clause.
--- Returns the line index (0-based) to insert before.
---@param bufnr number
---@return number
local function find_insert_line(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 60, false)
  local last_with = -1

  for i, line in ipairs(lines) do
    if line:match("^%s*with%s+") then
      last_with = i - 1  -- 0-based
    elseif last_with >= 0 and not line:match("^%s*$") then
      -- Past the with block
      return last_with + 1
    end
  end

  if last_with >= 0 then
    return last_with + 1
  end

  -- No existing with clause, find first non-empty line
  for i, line in ipairs(lines) do
    if not line:match("^%s*$") then
      return i - 1
    end
  end

  return 0
end

--- Insert a `with` clause for each missing unit.
---@param bufnr number
---@param units string[]
function M.ensure_withs(bufnr, units)
  if not units or #units == 0 then
    return
  end

  local to_insert = {}
  for _, unit in ipairs(units) do
    if not has_with(bufnr, unit) then
      table.insert(to_insert, unit)
    end
  end

  if #to_insert == 0 then
    return
  end

  table.sort(to_insert)

  local insert_line = find_insert_line(bufnr)

  -- Check if we need a blank line after the with block
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 60, false)
  local next_line = insert_line
  if next_line < #lines then
    local content_after = lines[next_line + 1]
    if content_after and content_after:match("^%s*$") then
      -- Already has blank line, insert before it
    else
      local after_blank = false
      for i = insert_line, math.min(insert_line + 3, #lines - 1) do
        if lines[i + 1]:match("^%s*$") then
          after_blank = true
          break
        end
      end
      if not after_blank then
        table.insert(to_insert, "") -- blank separator
      end
    end
  end

  -- Build lines to insert
  local insert_lines = {}
  for _, unit in ipairs(to_insert) do
    if unit == "" then
      table.insert(insert_lines, "")
    else
      table.insert(insert_lines, "with " .. unit .. ";")
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, insert_lines)
end

return M
