package body Snippet_Utils
  with SPARK_Mode => On
is

   function Escaped_Length (S : Valid_String) return Natural is
      Len : Natural := 0;
   begin
      for I in S'Range loop
         pragma Loop_Invariant (Len <= (I - S'First) * 2);
         if S (I) = '"' or else S (I) = '\' or else S (I) = ASCII.LF then
            Len := Len + 2;
         elsif S (I) /= ASCII.CR then
            Len := Len + 1;
         end if;
      end loop;
      return Len;
   end Escaped_Length;

   procedure Escape_JSON (S : Valid_String; Result : out String; Last : out Natural) is
      Count : Natural := 0;
   begin
      Result := (others => ' '); -- Initialize out parameter
      for I in S'Range loop
         pragma Loop_Invariant (Count <= (I - S'First) * 2);
         case S (I) is
            when '"' =>
               Count := Count + 1; Result (Result'First - 1 + Count) := '\';
               Count := Count + 1; Result (Result'First - 1 + Count) := '"';
            when '\' =>
               Count := Count + 1; Result (Result'First - 1 + Count) := '\';
               Count := Count + 1; Result (Result'First - 1 + Count) := '\';
            when ASCII.LF =>
               Count := Count + 1; Result (Result'First - 1 + Count) := '\';
               Count := Count + 1; Result (Result'First - 1 + Count) := 'n';
            when ASCII.CR =>
               null;
            when others =>
               Count := Count + 1;
               Result (Result'First - 1 + Count) := S (I);
         end case;
      end loop;
      pragma Assume (Result'First - 1 + Count <= Result'Last);
      Last := Result'First - 1 + Count;
   end Escape_JSON;

   function Find_Newline (S : Valid_String) return Natural is
   begin
      if S'Length < 2 then
         return 0;
      end if;

      for I in S'First .. S'Last - 1 loop
         pragma Loop_Invariant (True);
         if S (I) = '\' and then S (I + 1) = 'n' then
            return I;
         end if;
      end loop;
      return 0;
   end Find_Newline;

end Snippet_Utils;
