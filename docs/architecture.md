# Architecture

## File roles

```
ada-snippets.nvim/
├── lua/ada_snippets/
│   ├── init.lua           # Public API: setup(), expand(), get_filtered_snippets()
│   ├── config.lua         # Standard schema, validation, ISO label mapping
│   ├── registry.lua       # JSON loading, standard-based filtering, with_units lookup
│   ├── indicator.lua      # Buffer-top virtual text extmark management
│   └── autowith.lua       # With-clause scanning and insertion
├── ada/src/
│   ├── definitions.ads    # Canonical snippet type + standard mask constants
│   ├── definitions.adb    # 48 Ada snippet record definitions
│   └── gen_snippets.adb   # Generator: compiles Ada records → JSON
├── snippets/
│   └── ada.json           # VSCode JSON snippet database (committed)
├── plugin/
│   └── ada_snippets.lua   # Auto-setup on plugin load
└── docs/
    ├── overview.md
    ├── installation.md
    ├── configuration.md
    ├── snippets-reference.md
    ├── architecture.md
    ├── development.md
    ├── integration.md
    └── auto-with.md
```

## Data flow

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Ada source      │     │  snippets/       │     │  Lua plugin      │
│  definitions.adb │────>│  ada.json        │────>│  registry.lua    │
│  (canonical)     │     │  (committed)     │     │  (load + filter) │
└─────────────────┘     └──────────────────┘     └──────────────────┘
                                                         │
                                                         ▼
                                                  ┌──────────────────┐
                                                  │  Completion      │
                                                  │  plugin          │
                                                  │  (blink/nvim-cmp)│
                                                  └──────────────────┘
                                                         │
                                                   (user expands)
                                                         │
                                                         ▼
                                                  ┌──────────────────┐
                                                  │  autowith.lua    │
                                                  │  insert missing  │
                                                  │  with clauses    │
                                                  └──────────────────┘
```

## Module dependency graph

```
init.lua
  ├── config.lua      (no deps)
  ├── registry.lua    (no deps — JSON loader injected by init)
  ├── indicator.lua   (depends on config.lua)
  └── autowith.lua    (no deps)
```

No circular dependencies. `registry.lua` uses a setter
(`set_json_loader()`) to receive its JSON loading function from
`init.lua`, avoiding a direct require cycle.

## The "mostly Ada" principle

The Ada source in `ada/src/` is the canonical definition of every
snippet. Each `Snippet_Record` contains the prefix, body lines,
description, standard mask, and associated with-units. Running the
generator produces the JSON database.

The JSON is committed to the repository so that:
1. Users never need to install an Ada compiler
2. The exported JavaScript Object Notation file is the distributable artifact
3. Build-time generation is optional — only needed when snippet
   definitions change

To regenerate:
```bash
cd ada && alr build && ./bin/gen_snippets > ../snippets/ada.json
```

## Standard filtering logic

Each snippet in `ada.json` carries a `standards` array listing which
standards it applies to. On `setup()`, the Lua registry loads the
full JSON, filters to entries whose `standards` includes the user's
chosen standard, and caches the result. Subsequent calls to
`get_filtered_snippets()` return the cached filter.

This means:
- No overhead on each expansion
- Runtime `set_standard()` resets the cache and re-filters

## Auto-with flow

```
1. User expands a snippet (e.g. "putl")
2. expand() calls vim.snippet.expand() with the snippet body
3. expand() then looks up snippet metadata for with_units
4. autowith.ensure_withs() scans buffer lines 1-30 for existing
   "with Ada.Text_IO;" clauses
5. For each missing unit, inserts the clause sorted alphabetically
   among any existing with clauses
6. If no existing with block, inserts at line 1
```
