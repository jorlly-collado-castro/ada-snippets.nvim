with AUnit.Test_Cases; use AUnit.Test_Cases;
with AUnit.Test_Suites; use AUnit.Test_Suites;

package Test_Snippet_Utils is

   type Test is new Test_Case with null record;

   overriding procedure Register_Tests (T : in out Test);
   overriding function Name (T : Test) return AUnit.Message_String;

   procedure Test_Find_Newline (T : in out Test_Case'Class);
   procedure Test_Escape_JSON (T : in out Test_Case'Class);

   function Suite return Access_Test_Suite;

end Test_Snippet_Utils;
