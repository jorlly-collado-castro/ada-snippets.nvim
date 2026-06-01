# Snippets reference

72 snippets organized by category. All snippets use LSP snippet
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

## SPARK contract aspects (flow analysis)

Aspect specifications for the `with` clause on subprogram
declarations. SPARK-only features.

| Prefix             | Description              | Body                                                | Standards |
|--------------------|--------------------------|-----------------------------------------------------|-----------|
| `depends`          | Depends aspect           | `  Depends => (${1:Output} => ${2:Input});`         | spark     |
| `global`           | Global aspect            | `  Global => (${1:In} => ${2:Var});`                | spark     |
| `refined_state`    | Refined_State aspect     | `  Refined_State => (${1:State} => (${2:Concrete}));` | spark     |
| `refined_depends`  | Refined_Depends aspect   | `  Refined_Depends => (${1:Output} => ${2:Input});` | spark     |
| `refined_global`   | Refined_Global aspect    | `  Refined_Global => (${1:In} => ${2:Var});`        | spark     |
| `proof_in`         | Proof_In aspect          | `  Proof_In => (${1:Var});`                         | spark     |
| `proof_out`        | Proof_Out aspect         | `  Proof_Out => (${1:Var});`                        | spark     |

## Contract aspects (Ada 2012+)

| Prefix               | Description                 | Body                                                          | Standards      |
|----------------------|-----------------------------|---------------------------------------------------------------|----------------|
| `precondition`       | Precondition aspect         | `  Precondition => ${1:Condition};`                           | ada 2012+      |
| `postcondition`      | Postcondition aspect        | `  Postcondition => ${1:Condition};`                          | ada 2012+      |
| `contract_cases`     | Contract_Cases aspect       | `  Contract_Cases => (${1:Cond} => ${2:Post}, others => …);`  | ada 2012+      |
| `type_invariant`     | Type_Invariant aspect       | `  Type_Invariant => ${1:Condition};`                         | ada 2012+      |
| `predicate`          | Predicate aspect            | `  Predicate => ${1:Condition};`                              | ada 2012+      |
| `dynamic_predicate`  | Dynamic_Predicate aspect    | `  Dynamic_Predicate => ${1:Condition};`                      | ada 2012+      |

## Contract aspects (Ada 2022+)

| Prefix                | Description                   | Body                                                        | Standards |
|-----------------------|-------------------------------|-------------------------------------------------------------|-----------|
| `exceptional_cases`   | Exceptional_Cases aspect      | `  Exceptional_Cases => (${1:E} => ${2:Postcondition});`    | ada 2022  |
| `always_terminates`   | Always_Terminates aspect      | `  Always_Terminates => ${1:True};`                         | ada 2022  |
| `subprogram_variant`  | Subprogram_Variant aspect     | `  Subprogram_Variant => (${1:Decreases} => ${2:Expr});`    | ada 2022  |

## Loop annotations (SPARK)

| Prefix           | Description             | Body                                               | Standards |
|------------------|-------------------------|----------------------------------------------------|-----------|
| `loop_invariant` | pragma Loop_Invariant   | `pragma Loop_Invariant (${1:Condition});`          | spark     |
| `loop_variant`   | pragma Loop_Variant     | `pragma Loop_Variant (${1:Decreases} => ${2:Expr});` | spark     |

## SPARK assertion pragmas

| Prefix                | Description             | Body                                                      | Standards |
|-----------------------|-------------------------|-----------------------------------------------------------|-----------|
| `pragma_assume`       | pragma Assume           | `pragma Assume (${1:Condition});`                         | spark     |
| `pragma_annotate`     | pragma Annotate         | `pragma Annotate (${1:Check}, ${2:Proof}, ${3:Message});` | spark     |
| `pragma_check`        | pragma Check            | `pragma Check (${1:Name}, ${2:Condition});`               | spark     |

## Ghost constructs (SPARK)

| Prefix            | Description                  | Body                                                         | Standards |
|-------------------|------------------------------|--------------------------------------------------------------|-----------|
| `ghost_procedure` | Ghost procedure body         | `procedure ${1:Name} (${2:P} : ${3:T}) with Ghost is` …     | spark     |
| `ghost_function`  | Ghost function body          | `function ${1:Name} (${2:P} : ${3:T}) return ${4:RT} ...`   | spark     |
| `ghost_type`      | Ghost type                   | `type ${1:Name} is ${2:def} with Ghost;`                     | spark     |
| `ghost_package`   | Ghost package specification  | `package ${1:Name} is with Ghost` …                          | spark     |

## Assertion policy

| Prefix                   | Description               | Body                                    | Standards |
|--------------------------|---------------------------|-----------------------------------------|-----------|
| `pragma_assertion_policy`| pragma Assertion_Policy   | `pragma Assertion_Policy (${1:Check});` | ada 2012+ |

## Snippet count by standard

| Standard      | Snippets | Notable exclusions                        |
|---------------|----------|-------------------------------------------|
| `ada-2022`    | 54       | No SPARK-specific contracts/pragmas       |
| `ada-2012`    | 49       | No SPARK, no Ada 2022 contracts           |
| `ada-2005`    | 42       | No contracts, no SPARK, no Ada 2022       |
| `spark`       | 66       | No task specs/bodies                      |
| `spark-2014`  | 63       | No Ada 2022 contracts, no `parallel`      |
| `jorvik`      | 43       | No SPARK, no contracts, no Ada 2022       |
| `ravenscar`   | 40       | No SPARK, no contracts, no Ada.Text_IO    |
