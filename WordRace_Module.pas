unit WordRace_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ExtCtrls, StdCtrls, HangManGame_Module, DB, Grids,
  DBGrids, ADODB, DBCtrls, Spin, WordSearch_Module, BoardGames_Board__Module,
  jpeg, Math, Sorting, Achievements_Module, Achievements_Controller;

type
  RCellDir = Record
   X, Y: integer;
   C   : Char;
  end;

  TTrack = Class
   Private
    lblSubmit, lblShuffle: TLabel;
    imgCar: TImage;
    Position: TPoint;
    CurrentWord: String;
    sHeading: string;
   Public
    srdRoad: TStringGrid;

    procedure SetCurrentWord(sWord: string);
    function  GetCurrentWord: String;
    function  GetPosition: TPoint;
    procedure Redraw(Sender: TObject);
    procedure SetPosition(X, Y: Integer);
    Constructor Create(HContainer: TWinControl; qry: TADOQuery);
  end;

  TWordRace = Class(TBoard)
   Private
    pnlHolder: TPanel;
    trkPlayer: TTrack;
    lblScore, lblWord: TLabel;
    LastValidPosition, LastPosition: TPoint;
    Letters: Array of Array of String;
    cCells : Array of Array of String;
    CurrentWordLetters: Array of TPoint;
    TakenLetters: Array of RCellDir;
    CurrentTaken: Array of RCellDir;
    OriTime, TimeLeft: Integer;

    procedure KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawCell(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState);

    procedure SubmitClick(Sender: TObject);
    procedure lblShuffleClick(Sender: TObject);
    procedure CheckWord;
    procedure PlaceLetters;
    procedure SetScore;
    procedure PutBackWrongWordLetters;
    procedure MoveCar(C, R: integer);
    procedure CarBackspace;
    procedure CreatePath;
   protected
    procedure HighScore; Override;
   Public
    Constructor Create(HContainer: TWinControl; lblS, lblW: TLabel);
    procedure   Resize;
    procedure   NewGame(sTime: String);
    function    TimeRemaining: String;
    procedure   Quit; Override;
    procedure   ResetToDefault;
    procedure   SaveGame; Override;
    procedure   LoadGame; Override;
  end;

implementation

{ TTrack }
constructor TTrack.Create(HContainer: TWinControl; qry: TADOQuery);
begin
 //Self.qry := qry;

 imgCar := TImage.Create(nil);
 With imgCar do
  begin
   Parent := nil;
   Width  := 80;
   Height := 48;
   Picture.LoadFromFile('Resources/Car Player.bmp');
  end;

 srdRoad := TStringGrid.Create(nil);
 With srdRoad do
  begin
   Parent        := HContainer;
   Options       := [];
   GridLineWidth := 0;
   FixedCols     := 0;
   FixedRows     := 0;
   RowCount      := 3;
   ColCount      := 50;
   Height        := 150;
   DefaultColWidth  := 80;
   DefaultRowHeight := 50;
   Font.Color       := clGray;
   Font.Height      := 40;
   Color            := clBlack;
  end;

 lblSubmit := TLabel.Create(nil);
 With lblSubmit do
  begin
   Parent      := HContainer;
   Transparent := True;
   Font.Color  := clWhite;
   Font.Height := 25;
   Caption     := 'Submit';
  end;

 lblShuffle := TLabel.Create(nil);
 With lblShuffle do
  begin
   Parent      := HContainer;
   Transparent := True;
   Font.Color  := clWhite;
   Font.Height := 25;
   Caption     := 'Shuffle Letters';
  end;

  SetPosition(0, 1);
end;

function TTrack.GetCurrentWord: String;
begin
 Result := CurrentWord;
end;

function TTrack.GetPosition: TPoint;
begin
 Result := Position;
end;

procedure TTrack.Redraw(Sender: TObject);
begin
 lblSubmit.Left := srdRoad.Left;
 lblSubmit.Top  := srdRoad.Top - lblSubmit.Height;

 lblShuffle.Left := srdRoad.Left + srdRoad.Width - lblShuffle.Width;
 lblShuffle.Top  := srdRoad.Top  - lblShuffle.Height;
end;

