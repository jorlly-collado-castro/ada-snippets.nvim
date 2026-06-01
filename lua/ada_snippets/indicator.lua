local config = require("ada_snippets.config")

local M = {}

local ns_id = vim.api.nvim_create_namespace("ada_snippets_indicator")

local function buf_is_ada(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return ft == "ada"
end

--- Set the mode indicator extmark at the top of an Ada buffer.
---@param bufnr number
---@param standard string
function M.set_indicator(bufnr, standard)
  if not buf_is_ada(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local info = config.get_info(standard)
  local text = string.format(" %s (%s) ", info.label, info.iso)

  vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
    virt_text = { { text, "Comment" } },
    virt_text_pos = "overlay",
    hl_mode = "combine",
    priority = 200,
  })
end

--- Clear the indicator for a buffer.
---@param bufnr number
function M.clear_indicator(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

--- Set up autocommands to manage the indicator across all Ada buffers.
---@param standard string
function M.setup(standard)
  local group = vim.api.nvim_create_augroup("ada_snippets_indicator", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    group = group,
    pattern = "ada",
    callback = function(args)
      M.set_indicator(args.buf, standard)
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    pattern = "ada",
    callback = function(args)
      M.clear_indicator(args.buf)
    end,
  })
end

return M
