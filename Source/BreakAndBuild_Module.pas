unit BreakAndBuild_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ADODB, ComCtrls, Math, StdCtrls, ExtCtrls,
  BoardGames_Board__Module, Achievements_Module, Achievements_Controller;

type

  TBreakBuild = Class(TBoard)
   Private
    pnlHolder: TPanel;
    lblMain, lblScore, lblWordMadeFrom: TLabel;
    lsbWordsMade: TListBox;
    DeleteKeys: Array of TShape;
    InsertKeys: Array of TShape;
    WordsMade : Array of String;
    TimeRemaining: Integer;
    sWord, OriginalWord: String;

    procedure CreateDeleteKeys;
    procedure CreateInsertKeys;

    procedure DeleteLetter(Sender: TObject; Button: TMouseButton;
                            Shift: TShiftState; X, Y: Integer);
    procedure InsertLetter(Sender: TObject; Button: TMouseButton;
                            Shift: TShiftState; X, Y: Integer);

    function  GetWord: String;
    procedure LoadLSB;

    function CanInsert: Integer;
    function CanDelete: Integer;
    function canInsDel(Gradient: Integer): Boolean;
    procedure NoMoreOptions;
    procedure RemoveAllButtons;
   protected
    procedure HighScore; Override;
   Public
    Constructor Create(pnlH: TPanel; lblM, lblS, lblWMF: TLabel; lsbWM: TListBox);
    procedure   Resize;

    procedure  LoadGame; Override;
    procedure  SaveGame; Override;
    procedure  NewGame(iTime: Integer);
    function   GetTime: String;
    procedure  Quit; Override;
    procedure  ResetToDefault;
  end;

implementation

{ TBreakBuild }

function TBreakBuild.CanDelete: Integer;
    function DeleteLetter(i: integer): string;
    begin
     Result := RemoveSpaces(sWord);
     Delete(Result, i, 1);
    end;
var
 i: integer;
 sNew: string;
begin
 Result := 0;
 for i := 1 to Length(sWord) do
  begin
   sNew := DeleteLetter(i);
   if IsAWord(sNew)
    then
     inc(Result);
   if Result > 5 then exit;
  end;
end;

function TBreakBuild.canInsDel(Gradient: Integer): Boolean;
begin
 Result := CanInsert + CanDelete > Gradient;
end;

function TBreakBuild.CanInsert: Integer;
    function InsertLetter(i: integer; c: char): string;
    begin
     Result := RemoveSpaces(sWord);
     Insert(c, Result, i);
    end;

var
 i: integer;
 c: Char;
 sNew: String;
begin
 Result := 0;
 for i := 1 to Length(sWord) + 1 do
  for c := 'A' to 'Z' do
   begin
    sNew := InsertLetter(i, c);
    if IsAWord(sNew)
     then
      inc(Result);
    if Result > 5 then exit;
   end;
end;

constructor TBreakBuild.Create(pnlH: TPanel; lblM, lblS, lblWMF: TLabel;
  lsbWM: TListBox);
begin
 Inherited Create;
 SetGameName('Break And Build');
 pnlHolder := pnlH;
 lblMain   := lblM;
 lblScore  := lblS;
 lblWordMadeFrom := lblWMF;
 lsbWordsMade    := lsbWM;
 SetLength(DeleteKeys, 0);
 SetLength(InsertKeys, 0);
 State_Create(False);
end;

procedure TBreakBuild.CreateDeleteKeys;
    procedure CreateKey(iKey: Integer);
    begin
     DeleteKeys[iKey] := TShape.Create(nil);
     With DeleteKeys[iKey] do
      begin
       Parent       := pnlHolder;
       Shape        := stCircle;
       Brush.Color  := clRed;
       Pen.Color    := clWhite;
       Width        := 28;
       Height       := 28;
       Constraints.MinHeight := 10;
       Constraints.MinWidth  := 10;
       Constraints.MaxHeight := 100;
       Constraints.MaxWidth  := 100;
       Tag          := iKey + 1;
       OnMouseUp    := DeleteLetter;
      end;
    end;
var
 i: integer;
