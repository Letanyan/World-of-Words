unit WordSearch_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ADODB, ComCtrls, Math, StdCtrls, ExtCtrls, Spin,
  BoardGames_Board__Module, Achievements_Module, Achievements_Controller;

Type

 TWordSearch = class(TBoard)
  protected
    lsbWordsLeft                        : TListBox;
    Board                               : TStringGrid;
    BeginLetter, EndinLetter            : TPoint;
    WordFound                           : string;
    isHighligthing                      : boolean;
    left, right, top, bottom            : Integer;
    CorrectWords                        : array of TPoint;
    Words, WordsFound                   : array of string;
    WordAddresses                       : array of string;
    NumWords, upbound, lowbound, Dim    : integer;

    procedure HighligthWord(l, t, r, b : integer; cl : TColor);
    procedure HighligthAllCorrectWords;
    procedure BuildBoard; Virtual;

    procedure SetWords; Virtual;
    procedure FindWords;

    procedure DrawWordOnBoard(start : TPoint; style : integer; WordToDraw : string); virtual;
    function  CanFit(start : TPoint; style : integer; WordToCheck : string) : Boolean; Virtual;
    procedure ChangeBoardSize(param : integer);



    procedure SetBeginLetter(c, r : integer);
    procedure SetEndinLetter(x, y : integer);

    procedure BoardMouseDown(Sender: TObject;
                             Button: TMouseButton;
                             Shift: TShiftState;
                             X, Y: Integer);
    procedure BoardMouseMove(Sender: TObject;
                             Shift: TShiftState;
                             X, Y: Integer);
    procedure BoardMouseUp(Sender: TObject;
                           Button: TMouseButton;
                           Shift: TShiftState;
                           X, Y: Integer);
  protected
    procedure HighScore(item : integer); Overload; Virtual;
  public
   procedure HighligthandGetWord;
   procedure Resize(w, h, e: Integer); Overload; Virtual;

   constructor Create(srd : TStringGrid; lsb: TListBox);
   procedure SaveGame; Override;
   procedure LoadGame; Override;

   procedure GetWords(List : TStrings);
   procedure CheckWord(List: TStrings); Virtual;

   procedure NewGame(Parameter, NumberofWords             : integer;
                     w, h, e                              : Integer;
                     MinDif, MaxDif                       : Integer); Overload; Virtual;

   procedure Quit; Override;
   procedure ResetToDefault;
 end;

 procedure Parameters(sedMin, sedMax, sedDimension, sedNumberWords : TSpinEdit; sender : char);

implementation

function TWordSearch.CanFit(start : TPoint; style : integer; WordToCheck : string) : boolean;
var
 i : integer;
