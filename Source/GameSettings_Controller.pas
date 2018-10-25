unit GameSettings_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Spin, Game_Controller, GameSettings_Module,
  DB, ADODB, ButtonHandling_Module, BoardGames_Board__Module, Help_Module,
  Achievements_Controller, Achievements_Module;

type
  TfrmGameSettings = class(TForm)
    imgGameSetttingsBack: TImage;
    imgHeaderBar: TImage;
    lblHeading: TLabel;
    imgClose: TImage;
    tblUserNames: TADOTable;
    qryUsers: TADOQuery;
    imgStartGame: TImage;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    imgHowTo: TImage;
    procedure imgStartGameClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgCloseClick(Sender: TObject);
    procedure ReadytoMove(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NotMoving(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IsMoving(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure imgHowToClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CloseButton: TThemeButton;
    StartButton: TThemeButton;
    HowToButton: TThemeButton;
    GameSettings : TGameSettings;

    Moving : boolean;
    Origin : TPoint;
    Originfrm : TPoint;

    procedure Move;
  end;

var
  frmGameSettings: TfrmGameSettings;

implementation

uses AccountManagment_Controller, CrossWord_Module, Tutorial_Controller;

{$R *.dfm}

procedure TfrmGameSettings.imgStartGameClick(Sender: TObject);
    procedure SetUserName(brd: TBoard; uName: string);
    begin
     brd.SetUserName(uName);
    end;
var
 canstart : boolean;
 u1, u2, u3, u4, UserName : string;
begin
 canstart := true;
 UserName := frmAccountManagment.User.GetUserName;
 SetUserName(frmWoWGames.brdGame, UserName);
 if GameSettings.GamePlaying = 'Hangman' then
   begin
    with frmWoWGames do
     THangmanSettings(GameSettings).StartGame(HangMan, qryGameWords, imgHangedMan, lblHangmanWord)
   end else
 if GameSettings.GamePlaying = 'Build-A-Word' then
  with TBuildAWordSettings(GameSettings) do
   begin
    u1 := currentUser;
    SetUserNames(u2, u3, u4);
    if TBuildAWordSettings(GameSettings).StartNewGame(qryUsers)
     then
      frmWoWGames.BuildAWord.NewGame(frmWoWGames.pnlBuildaword, u1, u2, u3, u4, cmbMode.ItemIndex)
     else
      canstart := false;
   end else
 if GameSettings.GamePlaying = 'Word Search' then
  with TWordSearchSettings(GameSettings) do
   begin
    frmWoWGames.WordSearch.NewGame(sedDimensions.Value, sedTotalWords.Value, frmWoWGames.pnlWordSearch.Width, frmWoWGames.pnlWordSearch.Height, frmWoWGames.pnlWordSearchWords.Width, sedMinLetters.Value, sedMaxLetters.Value);
    frmWoWGames.WordSearch.GetWords(frmWoWGames.lsbWordSearchwords.Items);
   end else
 if GameSettings.GamePlaying = 'Find ''Em' then
  With TFindEmSettings(GameSettings) do
   begin
    frmWoWGames.FindEm.NewGame(cmbMode.Items[cmbMode.ItemIndex], Time, ScoreToReach, WordLimit, sedDimensions.Value);
    frmWoWGames.FindEm.Resize(frmWoWGames.pnlFindEm);
   end else
 if GameSettings.GamePlaying = 'Crossword' then
  With TCrossWordSettings(GameSettings) do
   begin
    if GameName <> ''
     then begin
      frmWoWGames.CrossWord.NewGame(frmWoWGames.lsbCrossWordDefs.Items, GameName);
      frmWoWGames.pnlCrossWordHUB.Width := frmWoWGames.CrossWord.AutoSizeWidth;
      frmWoWGames.lsbCrossWordDefs.Font.Size := frmWoWGames.CrossWord.AutoSizeFont;
     end else
      canstart := false;
    With frmWoWGames do
     CrossWord.ResizeBoard(pnlCrossWord.Width, pnlCrossWord.Height, pnlCrossWordHUB.Width);
   end else
 if GameSettings.GamePlaying = 'Word City' then
  With frmWoWGames do
   begin
    WordCity.NewGame(TWordCitySettings(GameSettings).sedTarget.Value);
   end else
 if GameSettings.GamePlaying = 'Build ''Em' then
  With TFindEmSettings(GameSettings) do
   begin
    frmWoWGames.BuildEm.NewGame(cmbMode.Items[cmbMode.ItemIndex], Time, ScoreToReach, WordLimit, sedDimensions.Value);
    frmWoWGames.BuildEm.Resize(frmWoWGames.pnlBuildEm);
   end else
 if GameSettings.GamePlaying = 'Anagrams' then
  With TAnagramSettings(GameSettings) do
   begin
    frmWoWGames.Anagram.NewGame(sedDifficulty.Value);
    With frmWoWGames do
     Anagram.Resize(pnlAnagrams, imgAnagramCheck, imgAnagramNext, pnlAnagramHUB.Width);
   end else
 if GameSettings.GamePlaying = 'Break && Build' then
  begin
   frmWoWGames.BreakBuild.NewGame(TBreakBuildSettings(GameSettings).sedTime.Value);
  end else
 if GameSettings.GamePlaying = 'Word Race' then
  With TWordRace(GameSettings) do
   begin
    frmWoWGames.WordRace.NewGame(cmbTime.Items[cmbTime.ItemIndex]);
   end;


 if canstart then
  begin
   frmWoWGames.imgPlayPause.Tag := 0;
   frmWoWGames.imgPlayPauseClick(nil);
   frmAchievements.AchievementComplete(And_So_It_Begins);
   GameSettings.Free;
   frmGameSettings.Close;
  end;
end;

procedure TfrmGameSettings.FormShow(Sender: TObject);
begin
 if frmWoWGames.GameSet = 'Hangman'
  then
   GameSettings := THangmanSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Build-A-Word'
  then
   GameSettings := TBuildAWordSettings.Create(frmGameSettings, tblUserNames, frmAccountManagment.User.GetUserName)
  else
 if frmWoWGames.GameSet = 'Word Search'
  then
   GameSettings := TWordSearchSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Find ''Em'
  then
   GameSettings := TFindEmSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Crossword'
  then
   GameSettings := TCrossWordSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Word City'
  then
   GameSettings := TWordCitySettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Build ''Em'
  then
   GameSettings := TBuildEmSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Anagrams'
  then
   GameSettings := TAnagramSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Break && Build'
  then
   GameSettings := TBreakBuildSettings.Create(frmGameSettings)
  else
 if frmWoWGames.GameSet = 'Word Race'
  then
   GameSettings := TWordRace.Create(frmGameSettings);

 if Assigned(GameSettings)
  then
   GameSettings.GamePlaying := frmWoWGames.GameSet;

 lblHeading.Left := ClientWidth div 2 - lblHeading.Width div 2;

 if not frmWoWGames.brdGame.GamePlayed then imgHowToClick(nil);
end;

procedure TfrmGameSettings.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfrmGameSettings.imgCloseClick(Sender: TObject);
var
 action : TCloseAction;
begin
 frmAchievements.AchievementComplete(Never_Mind);
 action := caFree;
 FormClose(frmGameSettings, action);
 frmGameSettings.Close;
end;

procedure TfrmGameSettings.Move;
begin
 Left := Origin.X - (Origin.X - Originfrm.X) + Mouse.CursorPos.X - Origin.X;
 Top  := Origin.Y - (Origin.Y - Originfrm.Y) + Mouse.CursorPos.Y - Origin.Y;
end;

procedure TfrmGameSettings.ReadytoMove(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Moving := true;
 GetCursorPos(Origin);
 Originfrm.X := Left;
 Originfrm.Y := Top;
end;

procedure TfrmGameSettings.NotMoving(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Moving := false;
end;

procedure TfrmGameSettings.IsMoving(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if Moving
  then
   Move;
end;

procedure TfrmGameSettings.FormCreate(Sender: TObject);
begin
 CloseButton := TThemeButton.Create(imgClose, 'Close', 'ico');
 StartButton := TThemeButton.Create(imgStartGame, 'Start Game', 'ico');
 HowToButton := TThemeButton.Create(imgHowTo, 'HowTo', 'ico');
end;

procedure TfrmGameSettings.imgHowToClick(Sender: TObject);
begin
 if Sender <> nil then frmAchievements.AchievementComplete(Worth_A_Reread);
 if frmWoWGames.GameSet <> 'Break && Build'
  then
   Showmessage(GetContent(frmWoWGames.GameSet))
  else
   Showmessage(GetContent('Break And Build')); 
end;

end.