begin
 for i := 0 to High(DeleteKeys) do FreeAndNil(DeleteKeys[i]);

 for i := 1 to Length(RemoveSpaces(sWord)) do
  begin
   SetLength(DeleteKeys, i);
   CreateKey(i - 1);
  end;
end;

procedure TBreakBuild.CreateInsertKeys;
    procedure CreateKey(iKey: Integer);
    begin
     InsertKeys[iKey] := TShape.Create(nil);
     With InsertKeys[iKey] do
      begin
       Parent       := pnlHolder;
       Shape        := stCircle;
       Brush.Color  := clGreen;
       Pen.Color    := clWhite;
       Width        := 28;
       Height       := 28;
       Constraints.MinHeight := 10;
       Constraints.MinWidth  := 10;
       Constraints.MaxHeight := 100;
       Constraints.MaxWidth  := 100;
       Tag          := iKey + 1;
       OnMouseUp    := InsertLetter;
      end;
    end;
var
 i: integer;
begin
 for i := 0 to High(InsertKeys) do FreeAndNil(InsertKeys[i]);

 for i := 1 to Length(RemoveSpaces(sWord)) + 1 do
  begin
   SetLength(InsertKeys, i);
   CreateKey(i - 1);
  end;
end;

procedure TBreakBuild.DeleteLetter(Sender: TObject; Button: TMouseButton;
                            Shift: TShiftState; X, Y: Integer);
var
 s: string;
begin
 if not CanPlay(True) then exit;
 if Length(sWord) < 2 then
  begin
   Showmessage('You Should Insert a Letter');
   exit;
  end;
 s := RemoveSpaces(sWord);
 Delete(s, TShape(Sender).Tag, 1);
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [Word List] WHERE Word = "' + s + '"';
 qry.Open;
 if (qry.RecordCount <= 0) or (Length(s) < 2) then
  begin
   MessageDlg('You tried to make something that was not a word', mtError, [mbOK], 1);
   exit;
  end else
 if s = OriginalWord
  then
   exit;


 sWord := SpaceOut(s);
 lblMain.Caption := sWord;
 SetLength(WordsMade, Length(WordsMade) + 1);
 WordsMade[Length(WordsMade) - 1] := s;
 LoadLSB;
 CreateDeleteKeys;
 CreateInsertKeys;
 Resize;
 NoMoreOptions;
end;

function TBreakBuild.GetTime: String;
var
 sMin, sSec: string;
begin
 if CanPlay(False)
  then
   dec(TimeRemaining);
 Result := '00:00';

 sMin := IntToStr(TimeRemaining div 60);
 sSec := IntToStr(TimeRemaining mod 60);

 if Length(sMin) = 1
  then
   sMin := '0' + sMin;

 if Length(sSec) = 1
  then
   sSec := '0' + sSec;

 if TimeRemaining > 0
  then
   Result := sMin + ':' + sSec
  else
  if CanPlay(false) then
   begin
    Result := '00:00';
    HighScore;
   end;

end;

function TBreakBuild.GetWord: String;
begin
 Result := '';
 Repeat
   While not(Length(Result) in [4..5]) do
    Result := UpperCase(GetAWord(850, 9984));
   sWord  := '';
   sWord := SpaceOut(Result);
   Result := sWord;
 Until CanInsDel(5);
end;

procedure TBreakBuild.HighScore;
begin
 qry.Close;
 qry.SQL.Clear;
 With qry.SQL do
  begin
   Add('INSERT INTO [Break And Build]');
   Add( GetInsertFields(qry));
   Add('VALUES(');
   Add('"' + Self.GetUserName  + '", ');
   Add('"' + OriginalWord + '", ');
   Add( IntToStr(High(WordsMade) + 1) + ', ');
   Add( IntToStr(Score)               + ', ');
   Add( IntToStr(TimePlaying)         + ', ');
   Add( FloatToStr(Date)              + ')' );
  end;
 qry.ExecSQL;
 Inherited;
end;

