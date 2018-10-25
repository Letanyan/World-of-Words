unit Game_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ExtCtrls, StdCtrls, HangManGame_Module, DB, Grids,
  DBGrids, ADODB, DBCtrls, Spin, WordSearch_Module, FindEm_Module,
  jpeg, BuildAWord_Module, Menus, TabSetManagment_Module, GameSettings_Module,
  CrossWord_Module, psApi, WordCity_Module, BoardGames_Board__Module,
  ButtonHandling_Module, BuildEm_Module, WordRace_Module, Anagram_Module,
  BreakAndBuild_Module, CheckLst, Achievements_Module;

type
  TfrmWoWGames = class(TForm)
    pnlMenu: TPanel;
    tblGames: TADOTable;
    qryGames: TADOQuery;
    imgMenuBack: TImage;
    pnlHangman: TPanel;
    imgHangedMan: TImage;
    pnlWordSearch: TPanel;
    srdwordSearchBoard: TStringGrid;
    pnlBuildaword: TPanel;
    imgWordSearchBack: TImage;
    pnlWordSearchWords: TPanel;
    imgWordSearchWords: TImage;
    lblWordSearchWords: TLabel;
    lsbWordSearchwords: TListBox;
    imgHangManHUB: TImage;
    lblHangmanWord: TLabel;
    imgBuildaWordHUB: TImage;
    pnlBuildAWordLetters: TPanel;
    srdBuildAWord: TStringGrid;
    tmrGames: TTimer;
    dsrTranslator: TDataSource;
    qryGameWords: TADOQuery;
    tmrGameSelTab: TTimer;
    tmrTabsMove: TTimer;
    imgBuildAWordBack: TImage;
    pnlFindEm: TPanel;
    imgFindEmBack: TImage;
    srdFindEm: TStringGrid;
    pnlCrossWord: TPanel;
    pnlCrossWordHUB: TPanel;
    imgCrossWordHUBBack: TImage;
    imgCrossWordBack: TImage;
    srdCrossWord: TStringGrid;
    lblCrossWordDefs: TLabel;
    lsbCrossWordDefs: TListBox;
    tmrDrawer: TTimer;
    imgLogout: TImage;
    imgStats: TImage;
    imgNewGame: TImage;
    lblTimeRemaining: TLabel;
    imgPlayPause: TImage;
    imgQuit: TImage;
    imgBAWSkipTurn: TImage;
    imgBAWRepick: TImage;
    imgBAWRecall: TImage;
    imgBAWCheck: TImage;
    pnlGames: TPanel;
    imgGameBack: TImage;
    imgSelGame: TImage;
    lblWordSearch: TLabel;
    lblHangMan: TLabel;
    lblBuildaWord: TLabel;
    lblFindEm: TLabel;
    lblCrossWord: TLabel;
    lblWordCity: TLabel;
    pnlWordCity: TPanel;
    imgWordCityHUB: TImage;
    imgWordCityBack: TImage;
    srdWordCity: TStringGrid;
    lblWordCityNextShape: TLabel;
    lsbWordCityWordsMade: TListBox;
    lblWordCityWordsMade: TLabel;
    lblMarginTimeR: TLabel;
    imgHelp: TImage;
    imgTools: TImage;
    lblLargerCrossWord: TLabel;
    lblSmallerCrossWord: TLabel;
    pnlFindEmHUB: TPanel;
    imgFindHUB: TImage;
    lblFindEmUserWord: TLabel;
    lblFindemScore: TLabel;
    imgFindemCheck: TImage;
    imgFindEmClear: TImage;
    edtHelpSearch: TEdit;
    pnlBuildEm: TPanel;
    imgBuildEmBack: TImage;
    srdBuildEm: TStringGrid;
    pnlBuildEmHUB: TPanel;
    imgBuildEmHUB: TImage;
    lblBuildEmWord: TLabel;
    lblBuildEmScore: TLabel;
    lblBuildEm: TLabel;
    imgCrossWordHelp: TImage;
    lblWordRace: TLabel;
    pnlWordRace: TPanel;
    lblAnagrams: TLabel;
    pnlAnagrams: TPanel;
    lblBreakAndBuild: TLabel;
    pnlBreakAndBuild: TPanel;
    imgAnagramBack: TImage;
    pnlAnagramHUB: TPanel;
    imgAnagramHUBBackground: TImage;
    imgAnagramHUBBack: TImage;
    lblAnagramLetterSet: TLabel;
    edtAnagramWord: TEdit;
    imgAnagramCheck: TImage;
    imgAnagramNext: TImage;
    lblAnagramScore: TLabel;
    lblAnagramLives: TLabel;
    imgBBBack: TImage;
    pnlBBHUB: TPanel;
    imgBBHUB: TImage;
    lsbBBWordsMade: TListBox;
    lblBBWordsMadeFrom: TLabel;
    lblBBScore: TLabel;
    lblBBMain: TLabel;
    pnlWordRaceHUB: TPanel;
    imgWordRaceHUB: TImage;
    lblWordRaceScore: TLabel;
    imgWordRaceBack: TImage;
    lblWordRaceWord: TLabel;
    tmrGameTransition: TTimer;
    clxAnagramsWordsMade: TCheckListBox;
    lblAnagramWordsMadeCount: TLabel;
    pnlHighscores: TPanel;
    imgHighscores: TImage;
    lblHighScores: TLabel;
    tmrHighscores: TTimer;
    imgAchievements: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgWordSearchWordsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrGamesTimer(Sender: TObject);
    procedure tmrGameSelTabTimer(Sender: TObject);
    procedure lblTabDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTabUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTabMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tmrTabsMoveTimer(Sender: TObject);
    procedure srdwordSearchBoardDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormPaint(Sender: TObject);
    procedure imgCrossWordHUBBackMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrDrawerTimer(Sender: TObject);
    procedure imgLogoutClick(Sender: TObject);
    procedure imgNewGameClick(Sender: TObject);
    procedure imgBAWSkipTurnClick(Sender: TObject);
    procedure imgBAWRepickClick(Sender: TObject);
    procedure imgBAWCheckClick(Sender: TObject);
    procedure imgFindEmClearClick(Sender: TObject);
    procedure imgBAWRecallClick(Sender: TObject);
    procedure imgToolsClick(Sender: TObject);
    procedure lblSmallerCrossWordMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lblLargerCrossWordMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgPlayPauseClick(Sender: TObject);
    procedure srdwordSearchBoardMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgQuitClick(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
    procedure imgFindemCheckClick(Sender: TObject);
    procedure imgAnagramCheckClick(Sender: TObject);
    procedure imgAnagramNextClick(Sender: TObject);
    procedure imgAnagramHUBBackClick(Sender: TObject);
    procedure edtAnagramWordKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure imgAnagramHUBBackgroundMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure imgCrossWordHelpClick(Sender: TObject);
    procedure tmrHighscoresTimer(Sender: TObject);
    procedure imgAchievementsClick(Sender: TObject);
    procedure edtHelpSearchEnter(Sender: TObject);
    procedure imgTutorialClick(Sender: TObject);
    procedure lblHighScoresMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblHighScoresMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblHighScoresMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure imgStatsClick(Sender: TObject);
    procedure lblAnagramLetterSetMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lblNewGameClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     brdGame    : TBoard;
     Anagram    : TAnagram;
     HangMan    : THangman;
     WordSearch : TWordSearch;
     BuildAWord : TBuildAWord;
     FindEm     : TFindEm;
     CrossWord  : TCrossWord;
     WordCity   : TWordCity;
     BuildEm    : TBuildEm;
     WordRace   : TWordRace;
     BreakBuild : TBreakBuild;
     GameSet : string;

     NewGame: TThemeButton;
     btnHelp: TThemeButton;
     Logout: TThemeButton;
     Tools: TThemeButton;
     Stats: TThemeButton;
     Quit: TThemeButton;
     Achievements: TThemeButton;
     btnPlayPause: TThemeButton;

     FindEmCheck: TThemeButton;
     FindEmClear: TThemeButton;
     BAWCheck: TThemeButton;
     BAWRecall: TThemeButton;
     BAWRepick: TThemeButton;
     BAWSkipTurn: TThemeButton;
     CrossWordClue: TThemeButton;
     AnagramCheck: TThemeButton;
     AnagramNext: TThemeButton;
     AnagramList: TThemeButton;
     Tutorial : TThemeButton;

     TabSet : TTabSet;
     MovingTb : boolean;

     ScoresMoveLeft: Boolean;

     lbUsing  : char;

     CurrentGame : String;
     CurrentGameTab : TLabel;
     CurrentGamePnl : TPanel;

     OriginalHighScore: TPoint;

     procedure StartNewGame(game : string);

     procedure ChangeSet(Game : String);

     procedure GameOver(Sender: TObject);
     procedure PlayPause(Start : boolean);
     procedure ChangePlayPause(Start : boolean);

     procedure SaveGames();
     procedure SaveGeneralSettings;
     procedure LoadGeneralSettings;
     procedure CheckInScreenView(frm: TForm);
     function  CanClose(WithMessage: Boolean): Boolean;
     procedure SetTimers(bON: Boolean);
  end;

var
  frmWoWGames: TfrmWoWGames;

implementation

uses AccountManagment_Controller, HighScoreUnit_Controller, Math,
  GameSettings_Controller, ToolBox_Controller, Achievements_Controller,
  Tutorial_Controller;

{$R *.dfm}

{(*General Managment}
procedure TfrmWoWGames.FormCreate(Sender: TObject);
    procedure SetUserName(brd: TBoard; uName: string);
    begin
     brd.SetUserName(uName);
    end;
var
 tabs : array[1..10] of TLabel;
 UserName: string;
begin
 pnlHangman.Align    := alClient;
 pnlWordSearch.Align := alClient;
 pnlBuildaword.Align := alClient;
 pnlFindEm.Align     := alClient;
 pnlCrossWord.Align  := alclient;
 pnlWordCity.Align   := alClient;
 pnlBuildEm.Align    := alClient;
 pnlWordRace.Align   := alClient;
 pnlAnagrams.Align   := alClient;
 pnlBreakAndBuild.Align := alClient;

 UserName := frmAccountManagment.User.GetUserName;

 HangMan    := THangman.Create(imgHangedMan, lblHangmanWord);
 WordSearch := TWordSearch.Create(srdwordSearchBoard, lsbWordSearchwords);
 BuildAWord := TBuildAWord.Create(frmWoWGames, pnlBuildAWordLetters, pnlBuildaword, srdBuildAWord);
 FindEm     := TFindEm.Create(srdFindEm, lblTimeRemaining, lblFindEmUserWord, lblFindemScore);
 CrossWord  := TCrossWord.Create(srdCrossWord, lsbCrossWordDefs);
 WordCity   := TWordCity.Create(srdWordCity, lsbWordCityWordsMade);
 BuildEm    := TBuildEm.Create(srdBuildEm, lblTimeRemaining, lblBuildEmWord, lblBuildEmScore);
 WordRace   := TWordRace.Create(pnlWordRace, lblWordRaceScore, lblWordRaceWord);
 BreakBuild := TBreakBuild.Create(pnlBreakAndBuild, lblBBMain, lblBBScore, lblBBWordsMadeFrom, lsbBBWordsMade);

 AnagramList:= TThemeButton.Create(imgAnagramHUBBack, 'Back', 'ico');
 Anagram    := TAnagram.Create(lblAnagramLetterSet, lblAnagramScore, lblAnagramLives, lblAnagramWordsMadeCount, AnagramList, edtAnagramWord, clxAnagramsWordsMade);

 FindEmCheck   := TThemeButton.Create(imgFindemCheck,   'Check', 'ico');
 FindEmClear   := TThemeButton.Create(imgFindEmClear,   'Clear', 'ico');
 BAWCheck      := TThemeButton.Create(imgBAWCheck,      'Check', 'ico');
 BAWRecall     := TThemeButton.Create(imgBAWRecall,     'Recall', 'ico');
 BAWRepick     := TThemeButton.Create(imgBAWRepick,     'Repick', 'ico');
 BAWSkipTurn   := TThemeButton.Create(imgBAWSkipTurn,   'Skip Turn', 'ico');
 CrossWordClue := TThemeButton.Create(imgCrossWordHelp, 'Check', 'ico');
 AnagramCheck  := TThemeButton.Create(imgAnagramCheck,  'Check', 'ico');
 AnagramNext   := TThemeButton.Create(imgAnagramNext,   'Next Set', 'ico');

 NewGame    := TThemeButton.Create(imgNewGame, 'New Game', 'ico');
 Logout     := TThemeButton.Create(imgLogout,  'Logout', 'ico');
 btnHelp    := TThemeButton.Create(imgHelp,    'Help', 'ico');
 Tools      := TThemeButton.Create(imgTools,   'Tools', 'ico');
 Stats      := TThemeButton.Create(imgStats,   'Stats', 'ico');
 Quit       := TThemeButton.Create(imgQuit,    'Quit', 'ico');
 Achievements := TThemeButton.Create(imgAchievements, 'Achievements', 'ico');
 btnPlayPause := TThemeButton.Create(imgPlayPause, 'Play', 'ico');

 CurrentGameTab := lblAnagrams;
 CurrentGamePnl := pnlAnagrams;
 brdGame        := Anagram;
 brdGame.OnGameOver := GameOver;
 ChangeSet(lblAnagrams.Caption);

 ScoresMoveLeft := True;
 lblHighScores.Left := 0;

 tabs[1] := lblAnagrams;
 tabs[2] := lblBreakAndBuild;
 tabs[3] := lblBuildaWord;
 tabs[4] := lblBuildEm;
 tabs[5] := lblCrossWord;
 tabs[6] := lblFindEm;
 tabs[7] := lblHangMan;
 tabs[8] := lblWordCity;
 tabs[9] := lblWordRace;
 tabs[10] := lblWordSearch;

 TabSet := TTabSet.Create(tabs, imgSelGame, lblAnagrams);
 TabSet.SetUpTabs;
 HighlightTab(frmWoWGames.CurrentGameTab, frmWoWGames.imgSelGame, frmWoWGames.tmrGameSelTab);

 SetTimers(True);
end;

procedure TfrmWoWGames.SaveGeneralSettings;
var
 GenSet: TextFile;
 sDir: string;
 i: integer;
begin
 sDir := frmAccountManagment.User.GetUserName + '.Settings';
 AssignFile(GenSet, sDir);
 Rewrite(GenSet);
 RenameFile('GenSet', sDir);

 WriteLn(GenSet, 'frmWoWGames.Tab='            + CurrentGameTab.Caption);
 WriteLn(GenSet, 'Anagram.GamePlayed='         + BoolToStr(Anagram.GamePlayed   , True));
 WriteLn(GenSet, 'Break And Build.GamePlayed=' + BoolToStr(BreakBuild.GamePlayed, True));
 WriteLn(GenSet, 'Build-A-Word.GamePlayed='    + BoolToStr(BuildAWord.GamePlayed, True));
 WriteLn(GenSet, 'Build ''Em.GamePlayed='      + BoolToStr(BuildEm.GamePlayed   , True));
 WriteLn(GenSet, 'Crossword.GamePlayed='      + BoolToStr(CrossWord.GamePlayed , True));
 WriteLn(GenSet, 'Find ''Em.GamePlayed='       + BoolToStr(FindEm.GamePlayed    , True));
 WriteLn(GenSet, 'Hangman.GamePlayed='         + BoolToStr(HangMan.GamePlayed   , True));
 WriteLn(GenSet, 'Word City.GamePlayed='       + BoolToStr(WordCity.GamePlayed  , True));
 WriteLn(GenSet, 'Word Race.GamePlayed='       + BoolToStr(WordRace.GamePlayed  , True));
 WriteLn(GenSet, 'Word Search.GamePlayed='     + BoolToStr(WordSearch.GamePlayed, True));
 WriteLn(GenSet, 'Highscores='                 + BoolToStr(pnlHighscores.Showing, True));

 WriteLn(GenSet, 'frmWoWGames.Showing='+ BoolToStr(Showing, True));
 WriteLn(GenSet, 'frmWoWGames.Left='   + IntToStr(Left));
 WriteLn(GenSet, 'frmWoWGames.Top='    + IntToStr(Top));
 WriteLn(GenSet, 'frmWoWGames.Width='  + IntToStr(Width));
 WriteLn(GenSet, 'frmWoWGames.Height=' + IntToStr(Height));

 WriteLn(GenSet, 'frmToolBox.Tab='    + frmToolBox.CurrentRef.Caption);
 WriteLn(GenSet, 'frmToolBox.Showing='+ BoolToStr(frmToolBox.Showing, True));
 WriteLn(GenSet, 'frmToolBox.Left='   + IntToStr(frmToolBox.Left));
 WriteLn(GenSet, 'frmToolBox.Top='    + IntToStr(frmToolBox.Top));
 WriteLn(GenSet, 'frmToolBox.Width='  + IntToStr(frmToolBox.Width));
 WriteLn(GenSet, 'frmToolBox.Height=' + IntToStr(frmToolBox.Height));

 WriteLn(GenSet, 'frmHighScores.Showing='+ BoolToStr(frmHighScores.Showing, True));
 WriteLn(GenSet, 'frmHighScores.Left='   + IntToStr(frmHighScores.Left));
 WriteLn(GenSet, 'frmHighScores.Top='    + IntToStr(frmHighScores.Top));
 WriteLn(GenSet, 'frmHighScores.Width='  + IntToStr(frmHighScores.Width));
 WriteLn(GenSet, 'frmHighScores.Height=' + IntToStr(frmHighScores.Height));

 WriteLn(GenSet, 'frmAchievements.Showing='+ BoolToStr(frmAchievements.Showing, True));
 WriteLn(GenSet, 'frmAchievements.Left='   + IntToStr(frmAchievements.Left));
 WriteLn(GenSet, 'frmAchievements.Top='    + IntToStr(frmAchievements.Top));
 WriteLn(GenSet, 'frmAchievements.Width='  + IntToStr(frmAchievements.Width));
 WriteLn(GenSet, 'frmAchievements.Height=' + IntToStr(frmAchievements.Height));
 for i := 0 to 5 do
  WriteLn(GenSet, 'frmAchievements.Checked=[' + IntToStr(i) + ']' + BoolToStr(frmAchievements.clxFilter.Checked[i], True));
 WriteLn(GenSet, 'frmAchievements.Vert=' + IntToStr(frmAchievements.scxAchievementsInfo.VertScrollBar.Position));

 WriteLn(GenSet, 'frmTutorial.Tab='    + IntToStr(frmTutorial.cmbTutorial.ItemIndex));
 WriteLn(GenSet, 'frmTutorial.Showing='+ BoolToStr(frmTutorial.Showing, True));
 WriteLn(GenSet, 'frmTutorial.Left='   + IntToStr(frmTutorial.Left));
 WriteLn(GenSet, 'frmTutorial.Top='    + IntToStr(frmTutorial.Top));
 WriteLn(GenSet, 'frmTutorial.Width='  + IntToStr(frmTutorial.Width));
 WriteLn(GenSet, 'frmTutorial.Height=' + IntToStr(frmTutorial.Height));
 WriteLn(GenSet, 'frmTutorial.Help='   + BoolToStr(frmTutorial.pnlHelp.Showing, True));

 CloseFile(GenSet);
end;

procedure TfrmWoWGames.CheckInScreenView(frm: TForm);
begin
 With frm do
  begin
   if Left > Screen.Width - 10
    then
     Left := Screen.Width - Width;

   if Top > Screen.Height - 10
    then
     Top := Screen.Height - Height;

   if Height > Screen.Height
    then
     Height := Screen.Height;

   if Width > Screen.Width
    then
     Width := Screen.Width;
  end;
end;

procedure TfrmWoWGames.LoadGeneralSettings;
var
 txt : TextFile;
 sLine, sVar, sDir, WoWTab, ToolTab : string;
 i: integer;
begin
 sDir := frmAccountManagment.User.GetUserName + '.Settings';
 AssignFile(txt, sDir);
 if FileExists(sDir)
  then
   Reset(txt)
  else begin
   Left   := Screen.Width  div 2 - Width  div 2;
   Top    := Screen.Height div 2 - Height div 2;
   Width  := 860;
   Height := 873;
   With frmAchievements do
    begin
     Left := screen.Width - 425;
     Top  := 25;
     Height := Constraints.MinHeight;
     Hide;
     for i := 0 to 5 do
      clxFilter.Checked[i] := True;
    end;
   With frmToolBox do
    begin
     Left   := Screen.Width  div 2 - Width  div 2;
     Top    := Screen.Height div 2 - Height div 2;
     Width  := 678;
     Height := 629;
     Hide;
    end;
   With frmHighScores do
    begin
     Left   := Screen.Width  div 2 - Width  div 2;
     Top    := Screen.Height div 2 - Height div 2;
     Width  := 860;
     Height := 617;
     Hide;
    end;
   Exit;
  end;

 While not eof(txt) do
  begin
   ReadLn(txt, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));
   if sVar = 'frmWoWGames.Tab'
    then
     WoWTab := sLine
    else
   if sVar = 'Anagram.GamePlayed'
    then
     Anagram.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Break And Build.GamePlayed'
    then
     BreakBuild.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Build-A-Word.GamePlayed'
    then
     BuildAWord.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Build ''Em.GamePlayed'
    then
     BuildEm.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Crossword.GamePlayed'
    then
     CrossWord.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Find ''Em.GamePlayed'
    then
     FindEm.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Hangman.GamePlayed'
    then
     HangMan.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Word City.GamePlayed'
    then
     WordCity.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Word Race.GamePlayed'
    then
     WordRace.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Word Search.GamePlayed'
    then
     WordSearch.GamePlayed := StrToBool(sLine)
    else
   if sVar = 'Highscores'
    then
     pnlHighscores.Visible := StrToBool(sLine)
    else                 //frmWoWGames
   if sVar = 'frmWoWGames.Showing'
    then
     Visible := StrToBool(sLine)
    else
   if sVar = 'frmWoWGames.Left'
    then
     frmWoWGames.Left := StrToInt(sLine)
    else
   if sVar = 'frmWoWGames.Top'
    then
     frmWoWGames.Top := StrToInt(sLine)
    else
   if sVar = 'frmWoWGames.Width'
    then
     frmWoWGames.Width := StrToInt(sLine)
    else
   if sVar = 'frmWoWGames.Height'
    then
     frmWoWGames.Height := StrToInt(sLine)
    else                     //frmToolBox
   if sVar = 'frmToolBox.Tab'
    then
     ToolTab := sLine
    else
   if sVar = 'frmToolBox.Showing'
    then
     frmToolBox.Visible := StrToBool(sLine)
    else
   if sVar = 'frmToolBox.Left'
    then
     frmToolBox.Left := StrToInt(sLine)
    else
   if sVar = 'frmToolBox.Top'
    then
     frmToolBox.Top := StrToInt(sLine)
    else
   if sVar = 'frmToolBox.Width'
    then
     frmToolBox.Width := StrToInt(sLine)
    else
   if sVar = 'frmToolBox.Height'
    then
     frmToolBox.Height := StrToInt(sLine)
    else                     //frmHighScores
   if sVar = 'frmHighScores.Showing'
    then
     frmHighScores.Visible := StrToBool(sLine)
    else
   if sVar = 'frmHighScores.Left'
    then
     frmHighScores.Left := StrToInt(sLine)
    else
   if sVar = 'frmHighScores.Top'
    then
     frmHighScores.Top := StrToInt(sLine)
    else
   if sVar = 'frmHighScores.Width'
    then
     frmHighScores.Width := StrToInt(sLine)
    else
   if sVar = 'frmHighScores.Height'
    then
     frmHighScores.Height := StrToInt(sLine)
    else                     //frmAchievements
   if sVar = 'frmAchievements.Showing'
    then
     frmAchievements.Visible := StrToBool(sLine)
    else
   if sVar = 'frmAchievements.Left'
    then
     frmAchievements.Left := StrToInt(sLine)
    else
   if sVar = 'frmAchievements.Top'
    then
     frmAchievements.Top := StrToInt(sLine)
    else
   if sVar = 'frmAchievements.Width'
    then
     frmAchievements.Width := StrToInt(sLine)
    else
   if sVar = 'frmAchievements.Height'
    then
     frmAchievements.Height := StrToInt(sLine)
    else
   if sVar = 'frmAchievements.Vert'
    then
     frmAchievements.scxAchievementsInfo.VertScrollBar.Position := StrToInt(sLine)
    else
   if sVar = 'frmAchievements.Checked' then
    begin
     i := StrToInt(Copy(sLine, 2, 1));
     delete(sLine, 1, 3);
     frmAchievements.clxFilter.Checked[i] := StrToBool(sLine);
    end else  //frmTutorial
   if sVar = 'frmTutorial.Showing'
    then
     frmTutorial.Visible := StrToBool(sLine)
    else
   if sVar = 'frmTutorial.Left'
    then
     frmTutorial.Left := StrToInt(sLine)
    else
   if sVar = 'frmTutorial.Top'
    then
     frmTutorial.Top := StrToInt(sLine)
    else
   if sVar = 'frmTutorial.Width'
    then
     frmTutorial.Width := StrToInt(sLine)
    else
   if sVar = 'frmTutorial.Height'
    then
     frmTutorial.Height := StrToInt(sLine)
    else
   if sVar = 'frmTutorial.Tab' then
    begin
     frmTutorial.cmbTutorial.ItemIndex := StrToInt(sLine);
     frmTutorial.cmbTutorialChange(frmTutorial.cmbTutorial);
     frmTutorial.SwitchTimers(False);
    end else
   if sVar = 'frmTutorial.Help'
    then
     frmTutorial.pnlHelp.Visible := StrToBool(sLine);
  end;

 CloseFile(txt);

 CheckInScreenView(frmWoWGames);
 CheckInScreenView(frmAchievements);
 CheckInScreenView(frmToolBox);
 CheckInScreenView(frmHighScores);
 CheckInScreenView(frmTutorial);

 if WoWTab = CurrentGame
  then
   pnlHighscores.Visible := not pnlHighscores.Visible;
 ChangeSet(WoWTab);
 TabSet.MovedTabsEnough(tmrTabsMove, pnlGames.Width, 0, CurrentGameTab, True);
 frmToolBox.ChangeRefrence(ToolTab, False);
 With frmToolBox do TabSet.MovedTabsEnough(tmrMoveTabs, pnlRefrence.Width, 0, CurrentRef, True);
end;

procedure TfrmWoWGames.FormPaint(Sender: TObject);
begin
 Anagram.Resize(pnlAnagrams, imgAnagramCheck, imgAnagramNext, pnlAnagramHUB.Width);
 HangMan.Resize(pnlHangman.Width);
 WordSearch.Resize(pnlWordSearch.Width, pnlWordSearch.Height, pnlWordSearchWords.Width);
 BuildAWord.ResizeBoard(pnlBuildaword);

 CrossWord.ResizeBoard(pnlCrossWord.Width, pnlCrossWord.Height, pnlCrossWordHUB.Width);
 imgCrossWordHelp.Left := pnlCrossWordHUB.Width div 2 - 64;
 imgCrossWordHelp.Top  := lsbCrossWordDefs.Height + lsbCrossWordDefs.Top + 8;

 FindEm.Resize(pnlFindEm);
 WordCity.Resize(pnlWordCity.Width, pnlWordCity.Height, imgWordCityHUB.Width);
 BuildEm.Resize(pnlBuildEm);
 WordRace.Resize;
 BreakBuild.Resize;
end;

procedure TfrmWoWGames.tmrGamesTimer(Sender: TObject);
var
 sTime : string;
 game  : string;
begin
 game := trim(CurrentGameTab.Caption);
 sTime := '';

 if game = 'Hangman'
  then
   sTime := HangMan.GetTimeElapsed
  else
 if game = 'Word Search'
  then
   sTime := WordSearch.GetTimeElapsed
  else
 if game = 'Build-A-Word'
  then
   BuildAWord.GetScore(lblTimeRemaining)
  else
 if game = 'Crossword'
  then
   sTime := CrossWord.GetTimeElapsed
  else
 if game = 'Find ''Em'
  then
   FindEm.GetTime(pnlMenu)
  else
 if game = 'Word City'
  then
   sTime := WordCity.GetTimeElapsed
  else
 if game = 'Build ''Em'
  then
   BuildEm.GetTime(pnlMenu)
  else
 if game = 'Anagrams' then
  begin
   lblTimeRemaining.Caption := Anagram.GetTimeElapsed;
   if edtAnagramWord.Showing and frmWoWGames.Focused
    then
     edtAnagramWord.SetFocus;
  end else
 if game = 'Break && Build'
  then
   lblTimeRemaining.Caption := BreakBuild.GetTime
  else
 if game = 'Word Race'
  then
   lblTimeRemaining.Caption := WordRace.TimeRemaining;

 lblMarginTimeR.Left := Left + Width;
 if sTime <> ''
  then
   lblTimeRemaining.Caption := sTime;
end;

procedure TfrmWoWGames.imgPlayPauseClick(Sender: TObject);
begin
  if (imgPlayPause.Tag = 1) or (not brdGame.GetHasStarted) then
  begin
   if not brdGame.GetHasStarted then
    if Sender <> nil then
    begin
     if MessageDlg('No game is being Played. Do you want to start a new game?', mtConfirmation, [mbYes, mbNo], 1) = mrYes
      then
       imgNewGameClick(nil);
     exit;
    end;
   btnPlayPause.Dir := ('Play');
   imgPlayPause.Tag := 0;
   PlayPause(False);
   if sender <> nil then frmAchievements.AchievementComplete(Take_A_break);
  end else
  if (brdGame.GetHasStarted) then
  begin
   btnPlayPause.Dir := ('Pause');
   imgPlayPause.Tag := 1;
   PlayPause(True);
  end;
end;

procedure TfrmWoWGames.ChangeSet(Game : String);
begin
 if (Game = CurrentGame) then
  begin
   pnlHighscores.Visible := not pnlHighscores.Showing;
   if not pnlHighscores.Showing
    then
     frmAchievements.AchievementComplete(Stop_The_Mockery);
  end;
 lblHighScores.Left := 0;
 CurrentGamePnl.Hide;
 CurrentGame := Game;
 CurrentGameTab.Font.Color := clSilver;
 Game := trim(Game);
 brdGame.SetGamePaused(True);

 if game = 'Anagrams' then
  begin
   brdGame        := Anagram;
   CurrentGamePnl := pnlAnagrams;
   CurrentGameTab := lblAnagrams;
  end else
 if game = 'Break && Build' then
  begin
   brdGame        := BreakBuild;
   CurrentGamePnl := pnlBreakAndBuild;
   CurrentGameTab := lblBreakAndBuild;
  end else
 if Game = 'Build-A-Word' then
  begin
   brdGame        := BuildAWord;
   CurrentGamePnl := pnlBuildaword;
   CurrentGameTab := lblBuildaWord;
  end else
 if game = 'Build ''Em' then
  begin
   brdGame        := BuildEm;
   CurrentGamePnl := pnlBuildEm;
   CurrentGameTab := lblBuildEm;
  end else
 if Game = 'Crossword' then
  begin
   brdGame        := CrossWord;
   CurrentGamePnl := pnlCrossWord;
   CurrentGameTab := lblCrossWord;
  end else
 if Game = 'Find ''Em' then
  begin
   brdGame        := FindEm;
   CurrentGamePnl := pnlFindEm;
   CurrentGameTab := lblFindEm;
  end else
 if Game = 'Hangman' then
  begin
   brdGame        := HangMan;
   CurrentGamePnl := pnlHangman;
   CurrentGameTab := lblHangMan;
  end else
 if game = 'Word City' then
  begin
   brdGame        := WordCity;
   CurrentGamePnl := pnlWordCity;
   CurrentGameTab := lblWordCity;
   pnlWordCity.Show;
   srdWordCity.SetFocus;
  end else
 if game = 'Word Race' then
  begin
   brdGame        := WordRace;
   CurrentGamePnl := pnlWordRace;
   CurrentGameTab := lblWordRace;
  end else
 if Game = 'Word Search' then
  begin
   brdGame        := WordSearch;
   CurrentGamePnl := pnlWordSearch;
   CurrentGameTab := lblWordSearch;
  end;

 brdGame.OnGameOver := GameOver;


 imgPlayPause.Tag := 1;
 imgPlayPauseClick(nil);
 lblHighScores.Caption := brdGame.GetTop10;
 CurrentGameTab.Font.Color := clWhite;

 tmrGameSelTab.Enabled := true;
 CurrentGamePnl.Show;
end;

procedure TfrmWoWGames.tmrDrawerTimer(Sender: TObject);
begin
 WordSearch.HighligthandGetWord;

 FindEm.HighLightSelectedWord;

 BuildEm.HighLightSelectedWord;
end;

procedure TfrmWoWGames.tmrGameSelTabTimer(Sender: TObject);
begin
 HighlightTab(CurrentGameTab, imgSelGame, tmrGameSelTab);
end;

procedure TfrmWoWGames.FormResize(Sender: TObject);
begin
 if WordSearch = nil then exit;

 if pnlWordSearchWords.Left < 400
  then
   pnlWordSearchWords.Width := pnlWordSearch.Width - 400;
 if WordSearch <> nil
  then
   WordSearch.Resize(pnlWordSearch.Width, pnlWordSearch.Height, pnlWordSearchWords.Width);

 if Hangman <> nil
  then
   HangMan.Resize(pnlHangman.Width);

 if BuildAWord <> nil
  then
   BuildAWord.ResizeBoard(pnlBuildaword);

 if pnlCrossWordHUB.Left < 400
  then
   pnlCrossWordHUB.Width := pnlCrossWord.Width - 400;
 imgCrossWordHelp.Left := pnlCrossWordHUB.Width div 2 - 64;
 imgCrossWordHelp.Top  := lsbCrossWordDefs.Height + lsbCrossWordDefs.Top + 8;
 if CrossWord <> nil
  then
   CrossWord.ResizeBoard(pnlCrossWord.Width, pnlCrossWord.Height, pnlCrossWordHUB.Width);

 if WordCity <> nil
  then
   WordCity.Resize(pnlWordCity.Width, pnlWordCity.Height, imgWordCityHUB.Width);
 if FindEm <> nil
  then
   FindEm.Resize(pnlFindEm);
 if BuildEm <> nil
  then
   BuildEm.Resize(pnlBuildEm);
 if pnlAnagramHUB.Left < 400
  then
   pnlAnagramHUB.Width := pnlAnagrams.Width - 400;
 if Anagram <> nil
  then
   Anagram.Resize(pnlAnagrams, imgAnagramCheck, imgAnagramNext, pnlAnagramHUB.Width);
 imgAnagramHUBBack.Left := pnlAnagramHUB.Width div 2 - imgAnagramHUBBack.Width div 2;

 if BreakBuild <> nil
  then
   BreakBuild.Resize;

 if WordRace <> nil
  then
   WordRace.Resize;

 if Assigned(CurrentGameTab)
  then
   TabSet.Resize(tmrTabsMove, pnlGames.Width);
 if CurrentGameTab.Caption <> '' then imgSelGame.Left := CurrentGameTab.Left;
 imgMenuBack.Stretch := ClientWidth > 2560;
end;

procedure TfrmWoWGames.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 if not CanClose(False) then
  begin
   CanClose(True);
   Action := caNone;
   exit;
  end;

 SetTimers(False);
 frmToolBox.tmrMoveTabs.Enabled := false;
 SaveGames;
 frmToolBox.Free;
 frmAccountManagment.Close;
end;

{Tabs}
procedure TfrmWoWGames.lblTabDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 TabSet.MouseDown(Sender, Mouse.CursorPos.X);
 tmrTabsMove.Enabled := false;
end;

procedure TfrmWoWGames.lblTabUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if not TabSet.MovedTabsEnough(tmrTabsMove, pnlGames.Width, Mouse.CursorPos.X, TLabel(Sender), false) then
  begin
   ChangeSet(TLabel(Sender).Caption);
  end;
end;

procedure TfrmWoWGames.lblTabMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 TabSet.MouseMove(Sender, tmrTabsMove, mouse.CursorPos.X);
end;

procedure TfrmWoWGames.tmrTabsMoveTimer(Sender: TObject);
begin
 TabSet.TimerMove(tmrTabsMove, pnlGames.Width);
end;
{Tabs}

{ Other Windows }
procedure TfrmWoWGames.imgLogoutClick(Sender: TObject);
begin
 frmAchievements.AchievementComplete(Checking_Out);
 frmWoWGames.SaveGames();
 brdGame.SetGamePaused(True);
 ChangePlayPause(brdGame.GetGamePaused);
 frmAccountManagment.show;
 frmWoWGames.Hide;

 frmToolBox.Hide;
 With frmToolBox do
  begin
   TabSet.MouseDown(lblDictionary, 0);
   tmrMoveTabs.Enabled := false;
   TabSet.MovedTabsEnough(tmrMoveTabs, pnlRefrence.Width, 0, TLabel(Sender), False);
   ChangeRefrence('Dictionary', False);
  end;

 frmHighScores.Hide;
 frmHighScores.CleanUp;

 frmAchievements.Hide;

 With frmTutorial do
  begin
   Hide;
   CleanUp;
   Left := Screen.Width div 2 - Width div 2;
   Top  := Screen.Height div 2 - Height div 2;
  end;

end;

procedure TfrmWoWGames.imgAchievementsClick(Sender: TObject);
begin
 frmAchievements.Show;
end;

procedure TfrmWoWGames.imgToolsClick(Sender: TObject);
begin
 frmToolBox.Show;
 frmAchievements.AchievementComplete(Handyman);
end;
{ Other Windows }

{General Managment*)}