procedure TTrack.SetCurrentWord(sWord: string);
begin
 CurrentWord := sWord;
end;

procedure TTrack.SetPosition(X, Y: Integer);
begin
 Position.X  := X;
 Position.Y  := Y;
 srdRoad.Col := X;
 srdRoad.Row := Y;
end;

{ TWordRace }

procedure TWordRace.CheckWord;
    procedure AddToTakenLetters;
    var
     C, R, i: integer;
    begin
     i := 0;
     for C := 0 to trkPlayer.srdRoad.ColCount - 1 do
       for R := 0 to trkPlayer.srdRoad.RowCount - 1 do
         if trkPlayer.srdRoad.Cells[C, R] <> ''
           then
             if trkPlayer.srdRoad.Cells[C, R][1] in ['>', '^', 'v'] then
               begin
                 SetLength(TakenLetters, i + 1);
                 TakenLetters[i].X := C;
                 TakenLetters[i].Y := R;
                 TakenLetters[i].C := trkPlayer.srdRoad.Cells[C, R][1];
                 inc(i);
               end;
    end;

begin
 if not CanPlay(True) then exit;
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [Word List] WHERE Word = "' + trkPlayer.GetCurrentWord + '"';
 qry.Open;
 if qry.RecordCount > 0 then
  begin
   LastValidPosition.X := trkPlayer.GetPosition.X;
   LastValidPosition.Y := trkPlayer.GetPosition.Y;
   AddToTakenLetters;
   LastPosition.X := LastValidPosition.X;
   LastPosition.Y := LastValidPosition.Y;
   SetLength(CurrentWordLetters, 1);
   CurrentWordLetters[0].X := trkPlayer.srdRoad.Col;
   CurrentWordLetters[0].Y := trkPlayer.srdRoad.Row;
   SetScore;
   if LastValidPosition.X = trkPlayer.srdRoad.ColCount - 1
    then
     HighScore;

  end else
  With trkPlayer do
  begin
   PutBackWrongWordLetters;
   srdRoad.Refresh;
   SetPosition(LastValidPosition.X, LastValidPosition.Y);
   LastPosition.X := LastValidPosition.X;
   LastPosition.Y := LastValidPosition.Y;
   srdRoad.Refresh;
   SetLength(CurrentWordLetters, 1);
   CurrentWordLetters[0].X := trkPlayer.srdRoad.Col;
   CurrentWordLetters[0].Y := trkPlayer.srdRoad.Row;
  end;
 trkPlayer.SetCurrentWord('');
 lblWord.Caption := ' Your Word: ';
 SetLength(CurrentTaken, 0);
end;

constructor TWordRace.Create(HContainer: TWinControl; lblS, lblW: TLabel);
begin
 Inherited Create;
 SetGameName('Word Race');
 pnlHolder := TPanel(HContainer);

 trkPlayer := TTrack.Create(HContainer, qry);

 trkPlayer.srdRoad.OnKeyUp := KeyUp;
 trkPlayer.srdRoad.OnMouseDown := MouseDown;
 trkPlayer.lblShuffle.OnClick := lblShuffleClick;
 trkPlayer.lblSubmit.OnClick  := SubmitClick;
 trkPlayer.srdRoad.OnDrawCell := DrawCell;

 lblScore.Caption := ' Score: 0';
 lblWord.Caption  := ' Your Word: ';

 lblScore := lblS;
 lblWord  := lblW;
 Resize;

 State_Create(False);
end;

procedure TWordRace.KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case key of
  VK_RETURN, VK_SPACE : CheckWord;
  VK_LEFT   : MoveCar(trkPlayer.Position.X - 1, trkPlayer.Position.Y);
  VK_RIGHT  : MoveCar(trkPlayer.Position.X + 1, trkPlayer.Position.Y);
  VK_UP     : MoveCar(trkPlayer.Position.X, trkPlayer.Position.Y - 1);
  VK_DOWN   : MoveCar(trkPlayer.Position.X, trkPlayer.Position.Y + 1);
  VK_BACK   : CarBackspace;
 end;
 if key = VK_SPACE
  then
   frmAchievements.AchievementComplete(You_Read_It);
