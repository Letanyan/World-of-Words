unit CrossWord_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Spin, BoardGames_Board__Module,
  DB, Grids, WordSearch_Module, ADODB, math, Achievements_Controller, Achievements_Module;

type
  TStartPoint = record
   X, Y: Integer;
   Cap: String;
  end;

  TCrossWord = Class(TBoard)
   Private
    NameofGame : String;
    ClueBox : TListBox;
    Board : TStringGrid;
    Letters : Array of array of String;
    DPoints, APoints : array of TStartPoint;
    Checks: Integer;

    Direction: Char;
    Pathway: Array of TPoint;
    WrongLetters: Array of TPoint;

    procedure BoardKeyPress(sender : TObject; var key : char);
    procedure BoardKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure BoardMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    
    procedure ClueBoxClick(sender : TObject);

    procedure BuildBoard(List : TStrings; theme : string);
    Procedure WriteToBoard(table : string);
    Function  GetTemplate(theme : string) : String;
    Procedure GetClues(List : TStrings; clues : string);
    procedure GetPoints;

    function  Alpha2Num(letter : char) : integer;
    function  PointInArrayTStart(X, Y: integer; Points: Array of TStartPoint): Integer;

    function isOnVoid(C, R: integer; CR: boolean): boolean;
    procedure SetDirection;
    procedure SetPathway;
    procedure SetWrongLetters(CheckBlank: Boolean);
    procedure GiveUp;
    function GetLongestWord(H: integer): Integer;
   protected
    procedure HighScore; Override;
   Public
    Constructor Create(srd : TStringGrid; lsb : TListBox);

    function AutoSizeWidth: Integer;
    function AutoSizeFont: Integer;
    procedure NewGame(List : TStrings; theme: string);
    procedure CheckBoard;
    procedure ResizeBoard(w, h, e: Integer);
    procedure Quit; Override;
    procedure ResetToDefault;
    procedure SaveGame; Override;
    procedure LoadGame; Override;

  end;

implementation

{ TCrossWord }

constructor TCrossWord.Create;
begin
 Inherited Create;
 SetGameName('Crossword');
 Board   := srd;
 Board.OnKeyPress := BoardKeyPress;
 Board.OnKeyUp    := BoardKeyup;
 Board.OnMouseUp  := BoardMouseUp;
 Board.OnDrawCell := BoardOnDrawCell;
 Board.DoubleBuffered := true;
 ClueBox := lsb;
 ClueBox.OnClick := ClueBoxClick;
 SetLength(WrongLetters, 0);
 SetLength(Pathway, 0);

 State_Create(True);
end;

function TCrossWord.GetTemplate(theme : string) : string;
var
 txt       : TextFile;
 textLine  : String;
 OverGame  : boolean;
begin
 AssignFile(txt, 'Templates.crswrd');
 if FileExists('Templates.crswrd')
  then
   Reset(txt)
  else
   exit;

 Result := '';
 OverGame := false;
 While not eof(txt) do
  begin
   ReadLn(txt, textLine);
   if textLine = '-' + theme
    then
     OverGame := true
    else
   if textLine <> ''
    then
     if (textLine[1] = '-') and (OverGame = true)
      then
       break;

   if OverGame then
    Result := Result + #13 +  textLine;
  end;
end;

procedure TCrossWord.WriteToBoard(table: string);
var
 C, R : integer;
 letter : String;
begin
 SetLength(Letters, Board.ColCount);
 for C := 0 to Board.ColCount - 1 do
  SetLength(Letters[C], Board.RowCount);

 for R := 0 to Board.RowCount - 1 do
  for C := 0 to Board.ColCount - 1 do
   begin
    letter := Copy(table, Pos('[', table) + 1, 1);
    Letters[C, R] := letter;
    Delete(table, 1, Pos(']', table));
    if letter = ' '
     then
      Board.Cells[C, R] := ' ';
   end;
