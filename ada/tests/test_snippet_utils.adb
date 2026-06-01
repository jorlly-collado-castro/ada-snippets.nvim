with AUnit.Assertions; use AUnit.Assertions;
with Snippet_Utils;

package body Test_Snippet_Utils is

   overriding function Name (T : Test) return AUnit.Message_String is
   begin
      return AUnit.Format ("Snippet_Utils Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Find_Newline'Access, "Test Find_Newline splitting");
      Register_Routine (T, Test_Escape_JSON'Access, "Test JSON Escaping");
   end Register_Tests;

   procedure Test_Find_Newline (T : in out Test_Case'Class) is
      Idx : Natural;
   begin
      Idx := Snippet_Utils.Find_Newline ("no newline here");
      Assert (Idx = 0, "Failed to return 0 for string with no newline");

      Idx := Snippet_Utils.Find_Newline ("hello\nworld");
      Assert (Idx = 6, "Failed to find newline at correct index");

      Idx := Snippet_Utils.Find_Newline ("\nstart");
      Assert (Idx = 1, "Failed to find newline at start");

      Idx := Snippet_Utils.Find_Newline ("end\n");
      Assert (Idx = 4, "Failed to find newline at end");
   end Test_Find_Newline;

   procedure Test_Escape_JSON (T : in out Test_Case'Class) is
      S : constant String := "hello "" \ world";
      Res : String (1 .. Snippet_Utils.Escaped_Length (S));
      Last : Natural;
   begin
      Snippet_Utils.Escape_JSON (S, Res, Last);
      Assert (Last = Res'Last, "Last index does not match computed length");
      Assert (Res = "hello \"" \\ world", "Incorrect escaping result");
   end Test_Escape_JSON;

   Result : aliased Test_Suite;
   T_Case : aliased Test;

   function Suite return Access_Test_Suite is
   begin
      Add_Test (Result'Access, T_Case'Access);
      return Result'Access;
   end Suite;

end Test_Snippet_Utils;