end;

procedure TWordRace.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 C, R: Integer;
begin
 trkPlayer.srdRoad.MouseToCell(X, Y, C, R);
 MoveCar(C, R);
end;

procedure TWordRace.NewGame(sTime: String);
var
 i: integer;
begin
 trkPlayer.SetPosition(0, 1);
 LastValidPosition.X := 0;
 LastValidPosition.Y := 1;
 LastPosition.X := 0;
 LastPosition.Y := 1;
 trkPlayer.SetCurrentWord('');
 Score := 0;
 SetLength(TakenLetters, 0);
 SetLength(CurrentTaken, 0);
 SetLength(CurrentWordLetters, 1);
 CurrentWordLetters[0].X := 0;
 CurrentWordLetters[0].Y := 1;
 lblScore.Caption := ' Score: 0';
 lblWord.Caption  := ' Your Word: ';

 TimeLeft := StrToInt(Copy(sTime, 1, Pos(' ', sTime) - 1)) * 60;
 OriTime := TimeLeft;

 trkPlayer.srdRoad.ColCount := 20;
 Resize;

 SetLength(cCells, trkPlayer.srdRoad.ColCount);
 for i := 0 to High(cCells) do
  SetLength(cCells[i], 3);

 CreatePath;
 PlaceLetters;

 State_NewGame(False);
end;

procedure TWordRace.Resize;
begin
 With trkPlayer.srdRoad do
  begin
   Left  := 32;
   Top   := pnlHolder.Height div 2 - Height div 2;
   Width := pnlHolder.Width  - 64;
   Height := DefaultRowHeight * RowCount + 28;
  end;
 trkPlayer.Redraw(nil);
end;

procedure TWordRace.PlaceLetters;
var
 C, R: integer;
begin
 SetLength(Letters, trkPlayer.srdRoad.ColCount);
 for C := 0 to trkPlayer.srdRoad.ColCount - 1 do
  begin
   SetLength(Letters[C], trkPlayer.srdRoad.RowCount);
   for R := 0 to trkPlayer.srdRoad.RowCount - 1 do
    begin
     trkPlayer.srdRoad.Cells[C, R] := cCells[C, R];
     Letters[C, R] := trkPlayer.srdRoad.Cells[C, R];
    end;
  end;

 for C := 0 to High(TakenLetters) do
  trkPlayer.srdRoad.Cells[TakenLetters[C].X, TakenLetters[C].Y] := TakenLetters[C].C;
end;

procedure TWordRace.SetScore;
begin
 Score := Score + Length(trkPlayer.CurrentWord) * GetWordScore(trkPlayer.GetCurrentWord);
 lblScore.Caption := ' Score: ' + IntToStr(Score);
end;

procedure TWordRace.PutBackWrongWordLetters;
var
 i: integer;
begin
 for i := 1 to High(CurrentWordLetters) do
  trkPlayer.srdRoad.Cells[CurrentWordLetters[i].X, CurrentWordLetters[i].Y] := Letters[CurrentWordLetters[i].X, CurrentWordLetters[i].Y];
 SetLength(CurrentWordLetters, 1);
end;

function TWordRace.TimeRemaining: String;
var
 sMin, sSec: string;
begin
  Result := '00:00';
  if CanPlay(False)
   then
    dec(TimeLeft);

  if (TimeLeft = 0) and CanPlay(False) then
   begin
    Quit;
    MessageDlg('Game Over. You Don''t Make The Highscore List', mtInformation, [mbOk], 1);
   end;

  sMin := IntToStr(TimeLeft div 60);
  sSec := IntToStr(TimeLeft mod 60);
  if Length(sMin) = 1
   then
    sMin := '0' + sMin;
  if Length(sSec) = 1
   then
    sSec := '0' + sSec;
  Result := sMin + ':' + sSec ;
end;

procedure TWordRace.HighScore;
begin
  qry.Close;
  With qry.SQL do
   begin
    Clear;
    Add('INSERT INTO [Word Race]');
    Add(GetInsertFields(qry));
    Add('VALUES(');
    Add('"' + GetUserName + '", ');
    Add( IntToStr(Score) + ', ');
    Add( IntToStr(OriTime - TimeLeft) + ', ');
    Add( FloatToStr(Date) + ')');
   end;
  qry.ExecSQL;
  Inherited;
