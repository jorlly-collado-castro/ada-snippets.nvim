# ada-snippets.nvim — Agent Guide

## Project overview

Ada snippets Neovim plugin. Provides standard-aware Ada code
snippets with auto-with insertion and a visible mode indicator.

## Repository structure

```
ada-snippets.nvim/
├── lua/ada_snippets/        # Lua plugin source
│   ├── init.lua             # Public API: setup(), expand(), get_filtered_snippets()
│   ├── config.lua           # Standard schema, validation, ISO label mapping
│   ├── registry.lua         # JSON loading, standard filtering, with_units lookup
│   ├── indicator.lua        # Buffer-top virtual text extmark
│   └── autowith.lua         # With-clause scanning and insertion
├── ada/src/                 # Ada source (canonical snippet definitions)
│   ├── definitions.ads      # Snippet type, Standard_Mask, masks constants
│   ├── definitions.adb      # 48 Snippet_Record definitions (the source of truth)
│   └── gen_snippets.adb     # Generator: compiles Ada records → VSCode JSON
├── snippets/
│   └── ada.json             # Committed VSCode JSON snippet database
├── plugin/
│   └── ada_snippets.lua     # lazy.nvim auto-loader
├── docs/                    # Documentation
│   ├── overview.md
│   ├── installation.md
│   ├── configuration.md
│   ├── snippets-reference.md
│   ├── architecture.md
│   ├── development.md
│   ├── integration.md
│   └── auto-with.md
├── CONCEPT.md
├── AGENTS.md
└── README.md
```

## Key design decisions

1. **Ada source is canonical** — all snippet definitions live in
   `ada/src/definitions.adb` as Ada `Snippet_Record` values. The
   JSON database is generated from this. Always edit the Ada source,
   then regenerate JSON.
2. **JSON is committed** — users never need an Ada compiler. Running
   `gen_snippets` is only required when snippet definitions change.
3. **VSCode JSON format** — ensures compatibility with every major
   snippet engine (vim.snippet, LuaSnip, vim-vsnip, blink.cmp).
4. **Lua is glue** — the Neovim interface is pure Lua. The Ada code
   never runs at plugin runtime; it only generates data.

## Conventions

### Lua
- 2-space indentation
- snake_case names for functions and variables
- Module-level `local M = {}` pattern for exports
- No global side effects outside `setup()`
- Call `registry.set_json_loader(fn)` from init to break circular deps
- `autowith.ensure_withs()` is safe to call multiple times (idempotent)

### Ada
- GNAT formatting conventions
- Standard_Mask is a 7-element Boolean array: indices 1-7 map to
  standards (definitions.ads line comments document the mapping)
- Body strings use `\n` for line breaks and LSP snippet syntax
- With_Units is comma-separated when multiple units are needed
- When adding a snippet, increment the array index and append to
  the `return Snippet_Array'` aggregate

### JSON
- 2-space indentation
- Extra metadata keys (`standards`, `with_units`) are present but
  ignored by standard VSCode loaders
- Always regenerated, never edited by hand

## Common tasks

### Add a new snippet
1. Add a `Snippet_Record` to `ada/src/definitions.adb`
2. Regenerate: `cd ada && alr build && ./bin/gen_snippets > ../snippets/ada.json`
3. Add to the trigger table in `docs/snippets-reference.md`
4. Add to the table in `README.md`

### Change snippet body text
1. Edit the `Body` field in `ada/src/definitions.adb`
2. Regenerate JSON
3. Update docs if the trigger or description changed

### Add a new standard
1. Increase `Standard_Mask` array size in `definitions.ads`
2. Add name to `Standard_Names` in `gen_snippets.adb`
3. Add entry to `config.lua` `M.standards` table with label + ISO
4. Update all snippet masks if needed
5. Regenerate JSON
6. Update docs

### Add a new auto-with unit
1. Set `With_Units` on the snippet record in `definitions.adb`
2. Regenerate JSON
3. The Lua side handles it automatically

## Standards index (Standard_Mask)

```
1 = ada-2022
2 = ada-2012
3 = ada-2005
4 = spark (latest)
5 = spark-2014
6 = jorvik
7 = ravenscar
```

## Predefined masks in definitions.ads

| Constant             | Meaning                                |
|----------------------|----------------------------------------|
| All_Standards        | Available in every standard            |
| Ada_2022_Only        | Ada 2022 only                          |
| Spark_All            | SPARK (both latest and 2014)           |
| Ravenscar_Compat     | All except pure SPARK profiles         |
| Ravenscar_Only       | Ravenscar only                         |
| Jorvik_Only          | Jorvik only                            |
| No_Ravenscar         | All except Ravenscar                   |

## Verification

- `python3 -c "import json; json.load(open('snippets/ada.json'))"`
  validates the JSON is well-formed
- `lua -e "assert(loadfile('lua/ada_snippets/init.lua'))"` validates
  Lua syntax (repeat for each .lua file)
- Count changes: `python3 -c "import json; d=json.load(open('snippets/ada.json')); print(len(d))"`

## Snippet format (VSCode JSON + extensions)

```json
{
  "<description>": {
    "prefix": ["trigger"],
    "body": ["line1", "line2"],
    "description": "<description>",
    "standards": ["ada-2022", "spark"],
    "with_units": ["Ada.Text_IO"]
  }
}
```

The `standards` and `with_units` keys are extensions specific to
this plugin. They are ignored by standard VSCode JSON loaders.

## Git conventions

### Atomic commits
- Each commit must represent a single logical change
- Never mix unrelated changes (e.g. a bugfix + a docs change)
- If a task touches multiple concerns, split into separate commits
- Verify with `git diff --stat` before committing

### Conventional commits

Format: `type(scope): description`

| Type       | Usage                                      |
|------------|--------------------------------------------|
| `feat`     | New snippet, standard, or feature          |
| `fix`      | Bug fix in snippet body, logic, or docs    |
| `docs`     | README, AGENTS.md, or doc updates          |
| `refactor` | Code restructuring with no behavior change |
| `chore`    | Build, CI, config, or tooling changes      |
| `test`     | Adding or fixing tests/verification        |

Scopes (optional): `snippet`, `lua`, `ada`, `json`, `docs`

Examples:
```
feat(snippet): add generic formal package snippet
fix(ada): correct putl body indentation
docs: update installation section for packer
chore: regenerate ada.json after definition change
```
