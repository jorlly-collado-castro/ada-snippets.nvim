# Installation

## Prerequisites

- Neovim ≥ 0.10 (for `vim.snippet` support)
- A completion plugin (blink.cmp, nvim-cmp, etc.) or snippet engine
  (LuaSnip, vim-vsnip) to surface the snippets

## lazy.nvim (recommended)

```lua
{
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  opts = {
    standard = "ada-2022",
  },
}
```

This configures lazy.nvim to load the plugin only when opening
`.ada` or `.ads` files, and passes the chosen Ada standard to
`setup()`. Snippet registration happens automatically — no
additional config is needed.

## vim-plug

```vim
Plug 'jorlly-collado-castro/ada-snippets.nvim'
```

Then in your Lua config:

```lua
require("ada_snippets").setup({ standard = "ada-2012" })
```

## packer.nvim

```lua
use {
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  config = function()
    require("ada_snippets").setup({ standard = "ada-2022" })
  end,
}
```

## Verifying the installation

Open an Ada file and run:

```
:lua require("ada_snippets").status()
```

Check:

1. `ada.json` is found on the runtimepath
2. **luasnip**, **blink.cmp**, or **vim.snippet** shows snippets registered
3. Tip at the bottom suggests LuaSnip if not installed (optional)
4. Your completion plugin offers snippet completions when you type
   `proc`, `putl`, `pkg`, etc.

For deeper blink.cmp diagnostics:

```
:lua require("ada_snippets").debug_completions()
```
