unit FindEm_Module;

interface

uses
 Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ADODB, ComCtrls, Math, StdCtrls, ExtCtrls, Spin,
  BoardGames_Board__Module, Achievements_Module, Achievements_Controller;

const
 LetterValues : Array['A'..'Z'] of Integer =
   (
     1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10
   );

type
  TFindEm = class(TBoard)
   protected
    Mode          : Char;
    Score2Reach   : Integer;
    WordLimit     : Integer;

    Board         : TStringGrid;
    lblTime, lblWord, lblScore : TLabel;
    CellsPicked   : Array of TPoint;
    //CurrentWord   : string;
    InitialTime   : Integer;
    WordsFound : integer;
    Dimension     : integer;

    function PointsMakeX: Boolean;
    function PointsCoverBoarder: Boolean;

    procedure BoardOnDrawCell(Sender: TObject;
                              ACol, ARow: Integer;
                              Rect: TRect;
                              State: TGridDrawState); Virtual;

    procedure BoardMouseDown(Sender: TObject;
                             Button: TMouseButton;
                             Shift : TShiftState;
                             X, Y  : Integer);  Virtual;

    procedure BoardMouseUp(Sender: TObject;
                           Button: TMouseButton;
                           Shift : TShiftState;
                           X, Y  : Integer);  Virtual;

    procedure BoardKeyUp(Sender: TObject;
                         var Key: Word;
                         Shift: TShiftState);

    function  GetCurrentword: String;
    function  GetWordScore : Integer;
    procedure SetWordScore; Virtual;
   protected
    procedure HighScore; Override;
   public
    constructor Create(srd : TStringGrid; lblT, lblW, lblS : TLabel); Overload; Virtual;
    procedure   NewGame(Mode, Time : string; Score2Reach, WordLimit, Dimension : Integer);
    procedure   SaveGame; Override;
    procedure   LoadGame; Override;

    procedure ClearWord;
    procedure CheckWord;

    procedure HighLightSelectedWord; Virtual;

    function  GetScore : String;
    procedure GetTime(ownr : TPanel);

    procedure Quit; Override;
    procedure ResetToDefault;
    procedure Resize(ownr : TPanel);
  end;

implementation

{ TFindEm }

//Word Score//
function TFindEm.GetWordScore : Integer;
var
 i : integer;
begin
 //CurrentWord := UpperCase(CurrentWord);
 Result := 0;
 for i := 1 to length(GetCurrentWord) do
  Result := Result + LetterValues[GetCurrentWord[i]];
end;

procedure TFindEm.BoardMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TFindEm.BoardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure RemoveAlreadySelected(C, R: Integer);
    var
     i, iPos: integer;
    begin
     iPos := High(CellsPicked);
     for i := 0 to High(CellsPicked) do
      if (CellsPicked[i].X = C) and (CellsPicked[i].Y = R) then
       begin
        iPos := i;
        Break;
       end;
     for i := iPos to High(CellsPicked) - 1 do
      begin
       CellsPicked[i].X := CellsPicked[i + 1].X;
       CellsPicked[i].Y := CellsPicked[i + 1].Y;
      end;
     SetLength(CellsPicked, Length(CellsPicked) - 1);
    end;
var
 C, R : integer;
begin
 if not CanPlay(True) then exit;
 Board.MouseToCell(X, Y, C, R);
 if High(CellsPicked) > -1
  then
 if PointInArray(C, R, CellsPicked) > -1 then
  begin
   RemoveAlreadySelected(C, R);
   Board.Refresh;
   lblWord.Caption := ' Your Word: ' + GetCurrentWord + ' = ' + IntToStr(GetWordScore);
   exit;
  end;
 SetLength(CellsPicked, Length(CellsPicked) + 1);
 CellsPicked[Length(CellsPicked) - 1].X := C;
 CellsPicked[Length(CellsPicked) - 1].Y := R;
 Board.Refresh;
 lblWord.Caption := ' Your Word: ' + GetCurrentWord + ' = ' + IntToStr(GetWordScore);
 //lblWord.Font.Height := 25 - length(lblWord.Caption) div 20;
end;