begin
 Result := true;
 case style of
  0..2 : for i := 1 to length(WordToCheck) do   // | down
           if not ((start.X in [0..Board.ColCount - 1]) and (start.Y + i - 1 in [0..Board.RowCount - 1]))
            then
             Result := false
            else
             if (Board.Cells[start.X, start.Y + i - 1] <> '') and (Board.Cells[start.X, start.Y + i - 1] <> WordToCheck[i])
              then
               Result := false;

  3..5 : for i :=  1 to length(WordToCheck) do    // | Up
           if not ((start.X in [0..Board.ColCount - 1]) and (start.Y - i + 1 in [0..Board.RowCount - 1]))
            then
             Result := false
            else
             if (Board.Cells[start.X, start.Y - i + 1] <> '') and (Board.Cells[start.X, start.Y - i + 1] <> WordToCheck[i])
              then
               Result := false;

  6..8 : for i :=  1 to length(WordToCheck) do    // - Rigth
           if not ((start.X + i - 1 in [0..Board.ColCount - 1]) and (start.Y in [0..Board.RowCount - 1]))
            then
             Result := false
            else
             if (Board.Cells[start.X + i - 1, start.Y] <> '') and (Board.Cells[start.X + i - 1, start.Y] <> WordToCheck[i])
              then
               Result := false;

  9 : for i :=  1 to length(WordToCheck) do        //- left
       if not ((start.X - i + 1 in [0..Board.ColCount - 1]) and (start.Y in [0..Board.RowCount - 1]))
        then
         Result := false
        else
         if (Board.Cells[start.X - i + 1, start.Y] <> '') and (Board.Cells[start.X - i + 1, start.Y] <> WordToCheck[i])
          then
           Result := false;

  10 : for i :=  1 to length(WordToCheck) do        // \ l2r
         if not ((start.X + i - 1 in [0..Board.ColCount - 1]) and (start.Y + i - 1 in [0..Board.RowCount - 1]))
          then
           Result := false
          else
           if (Board.Cells[start.X + i - 1, start.Y + i - 1] <> '') and (Board.Cells[start.X + i - 1, start.Y + i - 1] <> WordToCheck[i])
            then
             Result := false;

  11 : for i :=  1 to length(WordToCheck) do          // \ r2l
         if not ((start.X - i + 1 in [0..Board.ColCount - 1]) and (start.Y - i + 1 in [0..Board.RowCount - 1]))
          then
           Result := false
          else
           if (Board.Cells[start.X - i + 1, start.Y - i + 1] <> '') and (Board.Cells[start.X - i + 1, start.Y - i + 1] <> WordToCheck[i])
            then
             Result := false;

  12 : for i :=  1 to length(WordToCheck) do         // / r2l
         if not ((start.X + i - 1 in [0..Board.ColCount - 1]) and (start.Y - i + 1 in [0..Board.RowCount - 1]))
          then
           Result := false
          else
           if (Board.Cells[start.X + i - 1, start.Y - i + 1] <> '') and (Board.Cells[start.X + i - 1, start.Y - i + 1] <> WordToCheck[i])
            then
             Result := false;

  13 : for i :=  1 to length(WordToCheck) do         // / l2r
         if not ((start.X - i + 1 in [0..Board.ColCount - 1]) and (start.Y + i - 1 in [0..Board.RowCount - 1]))
          then
           Result := false
          else
           if (Board.Cells[start.X - i + 1, start.Y + i - 1] <> '') and (Board.Cells[start.X - i + 1, start.Y + i - 1] <> WordToCheck[i])
            then
             Result := false;

 end;
end;

procedure TWordSearch.DrawWordOnBoard(start : TPoint; style : integer; WordToDraw : string);
var
 i : integer;
begin
 case style of
  0..2 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X, start.Y + i - 1] := WordToDraw[i];

  3..5 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X, start.Y - i + 1] := WordToDraw[i];

  6..8 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X + i - 1, start.Y] := WordToDraw[i];

  9 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X - i + 1, start.Y] := WordToDraw[i];

  10 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X + i - 1, start.Y + i - 1] := WordToDraw[i];

  11 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X - i + 1, start.Y - i + 1] := WordToDraw[i];

  12 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X + i - 1, start.Y - i + 1] := WordToDraw[i];

  13 : for i :=  1 to length(WordToDraw) do
       Board.Cells[start.X - i + 1, start.Y + i - 1] := WordToDraw[i];

 end;
end;

procedure TWordSearch.GetWords;
var
 i : integer;
begin
 for i := 0 to List.Count do
  List.Delete(0);

 for i := 1 to length(words) - 1 do
  List.Add(words[i]);
end;

procedure TWordSearch.Resize(w, h, e : integer);
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

    Width  := wsBoard  - Abs(DefaultColWidth  * ColCount - wsBoard)  + 5;
    Height := wsBoard  - Abs(DefaultRowHeight * RowCount - wsBoard) + 5;

    Left   := w div 2 - Width  div 2 + 8 - e div 2;
    Top    := h div 2 - Height div 2 + 8;

    Font.Size        := wsBoard div (ColCount + Trunc(ColCount * 1.4));
  end;
end;

procedure TWordSearch.SetWords;
var
 i, k, j : integer;
 norepeats : array of integer;
 isrepeat : boolean;
begin
 tbl.Close;
 tbl.TableName := 'Word List';
 tbl.Open;
 Randomize;
 k := 1;
 SetLength(norepeats, NumWords + 1);
 for i := 0 to NumWords - 1 do
  begin
   Repeat

    Repeat
     isrepeat := false;
     norepeats[k] := Random(tbl.RecordCount);
     for j := 1 to High(norepeats) do
      if (norepeats[k] = norepeats[j]) and (k <> j)
       then
        isrepeat := true;
    Until not isrepeat;

    tbl.RecNo := norepeats[k];
    Words[k] := UpperCase(tbl.FieldValues['Word']);
    WordsFound[k] := Words[k];
   Until length(Words[k]) in [lowbound..upbound];
   inc(k);
  end;