procedure TBreakBuild.InsertLetter(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 s: string;
 sLetter: string;
begin
 if not CanPlay(True) then exit;
 if Length(sWord) < 2 then
  begin
   Showmessage('You Should Insert a Letter');
   exit;
  end;
 s := RemoveSpaces(sWord);
 sLetter := InputBox('Insert', 'Letter To Insert', '');
 if Length(sLetter) > 1 then
  begin
   MessageDlg('You can only enter one letter', mtError, [mbOK], 1);
   exit;
  end;
 Insert(sLetter, s, TShape(Sender).Tag);
 s := UpperCase(s);
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [Word List] WHERE Word = "' + s + '"';
 qry.Open;
 if (qry.RecordCount <= 0) or (Length(s) < 2) then
  begin
   MessageDlg('You tried to make a word that I don''t know about', mtError, [mbOK], 1);
   exit;
  end;

 sWord := SpaceOut(s);
 lblMain.Caption := sWord;
 if s <> OriginalWord then
  begin
   SetLength(WordsMade, Length(WordsMade) + 1);
   WordsMade[Length(WordsMade) - 1] := s;
   LoadLSB;
  end;
 CreateDeleteKeys;
 CreateInsertKeys;
 Resize;
 case Length(RemoveSpaces(sWord)) of
  6: frmAchievements.AchievementComplete(Thats_Pretty_Big);
  10: frmAchievements.AchievementComplete(Youre_Probably_Getting_Stuck);
 end;
 NoMoreOptions;
end;

procedure TBreakBuild.LoadGame;
var
 Line, Coro : string;
 txt  : TextFile;
 i : integer;
begin
 AssignFile(txt, GetGameSaveFile);
 if FileExists(GetGameSaveFile)
  then
   Reset(txt)
  else begin
   Quit;
   exit;
  end;
 While not eof(txt) do
  begin
   ReadLn(txt, Line);
   Coro := Copy(Line, 1, Pos('=', Line) - 1);
   Delete(Line, 1, Pos('=', Line));
   if coro = 'TimeRemaining'
    then
     TimeRemaining := StrToInt(Line)
    else
   if coro = 'Score'
    then
     Score := StrToInt(Line)
    else
   if coro = 'sWord'
    then
     sWord := Line
    else
   if coro = 'OriginalWord'
    then
     OriginalWord := Line
    else
   if coro = 'WordsMade' then
    begin
      i := StrToInt( Copy( Line, Pos('[', Line) + 1, Pos(']', Line) - 2 ) );
      SetLength(WordsMade, i + 1);
      Delete(Line, 1, Pos(']', Line));
      WordsMade[i] := Line;
    end;
  end;
 
 State_NewGame(true);
 lblScore.Caption := 'Score: ' + IntToStr(score);
 LoadLSB;
 lblWordMadeFrom.Caption := 'Words Made From' + #13 + '"' + OriginalWord + '"';
 lblMain.Caption := sWord;
 CreateDeleteKeys;
 CreateInsertKeys;
 Resize;

 CloseFile(txt);
end;

procedure TBreakBuild.LoadLSB;
   function WordInList(iPos: integer): boolean;
   var
    i: integer;
   begin
    Result := false;
    if iPos > 0 then
    for i := iPos - 1 downto 0 do
       if WordsMade[i] = WordsMade[iPos]
        then
         Result := True;
   end;
var
 i: integer;
begin
 Score := 0;
 lsbWordsMade.Items.Clear;
 for i := 0 to High(WordsMade) do
  if not WordInList(i) then
   begin
    Score := Score + Length(WordsMade[i]) * (i + 1);
    lsbWordsMade.Items.Add(WordsMade[i]);
   end;
 lsbWordsMade.ItemIndex := lsbWordsMade.Items.Count - 1;
 lblScore.Caption := 'Score: ' + IntToStr(score);
end;

procedure TBreakBuild.NewGame(iTime: Integer);
begin
 lblMain.Caption := GetWord;
 CreateDeleteKeys;
 CreateInsertKeys;
 TimeRemaining := iTime * 60;
 TimePlaying   := TimeRemaining;
 Resize;
 SetLength(WordsMade, 0);
 LoadLSB;
 lblWordMadeFrom.Caption := 'Words Made From' + #13 + '"' + RemoveSpaces(sWord) + '"';
 OriginalWord := RemoveSpaces(sWord);
 State_NewGame(False);
end;

procedure TBreakBuild.NoMoreOptions;
begin
 if not canInsDel(1) then
  begin
   MessageDlg('Your out of moves, so it''s Game Over', mtInformation, [mbOK], 1);
   HighScore;
   Quit;
  end;
end;

procedure TBreakBuild.Quit;
begin
  Inherited;
  ResetToDefault;
  RemoveAllButtons;
  Resize;
end;

procedure TBreakBuild.RemoveAllButtons;
var
 i: integer;
begin
 for i := 0 to High(DeleteKeys) do FreeAndNil(DeleteKeys[i]);
 for i := 0 to High(InsertKeys) do FreeAndNil(InsertKeys[i]);
 SetLength(DeleteKeys, 0);
 SetLength(InsertKeys, 0);
end;

procedure TBreakBuild.ResetToDefault;
begin
 lblMain.Caption := 'Press New Game';
 lblScore.Caption:= 'Score:';
 lblWordMadeFrom.Caption := 'Words Made From';
 TimeRemaining := 0;
 Score := 0;
 sWord := '';
 OriginalWord := '';
 lsbWordsMade.Items.Clear;
 SetLength(WordsMade, 0);
end;

procedure TBreakBuild.Resize;
var
 i: integer;
begin
 if lblMain.Width >= pnlHolder.Width - 300 then
  begin
   While lblMain.Width > pnlHolder.Width - 300 do
    begin
     lblMain.Font.Height := lblMain.Font.Height - 2;
     for i := 0 to High(DeleteKeys) do
      begin
       DeleteKeys[i].Width := DeleteKeys[i].Width - 1;
       DeleteKeys[i].Height := DeleteKeys[i].Height - 1;
      end;
     for i := 0 to High(InsertKeys) do
      begin
       InsertKeys[i].Width := InsertKeys[i].Width - 1;
       InsertKeys[i].Height := InsertKeys[i].Height - 1;
      end;
    end;
  end else
  if (lblMain.Font.Height < 90) and (lblMain.Width < pnlHolder.Width - 400) then
   While (lblMain.Width < pnlHolder.Width) and (lblMain.Font.Height < 90) do
    begin
     lblMain.Font.Height := lblMain.Font.Height + 2;
     for i := 0 to High(DeleteKeys) do
      begin
       DeleteKeys[i].Width := DeleteKeys[i].Width + 1;
       DeleteKeys[i].Height := DeleteKeys[i].Height + 1;
      end;
     for i := 0 to High(InsertKeys) do
      begin
       InsertKeys[i].Width := InsertKeys[i].Width + 1;
       InsertKeys[i].Height := InsertKeys[i].Height + 1;
      end;
    end;

 lblMain.Left   := pnlHolder.Width  div 2 - lblMain.Width  div 2 - 185 div 2;
 lblMain.Top    := pnlHolder.Height div 2 - lblMain.Height div 2;

 if Length(DeleteKeys) > 0 then
 for i := 0 to High(DeleteKeys) do
  begin
   DeleteKeys[i].Top  := lblMain.Top + lblMain.Height + 16;
   DeleteKeys[i].Left := lblMain.Left + i * GetTextDimension('AA', lblMain.Font, True) + GetTextDimension('A', lblMain.Font, True) div 4;
  end;

 if Length(InsertKeys) > 0 then
 for i := 0 to High(InsertKeys) do
  begin
   InsertKeys[i].Top  := lblMain.Top - 44;
   InsertKeys[i].Left := lblMain.Left + i * GetTextDimension('AA', lblMain.Font, True) - GetTextDimension('A', lblMain.Font, True) div 4 * 3;
  end;

end;

procedure TBreakBuild.SaveGame;
var
 GameSave : TextFile;
 i: integer;
begin
 if (not GetHasStarted) then exit;
 AssignFile(GameSave, GetGameSaveFile);
 Rewrite(GameSave);

 WriteLn(GameSave, 'OriginalWord=' + OriginalWord);
 WriteLn(GameSave, 'Score='  + IntToStr(Score));
 WriteLn(GameSave, 'sWord='  + sWord);
 WriteLn(GameSave, 'TimeRemaining=' + IntToStr(TimeRemaining));

 for i := 0 to Length(WordsMade) - 1 do
  begin
   WriteLn(GameSave, 'WordsMade=[' + IntToStr(i) + ']' + WordsMade[i]);
  end;

 CloseFile(GameSave);
end;

end.