{Game Stuff}
procedure TfrmWoWGames.imgNewGameClick(Sender: TObject);
begin
 brdGame.SetGamePaused(True);
 ChangePlayPause(brdGame.GetGamePaused);
 StartNewGame(trim(CurrentGameTab.Caption));
end;

procedure TfrmWoWGames.StartNewGame(game: string);
begin
  Application.CreateForm(TfrmGameSettings, frmGameSettings);
  GameSet := Game;
  frmGameSettings.lblHeading.Caption := Game + ' Set Up ';
  frmGameSettings.ShowModal;
end;

procedure TfrmWoWGames.ChangePlayPause(Start: boolean);
begin
 if Start
  then
   imgPlayPause.Picture.LoadFromFile('Resources/Play.ico')
  else
   imgPlayPause.Picture.LoadFromFile('Resources/Pause.ico');
end;

procedure TfrmWoWGames.PlayPause(Start : boolean);
var
 Game : string;
begin
 Game := Trim(CurrentGame);
 brdGame.SetGamePaused(not Start);
end;

procedure TfrmWoWGames.imgQuitClick(Sender: TObject);
begin
 TBoard(brdGame).Quit;
 ChangePlayPause(true);
 frmAchievements.AchievementComplete(Quiter);
end;
{Game Stuff}