end;

procedure TWordSearch.ChangeBoardSize(param: integer);
begin
 Board.ColCount := param;
 Board.RowCount := param;
end;

procedure TWordSearch.LoadGame;
var
 txt : TextFile;
 sLine, sVar : string;
 iWordCount, iWFoundCount, iAddress, iCor : integer;
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
 lsbWordsLeft.Items.Clear;
 iWordCount := 1;
 iWFoundCount := 1;
 iAddress   := 1;
 iCor := 0;

 While not eof(txt) do
  begin
   ReadLn(txt, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));
   if sVar = 'NumWords'
    then
     NumWords := StrToInt(sLine)
    else
   if sVar = 'upbound'
    then
     upbound := StrToInt(sLine)
    else
   if sVar = 'lowbound'
    then
     lowbound := StrToInt(sLine)
    else
   if sVar = 'Dim'
    then
     dim := StrToInt(sLine)
    else
   if sVar = 'TimePlaying'
    then
     TimePlaying := StrToInt(sLine)
    else
   if sVar = 'WordFound'
    then
     WordFound := sLine
    else
   if sVar = 'left'
    then
     left := StrToInt(sLine)
    else
   if sVar = 'right'
    then
     right := StrToInt(sLine)
    else
   if sVar = 'top'
    then
     top := StrToInt(sLine)
    else
   if sVar = 'bottom'
    then
     bottom := StrToInt(sLine)
    else
   if sVar = 'Words' then
    begin
     SetLength(Words, iWordCount + 1);
     Words[iWordCount] := sLine;
     inc(iWordCount);
    end else
   if sVar = 'WordsFound' then
    begin
     SetLength(WordsFound, iWFoundCount + 1);
     WordsFound[iWFoundCount] := sLine;
     inc(iWFoundCount);
     if sLine <> ''
      then
       lsbWordsLeft.Items.Add(sLine);
    end else
   if sVar = 'WordAddresses' then
    begin
     SetLength(WordAddresses, iAddress + 1);
     WordAddresses[iAddress] := sLine;
     inc(iAddress);
    end else
   if sVar = 'CorrectWords' then
    begin
     C := StrToInt(Copy(sLine, Pos('[', sLine) + 1, Pos(':', sLine) - Pos('[', sLine) - 1));
     R := StrToInt(Copy(sLine, Pos(':', sLine) + 1, Pos(']', sLine) - Pos(':', sLine) - 1));
     SetLength(CorrectWords, iCor + 1);
     CorrectWords[iCor].X := C;
     CorrectWords[iCor].Y := R;
     inc(iCor);
    end else
   if sVar = '$' then
    begin
     C := StrToInt(Copy(sLine, Pos('[', sLine) + 1, Pos(':', sLine) - Pos('[', sLine) - 1));
     R := StrToInt(Copy(sLine, Pos(':', sLine) + 1, Pos(']', sLine) - Pos(':', sLine) - 1));
     Board.Cells[C, R] := sLine[length(sLine)];
    end;
  end;
  
 State_NewGame(true);
 isHighligthing := False;
 CloseFile(txt);
end;

procedure TWordSearch.SaveGame;
var
 txt : TextFile;
 i, r : integer;
