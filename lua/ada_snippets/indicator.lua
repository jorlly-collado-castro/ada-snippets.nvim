local config = require("ada_snippets.config")

local M = {}

--- Set the winbar indicator for an Ada buffer.
---@param standard string
function M.set_indicator(standard)
  if vim.bo.filetype ~= "ada" then
    return
  end

  local info = config.get_info(standard)
  vim.wo.winbar = string.format(" %s (%s) ", info.label, info.iso)
end

--- Clear the winbar indicator.
function M.clear_indicator()
  vim.wo.winbar = ""
end

--- Set up autocommands to manage the indicator across all Ada buffers.
---@param standard string
function M.setup(standard)
  local group = vim.api.nvim_create_augroup("ada_snippets_indicator", { clear = true })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "ada",
    callback = function()
      M.set_indicator(standard)
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    callback = function()
      if vim.bo.filetype == "ada" then
        M.clear_indicator()
      end
    end,
  })
end

return M