{(*Word Search}
procedure TfrmWoWGames.imgWordSearchWordsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
 i : integer;
begin
 if X in [0..7]
  then
   imgWordSearchWords.Cursor := crHSplit
  else
   imgWordSearchWords.Cursor := crDefault;

 i := (width + left) - Mouse.CursorPos.X;
 if (i >= 220) and (i <= pnlWordSearch.Width - 400) and (GetAsyncKeyState(VK_LBUTTON) < 0) then
  begin
   pnlWordSearchWords.Width := i;
   WordSearch.Resize(pnlWordSearch.Width, pnlWordSearch.Height, pnlWordSearchWords.Width);
  end;
end;

procedure TfrmWoWGames.srdwordSearchBoardDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
 AlignCenterText(srdwordSearchBoard, ACol, ARow, Rect, srdwordSearchBoard.Cells[ACol, ARow]);
end;

procedure TfrmWoWGames.srdwordSearchBoardMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 
end;
{Word Search*)}

{Build a Word}
procedure TfrmWoWGames.imgBAWSkipTurnClick(Sender: TObject);
begin
 BuildAWord.SkipTurn;
end;

procedure TfrmWoWGames.imgBAWRepickClick(Sender: TObject);
begin
 BuildAWord.Repick;
end;

procedure TfrmWoWGames.imgBAWCheckClick(Sender: TObject);
begin
 if not BuildAWord.GetHasStarted then exit;
 BuildAWord.CheckWord;