procedure TFindEm.CheckWord;

     //Replace Letters//
     procedure RandomLetters;
     var
      i : integer;
     begin
      for i := 0 to High(CellsPicked) do
       Board.Cells[CellsPicked[i].X, CellsPicked[i].Y] := RandomLetter;
      SetLength(CellsPicked, 1);
     end;

     //Correct Word//
     procedure WasItCorrect(Correct : Boolean);
     var
      i, movement : integer;
      Start : TPoint;
     begin
      if correct
       then
        for i := 1 to 255 do              //Draw Tick
         begin
          Board.Canvas.Pen.Color := clGreen;
          Board.Canvas.Pen.Width := Board.DefaultColWidth div 2;
          if i < 55 then
           begin
            start.X := 0;
            start.Y := Board.Height div 4 * 3;

            movement := Board.Height div 4;

            Board.Canvas.MoveTo(start.X, start.Y);
            Board.Canvas.LineTo(start.X + (i * movement div 55), start.Y + (i * movement div 55));
           end else
           begin
            start.X := Board.Width div 4;
            start.Y := Board.Height;

            Movement := Board.Height div 4 * 3;

            Board.Canvas.MoveTo(start.X, start.Y);
            Board.Canvas.LineTo(start.X + (i * movement div 200), start.Y - (i * movement div 200) );
           end;

          if i mod 5 = 0 then Sleep(1);
         end
       else
        for i := 1 to 255 do             //Draw Cross
         begin
          Board.Canvas.Pen.Color := clRed;
          Board.Canvas.Pen.Width := Board.DefaultColWidth div 2;
          if i < 125 then
           begin
            start.X := 0;
            start.Y := 0;

            movement := Board.Width;

            Board.Canvas.MoveTo(start.X, start.Y);
            Board.Canvas.LineTo(start.X + (i * movement div 125), start.Y + (i * movement div 125));
           end else
           begin
            start.X := Board.Width;
            start.Y := 0;

            movement := Board.Width;

            Board.Canvas.MoveTo(start.X, start.Y);
            Board.Canvas.LineTo(start.X - ((i - 125) * movement div 125), start.Y + ((i - 125) * movement div 125));
           end;

          if i mod 5 = 0 then Sleep(1);
         end;
      Board.Canvas.Pen.Width := 1;
     end;

begin
 if not CanPlay(True) then exit;
 if length(GetCurrentWord) < 1 then exit;
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [Word List] WHERE Word = "' + GetCurrentWord + '"';
 qry.Open;
 WasItCorrect(qry.RecordCount > 0);
 lblWord.Caption := ' Your Word:';
 if qry.RecordCount > 0 then
  begin
   Score := Score + GetWordScore;
   if PointsCoverBoarder
    then
     frmAchievements.AchievementComplete(On_The_Boarder);
   if PointsMakeX
    then
     frmAchievements.AchievementComplete(X_Marks_The_Spot);
   RandomLetters;
   Inc(WordsFound);
  end;

  SetLength(CellsPicked, 0);

 Board.Refresh;

 if Mode in ['O', 'P'] then
  begin
   if Score >= Score2Reach
    then
     HighScore;
  end else
 if Mode = 'P' then
  if WordsFound > WordLimit
   then
    Quit;

 SetWordScore;
end;

procedure TFindEm.ClearWord;
begin
 if not CanPlay(true) then exit;
 SetLength(CellsPicked, 0);
 Board.Refresh;
 lblWord.Caption := 'Your Word:';
end;

constructor TFindEm.Create(srd: TStringGrid; lblT, lblW, lblS : TLabel);
begin
 Inherited Create;
 SetGameName('Find ''Em');
 Board := srd;
 Board.OnDrawCell  := BoardOnDrawCell;
 Board.OnMouseDown := BoardMouseDown;
 Board.OnMouseUp   := BoardMouseUp;
 Board.OnKeyUp     := BoardKeyUp;
 TimePlaying := 0;
 State_Create(False);
 SetLength(CellsPicked, 0);
 lblTime  := lblT;
 lblWord  := lblW;
 lblScore := lblS;
end;

