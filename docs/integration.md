# Integration

This plugin outputs filtered snippet tables in VSCode JSON format.
How you consume them depends on your snippet engine and completion
plugin.

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

## vim.snippet (Neovim ≥ 0.10)

`vim.snippet` handles expansion but does not provide completion
sourcing. You need a completion plugin. The recommended path is to
call `expand()` with the snippet key:

```lua
require("ada_snippets").expand("procedure body")
```

For completion integration, pipe the snippet table to your
completion source (see blink.cmp and nvim-cmp below).

## blink.cmp

blink.cmp has built-in snippet support. Add the snippet source:

```lua
sources = {
  { name = "snippets", module = "blink.cmp.sources.snippets" },
}
```

Then configure blink to find the ada_snippets JSON:

```lua
-- In your blink.cmp setup:
require("blink.cmp").setup({
  sources = {
    default = { "snippets" },
  },
  snippets = {
    vscode_snippet_paths = {
      vim.fn.stdpath("data") .. "/site/lazy/ada-snippets.nvim/snippets",
    },
  },
})
```

Alternatively, use the Lua API:

```lua
local snippets = require("ada_snippets").get_filtered_snippets()
for key, snip in pairs(snippets) do
  -- register with blink's snippet source programmatically
end
```

## nvim-cmp + LuaSnip

```lua
-- Load the VSCode JSON via LuaSnip's loader
require("luasnip.loaders.from_vscode").load({
  paths = vim.api.nvim_get_runtime_file("snippets", false),
})

-- nvim-cmp then sources from LuaSnip as usual
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

```lua
require("cmp").setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "vsnip" },
  },
})
```

vim-vsnip automatically picks up VSCode JSON files on the
runtimepath, so the ada.json in the snippets directory should be
found automatically.

## LuaSnip (standalone, without nvim-cmp)

```lua
require("luasnip.loaders.from_vscode").load({
  paths = vim.api.nvim_get_runtime_file("snippets", false),
})

-- Map tab to jump between nodes
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  end
end, { silent = true })
```

## Using the expand helper (auto-with support)

Regardless of your completion/snippet engine, call
`ada_snippets.expand()` for auto-with support:

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
-- Check what units a snippet would auto-with
local units = require("ada_snippets.registry").get_with_units("Put_Line statement")
-- => { "Ada.Text_IO" }
```

## Disabling the mode indicator

The indicator can be disabled by overriding the setup:

```lua
require("ada_snippets").setup({ standard = "ada-2022" })
-- The indicator is always set up; to remove it:
vim.api.nvim_del_augroup_by_name("ada_snippets_indicator")
```
