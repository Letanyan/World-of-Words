unit Achievements_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Achievements_Module, Menus, CheckLst,
  ButtonHandling_Module;

type
  TfrmAchievements = class(TForm)
    scxAchievementsInfo: TScrollBox;
    pnlHeader: TPanel;
    imgHeader: TImage;
    lblHeader: TLabel;
    imgBackground: TImage;
    clxFilter: TCheckListBox;
    imgFilter: TImage;
    imgClose: TImage;
    pnlResize: TPanel;
    imgResize: TImage;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBL: TPanel;
    pnlBR: TPanel;
    pnlBottom: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure clxFilterClickCheck(Sender: TObject);
    procedure imgFilterClick(Sender: TObject);
    procedure isMoving(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoingMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure NotMoving(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgResizeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UserName: string;
    AchievementTiles: Array of TAchievementTile;
    Ready: Boolean;
    btnClose: TThemeButton;
    btnFilter: TThemeButton;

    Moving : boolean;
    Origin : TPoint;
    Originfrm : TPoint;

    procedure AchievementComplete(aAchievement: String);
    function  GetAchievementAddress(aAchievement: string): integer;
    procedure SaveAchievements(sUserName: string);
    procedure LoadAchievements(sUserName: string);
    procedure CreateAchievementTiles;
    procedure FilterAchievementTiles;
    procedure Move;
  end;

var
  frmAchievements: TfrmAchievements;

implementation

{$R *.dfm}

procedure TfrmAchievements.AchievementComplete(aAchievement: String);
var
 i: integer;
begin
 for i := 0 to High(AchievementTiles) do
  if UpperCase(AchievementTiles[i].Heading) = UpperCase(aAchievement) then
   begin
    if AchievementTiles[i].Complete then exit;
    AchievementTiles[i].Complete := True;
    Show;
    scxAchievementsInfo.VertScrollBar.Position := i * 65;
    AchievementTiles[i].JustCompleted;
   end else
    AchievementTiles[i].Complete := AchievementTiles[i].Complete;
end;

procedure TfrmAchievements.CreateAchievementTiles;
var
 txt: TextFile;
 i: integer;
 lLevel: TLevel;
 sHeading, sDescription, sLevel, sLine: string;
begin
 AssignFile(txt, 'ACHIEVEMENTS.txt');
 if FileExists('ACHIEVEMENTS.txt')
  then
   Reset(txt)
  else
   exit;

 SetLength(AchievementTiles, 0);
 i := 0;
 While not eof(txt) do
  begin
   ReadLn(txt, sLine);

   sLevel := Copy(sLine, 1, Pos(',', sLine) - 1);
   Delete(sLine, 1, Pos(',', sLine));

   if sLevel = 'Gold'
    then
     lLevel := Gold
    else
   if sLevel = 'Silver'
    then
     lLevel := Silver
    else
     lLevel := Bronze;

   sHeading := Copy(sLine, 1, Pos(',', sLine) - 1);
   Delete(sLine, 1, Pos(',', sLine));

   sDescription := sLine;

   SetLength(AchievementTiles, i + 1);
   AchievementTiles[i] := TAchievementTile.Create(scxAchievementsInfo, lLevel, sHeading, sDescription);
   inc(i);
  end;

  CloseFile(txt);
  Ready := True;
end;

procedure TfrmAchievements.FormCreate(Sender: TObject);
var
 i: integer;
begin
 btnFilter := TThemeButton.Create(imgFilter, 'Filter', 'ico');
 btnClose  := TThemeButton.Create(imgClose, 'Close', 'ico');
 Constraints.MinHeight := 126;

 for i := 0 to 5 do
  clxFilter.Checked[i] := True;
 CreateAchievementTiles;
end;

function TfrmAchievements.GetAchievementAddress(
  aAchievement: string): integer;
var
 i: integer;
begin
 Result := -1;
 for i := 0 to High(AchievementTiles) do
  if aAchievement = AchievementTiles[i].Heading then
   begin
    Result := i;
    Exit;
   end;
end;

procedure TfrmAchievements.LoadAchievements(sUserName: string);
var
 txt: TextFile;
 sLine, sVar: string;
 i: integer;
begin
 UserName := sUserName;
 AssignFile(txt, sUserName + '.Achievements');
 if FileExists(sUserName + '.Achievements')
  then
   Reset(txt)
  else begin
   for i := 0 to High(AchievementTiles) do
    AchievementTiles[i].Complete := False;
   exit;
  end;

 while not Eof(txt) do
  begin
   ReadLn(txt, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));
   if GetAchievementAddress(sVar) > -1
    then
     AchievementTiles[GetAchievementAddress(sVar)].Complete := StrToBool(sLine);
  end;
  
 CloseFile(txt);
end;

procedure TfrmAchievements.SaveAchievements(sUserName: string);
var
 i: integer;
 txt: TextFile;
 IsShowing: boolean;
begin
 IsShowing := Showing;
 if not Showing then Show;
 
 AssignFile(txt, sUserName + '.Achievements');
 Rewrite(txt);
 RenameFile('txt', sUserName + '.Achievements');

 for i := 0 to High(AchievementTiles) do
   WriteLn(txt, AchievementTiles[i].Heading + '=' + BoolToStr(AchievementTiles[i].Complete, True));

 if not IsShowing then Hide;
 CloseFile(txt);
end;

procedure TfrmAchievements.FilterAchievementTiles;
var
 i: integer;
begin
 for i := 0 to High(AchievementTiles) do
  AchievementTiles[i].Hide;

 for i := High(AchievementTiles) downto 0 do
  begin
   if (clxFilter.Checked[0])
    then
   if (AchievementTiles[i].Level = Bronze) and not(AchievementTiles[i].Complete)
    then
     AchievementTiles[i].Show;

   if (clxFilter.Checked[1])
    then
   if (AchievementTiles[i].Level = Silver) and not(AchievementTiles[i].Complete)
    then
     AchievementTiles[i].Show;

   if (clxFilter.Checked[2])
    then
   if (AchievementTiles[i].Level = Gold) and not(AchievementTiles[i].Complete)
    then
     AchievementTiles[i].Show;

   if (clxFilter.Checked[3])
    then
   if (AchievementTiles[i].Level = Bronze) and (AchievementTiles[i].Complete)
    then
     AchievementTiles[i].Show;

   if (clxFilter.Checked[4])
    then
   if (AchievementTiles[i].Level = Silver) and (AchievementTiles[i].Complete)
    then
     AchievementTiles[i].Show;

   if (clxFilter.Checked[5])
    then
   if (AchievementTiles[i].Level = Gold) and (AchievementTiles[i].Complete)
    then
     AchievementTiles[i].Show;
  end;
end;

procedure TfrmAchievements.clxFilterClickCheck(Sender: TObject);
begin
 FilterAchievementTiles;
end;

procedure TfrmAchievements.imgFilterClick(Sender: TObject);
begin
 clxFilter.Visible := not clxFilter.Visible;
 if clxFilter.Visible
  then
   Height := Height + 65
  else
   Height := Height - 65;
end;

procedure TfrmAchievements.isMoving(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 GetCursorPos(Origin);
 Moving      := true;
 Originfrm.X := Left;
 Originfrm.Y := Top;
end;

procedure TfrmAchievements.DoingMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 if Moving then Move;
end;

procedure TfrmAchievements.NotMoving(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Moving := false;
end;

procedure TfrmAchievements.Move;
begin
 Left := Origin.X - (Origin.X - Originfrm.X) + Mouse.CursorPos.X - Origin.X;
 Top  := Origin.Y - (Origin.Y - Originfrm.Y) + Mouse.CursorPos.Y - Origin.Y;
end;

procedure TfrmAchievements.imgResizeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 if GetAsyncKeyState(VK_LBUTTON) < 0
  then
   Height := Mouse.CursorPos.Y - Top; 
end;

procedure TfrmAchievements.imgCloseClick(Sender: TObject);
begin
 close;
end;

end.
