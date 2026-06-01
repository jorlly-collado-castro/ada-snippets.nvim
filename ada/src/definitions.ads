with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

private package Definitions is

   type Standard_Mask is array (1 .. 7) of Boolean;
   --  1=ada-2022, 2=ada-2012, 3=ada-2005,
   --  4=spark, 5=spark-2014, 6=jorvik, 7=ravenscar

   All_Standards      : constant Standard_Mask := (others => True);
   Ada_2022_Only      : constant Standard_Mask := (1 => True, others => False);
   Spark_All          : constant Standard_Mask := (4 | 5 => True, others => False);
   Ravenscar_Compat   : constant Standard_Mask :=
     (1 | 2 | 3 | 6 | 7 => True, others => False);
   Jorvik_Only        : constant Standard_Mask := (6 => True, others => False);
   Ravenscar_Only     : constant Standard_Mask := (7 => True, others => False);
   No_Ravenscar       : constant Standard_Mask :=
     (1 | 2 | 3 | 4 | 5 | 6 => True, others => False);

   type Snippet_Record is record
      Prefix      : Unbounded_String;
      Body        : Unbounded_String;   -- JSON body with \n line separators
      Description : Unbounded_String;
      Standards   : Standard_Mask;
      With_Units  : Unbounded_String;   -- comma-separated, empty = none
   end record;

   type Snippet_Array is array (Positive range <>) of Snippet_Record;

   function All_Snippets return Snippet_Array;

end Definitions;
