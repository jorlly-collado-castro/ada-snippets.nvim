# Snippets reference

48 snippets organized by category. All snippets use LSP snippet
syntax for tab stops (`${1:default}`, `$0`, etc.) and support
jumping between fields.

## Subprograms

| Prefix  | Description                     | Body                                                          | Standards              |
|---------|---------------------------------|---------------------------------------------------------------|------------------------|
| `proc`  | procedure body                  | `procedure ${1:Name} is` … `end ${1:Name};`                   | all                    |
| `procs` | procedure specification         | `procedure ${1:Name} (${2:Param} : ${3:Type});`                | all                    |
| `func`  | function body                   | `function ${1:Name} … return ${4:Return_Type}` …               | all                    |
| `funcs` | function specification          | `function ${1:Name} (${2:Param} : ${3:Type}) return ${4:RT};`  | all                    |
| `subp`  | subprogram declaration          | `${1:procedure | function} ${2:Name} …`                        | all                    |

## Packages

| Prefix  | Description                     | Body                                                           |
|---------|---------------------------------|----------------------------------------------------------------|
| `pkg`   | package specification           | `package ${1:Name} is` … `end ${1:Name};`                       |
| `pkgb`  | package body                    | `package body ${1:Name} is` … `begin` … `end ${1:Name};`        |
| `gen`   | generic package specification   | `generic` … `package ${2:Name} is` … `end ${2:Name};`           |

## Tasking and concurrency

| Prefix  | Description                     | Standards              |
|---------|---------------------------------|------------------------|
| `task`  | task specification              | all except SPARK-only  |
| `taskb` | task body                       | all except SPARK-only  |
| `prot`  | protected object specification  | all                    |
| `protb` | protected object body           | all                    |
| `par`   | parallel for loop (Ada 2022)    | ada-2022 only          |
| `parb`  | parallel block (Ada 2022)       | ada-2022 only          |

## Control flow

| Prefix  | Description                     | Body                                                           |
|---------|---------------------------------|----------------------------------------------------------------|
| `if`    | if statement                    | `if ${1:Condition} then` … `end if;`                            |
| `ife`   | if/else statement               | `if ${1:Condition} then` … `else` … `end if;`                   |
| `case`  | case statement                  | `case ${1:Expression} is` … `when ${2:Choice} =>` … `end case;` |
| `loop`  | basic loop                      | `loop` … `end loop;`                                            |
| `for`   | for loop                        | `for ${1:Var} in ${2:Range} loop` … `end loop;`                 |
| `while` | while loop                      | `while ${1:Condition} loop` … `end loop;`                       |
| `declare`| declare block                  | `declare` … `begin` … `end;`                                    |
| `except`| exception handler               | `exception` … `when ${1:Error} =>`                              |

## Types

| Prefix   | Description                     | Body                                                           |
|----------|---------------------------------|----------------------------------------------------------------|
| `type`   | type declaration                | `type ${1:Name} is ${2:definition};`                            |
| `rec`    | record type                     | `type ${1:Name} is record` … `end record;`                      |
| `arr`    | array type                      | `type ${1:Name} is array (${2:Index}) of ${3:Component_Type};`  |
| `subtype`| subtype declaration             | `subtype ${1:Name} is ${2:Base_Type} range ${3:Limit};`         |
| `enum`   | enumeration type                | `type ${1:Name} is (${2:A}, ${3:B});`                           |
| `access` | access type                     | `type ${1:Name} is access ${2:Target_Type};`                    |
| `delta`  | fixed-point type                | `type ${1:Name} is delta ${2:D} range ${3:Low} .. ${4:High};`   |
| `digits` | floating-point type             | `type ${1:Name} is digits ${2:D} range ${3:Low} .. ${4:High};`  |

## Declarations

| Prefix   | Description                     | Body                                                           |
|----------|---------------------------------|----------------------------------------------------------------|
| `var`    | variable declaration            | `${1:Name} : ${2:Type}${3: := ${4:Default}};`                   |
| `const`  | constant declaration            | `${1:Name} : constant ${2:Type} := ${3:Value};`                 |
| `ren`    | renames declaration             | `${1:Name} : ${2:Type} renames ${3:Original};`                  |
| `separate`| separate body stub             | `separate (${1:Parent})`                                       |

## Clauses

| Prefix    | Description                     | Body                                                           |
|-----------|---------------------------------|----------------------------------------------------------------|
| `with`    | with clause                     | `with ${1:Unit};`                                               |
| `use`     | use clause                      | `use ${1:Unit};`                                                |
| `use_type`| use type clause                 | `use type ${1:Type};`                                           |

## I/O (auto-with enabled)

| Prefix  | Description                     | Body                                     | With unit    |
|---------|---------------------------------|------------------------------------------|--------------|
| `putl`  | Put_Line statement              | `Ada.Text_IO.Put_Line (${1:Item});`       | `Ada.Text_IO`|
| `put`   | Put statement                   | `Ada.Text_IO.Put (${1:Item});`            | `Ada.Text_IO`|
| `getl`  | Get_Line statement              | `Ada.Text_IO.Get_Line (${1:Item});`       | `Ada.Text_IO`|

These snippets are excluded in Ravenscar mode (no Text_IO in
high-integrity profiles).

## Pragmas

| Prefix           | Description                     | Body                                           | Standards     |
|------------------|---------------------------------|------------------------------------------------|---------------|
| `pragma`         | pragma line                     | `pragma ${1:Name} (${2:Args});`                 | all           |
| `pragma_import`  | pragma Import                   | `pragma Import (${1:C}, ${2:E}, ${3:"ext"});`   | all           |
| `pragma_assert`  | pragma Assert                   | `pragma Assert (${1:Condition});`               | all           |
| `elab`           | pragma Elaborate                | `pragma Elaborate (${1:Unit});`                 | all           |
| `ravenscar`      | pragma Profile (Ravenscar)      | `pragma Profile (Ravenscar);`                   | ravenscar     |
| `jorvik`         | pragma Profile (Jorvik)         | `pragma Profile (Jorvik);`                      | jorvik        |

## SPARK annotations

| Prefix  | Description                     | Body                    | Standards      |
|---------|---------------------------------|-------------------------|----------------|
| `req`   | SPARK precondition aspect       | `  ${1:Precondition};`  | spark, spark-2014 |
| `ens`   | SPARK postcondition aspect      | `  ${1:Postcondition};` | spark, spark-2014 |

## Snippet count by standard

| Standard      | Snippets | Notable exclusions                        |
|---------------|----------|-------------------------------------------|
| `ada-2022`    | 48       | (full set)                                |
| `ada-2012`    | 46       | No `parallel` constructs                  |
| `ada-2005`    | 46       | No `parallel` constructs                  |
| `spark`       | 47       | No task specs/bodies                      |
| `spark-2014`  | 47       | No task specs/bodies                      |
| `jorvik`      | 47       | No `Ada.Text_IO` snippets                 |
| `ravenscar`   | 45       | No `Ada.Text_IO`, no task entries         |
