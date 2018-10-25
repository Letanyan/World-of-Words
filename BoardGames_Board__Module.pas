unit BoardGames_Board__Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ADODB, ComCtrls, Math, StdCtrls, ExtCtrls, Spin,
  Achievements_Module, Achievements_Controller;

const
  LetterValues : Array['A'..'Z'] of Integer =  //Used For Scoring
   (
     1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10
   );

   DatabaseConnection = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=PAT.mdb;Persist Security Info=False';

   GameList: Array[0..9] of String = ('Anagrams', 'Break And Build', 'Build-A-Word',
                                      'Build ''Em', 'Crossword', 'Find ''Em',
                                      'Hangman', 'Word City', 'Word Race', 'Word Search');

type
  TBoard = class
   Private
     HasStarted  : Boolean;
     ShowingAnswers : boolean;
     CanShowAnswers : boolean;
     GamePaused  : Boolean;
     NewGameTheme: byte;
     fGameName: String;
     UserName: string;
     FGamePlayed: Boolean;
     FOnGameOver: TNotifyEvent;
     DT: TDateTime;
   Protected
     TimePlaying : Integer;
     qry: TADOQuery;
     tbl: TADOTAble;
     Score: Integer;

     function GetAWord: String; Overload;
     function GetAWord(iStart, iEnd: integer): String; Overload;
     function IsAWord(sWord: string): Boolean;

     procedure State_Create(ShowAnswer: Boolean);
     procedure State_NewGame(IsLoad: Boolean);

     function GetInsertFields(qry: TADOQuery): string;

     function UntilFit(srd: TStringGrid; s: string): Integer;
     function GetTextDimension(s : string; Font : TFont; Width : boolean) : integer; Overload;
     function GetTextDimension(s : string; Size : Integer; Width : boolean) : integer; Overload;
     function RandomLetter : char;
     function DisplayTime : string;
     function GetTimeSecs : string;
     procedure LockDrawing(c: TWinControl; bLock: Boolean);
     procedure Draw3DBorder(srd : TStringGrid; ACol, ARow : integer);
     function  ChangeWidthcmb(const cmb : TComboBox) : integer;
     procedure WaitingRoom(var Board: TStringGrid);
     procedure WaitingRoomSimple(var Board: TStringGrid);
     function  RemoveSpaces(sWord: string): string;
     function  SpaceOut(sWord: string): string;
     function  GetWordScore(s: string): Integer;
     procedure Highscore; Overload; Virtual;
   Public
     Constructor Create; Overload; Virtual;
     property OnGameOver: TNotifyEvent Read FOnGameOver Write FOnGameOver;

     function GetTimeElapsed : String; Virtual;
     function GetTop10: string;
     function CanPlay(WithMessage: Boolean) : boolean;

     procedure SetUserName(uName: string);
     function  GetUserName: string;
     function  GetHasStarted: boolean;
     procedure SetGamePaused(PauseGame: boolean);  Virtual;
     function  GetGamePaused: boolean;
     function  GetShowingAnswers: boolean;
     procedure SetGameName(sGameName: string);
     function  GetGameName: String;
     function  GetGameSaveFile: string;
     procedure LoadGame; Virtual; abstract;
     procedure SaveGame; Virtual; Abstract;
     procedure NewGame; Overload; Virtual;
     procedure Quit; Virtual;
     property  GamePlayed: Boolean read FGamePlayed Write FGamePlayed;

     procedure OpenQuery(sQuery: string);
     function GetTimePlayedForGame(sGame: string): Integer;
     function GetTimePlayedForAll: Integer;
     function GetScoreForGame(sGame: string): Integer;
     function GetScoreForAll: Integer;
     function GetGamesPlayedForGame(sGame: string): Integer;
     function GetGamesPlayedForAll: Integer;

     procedure SetDT;
     procedure GetDT;
  end;

  procedure AlignCenterText(var srd : TStringGrid; col, row : integer; rect : TRect; letter : string);
  function GetRandomLetter : char;
  function PointInArray(Pnt: TPoint; Points: Array of TPoint): integer; Overload;
  function PointInArray(X, Y: integer; Points: Array of TPoint): integer; Overload;
  function GetPlace(i: integer): string;

implementation

