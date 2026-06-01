with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Definitions;   use Definitions;
with Snippet_Utils;

procedure Gen_Snippets is

   Standard_Names : constant array (1 .. 7) of Unbounded_String :=
     (+"ada-2022", +"ada-2012", +"ada-2005",
      +"spark", +"spark-2014", +"jorvik", +"ravenscar");

   function Escaped_JSON (S : String) return String is
      Result : String (1 .. S'Length * 2);
      Last   : Natural;
   begin
      if S'Length = 0 then
         return "";
      end if;
      Snippet_Utils.Escape_JSON (S, Result, Last);
      return Result (1 .. Last);
   end Escaped_JSON;

   procedure Print_Snippet (S : Snippet_Record; Last : Boolean) is
   begin
      Put_Line ("    {");
      Put_Line ("      ""prefix"": [""" & Escaped_JSON (To_String (S.Prefix)) & """],");
      Put_Line ("      ""body"": [");

      --  Split body on \n and output JSON array
      declare
         Body_Str : constant String := To_String (S.Body_Str);
         Current  : Positive := Body_Str'First;
         NL_Idx   : Natural;
      begin
         loop
            NL_Idx := Snippet_Utils.Find_Newline (Body_Str (Current .. Body_Str'Last));
            if NL_Idx = 0 then
               --  Last line (no trailing LF)
               if Current <= Body_Str'Last then
                  Put ("        """ & Escaped_JSON (Body_Str (Current .. Body_Str'Last)) & """");
                  New_Line;
               end if;
               exit;
            else
               Put ("        """ & Escaped_JSON (Body_Str (Current .. NL_Idx - 1)) & """,");
               New_Line;
               Current := NL_Idx + 2; -- Skip the '\n'
            end if;
         end loop;
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