end;

procedure TWordRace.Quit;
begin
  inherited;
  ResetToDefault;
end;

procedure TWordRace.lblShuffleClick(Sender: TObject);
begin
 if MessageDlg('You will lose 10 points if you continue, Do you want to continue', mtConfirmation, [mbYes, mbNo], 1) = mrNo
  then
   exit;

 if (trkPlayer.Position.X = 0) and (trkPlayer.Position.Y = 1)
  then
   frmAchievements.AchievementComplete(Really_Already);

 if Length(CurrentWordLetters) > 1 then
 With trkPlayer do
  begin
   PutBackWrongWordLetters;
   srdRoad.Refresh;
   SetPosition(LastValidPosition.X, LastValidPosition.Y);
   LastPosition.X := LastValidPosition.X;
   LastPosition.Y := LastValidPosition.Y;
   srdRoad.Refresh;
   SetLength(CurrentWordLetters, 0);
   SetLength(CurrentTaken, 0);
   SetCurrentWord('');
   lblWord.Caption := ' Your Word: ';
  end;

 CreatePath;
 PlaceLetters;

 Score := Score - 10;
 lblScore.Caption := ' Score: ' + IntToStr(Score);
end;

procedure TWordRace.LoadGame;
var
 txt : TextFile;
 sLine, sVar : string;
 R, C : integer;
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
   ReadLn(txt, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));
   if sVar = 'Position' then
    begin
     trkPlayer.Position.X := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     trkPlayer.Position.Y := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
    end else
   if sVar = 'CurrentWord'
    then
     trkPlayer.CurrentWord := sLine
    else
   if sVar = 'sHeading'
    then
     trkPlayer.sHeading := sLine
    else
   if sVar = 'LastValidPosition' then
    begin
     LastValidPosition.X := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     LastValidPosition.Y := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
    end else
   if sVar = 'LastPosition' then
    begin
     LastPosition.X := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     LastPosition.Y := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
    end else
   if sVar = 'Score'
    then
     Score := StrToInt(sLine)
    else
   if sVar = 'OriTime'
    then
     OriTime := StrToInt(sLine)
    else
   if sVar = 'TimeLeft'
    then
     TimeLeft := StrToInt(sLine)
    else
   if sVar = 'Letters' then
    begin    
     C := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     R := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
     Delete(sLine, 1, Pos(']', sLine));
     SetLength(Letters, C + 1);
     SetLength(Letters[C], R + 1);
     Letters[C, R] := sLine;
    end else
   if sVar = 'CurrentWordLetters' then
    begin
     C := StrToInt(Copy(sLine, 1, Pos('[', sLine) - 1));
     Delete(sLine, 1, Pos('[', sLine) - 1);
     SetLength(CurrentWordLetters, C + 1);
     CurrentWordLetters[C].X := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     CurrentWordLetters[C].Y := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
    end else
   if sVar = 'TakenLetters' then
    begin
     C := StrToInt(Copy(sLine, 1, Pos('[', sLine) - 1));
     Delete(sLine, 1, Pos('[', sLine) - 1);
     SetLength(TakenLetters, C + 1);
     TakenLetters[C].X := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     TakenLetters[C].Y := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
     Delete(sLine, 1, Pos(']', sLine));
     TakenLetters[C].C := sLine[1];
    end else
   if sVar = 'CurrentTaken' then
    begin
     C := StrToInt(Copy(sLine, 1, Pos('[', sLine) - 1));
     Delete(sLine, 1, Pos('[', sLine) - 1);
     SetLength(CurrentTaken, C + 1);
     CurrentTaken[C].X := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     CurrentTaken[C].Y := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
     Delete(sLine, 1, Pos(']', sLine));
     CurrentTaken[C].C := sLine[1];
    end;
  end;

 trkPlayer.srdRoad.ColCount := Length(Letters);
 Resize;
 for C := 0 to trkPlayer.srdRoad.ColCount - 1 do
  for R := 0 to trkPlayer.srdRoad.RowCount - 1 do
   trkPlayer.srdRoad.Cells[C, R] := Letters[C, R];
 for C := 0 to High(TakenLetters) do
  trkPlayer.srdRoad.Cells[TakenLetters[C].X, TakenLetters[C].Y] := TakenLetters[C].C;

 for C := 0 to High(CurrentTaken) do
  trkPlayer.srdRoad.Cells[CurrentTaken[C].X, CurrentTaken[C].Y] := CurrentTaken[C].C;

 lblScore.Caption := ' Score: ' + IntToStr(Score);
 lblWord.Caption := ' Your Word: ' + trkPlayer.CurrentWord;

 SetLength(cCells, trkPlayer.srdRoad.ColCount);
 for C := 0 to High(cCells) do
  SetLEngth(cCells[C], 3);

 State_NewGame(true);
 CloseFile(txt);