begin
 if (not GetHasStarted) then exit;
 AssignFile(txt, GetGameSaveFile);
 Rewrite(txt);

 Writeln(txt, 'NumWords=' + IntToStr(NumWords));
 Writeln(txt, 'upbound=' + IntToStr(upbound));
 Writeln(txt, 'lowbound=' + IntToStr(lowbound));
 Writeln(txt, 'Dim=' + IntToStr(Dim));
 Writeln(txt, 'TimePlaying=' + IntToStr(TimePlaying));
 WriteLn(txt, 'WordFound='+WordFound);
 Writeln(txt, 'left=' + IntToStr(left));
 Writeln(txt, 'right=' + IntToStr(right));
 Writeln(txt, 'bottom=' + IntToStr(bottom));
 Writeln(txt, 'top=' + IntToStr(top));

 for i := Low(Words) + 1 to High(words) do
   WriteLn(txt, 'Words=' + Words[i]);


 for i := Low(WordsFound) + 1 to High(WordsFound) do
   WriteLn(txt, 'WordsFound=' + WordsFound[i]);


 for i := Low(WordAddresses) + 1 to High(WordAddresses) do
   WriteLn(txt, 'WordAddresses=' + WordAddresses[i]);

 for i := Low(CorrectWords) to High(CorrectWords) do
  WriteLn(txt, 'CorrectWords=['+ IntToStr(CorrectWords[i].X) + ':' + IntToStr(CorrectWords[i].Y) + ']');

 for i := 0 to Board.ColCount - 1 do
  for r := 0 to Board.RowCount - 1 do
   WriteLn(txt, '$=[' + IntToStr(i) + ':' + IntToStr(r) + ']' + Board.Cells[i, r]);


 CloseFile(txt);
end;

procedure TWordSearch.CheckWord(List : TStrings);
var
 i : integer;
 isWord : boolean;
begin
 if wordfound = '!' then
  begin
   BeginLetter.X  := -1;
   BeginLetter.Y  := -1;
   isHighligthing := false;
   MessageDlg('Please Make a Valid Selection', mtError, mbOKCancel, 1);
   exit;
  end;

 Board.MouseToCell(EndinLetter.X, EndinLetter.Y, right, bottom);
 left := BeginLetter.Y;
 top  := BeginLetter.X;

 isWord := false;
 for i := 1 to length(Words) - 1 do
  if Words[i] = WordFound then
   isWord := true;

 if not isWord then
  begin
   for i := length(WordFound) downto 1 do
    WordFound := WordFound + WordFound[i];

   delete(WordFound, 1, Length(WordFound) div 2);

   for i := 1 to length(Words) - 1 do
    if Words[i] = WordFound then
     isWord := true;
  end;

  if isWord then
   begin
    for i := 1 to length(WordsFound) - 1 do
     if WordsFound[i] = WordFound then
      WordsFound[i] := '';

    While List.Count > 0 do List.Delete(0);

    for i := 1 to length(WordsFound) - 1 do
     if WordsFound[i] <> '' then
      List.Add(wordsfound[i]);

    SetLength(CorrectWords, length(CorrectWords) + 2);
    CorrectWords[length(CorrectWords) - 2].X := Left;
    CorrectWords[length(CorrectWords) - 2].Y := Top;

    CorrectWords[length(CorrectWords) - 1].X := Right;
    CorrectWords[length(CorrectWords) - 1].Y := Bottom;
   end else
   begin
    HighligthWord(left, top, right, bottom, clRed);
   end;

 isHighligthing := false;
end;

procedure TWordSearch.HighligthandGetWord;
var
 w, h, f    : integer;
 l, t, r, b : integer;
begin
 if not GetHasStarted then WaitingRoom(Board);
 Board.Canvas.Pen.Color := clBlue;
 Board.Canvas.Pen.Width := 1;

 Board.MouseToCell(EndinLetter.X, EndinLetter.Y, right, bottom);
 left := BeginLetter.Y;
 top  := BeginLetter.X;

 l := left;
 r := right;
 t := top;
 b := bottom;

 if r < l then
  begin
   w := r;
   r := l;
   l := w;
  end;

 if b < t then
  begin
   h := b;
   b := t;
   t := h;
  end;

 if isHighligthing then
  begin

    WordFound := '';

    if (t = b) and (l <> r) then
     for f := l to r do
      WordFound := WordFound + Board.Cells[f, Board.row];

    if (t <> b) and (l = r) then
     for f := t to b do
      WordFound := WordFound + Board.Cells[Board.col, f];
    Board.Refresh;

    if (l = r) or (t = b)
     then begin

     end else
    if (l <> r) and (t <> b) then
    if (l - r) <> (t - b)
     then
      WordFound := '!'
     else
     begin
      Board.Canvas.Refresh;
      WordFound := '';

      if ((BeginLetter.X = t) and (BeginLetter.Y = l))     //NW to SE
      or ((BeginLetter.X > t) and (BeginLetter.Y > l)) then  //SE to NW
       begin

        for w := l to r do
         for h := t to b do
          if w - l = h - t
           then
            WordFound := WordFound + Board.Cells[w, h];

       end else
      if (BeginLetter.X > t) and (BeginLetter.Y = l)       //SW to NE
      or (BeginLetter.X = t) and (BeginLetter.Y > l) then      //NE to SW
       begin

        for w := l to r do
         for h := t to b do
          if w - l = -(h - t) + b - t
           then
            WordFound := WordFound + Board.Cells[w, h];

       end;

     end;

   HighligthWord(left, top, right, bottom, clBlue);
  end; //is highligthing

  HighligthAllCorrectWords;
