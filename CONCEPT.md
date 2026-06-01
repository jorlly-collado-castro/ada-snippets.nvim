# ada-snippets.nvim

Ada snippets for Neovim. Provides standard-aware snippets with
auto-with insertion and a visible mode indicator.

## Configuration

Plugin configuration supports setting the Ada standard, e.g.:

- `ada-2022` (default)
- `ada-2012` (legacy)
- `ada-2005`
- `spark` (latest)
- `spark-2014`
- `jorvik` (latest)
- `ravenscar` (latest)

The active standard and its ISO reference are displayed at the top of
every Ada buffer via a virtual text extmark.

## Auto-with

If a snippet uses a standard library unit (e.g. `Ada.Text_IO`), the
corresponding `with` clause is inserted automatically on expansion.
Only applies to explicitly expanded snippets.

## Architecture

- **Ada source** (`ada/src/`) is the canonical source of truth for all
  snippet definitions. `gen_snippets.adb` compiles snippet records to
  a VSCode JSON file (`snippets/ada.json`).
- **Lua plugin** (`lua/ada_snippets/`) handles Neovim integration:
  filtering by standard, mode indicator, auto-with insertion.
- **VSCode JSON format** is used for broad compatibility with all major
  snippet engines (vim.snippet, LuaSnip, vim-vsnip, blink.cmp, etc.).
- **Committed JSON** means users never need an Ada compiler to use the
  plugin. The Ada source is present for review and regeneration.

## Use-cases / templates (respects mode)

All snippets support tab-stop placeholders (`${1:default}`) for
filling in values and jumping between fields.

Snippet categories:
- procedure, function (body + spec)
- package (spec + body)
- task, protected object (spec + body)
- variable, constant, type, record, array, enumeration, access
- if, if/else, case, basic loop, for, while
- with, use, use type, renames
- declare block, exception handler, separate stub
- generic package, subprogram declaration
- Put_Line, Put, Get_Line (with auto-with)
- SPARK precondition/postcondition
- Parallel constructs (Ada 2022 only)
- Ravenscar/Jorvik profile pragmas
- Common pragmas (Import, Assert, Elaborate)