end;

procedure TfrmWoWGames.imgBAWRecallClick(Sender: TObject);
begin
 BuildAWord.Recall;
end;
{Build a Word}

{Find 'Em}
procedure TfrmWoWGames.imgFindEmClearClick(Sender: TObject);
begin
 FindEm.ClearWord;
end;

procedure TfrmWoWGames.imgFindemCheckClick(Sender: TObject);
begin
 FindEm.CheckWord;
end;
{Find 'Em}

{ Crossword }
procedure TfrmWoWGames.imgCrossWordHUBBackMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
 i : integer;
begin
 if X in [0..7]
  then
   TImage(Sender).Cursor := crHSplit
  else
   TImage(Sender).Cursor := crDefault;

 i := (width + left) - Mouse.CursorPos.X;
 if (i >= 220) and (i <= pnlCrossWord.Width - 400) and (GetAsyncKeyState(VK_LBUTTON) < 0)then
  begin
   pnlCrossWordHUB.Width := i;
   CrossWord.ResizeBoard(pnlCrossWord.Width, pnlCrossWord.Height, pnlCrossWordHUB.Width);
  end;
end;

procedure TfrmWoWGames.lblSmallerCrossWordMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if lsbCrossWordDefs.Font.Size - 2 >= 10 then
  begin
   lsbCrossWordDefs.Font.Size := lsbCrossWordDefs.Font.Size - 2;
   lsbCrossWordDefs.Canvas.Rectangle(0, 0, lsbCrossWordDefs.Width, lsbCrossWordDefs.Height);
  end else
   MessageDlg('You can resize the bar by dragging it out from the left of it', mtInformation, mbOKCancel, 0);
end;

procedure TfrmWoWGames.lblLargerCrossWordMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if lsbCrossWordDefs.Font.Size + 2 <= 18 then
  begin
   lsbCrossWordDefs.Font.Size := lsbCrossWordDefs.Font.Height + 2;
   lsbCrossWordDefs.Canvas.Rectangle(0, 0, lsbCrossWordDefs.Width, lsbCrossWordDefs.Height);
  end;
end;

{ Crossword }

procedure TfrmWoWGames.imgHelpClick(Sender: TObject);
begin
 frmTutorial.Show
end;

procedure TfrmWoWGames.imgAnagramCheckClick(Sender: TObject);
begin
 Anagram.CheckWord;
 Anagram.Resize(pnlAnagrams, imgAnagramCheck, imgAnagramNext, pnlAnagramHUB.Width);
end;

procedure TfrmWoWGames.imgAnagramNextClick(Sender: TObject);
begin
 Anagram.NextWordSet;
 Anagram.Resize(pnlAnagrams, imgAnagramCheck, imgAnagramNext, pnlAnagramHUB.Width);
end;

procedure TfrmWoWGames.imgAnagramHUBBackClick(Sender: TObject);
begin
 Anagram.BackWordSet;
end;

procedure TfrmWoWGames.edtAnagramWordKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key = VK_RETURN
  then
   imgAnagramCheckClick(nil);
end;

procedure TfrmWoWGames.SaveGames();
begin
 HangMan   .SaveGame();
 CrossWord .SaveGame();
 WordSearch.SaveGame();
 WordCity  .SaveGame();
 FindEm    .SaveGame();
 BuildEm   .SaveGame();
 BuildAWord.SaveGame();
 Anagram   .SaveGame();
 BreakBuild.SaveGame();
 WordRace  .SaveGame();
 SaveGeneralSettings;
 frmAchievements.SaveAchievements(brdGame.GetUserName);
end;

procedure TfrmWoWGames.imgAnagramHUBBackgroundMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
 i : integer;
begin
 if X in [0..7]
  then
   TImage(Sender).Cursor := crHSplit
  else
   TImage(Sender).Cursor := crDefault;

 i := (width + left) - Mouse.CursorPos.X;
 if (i >= 220) and (i <= pnlAnagrams.Width - 400) and (GetAsyncKeyState(VK_LBUTTON) < 0)then
  begin
   pnlAnagramHUB.Width := i;
   Anagram.Resize(pnlAnagrams, imgAnagramCheck, imgAnagramNext, pnlAnagramHUB.Width);
   imgAnagramHUBBack.Left := pnlAnagramHUB.Width div 2 - imgAnagramHUBBack.Width div 2;
  end;
end;

procedure TfrmWoWGames.imgCrossWordHelpClick(Sender: TObject);
begin
 CrossWord.CheckBoard;
end;

procedure TfrmWoWGames.lblAnagramLetterSetMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if (Sender as TLabel).Caption = 'Press New Game'
  then
   imgNewGameClick(nil)
  else
   edtAnagramWord.Text := edtAnagramWord.Text + Anagram.GetLetter(X);
end;

procedure TfrmWoWGames.tmrHighscoresTimer(Sender: TObject);
var
 Trimmed, iPace, iMid: Integer;
begin
 if brdGame.GetTop10 <> lblHighScores.Caption
  then
   lblHighScores.Caption := brdGame.GetTop10;
 Trimmed :=  (Length(Trim(lblHighScores.Caption)) - 1) * 10;
 iMid    :=  ClientWidth div 2 - lblHighScores.Width div 2;

 if (Trimmed < ClientWidth) and (lblHighScores.Left <> iMid) then
  begin
   iPace := 7;
   if (lblHighScores.Left > iMid) then
    begin
     lblHighScores.Left := lblHighScores.Left - iPace;
     if lblHighScores.Left - iPace < iMid
      then
       lblHighScores.Left  := iMid;
    end else
    begin
     lblHighScores.Left := lblHighScores.Left + iPace;
     if lblHighScores.Left + iPace > iMid
      then
       lblHighScores.Left  := iMid;
    end;
   exit;
  end;

 iPace := 1;
 if ScoresMoveLeft then
  begin
   if (lblHighScores.Left > ClientWidth - lblHighScores.Width)
    then
     lblHighScores.Left := lblHighScores.Left - iPace
    else
     ScoresMoveLeft := false;
  end else
   if (lblHighScores.Left < 0)
    then
     lblHighScores.Left := lblHighScores.Left + iPace
    else
     ScoresMoveLeft := true;
end;

function TfrmWoWGames.CanClose(WithMessage: Boolean): Boolean;
begin
 Result := not Anagram.Running;
 if not Result and WithMessage
  then
   MessageDlg('Sorry, some technical stuff is still running, try again later in 30 secounds', mtError, [mbOK], 1);
end;

procedure TfrmWoWGames.edtHelpSearchEnter(Sender: TObject);
begin
 (Sender as Tedit).Clear;
end;

procedure TfrmWoWGames.imgTutorialClick(Sender: TObject);
begin
 frmTutorial.Show;
end;

procedure TfrmWoWGames.SetTimers(bON: Boolean);
begin
 tmrGames.Enabled := bON;
 tmrGameSelTab.Enabled := bON;
 tmrTabsMove.Enabled := bON;
 tmrDrawer.Enabled := bON;
 tmrGameTransition.Enabled := bON;
 tmrHighscores.Enabled := bON;
end;

procedure TfrmWoWGames.lblHighScoresMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 tmrHighscores.Enabled := False;
 GetCursorPos(OriginalHighScore);
 OriginalHighScore.Y := lblHighScores.Left;
end;

procedure TfrmWoWGames.lblHighScoresMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 tmrHighscores.Enabled := True;
end;

procedure TfrmWoWGames.lblHighScoresMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
 iPos: integer;
begin
 iPos := OriginalHighScore.X - (OriginalHighScore.X - OriginalHighScore.Y) + Mouse.CursorPos.X - OriginalHighScore.X;
 if not tmrHighscores.Enabled
  then
   if ( iPos > Width - lblHighScores.Width - 25) and (iPos < 0)
    then
     lblHighScores.Left := iPos

end;

procedure TfrmWoWGames.imgStatsClick(Sender: TObject);
begin
 frmHighScores.Show;
end;

procedure TfrmWoWGames.GameOver(Sender: TObject);
begin
 ChangePlayPause(True);
 if (frmHighScores.Filter.GetGameName = Trim(GameSet)) or
    (Trim(GameSet) = 'Break && Build') and (frmHighScores.Filter.GetGameName = 'Break And Build')
  then
   frmHighScores.Filter.RefreshGameList;
end;

procedure TfrmWoWGames.lblNewGameClick(Sender: TObject);
begin
 if (Sender as TLabel).Caption = 'Press New Game'
  then
   imgNewGameClick(nil);
end;

end.
