# ada-snippets.nvim — Overview

Ada snippets for Neovim. Provides standard-aware Ada code snippets
with auto-with insertion and a visible mode indicator.

## Features

- **Standard-aware filtering** — snippets adapt to your chosen Ada
  standard. Select from Ada 2022, Ada 2012, Ada 2005, SPARK (latest),
  SPARK 2014, Jorvik, or Ravenscar. Each standard gets only the
  snippets that apply — no Ravenscar snippets in Ada 2022 mode, no
  Ada 2022 `parallel` constructs in Ada 2012 mode.

- **Auto-with insertion** — when a snippet references a standard
  library unit (e.g. `Ada.Text_IO.Put_Line`), the corresponding
  `with Ada.Text_IO;` clause is automatically inserted at the top
  of the buffer, sorted alphabetically among any existing with
  clauses.

- **Mode indicator** — a virtual text annotation at line 0 of every
  Ada buffer displays the active standard and its ISO/IEC reference
  (e.g. `Ada 2022 (ISO/IEC 8652:2023)` or
  `Ravenscar (ISO/IEC TS 24718:2025)`).

- **VSCode JSON format** — snippets are stored in the portable
  VSCode JSON format (LSP snippet syntax). Compatible with
  `vim.snippet`, LuaSnip, vim-vsnip, and any completion plugin that
  reads VSCode snippets (blink.cmp, nvim-cmp, etc.).

- **Ada-authored definitions** — snippet content is defined in Ada
  source code (`ada/src/definitions.adb`), then compiled into the
  JSON snippet database. The JSON is committed to the repository so
  users never need an Ada compiler to use the plugin.

## Quick start

Using lazy.nvim:

```lua
{
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  opts = { standard = "ada-2022" },
}
```

Once installed, filtered snippets are available via
`require("ada_snippets").get_filtered_snippets()`. Integrate with
your preferred completion plugin (see `integration.md`).