function TFindEm.GetScore: String;
begin
 if Mode = 'C'
  then
   Result := ' Score: ' + IntToStr(Score)
  else
   Result := ' Score: ' + IntToStr(Score) + ' / ' + IntToStr(Score2Reach);
end;

procedure TFindEm.GetTime(ownr : TPanel);
var
 min, sec : String;
 CanPlay : boolean;
begin
 CanPlay := not(GetGamePaused or not GetHasStarted);

 if Mode = 'P' then
  begin
   lblTime.Caption := 'Words Remaining: ' + IntToStr(WordLimit - WordsFound);
   Exit;
   Inc(InitialTime);
   Inc(TimePlaying);
  end else
 if not TimePlaying > 0 then
  begin
   lblTime.Caption := '00:00';
   exit;
  end;

 min := IntToStr(TimePlaying div 60);
 sec := IntToStr(TimePlaying mod 60);
 if length(min) = 1
  then
   min := '0' + min;
 if length(sec) = 1
  then
   sec := '0' + sec;

 lblTime.Caption := min + ':' + sec;
 if CanPlay then dec(TimePlaying);

 if CanPlay then
 if TimePlaying = 0 then
  if Mode = 'C'
   then
    HighScore
   else
  if Mode = 'O'
   then
    Quit;

 lblTime.Left := ownr.Width  - lblTime.Width - 16;
 lblTime.Top  := ownr.Height - 33;   
end;

function GetTextWidth(s : string; size : integer) : integer;
var
 cnvs : TBitmap;
begin
 Try
  cnvs := TBitmap.Create;
  cnvs.Canvas.Font.Name := 'Tahoma';
  cnvs.Canvas.Font.Size := size;
  cnvs.Canvas.TextOut(0, 0, s);
  Result := cnvs.Canvas.TextWidth(s);
 Finally
  freeAndNil(cnvs);
 end;
end;

function TFindEm.GetCurrentword: String;
var
 i: integer;
begin
 Result := '';
 for i := 0 to High(CellsPicked) do
  Result := Result + Board.Cells[CellsPicked[i].X, CellsPicked[i].Y];
end;

procedure HighLightCell(srd : TStringGrid; C, R : Integer);
var
 W, H : Integer;
 Letter  : String;
 anchor : integer;
begin
 W := srd.DefaultColWidth;
 H := srd.DefaultRowHeight;
 Letter := srd.Cells[C, R];
 srd.Canvas.Pen.Color := clBlue;
 srd.Canvas.Brush.Style := bsClear;

 anchor := 10;
 srd.Canvas.Pen.Width   := 1;
 srd.Canvas.Rectangle(C * W + anchor, R * H + anchor, (C + 1) * W - anchor, (R + 1) * H - anchor);
 anchor := 15;
 srd.Canvas.Pen.Width   := 2;
 srd.Canvas.Rectangle(C * W + anchor, R * H + anchor, (C + 1) * W - anchor, (R + 1) * H - anchor);
end;

procedure TFindEm.HighLightSelectedWord;
begin
 if not GetHasStarted
  then
   WaitingRoom(Board);
end;

procedure TFindEm.HighScore;
var
 sMode: string;
begin
 case Mode of
  'P' : sMode := 'Puzzle';
  'C' : sMode := 'Classic';
  'O' : sMode := 'On A Schedule';
 end;

 qry.Close;
 qry.SQL.Text := 'INSERT INTO [' + GetGameName + '] ' + GetInsertFields(qry) + 
                                              'VALUES("' + GetUserName              + '", "'
                                                         + sMode                    + '",  '
                                                         + IntToStr(InitialTime)    + ' ,  '
                                                         + IntToStr(WordsFound)     + ' ,  '
                                                         + IntToStr(Board.ColCount) + ' ,  '
                                                         + IntToStr(Score)          + ' ,  '
                                                         + IntToStr(WordLimit)      + ' ,  '
                                                         + FloatToStr(Date)         + ')';
 qry.ExecSQL;
 Inherited;
 Quit;
end;

procedure TFindEm.NewGame(Mode, Time : string; Score2Reach, WordLimit, Dimension : Integer);
var
 C, R : integer;
