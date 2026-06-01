# ada-snippets.nvim

Ada snippets for Neovim. Provides standard-aware Ada code snippets
with auto-`with` insertion and a visible mode indicator.

## Features

- **Standard-aware filtering** — snippets adapt to your chosen Ada standard
  (`ada-2022`, `ada-2012`, `ada-2005`, `spark`, `spark-2014`, `jorvik`, `ravenscar`)
- **Auto-with** — when a snippet uses standard library units (e.g.
  `Ada.Text_IO`), the corresponding `with` clause is inserted automatically
- **Mode indicator** — shows active standard and ISO reference at the top of
  every Ada buffer
- **VSCode JSON format** — compatible with `vim.snippet`, LuaSnip, vim-vsnip,
  blink.cmp, nvim-cmp, and any engine that reads the LSP snippet format
- **Ada-generated** — snippet definitions are authored in Ada (see `ada/src/`),
  compiled to `snippets/ada.json`. The JSON is committed so no compiler is
  needed to use the plugin.

## Installation

### Prerequisites

- Neovim ≥ 0.10 (for `vim.snippet` support)
- A completion plugin (blink.cmp, nvim-cmp, etc.) or snippet engine
  (LuaSnip, vim-vsnip) to surface the snippets

### lazy.nvim (recommended)

Minimal setup:

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

### vim-plug

```vim
Plug 'jorlly-collado-castro/ada-snippets.nvim'
```

Then in your Lua config:

```lua
require("ada_snippets").setup({ standard = "ada-2012" })
```

### packer.nvim

```lua
use {
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  config = function()
    require("ada_snippets").setup({ standard = "ada-2022" })
  end,
}
```

### Verifying the installation

Open an Ada file and check:

1. A mode indicator appears at line 0 (e.g. `Ada 2022 (ISO/IEC 8652:2023)`)
2. `:lua print(vim.inspect(require("ada_snippets").get_standard()))`
   prints your configured standard
3. Your completion plugin offers snippet completions when you type
   `proc`, `putl`, `pkg`, etc.

## Configuration

| Option     | Type   | Default      | Description                                |
|------------|--------|--------------|--------------------------------------------|
| `standard` | string | `"ada-2022"` | Ada standard to filter snippets by.        |

Supported standards:

| Key            | Label          | ISO Reference              |
|----------------|----------------|----------------------------|
| `ada-2022`     | Ada 2022       | ISO/IEC 8652:2023          |
| `ada-2012`     | Ada 2012       | ISO/IEC 8652:2012          |
| `ada-2005`     | Ada 2005       | ISO/IEC 8652:2007          |
| `spark`        | SPARK          | ISO/IEC 8652:2023 + SPARK  |
| `spark-2014`   | SPARK 2014     | ISO/IEC 8652:2012 + SPARK  |
| `jorvik`       | Jorvik         | ISO/IEC 24718:2025         |
| `ravenscar`    | Ravenscar      | ISO/IEC TS 24718:2025      |

## Snippets

| Prefix           | Description                        | Standards              |
|------------------|------------------------------------|------------------------|
| `proc`           | procedure body                     | all                    |
| `procs`          | procedure specification            | all                    |
| `func`           | function body                      | all                    |
| `funcs`          | function specification             | all                    |
| `pkg`            | package specification              | all                    |
| `pkgb`           | package body                       | all                    |
| `task`           | task specification                 | all except SPARK-only  |
| `taskb`          | task body                          | all except SPARK-only  |
| `prot`           | protected object spec              | all                    |
| `protb`          | protected object body              | all                    |
| `with`           | with clause                        | all                    |
| `use`            | use clause                         | all                    |
| `if`             | if statement                       | all                    |
| `ife`            | if/else statement                  | all                    |
| `case`           | case statement                     | all                    |
| `loop`           | basic loop                         | all                    |
| `for`            | for loop                           | all                    |
| `while`          | while loop                         | all                    |
| `type`           | type declaration                   | all                    |
| `rec`            | record type                        | all                    |
| `arr`            | array type                         | all                    |
| `var`            | variable declaration               | all                    |
| `const`          | constant declaration               | all                    |
| `putl`           | Put_Line statement                 | all except Ravenscar   |
| `put`            | Put statement                      | all except Ravenscar   |
| `getl`           | Get_Line statement                 | all except Ravenscar   |
| `gen`            | generic package spec               | all                    |
| `pragma`         | pragma line                        | all                    |
| `subp`           | subprogram declaration             | all                    |
| `declare`        | declare block                      | all                    |
| `except`         | exception handler                  | all                    |
| `req`            | SPARK precondition aspect          | spark, spark-2014      |
| `ens`            | SPARK postcondition aspect         | spark, spark-2014      |
| `par`            | parallel for loop (Ada 2022)       | ada-2022               |
| `parb`           | parallel block (Ada 2022)          | ada-2022               |
| `subtype`        | subtype declaration                | all                    |
| `enum`           | enumeration type                   | all                    |
| `access`         | access type                        | all                    |
| `delta`          | fixed-point type                   | all                    |
| `digits`         | floating-point type                | all                    |
| `ren`            | renames declaration                | all                    |
| `separate`       | separate body stub                 | all                    |
| `elab`           | pragma Elaborate                   | all                    |
| `ravenscar`      | pragma Profile (Ravenscar)         | ravenscar              |
| `jorvik`         | pragma Profile (Jorvik)            | jorvik                 |
| `use_type`       | use type clause                    | all                    |
| `pragma_import`  | pragma Import                      | all                    |
| `pragma_assert`  | pragma Assert                      | all                    |

## Architecture

```
ada-snippets.nvim/
├── lua/
│   ├── ada-snippets.lua   # Module bridge (hyphen → underscore for lazy.nvim compat)
│   └── ada_snippets/
│       ├── init.lua       # Entry: setup(), get_filtered_snippets(), set_standard()
│       ├── config.lua     # Standard schema, validation, ISO mapping
│       ├── registry.lua   # Load & filter ada.json by standard
│       ├── indicator.lua  # Buffer-top extmark showing active mode
│       └── autowith.lua   # Auto-insert missing with clauses
├── ada/src/
│   ├── definitions.ads # Ada snippet records (canonical source of truth)
│   ├── definitions.adb # 48 Ada snippet definitions
│   └── gen_snippets.adb# Generator: compiles definitions → ada.json
├── snippets/
│   └── ada.json        # Generated VSCode JSON (committed)
├── plugin/
│   └── ada_snippets.lua# lazy.nvim loader
├── CONCEPT.md
└── README.md
```

The Ada generator (`ada/src/gen_snippets.adb`) is the canonical source for
all snippet definitions. Running it produces `snippets/ada.json`, which is
committed so users never need an Ada compiler.

### Regenerating ada.json

```bash
cd ada
alr build
./bin/gen_snippets > ../snippets/ada.json
```

## Integration with completion plugins

### blink.cmp
```lua
sources = {
  { name = "snippets", module = "blink.cmp.sources.snippets" },
}
```

### nvim-cmp + vim-vsnip / LuaSnip
```lua
-- LuaSnip loader for ada_snippets JSON
require("luasnip.loaders.from_vscode").load({
  paths = vim.api.nvim_get_runtime_file("snippets", false),
})
```
