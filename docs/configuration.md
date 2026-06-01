# Configuration

## Options

| Option     | Type   | Default      | Description                          |
|------------|--------|--------------|--------------------------------------|
| `standard` | string | `"ada-2022"` | Ada standard for snippet filtering.  |

Pass options to `setup()`:

```lua
require("ada_snippets").setup({
  standard = "ravenscar",
})
```

With lazy.nvim, pass via `opts`:

```lua
{
  "jorlly-collado-castro/ada-snippets.nvim",
  ft = "ada",
  opts = { standard = "spark-2014" },
}
```

## Standards reference

| Key            | Label          | ISO Reference              | Description                    |
|----------------|----------------|----------------------------|--------------------------------|
| `ada-2022`     | Ada 2022       | ISO/IEC 8652:2023          | Latest Ada standard (default)  |
| `ada-2012`     | Ada 2012       | ISO/IEC 8652:2012          | Widely deployed previous gen   |
| `ada-2005`     | Ada 2005       | ISO/IEC 8652:2007          | Legacy standard                |
| `spark`        | SPARK          | ISO/IEC 8652:2023 + SPARK  | Latest SPARK subset            |
| `spark-2014`   | SPARK 2014     | ISO/IEC 8652:2012 + SPARK  | SPARK 2014 subset              |
| `jorvik`       | Jorvik         | ISO/IEC 24718:2025         | Jorvik profile (tasking)       |
| `ravenscar`    | Ravenscar      | ISO/IEC TS 24718:2025      | Ravenscar profile (high-integrity) |

## Standard filtering semantics

- **All** standards include: procedure, function, package, if/case/loop,
  type/record/array, declare, exception, pragmas, subprogram declarations
- **Ada 2022-only**: `parallel` loop and `parallel` block
- **SPARK** (both variants): full contract aspects (`Depends`, `Global`,
  `Proof_In`, `Proof_Out`), loop annotations, assertion pragmas,
  ghost constructs, and Ada 2012+ contract aspects
- **SPARK 2014**: everything in SPARK except Ada 2022 aspects
  (`Always_Terminates`, `Exceptional_Cases`, `Subprogram_Variant`)
- **Ravenscar**: restricted to profile-compatible snippets (no
  `Ada.Text_IO`, no `delay`, no `select`); includes `pragma Profile (Ravenscar)`
- **Jorvik**: like Ravenscar but with the Jorvik profile pragma

## Runtime standard switching

Change the standard at runtime without restarting Neovim:

```lua
require("ada_snippets").set_standard("spark")
```

This re-filters the snippet cache and updates the buffer indicator
immediately.

## Indicator display

The mode indicator is a virtual text extmark at line 0 of every Ada
buffer. It automatically shows and hides on `BufEnter`/`BufLeave`.
The display format is:

```
 Ada 2022 (ISO/IEC 8652:2023)
```

The indicator is rendered in the `Comment` highlight group. It does
not modify the actual buffer contents.