begin
 Self.Mode := Mode[1];
 Self.Score2Reach := Score2Reach;
 Self.WordLimit := WordLimit;

 SetLength(CellsPicked, 0);
 Score := 0;
 WordsFound := 0;

 if Self.Mode in ['C', 'O'] then
  begin
   TimePlaying := 60 * StrToInt(Copy(Time, 1, Pos(' ', Time) - 1));
   InitialTime := TimePlaying;
  end else
  begin
   TimePlaying := 0;
   InitialTime := 0;
  end;

 Self.Dimension := Dimension;
 Board.ColCount := Dimension;
 Board.RowCount := Dimension;
 Board.Font.Color := clBlack;

 SetWordScore;

 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   Board.Cells[C, R] := RandomLetter;
 State_NewGame(false);
end;

procedure TFindEm.Quit;
begin
 Inherited;
 ResetToDefault;
 Board.Refresh;
end;

procedure TFindEm.Resize(ownr : TPanel);
var
 MinLength : Integer;
begin
 MinLength := Min(ownr.Width, ownr.Height - 49) - 16;

 Board.Width  := MinLength;
 Board.Height := MinLength;

 Board.DefaultColWidth  := MinLength  div Board.ColCount - 2;
 Board.DefaultRowHeight := MinLength  div Board.RowCount - 2;

 Board.Width  := Board.Width  - Abs(Board.DefaultColWidth  * Board.ColCount - Board.Width)  + 5;
 Board.Height := Board.Height - Abs(Board.DefaultRowHeight * Board.RowCount - Board.Height) + 5;

 Board.Left   := ownr.Width  div 2 - Board.Width  div 2;
 Board.Top    := (ownr.Height - 49) div 2 - Board.Height div 2;

 Board.Font.Size := MinLength div (Board.ColCount + Trunc(Board.ColCount * 1.4));
end;

procedure TFindEm.BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
 AlignCenterText(Board, ACol, ARow, Rect, Board.Cells[ACol, ARow]);
 if PointInArray(ACol, ARow, CellsPicked) > -1
  then
   HighLightCell(Board, ACol, ARow);
end;

procedure TFindEm.LoadGame;
var
 FindEm : TextFile;
 iCellsPicked, C, R : integer;
 sLine, sVar : string;
begin
 AssignFile(FindEm, GetGameSaveFile);
 if FileExists(GetGameSaveFile)
  then
   Reset(FindEm)
  else begin
   Quit;
   exit;
  end;
 iCellsPicked := 1;

 While not eof(FindEm) do
  begin
   ReadLn(FindEm, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));
   if sVar = 'Mode'
    then
     Mode := sLine[1]
    else
   if sVar = 'Score2Reach'
    then
     Score2Reach := StrToInt(sLine)
    else
   if sVar = 'WordLimit'
    then
     WordLimit := StrToInt(sLine)
    else
   if sVar = 'InitialTime'
    then
     InitialTime := StrToInt(sLine)
    else
   if sVar = 'Score'
    then
     Score := StrToInt(sLine)
    else
   if sVar = 'Dimension'
    then
     Dimension := StrToInt(sLine)
    else
   if sVar = 'WordsFound'
    then
     WordsFound := StrToInt(sLine)
    else
   if sVar = 'TimePlaying'
    then
     TimePlaying := StrToInt(sLine)
    else
   if sVar = 'CellsPicked' then
    begin
     SetLength(CellsPicked, iCellsPicked + 1);
     CellsPicked[iCellsPicked].X := StrToInt(Copy(sLine, Pos('=', sLine) + 1, 1));
     CellsPicked[iCellsPicked].Y := StrToInt(Copy(sLine, Pos(':', sLine) + 1, 1));
     inc(iCellsPicked);
    end else
   if sVar = '$' then
    begin
     C := StrToInt(Copy(sLine, Pos('[', sLine) + 1, Pos(':', sLine) - Pos('[', sLine) - 1));
     R := StrToInt(Copy(sLine, Pos(':', sLine) + 1, Pos(']', sLine) - Pos(':', sLine) - 1));
     Board.Cells[C, R] := sLine[length(sLine)];
    end;
  end;

 SetLength(CellsPicked, 0);
 lblWord.Caption := ' Your Word: ' + GetCurrentWord;
 CloseFile(FindEm);
 Board.ColCount := Dimension;
 Board.RowCount := Dimension;
 SetWordScore;
 State_NewGame(true);