end;

constructor TWordSearch.Create(srd : TStringGrid; lsb: TListBox);
begin
 Inherited Create;
 SetGameName('Word Search');
 Board := srd;
 Board.OnMouseDown := BoardMouseDown;
 Board.OnMouseMove := BoardMouseMove;
 Board.OnMouseUp   := BoardMouseUp;
 lsbWordsLeft := lsb;
 BeginLetter.X := -1;
 BeginLetter.Y := -1;
 isHighligthing := false;
 State_Create(True);
end;

procedure TWordSearch.HighScore(item : integer);
begin
 Score := Trunc(1 / TimePlaying * 10000) + NumWords * 10;
 if (item <> 0) or (not GetHasStarted) then exit;
 qry.Close;
 qry.SQL.Text := 'INSERT INTO [Word Search] ' + GetInsertFields(qry) +
                                              'VALUES("' + GetUserName          + '",  '
                                                         + IntToStr(Score)      + ' ,  '
                                                         + IntToStr(TimePlaying)+ ' ,  '
                                                         + IntToStr(NumWords)   + ' ,  '
                                                         + IntToStr(Dim)        + ' , "'
                                                         + IntToStr(lowbound)   + '-' + IntToStr(upbound) + '", '
                                                         + FloatToStr(Date)     + ')';
 qry.ExecSQL;
 Inherited HighScore;
end;

procedure TWordSearch.NewGame(Parameter, NumberofWords             : integer;
                              w, h, e                              : Integer;
                              MinDif, MaxDif                       : integer);
begin
 BeginLetter.X := -1;
 BeginLetter.Y := -1;
 isHighligthing := false;

 NumWords := NumberofWords;
 lowbound := MinDif;
 upbound  := MaxDif;
 Dim := Board.ColCount;
 SetLength(Words, 1);
 SetLength(WordsFound, 1);
 SetLength(Words, NumWords + 1);
 SetLength(WordsFound, NumWords + 1);
 SetWords;

 ChangeBoardSize(Parameter);
 Resize(w, h, e);
 SetLength(CorrectWords, 0);

 BuildBoard;

 State_NewGame(false);
 TimePlaying := 0;
 if Board.ColCount = NumWords
  then
   frmAchievements.AchievementComplete(To_The_Limit);
 if MaxDif - MinDif = 1
  then
   frmAchievements.AchievementComplete(No_Breathing_Space);  
end;

procedure TWordSearch.Quit;
begin
 Inherited Quit;
 FindWords;
end;

procedure TWordSearch.SetBeginLetter(c, r: integer);
begin
 BeginLetter.X := r;
 BeginLetter.Y := c;
 isHighligthing := true;
end;

procedure TWordSearch.SetEndinLetter(x, y: integer);
begin
 EndinLetter.X := x;
 EndinLetter.Y := y;
end;

procedure TWordSearch.HighligthWord(l, t, r, b: integer; cl : TColor);
var
  i : integer;
  isForSlash : boolean;
