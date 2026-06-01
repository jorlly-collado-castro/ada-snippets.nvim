with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Definitions;   use Definitions;

procedure Gen_Snippets is

   Standard_Names : constant array (1 .. 7) of Unbounded_String :=
     (+"ada-2022", +"ada-2012", +"ada-2005",
      +"spark", +"spark-2014", +"jorvik", +"ravenscar");

   function Escaped_JSON (S : String) return String is
      Result : String (1 .. S'Length * 2);
      Len    : Natural := 0;
   begin
      for C of S loop
         case C is
            when '"'  => Len := Len + 2; Result (Len - 1 .. Len) := "\\\"";
            when '\\' => Len := Len + 2; Result (Len - 1 .. Len) := "\\\\";
            when '\n' => Len := Len + 2; Result (Len - 1 .. Len) := "\\n";
            when '\t' => Len := Len + 2; Result (Len - 1 .. Len) := "\\t";
            when ASCII.LF => Len := Len + 2; Result (Len - 1 .. Len) := "\\n";
            when ASCII.CR => null;
            when others =>
               Len := Len + 1;
               Result (Len) := C;
         end case;
      end loop;
      return Result (1 .. Len);
   end Escaped_JSON;

   procedure Print_Snippet (S : Snippet_Record; Last : Boolean) is
   begin
      Put_Line ("    {");
      Put_Line ("      ""prefix"": [""" & Escaped_JSON (To_String (S.Prefix)) & """],");
      Put_Line ("      ""body"": [");

      --  Split body on \n and output JSON array
      declare
         Body_Str : constant String := To_String (S.Body);
         Start_Pos : Positive := Body_Str'First;
      begin
         for I in Body_Str'Range loop
            if Body_Str (I) = ASCII.LF then
               Put ("        """ & Escaped_JSON (Body_Str (Start_Pos .. I - 1)) & """,");
               New_Line;
               Start_Pos := I + 1;
            end if;
         end loop;
         --  Last line (no trailing LF)
         if Start_Pos <= Body_Str'Last then
            Put ("        """ & Escaped_JSON (Body_Str (Start_Pos .. Body_Str'Last)) & """");
            New_Line;
         end if;
      end;

      Put_Line ("      ],");
      Put_Line ("      ""description"": """ & Escaped_JSON (To_String (S.Description)) & """,");
      Put ("      ""standards"": [");
      declare
         First_Std : Boolean := True;
      begin
         for J in Standard_Names'Range loop
            if S.Standards (J) then
               if not First_Std then
                  Put (", ");
               end if;
               Put ("""" & To_String (Standard_Names (J)) & """");
               First_Std := False;
            end if;
         end loop;
      end;
      Put_Line ("],");

      declare
         WU : constant String := To_String (S.With_Units);
      begin
         if WU = "" then
            Put_Line ("      ""with_units"": []");
         else
            Put ("      ""with_units"": [");
            declare
               Start_Pos : Positive := WU'First;
            begin
               for I in WU'Range loop
                  if WU (I) = ',' then
                     Put ("""" & Escaped_JSON (WU (Start_Pos .. I - 1)) & """, ");
                     Start_Pos := I + 1;
                  end if;
               end loop;
               Put ("""" & Escaped_JSON (WU (Start_Pos .. WU'Last)) & """");
            end;
            Put_Line ("]");
         end if;
      end;

      if Last then
         Put_Line ("    }");
      else
         Put_Line ("    },");
      end if;
   end Print_Snippet;

   Snippets : constant Snippet_Array := All_Snippets;

begin
   Put_Line ("{");
   for I in Snippets'Range loop
      Put ("  """ & Escaped_JSON (To_String (Snippets (I).Description)) & """: ");
      Print_Snippet (Snippets (I), I = Snippets'Last);
   end loop;
   Put_Line ("}");
end Gen_Snippets;