end;

procedure TWordRace.SaveGame;
var
 txt : TextFile;
 i, r : integer;
begin
 if (not GetHasStarted) then exit;
 AssignFile(txt, GetGameSaveFile);
 Rewrite(txt);

 if Length(CurrentWordLetters) > 1 then
 With trkPlayer do
  begin
   PutBackWrongWordLetters;
   srdRoad.Refresh;
   SetPosition(LastValidPosition.X, LastValidPosition.Y);
   LastPosition.X := LastValidPosition.X;
   LastPosition.Y := LastValidPosition.Y;
   srdRoad.Refresh;
   SetLength(CurrentWordLetters, 0);
   SetLength(CurrentTaken, 0);
   SetCurrentWord('');
   lblWord.Caption := ' Your Word: ';
  end;

 Writeln(txt, 'Position=[' + IntToStr(trkPlayer.Position.X) + ',' + IntToStr(trkPlayer.Position.Y) + ']');
 Writeln(txt, 'CurrentWord=' + trkPlayer.CurrentWord);
 Writeln(txt, 'sHeading=' + trkPlayer.sHeading);

 Writeln(txt, 'LastValidPosition=[' + IntToStr(LastValidPosition.X) + ',' + IntToStr(LastValidPosition.Y) + ']');
 Writeln(txt, 'LastPosition=[' + IntToStr(LastPosition.X) + ',' + IntToStr(LastPosition.Y) + ']');
 Writeln(txt, 'Score=' + IntToStr(Score));
 Writeln(txt, 'OriTime=' + IntToStr(OriTime));
 Writeln(txt, 'TimeLeft=' + IntToStr(TimeLeft));

 for i := 0 to High(Letters) do
  for r := 0 to High(Letters[i]) do
   WriteLn(txt, 'Letters=[' + IntToStr(i) + ',' + IntToStr(r) + ']' + Letters[i, r]);


 for i := 0 to High(CurrentWordLetters) do
   WriteLn(txt, 'CurrentWordLetters=' + IntToStr(i) + '[' + IntToStr(CurrentWordLetters[i].X) + ',' + IntToStr(CurrentWordLetters[i].Y) + ']');

 for i := 0 to High(TakenLetters) do
   WriteLn(txt, 'TakenLetters=' + IntToStr(i) + '[' + IntToStr(TakenLetters[i].X) + ',' + IntToStr(TakenLetters[i].Y) + ']' + TakenLetters[i].C);

 for i := 0 to High(CurrentTaken) do
   WriteLn(txt, 'CurrentTaken=' + IntToStr(i) + '[' + IntToStr(CurrentTaken[i].X) + ',' + IntToStr(CurrentTaken[i].Y) + ']' + CurrentTaken[i].C);

 CloseFile(txt);
end;

procedure TWordRace.ResetToDefault;
var
 C, R: integer;
begin
 trkPlayer.SetPosition(0, 1);
 trkPlayer.SetCurrentWord('');
 lblScore.Caption := ' Score:';
 lblWord.Caption  := ' Your Word:';
 LastValidPosition.X := 0;
 LastValidPosition.Y := 1;
 LastPosition.X := 0;
 LastPosition.Y := 1;
 SetLength(Letters, 0);
 SetLength(CurrentWordLetters, 0);
 SetLength(TakenLetters, 0);
 Score := 0;
 OriTime := 0;
 TimeLeft := 0;
 for C := 0 to trkPlayer.srdRoad.ColCount - 1 do
  for R := 0 to trkPlayer.srdRoad.RowCount - 1 do
   trkPlayer.srdRoad.Cells[C, R] := '';