begin
  if ((l > r) and (t < b)) or ((t > b) and (l < r))
   then
    isForSlash := True
   else
    isForSlash := false;

  if r < l then
  begin
   i := r;
   r := l;
   l := i;
  end;

 if b < t then
  begin
   i := b;
   b := t;
   t := i;
  end;

  Board.Canvas.Pen.Color := cl;
  i := Board.DefaultColWidth;
  With Board.canvas do
   begin
    if (l = r) or (t = b)
     then begin
      if (l = r) and (t <> b) then    //up down
         begin
          MoveTo(l * i + i div 4    , t * i + i div 6);
          LineTo(l * i + i div 5 * 4, t * i + i div 6);
          LineTo(l * i + i div 5 * 4, b * i + i);
          LineTo(l * i + i div 4    , b * i + i);
          LineTo(l * i + i div 4    , t * i + i div 6);
         end else
        if (t = b) and (l <> r) then     //left right
         begin
          MoveTo(l * i + i div 6    , t * i + i div 6);
          LineTo(r * i - i div 6 + i, t * i + i div 6);
          LineTo(r * i - i div 6 + i, (t + 1) * i - i div 6);
          LineTo(l * i + i div 6    , (t + 1) * i - i div 6);
          LineTo(l * i + i div 6    , t * i + i div 6);
         end;

     end else
    if (l <> r) and (t <> b) then
    if (l - r) = (t - b) then
     begin
      Refresh;

      if not isForSlash then  //SE to NW
       begin
        MoveTo(l * i + i div 2, t * i);
        LineTo(r * i + i      , b * i + i div 2);

        MoveTo(l * i          , t * i + i div 2);
        LineTo(r * i + i div 2, b * i + i);


        MoveTo(l * i          , t * i + i div 2);
        LineTo(l * i + i div 2, t * i);

        MoveTo(r * i + i div 2, b * i + i);
        LineTo(r * i + i      , b * i + i div 2);

       end else
       begin            //SW to NE
        MoveTo(r * i + i div 2, t * i);
        LineTo(l * i          , b * i + i div 2);

        MoveTo(r * i + i      , t * i + i div 2);
        LineTo(l * i + i div 2, b * i + i);


        MoveTo(r * i + i div 2, t * i);
        LineTo(r * i + i      , t * i + i div 2);

        MoveTo(l * i          , b * i + i div 2);
        LineTo(l * i + i div 2, b * i + i);
       end;
     end;
  end;
end;

procedure TWordSearch.HighligthAllCorrectWords;
var
 i : integer;
begin
 for i := 0 to length(CorrectWords) - 2 do
  if i mod 2 = 0
   then
    HighligthWord(CorrectWords[i].X, CorrectWords[i].Y, CorrectWords[i+1].X, CorrectWords[i+1].Y, clGreen)
   else
    Continue;
end;

procedure TWordSearch.BuildBoard;
var
 i, k : integer;
 style : integer;
 cel : TPoint;
begin
 Randomize;
 Board.Font.Color := clBlack;
 for i := 0 to Board.ColCount do
   for k := 0 to Board.RowCount do
     Board.Cells[i, k] := '';


 SetLength(WordAddresses, length(Words));
 for i := 1 to length(Words) - 1 do
  begin
   Repeat
    style := Random(14);

    Repeat
     cel.X := Random(Board.ColCount);
     cel.Y := Random(Board.RowCount);
    Until (Board.Cells[cel.X, cel.Y] = '') or (Board.Cells[cel.X, cel.Y] = Words[i]);

   Until CanFit(cel, style, Words[i]);

   WordAddresses[i] := IntToStr(cel.X) + ':' + IntToStr(cel.Y);

   DrawWordOnBoard(cel, style, Words[i]);
  end;

  for i := 0 to Board.ColCount do
   for k := 0 to Board.RowCount do
    if Board.Cells[i, k] = '' then
     Board.Cells[i, k] := RandomLetter;
end;

procedure Parameters(sedMin, sedMax, sedDimension,
  sedNumberWords: TSpinEdit; sender: char);
begin
 if sedDimension.Value < 20 then
  begin
   sedMin.MaxValue := sedDimension.Value - 1;
   sedMax.MaxValue := sedDimension.Value;
  end;
 sedNumberWords.MaxValue := sedDimension.Value ;

 case sender of
  'S' : begin
         if sedMin.Text <> ''
          then
         if sedMin.Value >= sedmax.Value
          then
           sedMax.Value := sedMin.Value + 1;
        end;

  'L' : if sedMax.Text <> ''
          then
        if sedMin.Value >= sedmax.Value
         then
          sedMin.Value := sedMax.Value - 1;
 end;
end;