end;

procedure TCrossWord.GetClues(List: TStrings; clues : string);
var
 i : integer;
 clue : string;
begin
 List.Clear;
 for i := 1 to length(Clues) do
  begin
   clue := '';
   clue := Copy(clues, 1, Pos(#13, clues) - 1);
   List.Add(clue);
   delete(Clues, 1, Pos(#13, clues));
   if Pos(#13, clues) = 0 then break;
  end;
end;

procedure TCrossWord.BuildBoard(List : TStrings; theme: string);
var
 template   : String;
 ACol, ARow : Integer;
 Table      : String;
 Clues      : string;
begin
 for ACol := 0 to Board.ColCount - 1 do
  for ARow := 0 to Board.RowCount - 1 do
   Board.Cells[ACol, ARow] := '';

 template :=  GetTemplate(theme);
 
 Delete(template, 1, Pos('^', template));
 ACol := StrToInt(Copy(template, Pos('C', template) + 1, Pos('R', template) - 2));
 Delete(template, 1, Pos('R', template));
 ARow := StrToInt(Copy(template, 1, Pos('^', template) - 1));
 Delete(template, 1, Pos('0', template) - 1);

 Board.ColCount := ACol;
 Board.RowCount := ARow;

 Table := Copy(template, 1, Pos('.', template) - 1);
 Delete(template, 1, Pos('(', template) - 1);

 Clues := Copy(template, 1, Pos('.', template));

 WriteToBoard(table);
 GetClues(List, Clues);
 GetPoints;
end;

procedure TCrossWord.ResizeBoard(w, h, e: Integer);
var
 wsBoard : integer;
begin
 w := w - 16;
 h := h - 16;
 wsBoard    := Min(w - e, h);
 With Board do
  begin
    DefaultColWidth  := wsBoard div ColCount - 2;
    DefaultRowHeight := wsBoard div ColCount - 2;

    Width  := DefaultColWidth  * ColCount + 5;
    Height := DefaultRowHeight * rowCount + 5;

    Left   := w div 2 - Width  div 2 + 8 - e div 2;
    Top    := h div 2 - Height div 2 + 8;

    Font.Size        := wsBoard div (ColCount + Trunc(ColCount * 1.4));
  end;
end;

procedure TCrossWord.BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

   procedure DrawWrongOrCorrectLetter(clr: TColor);
   begin
    Board.Canvas.Pen.Color := clr;
    Board.Canvas.Brush.Style := bsClear;
    Board.Canvas.Pen.Width := 3;
    InflateRect(Rect, -2, -2);
    Board.Canvas.Rectangle(Rect);
   end;

   procedure DrawBlock(Fill: boolean);
   begin
    Board.Canvas.Brush.Color := clBlack;
    Board.Canvas.Pen.Color := clBlack;
    Board.Canvas.Pen.Width := 1;
    if Fill
     then
      Board.Canvas.Brush.Style := bsSolid
     else
      Board.Canvas.Brush.Style := bsClear;

    Board.Canvas.Rectangle(Rect);
   end;

   procedure DrawPathStep;
   begin
    Board.Canvas.Pen.Color := clBlue;
    Board.Canvas.Brush.Style := bsClear;
    Board.Canvas.Pen.Width := 1;
    InflateRect(Rect, -Board.DefaultColWidth div 8, -Board.DefaultColWidth div 8);
    Board.Canvas.Ellipse(Rect);
   end;

   procedure DrawPathStepOn;
   var
    D: integer;
    Letter: string;
   begin
    D := Board.DefaultColWidth;
    Letter := Board.Cells[ACol, ARow];
    Board.Canvas.Pen.Color := clBlue;
    Board.Canvas.Brush.Style := bsSolid;
    Board.Canvas.Pen.Width := 2;
    InflateRect(Rect, -Board.DefaultColWidth div 32, -Board.DefaultColWidth div 32);
    Board.Canvas.Ellipse(Rect);
    Board.Canvas.Font.Size := Board.Canvas.Font.Size + 3;
    SetTextAlign(Board.Canvas.Handle, TA_CENTER);
    With Board.Canvas do
      TextOut(ACol * D + D div 2, ARow * D + D div 2 - TextHeight(Letter) div 2, Letter);
    SetTextAlign(Board.Canvas.Handle, TA_LEFT);
    Board.Canvas.Font.Size := Board.Canvas.Font.Size - 3;
   end;

   procedure DrawStartLetter(Points: Array of TStartPoint);
   var
    FontSize: Integer;
   begin
    FontSize := Board.canvas.Font.Size;
    With Board.Canvas do
     begin
      Font.Size := Board.DefaultColWidth div 9;
      Font.Color := clBlack;
      Brush.Color := clWhite;
      Pen.Color := clBlack;
      TextOut(rect.Left + 2, Rect.Top + 2, Points[PointInArrayTStart(ACol, ARow, Points)].Cap);
     end;
    Board.Canvas.Font.Size := FontSize;
   end;

begin
 if not GetHasStarted then
  if (ACol = Board.ColCount - 1) and (ARow = Board.RowCount - 1)
   then
    WaitingRoomSimple(Board);

 AlignCenterText(Board, ACol, ARow, Rect, Board.Cells[ACol, ARow]);

 if GetHasStarted or GetShowingAnswers then DrawBlock(Board.Cells[ACol, ARow] = ' ');

 if PointInArrayTStart(ACol, ARow, APoints) > -1
  then
   DrawStartLetter(APoints)
  else
 if PointInArrayTStart(ACol, ARow, DPoints) > -1
  then
   DrawStartLetter(DPoints);

 if PointInArray(ACol, ARow, WrongLetters) > -1
  then
   DrawWrongOrCorrectLetter(clRed)
  else
   if GetShowingAnswers
    then
     if Board.Cells[ACol, ARow] <> ' '
      then
       DrawWrongOrCorrectLetter(clGreen);


 if not isOnVoid(ACol, ARow, True)
  then
 if (ACol = Board.Col) and (ARow = Board.Row)
  then
   DrawPathStepOn
  else
 if PointInArray(ACol, ARow, Pathway)  > -1
  then
   DrawPathStep;
end;

procedure TCrossWord.GetPoints;
var
 isdown : boolean;
 i, k : integer;
 sline : string;
begin
 isdown := false;
 k := 1;
 for i := 1 to ClueBox.Items.Count - 1 do
  begin
   sline := ClueBox.Items[i];
   if sline = '(Down)' then
    begin
     k := 1;
     isdown := true;
     Continue;
    end;

   if isdown then
    begin
     SetLength(DPoints, k + 1);
     DPoints[k].X := StrToInt(sline[1]) - 1;
     DPoints[k].Y := Alpha2Num(sline[2]) - 1;
     DPoints[k].Cap := sLine[1] + sLine[2];
     inc(k);
    end else
    begin
     SetLength(APoints, k + 1);
     APoints[k].X := StrToInt(sline[1]) - 1;
     APoints[k].Y := Alpha2Num(sline[2]) - 1;
     APoints[k].Cap := sLine[1] + sLine[2];
     inc(k);
    end;
  end;
end;

function TCrossWord.isOnVoid(C, R: integer; CR: boolean): boolean;   //CR true if Using Col and Row else X and Y
begin
 Result := True;
 if CR then
  begin
   if (C or R = -1) or (C > Board.ColCount - 1) or (R > Board.RowCount - 1)
    then
     exit;
  end else
   if (C or R < 0) or (Board.MouseCoord(C, R).X > Board.ColCount - 1) or (Board.MouseCoord(C, R).Y > Board.RowCount - 1)
    then
     exit;

 if not GetHasStarted
  then
   exit
  else
 if CR
  then
   Result := Letters[C, R] = ' '
  else
 if not (Board.MouseCoord(C, R).X or Board.MouseCoord(C, R).Y > 0)
  then
   Result := Letters[Board.MouseCoord(C, R).X, Board.MouseCoord(C, R).Y] = ' '
end;

procedure TCrossWord.BoardKeyPress(sender: TObject; var key: char);
begin
 key := UpCase(key);
 if not CanPlay(True) or not (key in ['A'..'Z']) then exit;

 Board.Cells[Board.Col, Board.Row] := key;

 if Direction = 'A' then
  begin
   if not isOnVoid(Board.Col + 1, Board.Row, True)
    then
     Board.Col := Board.Col + 1;
  end else
 if Direction = 'D' then
  begin
   if not isOnVoid(Board.Col, Board.Row + 1, True)
    then
     Board.Row := Board.Row + 1;
  end;
end;

procedure TCrossWord.ClueBoxClick(sender: TObject);

    function AcrossWord(Start : integer) : Boolean;
    var
     i : integer;
    begin
     Result := False;
     for i := Start to ClueBox.Items.Count - 1 do
      if ClueBox.Items[i] = '(Down)'
       then
        result := True;
    end;

begin
 if (ClueBox.Items[ClueBox.ItemIndex] = '(Down)') or (ClueBox.Items[ClueBox.ItemIndex] = '(Across)')
  then
   Exit;

 if CanPlay(False) then SetLength(WrongLetters, 0);
 Board.Col := StrToInt(ClueBox.Items[ClueBox.ItemIndex][1]) - 1;
 Board.Row := Alpha2Num(ClueBox.Items[ClueBox.ItemIndex][2]) - 1;
 SetDirection;
 Board.Refresh;
 Board.SetFocus;
end;

procedure TCrossWord.BoardKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if PointInArray(Board.Col, Board.Row, Pathway) = -1 then
  begin
    SetLength(Pathway, 0);
    Direction := ' ';
  end;
  Board.Refresh;

 if isOnVoid(Board.Col, Board.Row, True) or not CanPlay(False) then exit;
 if CanPlay(False) then SetLength(WrongLetters, 0);
 Board.Refresh;

 if key = VK_BACK then
  begin
   if Board.Cells[Board.Col, Board.Row] <> ''
    then
     Board.Cells[Board.Col, Board.Row] := ''
    else begin
     case Direction of
      'A' : if Board.Col - 1 > -1 then Board.Col := Board.Col - 1;
      'D' : if Board.Row - 1 > -1 then Board.Row := Board.Row - 1;
     end;
     Board.Cells[Board.Col, Board.Row] := '';
    end;
  end;
end;

procedure TCrossWord.HighScore;
begin
 Score := Trunc((1/TimePlaying) * 10000) + Trunc(1 / (Checks + 1) * 100);
 with qry do
  begin
   Close;
   SQL.Clear;
   with SQL do
    begin
     Add('INSERT INTO [Crossword]');
     Add( GetInsertFields(qry));
     Add('VALUES(');
     Add('"' + GetUserName    + '", ');
     Add(IntToStr(Score) + ', ');
     Add(IntToStr(Checks + 1) + ', ');
     Add(GetTimeSecs + ' ,"');
     Add(NameofGame     + '", ');
     Add(FloatToStr(Date) + ')');
    end;
   ExecSQL;
  end;
 Inherited;
end;

procedure TCrossWord.NewGame(List: TStrings; theme: string);
begin
 Board.Font.Color := clBlack;
 TimePlaying := 0;
 BuildBoard(List, theme);
 NameofGame := theme;
 Checks := -1;
 Score := 0;
 SetLength(WrongLetters, 0);
 SetLength(Pathway, 0);
 State_NewGame(false);
end;

procedure TCrossWord.GiveUp;
var
 C, R : integer;
begin
 SetWrongLetters(True);
 if Assigned(Letters) then
 for R := 0 to Board.RowCount - 1 do
  for C := 0 to Board.ColCount - 1 do
   Board.Cells[C, R] := Letters[C, R];
end;

procedure TCrossWord.BoardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if PointInArray(Board.Col, Board.Row, Pathway) = -1 then
  if (PointInArrayTStart(Board.Col, Board.Row, APoints) > -1)
    or (PointInArrayTStart(Board.Col, Board.Row, DPoints) > -1) then
  begin
   SetDirection;
  end else
  begin
   SetLength(Pathway, 0);
   Direction := ' ';
   Board.Refresh;
  end;
 if CanPlay(False) then SetLength(WrongLetters, 0);
 Board.Refresh;
end;

function TCrossWord.Alpha2Num(letter: char): integer;
var
 i : integer;
 c : char;
begin
 i := 0;
 Result := 0;

 for c := 'A' to 'Z' do
  begin
   inc(i);
   if c = letter
    then
     Result := i;
  end;
end;

procedure TCrossWord.Quit;
begin
  inherited;
  GiveUp;
end;

procedure TCrossWord.ResetToDefault;
var
 C, R : Integer;
begin
 NameofGame := '';
 ClueBox.Items.Clear;
 Checks := -1;
 SetLength(Letters, 0);
 SetLength(DPoints, 0);
 SetLength(APoints, 0);
 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   Board.Cells[C, R] := '';
end;

procedure TCrossWord.LoadGame;
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
   ResetToDefault;
   State_Create(True);
   exit;
  end;
 ClueBox.Items.Clear;
 While not eof(txt) do
  begin
   ReadLn(txt, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));
   if sVar = 'NameofGame'
    then begin
     NameofGame := sLine;
     BuildBoard(ClueBox.Items, NameofGame);
    end else
   if sVar = 'TimePlaying'
    then
     TimePlaying := StrToInt(sLine)
    else
   if sVar = 'Score'
    then
     Score := StrToInt(sLine)
    else
   if sVar = 'Checks'
    then
     Checks := StrToInt(sLine)
    else     
   if sVar = '$' then
    begin
     C := StrToInt(Copy(sLine, 2, Pos(',', sLine) - 2));
     Delete(sLine, 1, Pos(',', sLine));
     R := StrToInt(Copy(sLine, 1, Pos(']', sLine) - 1));
     Delete(sLine, 1, Pos(']', sLine));
     Board.Cells[C, R] := sLine;
    end;
  end;

 State_NewGame(true);
 CloseFile(txt);
end;

procedure TCrossWord.SaveGame;
var
 txt : TextFile;
 i, C, R: integer;
begin
 if (not GetHasStarted) then exit;
 AssignFile(txt, GetGameSaveFile);
 Rewrite(txt);

 WriteLn(txt, 'NameofGame=' + NameofGame);
 WriteLn(txt, 'TimePlaying=' + IntToStr(TimePlaying));
 WriteLn(txt, 'Score=' + IntToStr(Score));
 WriteLn(txt, 'Checks=' + IntToStr(Checks));

 for i := 0 to ClueBox.Items.Count - 1 do
  WriteLn(txt, 'ClueBox=' + ClueBox.Items[i]);

 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   WriteLn(txt, 'Letters=[' + IntToStr(C) + ',' + InttoStr(R) + ']' + Letters[C, R]);

 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   WriteLn(txt, '$=[' + IntToStr(C) + ',' + InttoStr(R) + ']' + Board.Cells[C, R]);

 CloseFile(txt);
end;

procedure TCrossWord.SetDirection;
begin
 Direction := ' ';
 if PointInArrayTStart(Board.Col, Board.Row, APoints) > -1
  then
   Direction := 'A';

 if PointInArrayTStart(Board.Col, Board.Row, DPoints) > -1
  then
   if Direction = ' '
    then
     Direction := 'D'
    else
     if Direction = 'A'
      then
       Direction := 'B';

 SetPathway;
end;

procedure TCrossWord.SetPathway;
var
 C, R: integer;
begin
 C := Board.Col;
 R := Board.Row;
 if C or R = -1 then exit;

 SetLength(Pathway, 0);

 if Direction in ['A', 'B'] then
  Begin
   While not IsOnVoid(C, R, True) do dec(C);
   inc(C);
   Repeat
    SetLength(Pathway, Length(Pathway) + 1);
    Pathway[Length(Pathway) - 1].X := C;
    Pathway[Length(Pathway) - 1].Y := R;

    inc(C);

    if C > Board.ColCount - 1
     then
      break;
   Until isOnVoid(C, R, True)
  end;

 if Direction in ['D', 'B'] then
  Begin
   While not IsOnVoid(C, R, True) do dec(R);
   inc(R);
   Repeat
    SetLength(Pathway, Length(Pathway) + 1);
    Pathway[Length(Pathway) - 1].X := C;
    Pathway[Length(Pathway) - 1].Y := R;

    inc(R);
    if R > Board.RowCount - 1
     then
      break;
   Until isOnVoid(C, R, True)
  end;
end;

procedure TCrossWord.CheckBoard;
var
 C, R: integer;
 Cleared: Boolean;
begin
 SetWrongLetters(False);
 Cleared := True;
 inc(Checks);
 For C := 0 to Board.ColCount - 1 do
  For R := 0 to Board.RowCount - 1 do
   if Board.Cells[C, R] <> Letters[C, R] then
    begin
     Cleared := False;
     Break;
    end;
 if (Checks = 0) and cleared then frmAchievements.AchievementComplete(One_Check_wonder);

 if Cleared
  then
   HighScore
  else
   if Length(WrongLetters) = 0
    then
     MessageDlg('You should complete the puzzle then check if you''re complete', mtInformation, [mbOK], 1);
end;

procedure TCrossWord.SetWrongLetters(CheckBlank: Boolean);
var
 C, R: integer;
begin
 SetLength(WrongLetters, 0);
 For C := 0 to High(Letters) do
  For R := 0 to High(Letters[C]) do
   if (Board.Cells[C, R] <> '') or (CheckBlank) then
    if Board.Cells[C, R] <> Letters[C, R] then
     begin
      SetLength(WrongLetters, Length(WrongLetters) + 1);
      WrongLetters[Length(WrongLetters) - 1].X := C;
      WrongLetters[Length(WrongLetters) - 1].Y := R;
     end;
 Board.Refresh;    
end;

function TCrossWord.GetLongestWord(H: integer): Integer;
var
 i, iStore: integer;
begin
 Result := GetTextDimension(ClueBox.Items[0], H, True);
 for i := 1 to ClueBox.Items.Count - 1 do
  begin
   iStore := GetTextDimension(ClueBox.Items[i], H, True);
   if iStore > Result
    then
     Result := iStore;
  end;
end;

function TCrossWord.AutoSizeWidth: Integer;
var
 iLongestWord: Integer;
begin
 iLongestWord := GetLongestWord(ClueBox.Font.Height);

 Result := ClueBox.Width;
 While (iLongestWord > Result) and (Result < Board.Width div 2)  do
  Result := Result + 1;

 Result := Result + 20;
end;

function TCrossWord.AutoSizeFont: Integer;
begin
 Result := ClueBox.Font.Size;
 While (GetLongestWord(Result) > ClueBox.Width) and (Result < 18)  do
   Result := Result + 1;

end;

function TCrossWord.PointInArrayTStart(X, Y: integer;
  Points: array of TStartPoint): Integer;
var
 i: integer;
begin
 Result := -1;
 for i := 0 to High(Points) do
 if (X = Points[i].X) and (Y = Points[i].Y) then
  begin
   Result := i;
   Break;
  end;
end;

end.