end;

procedure TWordRace.SubmitClick(Sender: TObject);
begin
 CheckWord;
end;

procedure TWordRace.MoveCar(C, R: integer);
var
 LP : TPoint;

    procedure Backwards;
    begin
     if ((C = LP.X - 1) and (R = LP.Y)) then  //Left
      begin
        if trkPlayer.srdRoad.Cells[C, R] = '>'
         then
          CarBackspace;
      end else
     if ((C = LP.X) and (R = LP.Y + 1)) then  //Down
      begin
        if trkPlayer.srdRoad.Cells[C, R] = '^'
         then
          CarBackspace;
      end else
     if ((C = LP.X) and (R = LP.Y - 1)) then //Up
      begin
        if trkPlayer.srdRoad.Cells[C, R] = 'v'
         then
          CarBackspace;
      end;
    end;
begin
 if not CanPlay(True) or not(C in [0..25]) or not(R in [0..2]) then exit;
 With trkPlayer do
  begin
   LP.X := LastPosition.X;
   LP.Y := LastPosition.Y;
   if C or R = -1 then exit;
   if srdRoad.Cells[C, R] <> ''
    then
     if srdRoad.Cells[C, R][1] in ['>', '^', 'v', '+']
      then begin
       Backwards;
       exit;
      end;

   if ((C = LP.X + 1) and (R = LP.Y))
   or (((R in [LP.Y - 1..LP.Y + 1]) or (R = LP.Y + 1)) and (C = LP.X)) then
    begin
     if ((C = LP.X + 1) and (R = LP.Y))
      then
       srdRoad.Cells[LastPosition.X, LastPosition.Y] := '>'
      else
     if ((R = LP.Y + 1) and (C = LP.X))
      then
       srdRoad.Cells[LastPosition.X, LastPosition.Y] := 'v'
      else
       srdRoad.Cells[LastPosition.X, LastPosition.Y] := '^';

     LastPosition.X := C;
     LastPosition.Y := R;
    end else
    begin
     exit;
    end;

   SetCurrentWord(GetCurrentWord + srdRoad.Cells[C, R]);
   lblWord.Caption := ' Your Word: ' + GetCurrentWord;
   srdRoad.Refresh;
   SetPosition(C, R);
   srdRoad.Refresh;
   SetLength(CurrentWordLetters, Length(CurrentWordLetters) + 1);
   CurrentWordLetters[Length(CurrentWordLetters) - 1].X := C;
   CurrentWordLetters[Length(CurrentWordLetters) - 1].Y := R;
   SetLength(CurrentTaken, Length(CurrentTaken) + 1);
   CurrentTaken[Length(CurrentTaken) - 1].X := C;
   CurrentTaken[Length(CurrentTaken) - 1].Y := R;
   CurrentTaken[Length(CurrentTaken) - 1].C := srdRoad.Cells[LP.X, LP.Y][1];
  end;
end;

procedure TWordRace.CarBackspace;
var
 i: integer;
begin
 i := Length(CurrentWordLetters) - 1;
 if i < 1 then exit;
 SetLength(CurrentWordLetters, i);
 SetLength(CurrentTaken, i);
 trkPlayer.SetPosition(CurrentWordLetters[i - 1].X, CurrentWordLetters[i - 1].Y);
 LastPosition.X := CurrentWordLetters[i - 1].X;
 LastPosition.Y := CurrentWordLetters[i - 1].Y;

 trkPlayer.srdRoad.Cells[CurrentWordLetters[i - 1].X, CurrentWordLetters[i - 1].Y] :=
   Letters[CurrentWordLetters[i - 1].X, CurrentWordLetters[i - 1].Y];
 Delete(trkPlayer.CurrentWord, Length(trkPlayer.CurrentWord), 1);
 lblWord.Caption := ' Your Word: ' + trkPlayer.CurrentWord;

 trkPlayer.srdRoad.Refresh;