procedure TWordSearch.BoardMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not CanPlay(False) then exit;
 SetBeginLetter(Board.Col, Board.Row);
end;

procedure TWordSearch.BoardMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 EndCell : TPoint;
begin
 if not CanPlay(False) then exit;
 EndCell.X := Board.MouseCoord(X, Y).X;
 EndCell.Y := Board.MouseCoord(X, Y).Y;
 if (EndCell.X > - 1)and (endCell.Y > -1)
  then
   SetEndinLetter(X, Y);
 HighligthandGetWord;
end;


procedure TWordSearch.FindWords;
    procedure FindEndofWord(var C, R : integer; WordToFind: string);
    var
     i, iC, iR : integer;
     sWord : string;
    begin
     iC := C;
     iR := R;
     sWord := WordToFind[1];

     if C - 1 > -1 then  //W
      if Board.Cells[C - 1, R][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          dec(C);
          if C > -1 then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if ((C - 1) > -1) and(R + 1 < Board.RowCount) then  //SW
      if Board.Cells[C - 1, R + 1][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          dec(C);
          inc(R);
          if (C > -1) and (R < Board.RowCount) then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if (R + 1) < Board.RowCount then  //S
      if Board.Cells[C, R + 1][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          inc(R);
          if R < Board.RowCount then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if (R + 1 < Board.RowCount) and (C + 1 < Board.ColCount) and (Board.Cells[C + 1, R + 1] <> '') then  //SE
      if Board.Cells[C + 1, R + 1][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          inc(R);
          inc(C);
          if R and c < Board.RowCount then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if (C + 1) < Board.ColCount then  //E
      if Board.Cells[C + 1, R][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          inc(C);
          if C < Board.ColCount then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if ((R - 1) > - 1) and (C + 1 < Board.ColCount) then  //NE
      if Board.Cells[C + 1, R - 1][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          dec(R);
          inc(C);
          if (R > -1) and (C < Board.ColCount) then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if (R - 1) > - 1 then  //N
      if Board.Cells[C, R - 1][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          dec(R);
          if R > -1 then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;

     if (R - 1 > - 1) and (C - 1 > -1) then  //NW
      if Board.Cells[C - 1, R - 1][1] = WordToFind[2]
       then
        for i := 1 to length(WordToFind) - 1 do
         begin
          dec(R);
          dec(C);
          if R and C > -1 then sWord := sWord + Board.Cells[C, R];
         end;

     if sWord = WordToFind
      then
       exit
      else begin
       sWord := WordToFind[1];
       C := iC;
       R := iR;
      end;
    end;

var
 i : integer;
 C, R : integer;
begin
 SetLength(CorrectWords, 0);
 for i := 1 to High(WordAddresses) do
  begin
    SetLength(CorrectWords, length(CorrectWords) + 2);
    C := StrToInt(Copy(WordAddresses[i], 1, Pos(':', WordAddresses[i]) - 1));
    R := StrToInt(Copy(WordAddresses[i], Pos(':', WordAddresses[i]) + 1, length(WordAddresses[i])));
    CorrectWords[length(CorrectWords) - 2].X := C;
    CorrectWords[length(CorrectWords) - 2].Y := R;

    FindEndofWord(C, R, Words[i]);

    CorrectWords[length(CorrectWords) - 1].X := C;
    CorrectWords[length(CorrectWords) - 1].Y := R;
  end;
end;

procedure TWordSearch.ResetToDefault;
var
 C, R: integer;
begin
 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   Board.Cells[C, R] := '';
 BeginLetter.X := -1;
 BeginLetter.Y := -1;
 EndinLetter.X := -1;
 EndinLetter.Y := -1;
 WordFound := '';
 left := 0;
 right := 0;
 top := 0;
 bottom := 0;
 SetLength(CorrectWords, 0);
 SetLength(Words, 0);
 SetLength(WordsFound, 0);
 SetLength(WordAddresses, 0);
 NumWords := 0;
 upbound := 0;
 lowbound := 0;
 Dim := 0;
 lsbWordsLeft.Items.Clear;
end;

procedure TWordSearch.BoardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not CanPlay(True) then exit;
 CheckWord(lsbWordsLeft.Items);
 HighScore(lsbWordsLeft.Items.Count);
end;

end.
