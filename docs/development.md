# Development

## Project structure for developers

This repository contains both the canonical Ada source and the
generated JSON snippet database. The Ada code is the source of
truth; the JSON is the distributable artifact.

## Prerequisites for Ada development

- GNAT Ada compiler (GCC Ada) or Alire (`alr`)
- Neovim ≥ 0.10 for testing Lua integration
- (Optional) luacheck for Lua linting

## Regenerating the snippet database

```bash
# Using Alire (recommended)
cd ada
alr build
./bin/gen_snippets > ../snippets/ada.json

# Using gnatmake directly
cd ada/src
gnatmake gen_snippets.adb
./gen_snippets > ../../snippets/ada.json
```

## Adding a new snippet

### 1. Define the snippet in Ada

Edit `ada/src/definitions.adb` and add a new entry to the
`All_Snippets` array:

```ada
N =>
  (Prefix      => +"mytrigger",
   Body        => +"Ada.Text_IO.Put_Line (""${1:Hello}"");",
   Description => +"my snippet description",
   Standards   => All_Standards,
   With_Units  => +"Ada.Text_IO"),
```

The `Body` field uses `\n` for line breaks and LSP snippet syntax
for tab stops (`${1:default}`, `$0`, etc.). The `Standards` field
uses a `Standard_Mask` bitmask. Available masks:

| Mask                  | Meaning                                |
|-----------------------|----------------------------------------|
| `All_Standards`       | Available in every standard            |
| `Ada_2022_Only`       | Ada 2022 only                          |
| `Spark_All`           | SPARK (both latest and 2014)           |
| `Ravenscar_Compat`    | All except pure SPARK profiles         |
| `Ravenscar_Only`      | Ravenscar only                         |
| `Jorvik_Only`         | Jorvik only                            |
| `No_Ravenscar`        | All except Ravenscar                   |

You can also construct custom masks:

```ada
(1 | 2 => True, others => False)  -- Ada 2022 + Ada 2012 only
```

### 2. Regenerate the JSON

```bash
cd ada && alr build && ./bin/gen_snippets > ../snippets/ada.json
```

### 3. Verify

```bash
python3 -c "import json; json.load(open('snippets/ada.json'))"
```

### 4. Test in Neovim

```lua
require("ada_snippets").setup({ standard = "ada-2022" })
local snippets = require("ada_snippets").get_filtered_snippets()
print(vim.inspect(snippets["my snippet description"]))
```

## Modifying an existing snippet

1. Edit the `Snippet_Record` in `ada/src/definitions.adb`
2. Regenerate the JSON
3. Verify the output matches expectations

## Standard mask reference

```ada
-- Index positions in Standard_Mask:
-- 1 = ada-2022
-- 2 = ada-2012
-- 3 = ada-2005
-- 4 = spark (latest)
-- 5 = spark-2014
-- 6 = jorvik
-- 7 = ravenscar

All_Standards      : (others => True)
Ada_2022_Only      : (1 => True, others => False)
Spark_All          : (4 | 5 => True, others => False)
Ravenscar_Compat   : (1 | 2 | 3 | 6 | 7 => True, others => False)
Ravenscar_Only     : (7 => True, others => False)
Jorvik_Only        : (6 => True, others => False)
No_Ravenscar       : (1 | 2 | 3 | 4 | 5 | 6 => True, others => False)
```

## Running Lua tests

The plugin does not yet have a formal test suite. For manual testing:

```lua
-- Load and verify
local ok, err = pcall(require, "ada_snippets")
if not ok then
  print("Load error: " .. err)
end

-- Verify standard filtering
local ada = require("ada_snippets")
ada.setup({ standard = "ada-2022" })
local s = ada.get_filtered_snippets()
print("Snippet count (ada-2022): " .. vim.tbl_count(s))

ada.set_standard("ravenscar")
s = ada.get_filtered_snippets()
print("Snippet count (ravenscar): " .. vim.tbl_count(s))

-- Verify expand
ada.expand("procedure body")  -- should expand proc template
```

## Style guide

- **Ada**: follow GNAT formatting conventions (Alire defaults)
- **Lua**: 2-space indentation, snake_case names, no global side
  effects outside `setup()`
- **JSON**: 2-space indentation, trailing comma allowed during
  generation but removed in committed file

## Git Hooks

This project uses tracked Git hooks to enforce code quality. After cloning, configure Git to use them:

```bash
git config core.hooksPath .githooks
```
