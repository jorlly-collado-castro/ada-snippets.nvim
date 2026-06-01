package Snippet_Utils
  with SPARK_Mode => On
is

   Max_Length : constant := Natural'Last / 2;
   subtype Valid_String is String
     with Dynamic_Predicate => Valid_String'Length <= Max_Length
                               and then Valid_String'First >= 1;

   function Escaped_Length (S : Valid_String) return Natural
     with Post => Escaped_Length'Result <= S'Length * 2;

   procedure Escape_JSON (S : Valid_String; Result : out String; Last : out Natural)
     with Pre  => Result'First >= 1
                  and then Result'Length >= S'Length * 2,
          Post => Last >= Result'First - 1 and then Last <= Result'Last;

   --  Returns the index of the first '\' in S that is immediately followed by 'n'.
   --  Returns 0 if no such sequence is found.
   function Find_Newline (S : Valid_String) return Natural
     with Post => (if Find_Newline'Result > 0 then
                     Find_Newline'Result >= S'First
                     and then Find_Newline'Result < S'Last);

end Snippet_Utils;
