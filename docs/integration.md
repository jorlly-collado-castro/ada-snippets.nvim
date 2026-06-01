# Integration

During `setup()`, snippets are automatically registered with the
first available engine in this priority order:

1. **LuaSnip** — via `luasnip.loaders.from_vscode`
2. **blink.cmp** — via direct registry injection (default preset)
3. **vim.snippet.snippets** (Neovim 0.11+)
4. **omnifunc** — `<C-x><C-o>` fallback for Ada buffers

No manual configuration is needed for basic completion.

## Available snippet source functions

```lua
-- Get all snippets filtered by the active standard
require("ada_snippets").get_filtered_snippets()

-- Get a specific snippet by its description key
local snippets = require("ada_snippets").get_filtered_snippets()
local snippet = snippets["procedure body"]
-- snippet.prefix  => ["proc"]
-- snippet.body    => {"procedure ${1:Name} is", ...}
-- snippet.description => "procedure body"
```

## blink.cmp

The plugin injects `snippets/ada.json` directly into blink.cmp's
snippet registry during `setup()`. No additional config is needed.

If LuaSnip is installed, `setup()` registers with LuaSnip first
and blink.cmp picks them up via its LuaSnip preset.

### Diagnostics

```lua
:lua require("ada_snippets").debug_completions()
```

Traces the full blink.cmp pipeline: JSON validity, config state,
provider initialization, registry file mapping, file I/O, and
completion cache status.

## nvim-cmp + LuaSnip

```lua
require("luasnip.loaders.from_vscode").load({
  paths = vim.api.nvim_get_runtime_file("snippets", false),
})

require("cmp").setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  sources = {
    { name = "luasnip" },
  },
})
```

## nvim-cmp + vim-vsnip

vim-vsnip automatically picks up VSCode JSON files on the
runtimepath, so `snippets/ada.json` is found automatically
without additional configuration.

## LuaSnip (standalone, without nvim-cmp)

```lua
require("luasnip.loaders.from_vscode").load({
  paths = vim.api.nvim_get_runtime_file("snippets", false),
})

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  end
end, { silent = true })
```

## Using the expand helper (auto-with support)

```lua
-- In your completion plugin's confirm/select handler:
require("ada_snippets").expand(selected_snippet_key)
```

This:
1. Looks up the snippet body for the active standard
2. Expands it via `vim.snippet.expand()`
3. Injects missing `with` clauses based on snippet metadata

## Accessing snippet metadata

```lua
local units = require("ada_snippets.registry").get_with_units("Put_Line statement")
-- => { "Ada.Text_IO" }
```

## Disabling the mode indicator

```lua
vim.api.nvim_del_augroup_by_name("ada_snippets_indicator")
```
