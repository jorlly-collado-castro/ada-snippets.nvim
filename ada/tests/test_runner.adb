with AUnit.Reporter.Text;
with AUnit.Run;
with Test_Snippet_Utils;

procedure Test_Runner is
   procedure Run is new AUnit.Run.Test_Runner (Test_Snippet_Utils.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Run (Reporter);
end Test_Runner;