function GetPlace(i: integer): string;
begin
 case i of
  1: result := '1st';
  2: Result := '2nd';
  3: Result := '3rd';
  else Result := IntToStr(i) + 'th';
 end;
end;

{ TBoard }

procedure AlignCenterText(var srd: TStringGrid; col, row: integer;
  rect: TRect; letter: string);
begin
 SetTextAlign(srd.Canvas.Handle, TA_CENTER);
 srd.Canvas.TextRect(Rect, Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Top + (Rect.Bottom - Rect.Top) div 6, Letter);
 SetTextAlign(srd.Canvas.Handle, TA_LEFT);
end;

function TBoard.CanPlay(WithMessage: Boolean): boolean;
begin
 if WithMessage then
 if ShowingAnswers
  then
   MessageDlg('Showing Answers' + #13 + 'To Start Again Press' + #13 + 'New Game', mtError, [mbOK], 0)
  else
 if not HasStarted
  then
   MessageDlg('No Game is being Played' + #13 + 'To Start Again Press' + #13 + 'New Game', mtError, [mbOK], 0)
  else
 if GamePaused
  then
   MessageDlg('Game is Paused' + #13 + 'To Continue Playing Press' + #13 + 'Play (Top Right)', mtInformation, [mbOK], 0);

 Result := HasStarted and Not GamePaused and not ShowingAnswers;
end;

function TBoard.ChangeWidthcmb(const cmb: TComboBox): integer;
var
 i  : integer;
 nw : integer;
begin
 Result := cmb.Width;
 for i := 0 to cmb.Items.Count -1 do
  begin
   nw := length(cmb.Items[i]) * 7 + 12;
   if nw > Result then Result := nw;
  end;
end;

function TBoard.DisplayTime: string;
    function SecToMinSec : String;
    var
     min, sec : string;
    begin
     min := IntToStr(TimePlaying div 60);
     sec := IntToStr(TimePlaying mod 60);
     if length(min) = 1
      then
       min := '0' + min;
     if length(sec) = 1
      then
       sec := '0' + sec;
     Result := min + ':' + sec;
    end;
begin
 if (TimePlaying <> 0)
  then
   Result := SecToMinSec
  else
   Result := '00:00';
 if not HasStarted then Result := '00:00';  
end;

procedure TBoard.Draw3DBorder(srd: TStringGrid; ACol, ARow: integer);
var
 X1, X2, Y1, Y2 : integer;
begin
 X1 := ACol * srd.DefaultColWidth;
 X2 := (ACol + 1) * srd.DefaultColWidth;
 Y1 := ARow * srd.DefaultRowHeight;
 Y2 := (ARow + 1) * srd.DefaultRowHeight;

 srd.Canvas.Brush.Color := clWhite;
 srd.Canvas.Pen  .Color := clWhite;
 srd.Canvas.Rectangle(X1, Y1, X2, Y1 + 1);
 srd.Canvas.Rectangle(X1, Y1, X1 + 1, Y2);
  
 srd.Canvas.Brush.Color := clBlack;
 srd.Canvas.Pen  .Color := clBlack;
 srd.Canvas.Rectangle(X1, Y2, X2, Y2 - 1);
 srd.Canvas.Rectangle(X2, Y1, X2 - 1, Y2);
end;

function TBoard.GetHasStarted: boolean;
begin
 Result := HasStarted;
end;

function TBoard.GetTimeElapsed: String;
begin
 if CanPlay(False)
  then
   inc(TimePlaying);
 Result := DisplayTime;
end;

function TBoard.GetTimeSecs: string;
begin
 Result := IntToStr(TimePlaying);
end;

procedure TBoard.LockDrawing(c: TWinControl; bLock: Boolean);
begin
  if (c = nil) or (c.Handle = 0) then Exit;
  if bLock then
    SendMessage(c.Handle, WM_SETREDRAW, 0, 0)
  else
  begin
    SendMessage(c.Handle, WM_SETREDRAW, 1, 0);
    RedrawWindow(c.Handle, nil, 0,
      RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
  end;
end;

procedure TBoard.SetGamePaused(PauseGame: boolean);
begin
 GamePaused := PauseGame;
end;

procedure TBoard.Quit;
begin
 Randomize;
 HasStarted := false;
 GamePaused := True;
 TimePlaying := 0;
 ShowingAnswers := CanShowAnswers;
 NewGameTheme := Random(6);
 if FileExists(GetGameSaveFile)
  then
   DeleteFile(GetGameSaveFile);
end;

function TBoard.RandomLetter: char;
begin
 Randomize;
 Result := ' ';
 Case Random(99) of
  0..8   : Result := 'A';
  9..10  : Result := 'B';
  11..12 : Result := 'C';
  13..16 : Result := 'D';
  17..28 : Result := 'E';
  29..30 : Result := 'F';
  31..33 : Result := 'G';
  34..35 : Result := 'H';
  36..44 : Result := 'I';
  45     : Result := 'J';
  46     : Result := 'K';
  47..50 : Result := 'L';
  51..52 : Result := 'M';
  53..58 : Result := 'N';
  59..66 : Result := 'O';
  67..68 : Result := 'P';
  69     : Result := 'Q';
  70..75 : Result := 'R';
  76..79 : Result := 'S';
  80..85 : Result := 'T';
  86..89 : Result := 'U';
  90..91 : Result := 'V';
  92..93 : Result := 'W';
  94     : Result := 'X';
  95..96 : Result := 'Y';
  97..98 : Result := 'Z';
 end;
end;

function GetRandomLetter : char;
begin
 Randomize;
 Result := ' ';
 Case Random(99) of
  0..8   : Result := 'A';
  9..10  : Result := 'B';
  11..12 : Result := 'C';
  13..16 : Result := 'D';
  17..28 : Result := 'E';
  29..30 : Result := 'F';
  31..33 : Result := 'G';
  34..35 : Result := 'H';
  36..44 : Result := 'I';
  45     : Result := 'J';
  46     : Result := 'K';
  47..50 : Result := 'L';
  51..52 : Result := 'M';
  53..58 : Result := 'N';
  59..66 : Result := 'O';
  67..68 : Result := 'P';
  69     : Result := 'Q';
  70..75 : Result := 'R';
  76..79 : Result := 'S';
  80..85 : Result := 'T';
  86..89 : Result := 'U';
  90..91 : Result := 'V';
  92..93 : Result := 'W';
  94     : Result := 'X';
  95..96 : Result := 'Y';
  97..98 : Result := 'Z';
 end;
end;

function PointInArray(Pnt: TPoint; Points: Array of TPoint): integer;
var
 i: integer;
begin
 Result := -1;
 for i:= 0 to High(Points) do
  if (Pnt.X = Points[i].X) and (Pnt.Y = Points[i].Y) then
   begin
    Result := i;
    Exit;
   end;
end;

function PointInArray(X, Y: integer; Points: Array of TPoint): integer;
var
 i: integer;
begin
 Result := -1;
 for i:= 0 to High(Points) do
  if (X = Points[i].X) and (Y = Points[i].Y) then
   begin
    Result := i;
    Exit;
   end;
end;

procedure TBoard.State_Create(ShowAnswer: Boolean);
begin
 Randomize;
 HasStarted := false;
 GamePaused := true;
 CanShowAnswers := ShowAnswer;
 ShowingAnswers := false;
 NewGameTheme := Random(6);
end;

procedure TBoard.State_NewGame(IsLoad: boolean);
begin
 HasStarted := true;
 GamePaused := IsLoad;
 ShowingAnswers := false;
 GamePlayed := True;
end;

function TBoard.UntilFit(srd: TStringGrid; s: string): Integer;
begin
 Result := 100;
 While GetTextDimension(s, Result, True) > srd.Width - 16 do dec(Result);
end;

procedure TBoard.WaitingRoom(var Board: TStringGrid);
var
 AnimationColor : byte;
 OldStyle: TBrushStyle;
 sMessage: String;
begin
 if ShowingAnswers then exit;

  (* Random Cell Letters *)
  OldStyle := Board.Canvas.Brush.Style;

   Board.Canvas.Font.Size := RandomRange(12, Board.DefaultColWidth div Trunc(Board.ColCount * 1.4) + 12);
   AnimationColor := Random(256);
   Board.Canvas.Font.Color := RGB(AnimationColor, AnimationColor, AnimationColor);

   Board.Canvas.Brush.Style := bsClear;
   Board.Canvas.TextOut(Random(Board.Width), Random(Board.Height), RandomLetter);

   case NewGameTheme of
    0: Board.Canvas.Font.Color := RGB(AnimationColor, 0, 0); //Red
    1: Board.Canvas.Font.Color := RGB(0, AnimationColor, 0); //Green
    2: Board.Canvas.Font.Color := RGB(0, 0, AnimationColor); //Blue
    3: Board.Canvas.Font.Color := RGB(AnimationColor, AnimationColor, 0); //Yellow
    4: Board.Canvas.Font.Color := RGB(AnimationColor, 0, AnimationColor); //Purple
    5: Board.Canvas.Font.Color := RGB(0, AnimationColor, AnimationColor); //Teal
   end;
   sMessage := 'Press New Game';
   Board.Canvas.Font.Size := UntilFit(Board, sMessage);
   Board.Canvas.TextOut( Board.Width  div 2 - GetTextDimension(sMessage, Board.Canvas.Font.Size, True) div 2,
                         Board.Height div 2 - GetTextDimension(sMessage, Board.Canvas.Font.Size, False) div 2,
                         sMessage
   );

   Board.Canvas.Brush.Style := OldStyle;

end;


procedure TBoard.WaitingRoomSimple(var Board: TStringGrid);
var
 AnimationColor : byte;
 OldStyle: TBrushStyle;
 sMessage: String;
 BackColor: Byte;
begin
 if ShowingAnswers then exit;

  (* Random Cell Letters *)
  OldStyle := Board.Canvas.Brush.Style;

   Board.Canvas.Font.Size := RandomRange(12, Board.DefaultColWidth div Trunc(Board.ColCount * 1.4) + 12);
   AnimationColor := Random(256);
   Board.Canvas.Font.Color := RGB(AnimationColor, AnimationColor, AnimationColor);

   Board.Canvas.Brush.Style := bsClear;

   if Board.Color = clBlack
    then
     BackColor := 255
    else
     BackColor := 0;

   case NewGameTheme of
    0: Board.Canvas.Font.Color := RGB(AnimationColor, BackColor, BackColor); //Red
    1: Board.Canvas.Font.Color := RGB(BackColor, AnimationColor, BackColor); //Green
    2: Board.Canvas.Font.Color := RGB(BackColor, BackColor, AnimationColor); //Blue
    3: Board.Canvas.Font.Color := RGB(AnimationColor, AnimationColor, BackColor); //Yellow
    4: Board.Canvas.Font.Color := RGB(AnimationColor, BackColor, AnimationColor); //Purple
    5: Board.Canvas.Font.Color := RGB(BackColor, AnimationColor, AnimationColor); //Teal
   end;
   sMessage := 'Press New Game';
   Board.Canvas.Font.Size := UntilFit(Board, sMessage);
   Board.Canvas.TextOut( Board.Width  div 2 - GetTextDimension(sMessage, Board.Canvas.Font.Size, True) div 2,
                         Board.Height div 2 - GetTextDimension(sMessage, Board.Canvas.Font.Size, False) div 2,
                         sMessage
   );

   Board.Canvas.Brush.Style := OldStyle;
end;

function TBoard.GetGamePaused: boolean;
begin
 Result := GamePaused;
end;

function TBoard.GetShowingAnswers: boolean;
begin
 Result := ShowingAnswers;
end;

function TBoard.GetTextDimension(s: string; Font: TFont;
  Width: boolean): integer;
var
 cnvs : TBitmap;
begin
 Try
  cnvs := TBitmap.Create;
  cnvs.Canvas.Font.Name := Font.Name;
  cnvs.Canvas.Font.Size := Font.Size;
  cnvs.Canvas.TextOut(0, 0, s);
  if width
   then
    Result := cnvs.Canvas.TextWidth(s)
   else
    Result := cnvs.Canvas.TextHeight(s);
 Finally
  freeAndNil(cnvs);
 end;
end;

function TBoard.GetTextDimension(s: string; Size: Integer;
  Width: boolean): integer;
var
 cnvs : TBitmap;
begin
 Try
  cnvs := TBitmap.Create;
  cnvs.Canvas.Font.Size := Size;
  cnvs.Canvas.TextOut(0, 0, s);
  if width
   then
    Result := cnvs.Canvas.TextWidth(s)
   else
    Result := cnvs.Canvas.TextHeight(s);
 Finally
  freeAndNil(cnvs);
 end;
end;

function TBoard.GetGameName: String;
begin
 Result := fGameName;
end;

procedure TBoard.SetGameName(sGameName: string);
begin
 fGameName := trim(sGameName);
end;

function TBoard.RemoveSpaces(sWord: string): string;
begin
 Result := trim(sWord);
 While Pos(' ', Result) > 0 do
  delete(Result, Pos(' ', Result), 1);
end;

function TBoard.SpaceOut(sWord: string): string;
var
 i: integer;
begin
 Result  := sWord;
 i := 1;
 While i < Length(Result) do
  begin
   Insert(' ', Result, i + 1);
   inc(i, 2);
  end;
end;

procedure TBoard.SetUserName(uName: string);
begin
 UserName := UpperCase(uName);
end;

function TBoard.GetUserName: string;
begin
 Result := UserName;
end;

function TBoard.GetWordScore(s: string): Integer;
var
 i: integer;
begin
 Result := 0;
 for i := 1 to Length(s) do
  Result := Result + LetterValues[UpCase(s[i])];
end;

function TBoard.GetGameSaveFile: string;
begin
 Result := GetUserName + '-' + GetGameName + '.GameSave';
end;

function TBoard.GetInsertFields(qry: TADOQuery): string;
var
 strings: TStringList;
 i: integer;
 sBackup: string;
begin
 try
   strings := TStringList.Create;
   sBackup := qry.SQL.Text;
   qry.Close;
   qry.SQL.Text := 'SELECT * FROM [' + GetGameName + ']';
   qry.Open;
   qry.GetFieldNames(strings);
   Result := '(';
   for i := 0 to strings.Count - 1 do
    Result := Result + ',[' + strings[i] + ']';
   Result := Result + ')';
   Delete(Result, 2, 1);
   Delete(Result, 2, Pos(',', Result) - 1);
   qry.Close;
   qry.SQL.Text := sBackup;
 finally
  FreeAndNil(strings);
 end;
end;

constructor TBoard.Create;
begin
 tbl := TADOTable.Create(nil);
 tbl.ConnectionString := DatabaseConnection;
 tbl.TableName := 'Word List';

 qry := TADOQuery.Create(nil);
 qry.ConnectionString := DatabaseConnection;
end;

function TBoard.GetAWord: String;
begin
 Randomize;
 tbl.Open;
 tbl.RecNo := Random(tbl.RecordCount);
 Result := tbl.FieldValues['Word'];
 tbl.Close;
end;

function TBoard.GetAWord(iStart, iEnd: integer): String;
begin
 Randomize;
 tbl.Open;
 tbl.RecNo := RandomRange(iStart, iEnd);
 Result := tbl.FieldValues['Word'];
 tbl.Close;
end;

function TBoard.IsAWord(sWord: string): Boolean;
begin
 With qry do
  begin
   Close;
   SQL.Text := 'SELECT Word FROM [Word List] WHERE Word = "' + sWord + '"';
   Open;
   Result := RecordCount > 0;
  end;
end;

procedure TBoard.GetDT;
begin
 Showmessage(FormatDateTime('nn:ss:zz', Now - DT));
end;

procedure TBoard.setDT;
begin
 DT := Now;
end;

procedure TBoard.NewGame;
var
 i: integer;
begin
 State_NewGame(False);
 for i := 0 to 9 do
  if GetTimePlayedForGame(GameList[i]) = 0 then
   exit;
 frmAchievements.AchievementComplete(World_Traveler);
end;

function TBoard.GetTop10: string;
var
 i: integer;
begin
 if GetGameName = '' then exit;
 qry.Close;
 qry.SQL.Text := 'SELECT TOP 10 [User Name], [Score] FROM [' + GetGameName + '] ORDER BY Score DESC';
 qry.Open;
 if qry.RecordCount = 0 then
  begin
   Result := 'HighScores';
   exit;
  end;
 for i := 1 to 10 do
  begin
   if i > qry.RecordCount then break;
   qry.RecNo := i;
   Result := Result + '      ' + IntToStr(i) + '. ' + qry.Fields[0].Text + ' - ' + qry.Fields[1].Text;
  end;
 Result := '      Highscores:' + Result + '      ';
end;

procedure TBoard.OpenQuery(sQuery: string);
begin
 With qry do
  begin
   qry.Close;
   qry.SQL.Text := sQuery;
   qry.Open;
  end;
end;

function TBoard.GetGamesPlayedForAll: Integer;
var
 i: integer;
begin
 Result := 0;
 for i := 0 to 9 do
  begin
   OpenQuery('SELECT * FROM [' + GameList[i] + '] WHERE [User Name] = "' + GetUserName + '"');
   Result := Result + qry.RecordCount;
  end;
end;

function TBoard.GetGamesPlayedForGame(sGame: string): Integer;
begin
 OpenQuery('SELECT * FROM [' + sGame + ']');
 Result := qry.RecordCount;
end;

function TBoard.GetScoreForAll: Integer;
var
 i, k: integer;
 r: real;
begin
 Result := 0;
 for i := 0 to 9 do
  begin
   OpenQuery('SELECT [User Name], SUM(Score) ' +
             'FROM [' + GameList[i] + '] ' +
             'WHERE [User Name] = "' + GetUserName + '" ' +
             'GROUP BY [User Name] '
             );
   val(qry.Fields[1].Text, r, k);
   Result := Result + Trunc(r);
  end;
end;

function TBoard.GetScoreForGame(sGame: string): Integer;
var
 r: real;
 k: integer;
begin
 OpenQuery(  'SELECT [User Name], SUM(Score) ' +
             'FROM [' + sGame + '] ' +
             'WHERE [User Name] = "' + GetUserName + '" ' +
             'GROUP BY [User Name] '
             );
 val(qry.Fields[1].Text, r, k);
 Result := Trunc(r);
end;

function TBoard.GetTimePlayedForAll: Integer;
var
 i, k: integer;
 r: real;
begin
 Result := 0;
 for i := 0 to 9 do
  begin
   OpenQuery('SELECT [User Name], SUM(Time) ' +
             'FROM [' + GameList[i] + '] ' +
             'WHERE [User Name] = "' + GetUserName + '" ' +
             'GROUP BY [User Name] '
             );
   val(qry.Fields[1].Text, r, k);
   Result := Result + Trunc(r);
  end;
end;

function TBoard.GetTimePlayedForGame(sGame: string): Integer;
var
 r: real;
 k: integer;
begin
 OpenQuery(  'SELECT [User Name], SUM(Time) ' +
             'FROM [' + sGame + '] ' +
             'WHERE [User Name] = "' + GetUserName + '" ' +
             'GROUP BY [User Name] '
             );
  val(qry.Fields[1].Text, r, k);
   Result := Trunc(r);
end;

procedure TBoard.Highscore;
var
 iScore, i: Integer;
begin
 if Assigned(OnGameOver)
  then
   OnGameOver(Self);

 if GetTimePlayedForAll = 60 * 60
  then
   frmAchievements.AchievementComplete(One_Hour_And_Counting)
  else
 if GetTimePlayedForAll = 60 * 60 * 24
  then
   frmAchievements.AchievementComplete(One_Day_And_Counting)
  else
 if GetTimePlayedForAll = 60 * 60 * 24 * 7
  then
   frmAchievements.AchievementComplete(One_Week_And_Counting);

 iScore:= Score;
 qry.Close;
 qry.SQL.Text := 'SELECT Score FROM [' + GetGameName + '] ORDER BY Score DESC';
 qry.Open;
 Quit;
 i := 0;
 if qry.RecordCount > 1
  then
 While qry.RecNo < qry.RecordCount do
  begin
   inc(i);
   qry.RecNo := i;
   if iScore > StrToInt(qry.FieldList[0].Text) then
    begin
     Showmessage(GetUserName + ' you placed ' + GetPlace(qry.RecNo - 1) + ' with a score of ' + IntToStr(iScore));
     exit;
    end;
  end;

 if qry.RecordCount = 1
  then
   Showmessage(GetUserName + ' you placed 1st with a score of ' + IntToStr(iScore))
  else
   Showmessage(GetUserName + ' you placed Last with a score of ' + IntToStr(iScore));
end;

end.
