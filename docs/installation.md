# Installation

## Prerequisites

- Neovim ≥ 0.10 (for `vim.snippet` support)
- A completion plugin (blink.cmp, nvim-cmp, etc.) or snippet engine
  (LuaSnip, vim-vsnip) to surface the snippets

## lazy.nvim (recommended)

Minimal setup:

```lua
{
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  opts = { standard = "ada-2022" },
  config = function(_, opts)
    require("ada_snippets").setup(opts)
  end,
}
```

This configures lazy.nvim to load the plugin only when opening
`.ada` or `.ads` files, and passes the chosen Ada standard to
`setup()`.

If you use LuaSnip and want VSCode JSON loader integration:

```lua
{
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  opts = { standard = "spark" },
  config = function(_, opts)
    require("ada_snippets").setup(opts)
    require("luasnip.loaders.from_vscode").load({
      paths = vim.api.nvim_get_runtime_file("snippets", false),
    })
  end,
}
```

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

Open an Ada file and check:

1. A mode indicator appears at line 0 (e.g. `Ada 2022 (ISO/IEC 8652:2023)`)
2. `:lua print(vim.inspect(require("ada_snippets").get_standard()))`
   prints your configured standard
3. Your completion plugin offers snippet completions when you type
   `proc`, `putl`, `pkg`, etc.
