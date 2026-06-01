-- ada_snippets: Ada snippets for Neovim.
--
-- Install via lazy.nvim:
--   {
--     "jorlly-collado-castro/ada-snippets.nvim",
--     ft = "ada",
--     opts = { standard = "ada-2022" },
--   }
--
-- Then point your completion plugin at the filtered snippets:
--   require("ada_snippets").get_filtered_snippets()

if vim.g.did_load_ada_snippets then
  return
end
vim.g.did_load_ada_snippets = true

local ok, err = pcall(function()
  require("ada_snippets").setup({ standard = "ada-2022" })
end)

if not ok then
  vim.notify("ada_snippets: " .. tostring(err), vim.log.levels.WARN)
end