end;

procedure TWordRace.CreatePath;
var CurrentPosition: TPoint;

    procedure PlaceAWord;
        function CanBePlacedHere(X, Y: integer): Boolean;
        begin
          if (X in [0..High(cCells)]) and (Y in [0..High(cCells[0])])
           then
            Result := (cCells[X, Y] = '')
           else
            Result := false;
        end;

        procedure SetARandomPos;
        var
         FreePos: Array[0..2] of Boolean;
         PosIndex: Integer;
        begin
         FreePos[0] := CanBePlacedHere(CurrentPosition.X + 1, CurrentPosition.Y); //F
         FreePos[1] := CanBePlacedHere(CurrentPosition.X, CurrentPosition.Y + 1); //D
         FreePos[2] := CanBePlacedHere(CurrentPosition.X, CurrentPosition.Y - 1); //U

         if not ((FreePos[0]) or (FreePos[1]) or (FreePos[2])) then exit;

         Repeat
          PosIndex := Random(3);
         Until FreePos[PosIndex];

         Case PosIndex of
          0: Inc(CurrentPosition.X);
          1: Inc(CurrentPosition.Y);
          2: Dec(CurrentPosition.Y);
         end;
        end;
    var
     sWord: string;
     i: integer;
    begin
     tbl.Open;
     sWord := GetAWord(850, tbl.RecordCount);
     for i := 1 to Length(sWord) do
     if CurrentPosition.X < High(cCells) then
      begin
       SetARandomPos;
       cCells[CurrentPosition.X, CurrentPosition.Y] := UpCase(sWord[i]);
      end else
       exit;
    end;

    function ReachedTheEnd: boolean;
    begin
     Result := CurrentPosition.X >= High(cCells);
    end;

var
 C, R: Integer;
begin
    for C := 0 to High(cCells) do
     for R := 0 to High(cCells[C]) do
      if (C = 0) and (R = 1)
         then
          cCells[C, R] := '+'
         else
          cCells[C, R] := '';


    CurrentPosition.X := 0;
    CurrentPosition.Y := 1;

    Repeat
     PlaceAWord;
    Until ReachedTheEnd;

    for C := 0 to High(cCells) do
      for R := 0 to High(cCells[C]) do
       if (C = 0) and (R = 1)
        then
         cCells[C, R] := '+'
        else
         if cCells[C, R] = ''
          then
           cCells[C, R] := GetRandomLetter;       
end;

procedure TWordRace.DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

    procedure HighlightLetter(C, R: Integer; clr: TColor);
    begin
     if R < 0 then exit;
     With trkPlayer.srdRoad do
      begin
       Canvas.Brush.Style := bsSolid;
       Canvas.Font.Color := clr;
       Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Cells[C, R]);
       Canvas.Font.Color := clGray;
      end;
    end;

begin
 With trkPlayer do
  begin
  if not GetHasStarted
   then
    if (ACol and ARow = 0)
     then
       WaitingRoomSimple(srdRoad);
  if (srdRoad.Cells[ACol, ARow] = '') and ((ACol <> Position.X) and (ARow <> Position.Y)) then exit;

  if ((ACol = Position.X + 1) and (ARow = Position.Y)) //Foward
  or ((ACol = Position.X) and (ARow = Position.Y - 1)) //Up
  or ((ACol = Position.X) and (ARow = Position.Y + 1)) //Down
   then
    if srdRoad.Cells[ACol, ARow] <> ''
     then
      if not (srdRoad.Cells[ACol, ARow][1] in ['v', '>', '^'])
       then
        HighlightLetter(ACol, ARow, clWhite);

  if srdRoad.Cells[ACol, ARow] <> ''
   then
    if srdRoad.Cells[ACol, ARow][1] in ['v', '>', '^']
     then
      HighlightLetter(ACol, ARow, clYellow);

  if ((ACol = Position.X) and (ARow = Position.Y)) and GetHasStarted then
   With srdRoad.Canvas do
    begin
     FillRect(Rect);
     Draw(Rect.Left, Rect.Top, imgCar.Picture.Bitmap);
    end;
 end;
end;

end.