end;

procedure TFindEm.SaveGame;
var
 FindEm : TextFile;
 i, C, R: integer;
begin
 if (not GetHasStarted) then exit;
 AssignFile(FindEm, GetGameSaveFile);
 Rewrite(FindEm);

 WriteLn(FindEm, 'Mode=' + Mode);
 WriteLn(FindEm, 'Score2Reach=' + IntToStr(Score2Reach));
 WriteLn(FindEm, 'WordLimit=' + IntToStr(WordLimit));

 for i := 0 to High(CellsPicked) do
  WriteLn(FindEm, 'CellsPicked=' + IntToStr(CellsPicked[i].X) + ':' + IntToStr(CellsPicked[i].Y));

 WriteLn(FindEm, 'InitialTime=' + IntToStr(InitialTime));
 WriteLn(FindEm, 'Score=' + IntToStr(Score));
 WriteLn(FindEm, 'Dimension=' + IntToStr(Dimension));
 WriteLn(FindEm, 'WordsFound=' + IntToStr(WordsFound));
 WriteLn(FindEm, 'TimePlaying=' + IntToStr(TimePlaying));

 for C := 0 to Dimension - 1 do
  for R := 0 to Dimension - 1 do
   WriteLn(FindEm, '$=[' + IntToStr(C) + ':' + InttoStr(R) + ']' + Board.Cells[C, R]);

 CloseFile(FindEm);
end;

procedure TFindEm.SetWordScore;
begin
 lblScore.Caption := 'Score: ';
 if Mode = 'C'
  then
   lblScore.Caption := ' Score: ' + IntToStr(Score)
  else
   lblScore.Caption := ' Score: ' + IntToStr(Score) + ' / ' + IntToStr(Score2Reach);
end;

procedure TFindEm.ResetToDefault;
var
 C, R: integer;
begin
 Mode := ' ';
 Score2Reach := 0;
 Score       := 0;
 WordLimit := 0;
 lblTime.Caption := '00:00';
 lblWord.Caption := ' Your Word: ';
 lblScore.Caption := ' Score: ';
 SetLength(CellsPicked, 0);
 InitialTime := 0;
 WordsFound := 0;
 Dimension := 5;
 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   Board.Cells[C, R] := '';
end;

procedure TFindEm.BoardKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case key of
  VK_RETURN : CheckWord;
 end;
end;

function TFindEm.PointsCoverBoarder: Boolean;
var
 i: integer;
begin
 Result := True;

 for i := 0 to Board.ColCount - 1 do  //TL to TR
  if PointInArray(i, 0, CellsPicked) = -1 then
   begin
    Result := false;
    exit;
   end;

 for i := 0 to Board.ColCount - 1 do  //TR to BR
  if PointInArray(Board.ColCount - 1, i, CellsPicked) = -1 then
   begin
    Result := false;
    exit;
   end;

 for i := 0 to Board.ColCount - 1 do  //BR to BL
  if PointInArray(i, Board.ColCount - 1, CellsPicked) = -1 then
   begin
    Result := false;
    exit;
   end;

 for i := 0 to Board.ColCount - 1 do  //BL to TL
  if PointInArray(0, i, CellsPicked) = -1 then
   begin
    Result := false;
    exit;
   end;
end;

function TFindEm.PointsMakeX: Boolean;
var
 iInv, i: Integer;
begin
 Result := True;

 for i := 0 to Board.ColCount - 1 do     //TL to BR
  if PointInArray(i, i, CellsPicked) = -1 then
   begin
    Result := false;
    exit;
   end;

 iInv := Board.ColCount - 1;
 for i := 0 to Board.ColCount - 1 do     //BL to TR
  begin
   if PointInArray(i, iInv, CellsPicked) = -1 then
    begin
     Result := false;
     exit;
    end;
   dec(iInv);
  end;
end;

end.
