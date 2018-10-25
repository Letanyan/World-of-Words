program WorldOfWords_Project;

uses
  Forms,
  Game_Controller in 'Game_Controller.pas' {frmWoWGames},
  HangmanGame_Module in 'HangmanGame_Module.pas',
  HighScoreUnit_Controller in 'HighScoreUnit_Controller.pas' {frmHighScores},
  AccountManagment_Controller in 'AccountManagment_Controller.pas' {frmAccountManagment},
  UserInfo_Module in 'UserInfo_Module.pas',
  WordSearch_Module in 'WordSearch_Module.pas',
  BuildAWord_Module in 'BuildAWord_Module.pas',
  TabSetManagment_Module in 'TabSetManagment_Module.pas',
  Tools_Module in 'Tools_Module.pas',
  GameSettings_Controller in 'GameSettings_Controller.pas' {frmGameSettings},
  GameSettings_Module in 'GameSettings_Module.pas',
  HIghScoreFilter_Module in 'HIghScoreFilter_Module.pas',
  BoardGames_Board__Module in 'BoardGames_Board__Module.pas',
  FindEm_Module in 'FindEm_Module.pas',
  CrossWord_Module in 'CrossWord_Module.pas',
  WordCity_Module in 'WordCity_Module.pas',
  Help_Module in 'Help_Module.pas',
  ButtonHandling_Module in 'ButtonHandling_Module.pas',
  BuildEm_Module in 'BuildEm_Module.pas',
  Sorting in 'Sorting.pas',
  WordPath_Module in 'WordPath_Module.pas',
  WordRace_Module in 'WordRace_Module.pas',
  Admin_Controller in 'Admin_Controller.pas' {frmAdmin},
  ToolBox_Controller in 'ToolBox_Controller.pas' {frmToolBox},
  Anagram_Module in 'Anagram_Module.pas',
  BreakAndBuild_Module in 'BreakAndBuild_Module.pas',
  Achievements_Controller in 'Achievements_Controller.pas' {frmAchievements},
  Achievements_Module in 'Achievements_Module.pas',
  Tutorial_Controller in 'Tutorial_Controller.pas' {frmTutorial};

{$R *.res}
begin
  Application.Initialize;
  Application.Title := 'Word Hound';
  Application.CreateForm(TfrmAccountManagment, frmAccountManagment);
  Application.CreateForm(TfrmWoWGames, frmWoWGames);
  Application.CreateForm(TfrmHighScores, frmHighScores);
  Application.CreateForm(TfrmGameSettings, frmGameSettings);
  Application.CreateForm(TfrmAdmin, frmAdmin);
  Application.CreateForm(TfrmToolBox, frmToolBox);
  Application.CreateForm(TfrmAchievements, frmAchievements);
  Application.CreateForm(TfrmTutorial, frmTutorial);
  frmAchievements.Ready := False;
  With frmWoWGames do
   begin
    pnlHangman.Hide;
    pnlWordSearch.Hide;
    pnlBuildaword.Hide;
    pnlFindEm.Hide;
    pnlCrossWord.Hide;
    pnlWordCity.Hide;
    pnlBuildEm.Hide;
    pnlWordRace.Hide;
    pnlBreakAndBuild.Hide;
   end;
  Application.Run;
end.
