# Auto-with insertion

When a snippet references a standard library unit, the corresponding
`with` clause is automatically inserted.

## How it works

Each snippet in `snippets/ada.json` carries a `with_units` array:

```json
{
  "Put_Line statement": {
    "prefix": ["putl"],
    "body": ["Ada.Text_IO.Put_Line (${1:Item});"],
    "with_units": ["Ada.Text_IO"]
  }
}
```

When `expand()` is called for this snippet:

1. The snippet body is expanded via `vim.snippet.expand()`
2. The plugin looks up `with_units` for the snippet key
3. `autowith.ensure_withs()` scans buffer lines 1–60 for existing
   `with Ada.Text_IO;` declarations
4. For each missing unit, a new `with` clause is inserted

## Insertion rules

`autowith.ensure_withs()` follows these rules:

1. **Scan window**: checks lines 1–60 for `^with\s+<unit>\s*;`
   patterns
2. **Existing with block**: if one or more `with` clauses already
   exist, the new clause is inserted after the last existing `with`,
   in alphabetical order
3. **No with block**: if no `with` clauses exist, the new clause
   is inserted at the first non-empty line of the buffer
4. **Blank line spacing**: if the existing with block has no blank
   line after it, a blank separator line is added
5. **Alphabetical sort**: when multiple units are missing, they are
   sorted alphabetically before insertion

## Example

Before expansion (buffer contents):
```
procedure Hello is
begin
  null
end Hello;
```

User types `putl` and expands the snippet. After expansion:
```
with Ada.Text_IO;

procedure Hello is
begin
  Ada.Text_IO.Put_Line ("Hello world");
end Hello;
```

## Snippets with auto-with

| Prefix | Units inserted       |
|--------|----------------------|
| `putl` | `Ada.Text_IO`        |
| `put`  | `Ada.Text_IO`        |
| `getl` | `Ada.Text_IO`        |

## Limitations

- Only fires on explicit `expand()` calls, not on arbitrary
  completion engine expansions (unless the engine invokes
  `vim.snippet.expand` and the plugin can detect the snippet key)
- Scans only the first 60 lines for existing with clauses
- Does not handle `with` clauses split across multiple lines
- Does not handle context clauses with `use` or `rename`
- Does not remove unused with clauses
