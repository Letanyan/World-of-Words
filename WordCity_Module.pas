unit WordCity_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, BoardGames_Board__Module, math, ADODB,
  Achievements_Module, Achievements_Controller;

const
 LetterValues : Array['A'..'Z'] of Integer =
   (
     1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10
   );

type
  TWordCityTile = class
   Letter      : Array[0..3] of Char;
   Orientation : Integer;
   Shape       : String;
   Points      : Array[0..3] of TPoint;
  end;

  TWordCity = class(TBoard)
   private
    Board        : TStringGrid;
    NextShapeBoard : TStringGrid;
    lsbWordsMade : TListBox;
    lblScore     : TLabel;
    timer        : TTimer;
    CurrentShape, NextShape : TWordCityTile;
    VirtualPoints           : Array[0..3] of TPoint;
    Target                  : Integer;

    function  OverLapping(var VirtualShapePoints : Array of TPoint) : boolean;
    procedure UpdatePos;
    procedure DrawCurrent;
    procedure CreateShape;
    procedure SwapEm;
    procedure ClearCurrent;
    procedure VirtualCurrent(VirtualShape : TWordCityTile);
    procedure DrawBlock(SRD : TStringGrid; C, R : Integer; clrBlock : TColor);
    procedure BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawNextShape;

    procedure OnTimer(Sender : TObject);
    procedure OnBoardKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

   protected
    procedure Highscore; Override;
   Public
    Constructor Create(Board : TStringGrid; lsbWordsMade : TListBox);
    procedure   NewGame(Target : Integer);
    procedure   Resize(w, h, e : integer);
    procedure   LoadGame; Override;
    procedure   SaveGame; Override;
    procedure   Quit; Override;
    procedure   ResetToDefault;
  end;

implementation

{ TWordCity }

procedure TWordCity.ClearCurrent;
var
 i : integer;
begin
 for i := 0 to 3 do
   if CurrentShape.Points[i].Y > - 1
    then
     Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y] := '';
end;

constructor TWordCity.Create(Board: TStringGrid; lsbWordsMade : TListBox);
begin
 Inherited Create;
 SetGameName('Word City');
 NextShape    := TWordCityTile.Create;
 CurrentShape := TWordCityTile.Create;

 Self.Board      := Board;
 Board.OnKeyDown := OnBoardKeyDown;
 Board.OnDrawCell := BoardOnDrawCell;

 NextShapeBoard := TStringGrid.Create(nil);
 With NextShapeBoard do
  begin
   Parent  := Board.Parent;
   Width   := 153;
   Left    := lsbWordsMade.Left;
   Height  := 153;
   Top     := 40;
   Anchors := [akRight, akTop];
   DefaultColWidth  := 36;
   DefaultRowHeight := 36;
   Options          := [];
   GridLineWidth    := 0;
   Color            := clBlack;
   Font.Color       := clWhite;
   RowCount         := 4;
   ColCount         := 4;
   ScrollBars       := ssNone;
   FixedCols        := 0;
   FixedRows        := 0;
   OnDrawCell       := BoardOnDrawCell;
  end;

 Self.lsbWordsMade := lsbWordsMade;

 Timer          := TTimer.Create(Board.Parent);
 Timer.Enabled  := False;
 Timer.Interval := 500;
 Timer.OnTimer  := OnTimer;

 lblScore         := TLabel.Create(nil);
 With lblScore do
  begin
   Parent  := Board.Parent;
   Left    := lsbWordsMade.Left;
   Top     := lsbWordsMade.Top + lsbWordsMade.Height + 8;
   Caption := 'Score: 0';
   Transparent := True;
   Font.Color  := clWhite;
   Anchors     := [akRight, akBottom];
  end;

 State_Create(False);
end;

procedure TWordCity.CreateShape;
var max : Integer;
    procedure CreateLine;
    begin
       NextShape.Points[0].X := 4;
       NextShape.Points[0].Y := -4;

       NextShape.Points[1].X := 4;
       NextShape.Points[1].Y := -3;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -2;

       NextShape.Points[3].X := 4;
       NextShape.Points[3].Y := -1;
    end;

    procedure CreateChilledAsh;
    begin
       NextShape.Points[0].X := 4;
       NextShape.Points[0].Y := -3;

       NextShape.Points[1].X := 4;
       NextShape.Points[1].Y := -2;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -1;

       NextShape.Points[3].X := 5;
       NextShape.Points[3].Y := -1;
    end;

    procedure CreateGottaCatchEm;
    begin
       NextShape.Points[0].X := 4;
       NextShape.Points[0].Y := -3;

       NextShape.Points[1].X := 4;
       NextShape.Points[1].Y := -2;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -1;

       NextShape.Points[3].X := 3;
       NextShape.Points[3].Y := -1;
    end;

    procedure CreateBlock;
    begin
       NextShape.Points[0].X := 4;
       NextShape.Points[0].Y := -2;

       NextShape.Points[1].X := 5;
       NextShape.Points[1].Y := -2;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -1;

       NextShape.Points[3].X := 5;
       NextShape.Points[3].Y := -1;
    end;

    procedure CreateZed;
    begin
       NextShape.Points[0].X := 3;
       NextShape.Points[0].Y := -2;

       NextShape.Points[1].X := 4;
       NextShape.Points[1].Y := -2;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -1;

       NextShape.Points[3].X := 5;
       NextShape.Points[3].Y := -1;
    end;

    procedure CreateEs;
    begin
       NextShape.Points[0].X := 5;
       NextShape.Points[0].Y := -2;

       NextShape.Points[1].X := 4;
       NextShape.Points[1].Y := -2;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -1;

       NextShape.Points[3].X := 3;
       NextShape.Points[3].Y := -1;
    end;

    procedure CreateIcon;
    begin
       NextShape.Points[0].X := 4;
       NextShape.Points[0].Y := -2;

       NextShape.Points[1].X := 3;
       NextShape.Points[1].Y := -1;

       NextShape.Points[2].X := 4;
       NextShape.Points[2].Y := -1;

       NextShape.Points[3].X := 5;
       NextShape.Points[3].Y := -1;
    end;

    procedure RandomOrientation;
    var i, k : integer;
    begin
     for i := 0 to NextShape.Orientation do
     begin
      VirtualCurrent(NextShape);

      for k := 0 to 3 do
       begin
        NextShape.Points[k].X := VirtualPoints[k].X;
        NextShape.Points[k].Y := VirtualPoints[k].Y;
       end;
     end;
    end;

    procedure GetAboveTop;
    var i : integer;
    begin
     max := NextShape.Points[0].Y;
     for i := 1 to 3 do
      if NextShape.Points[i].Y > max
       then
        max := NextShape.Points[i].Y;

     for i := 0 to 3 do
      NextShape.Points[i].Y := NextShape.Points[i].Y - max - 1;
    end;

    procedure SetLetters;
    var
     i : integer;
    begin
     for i := 0 to 3 do NextShape.Letter[i] := RandomLetter;
    end;
begin
 Randomize;
 NextShape.Orientation := Random(4);
 SetLetters;
 case Random(13) of
  0,1 : begin
       CreateLine;
       NextShape.Shape := 'Line';
      end;
  2,3 : begin
       CreateChilledAsh;
       NextShape.Shape := 'ChilledAsh';
      end;
  4,5 : begin
       CreateGottaCatchEm;
       NextShape.Shape := 'GottaCatchEm';
      end;
  6 : begin
       CreateBlock;
       NextShape.Shape := 'Block';
      end;
  7,8 : begin
       CreateZed;
       NextShape.Shape := 'Zed';
      end;
  9,10 : begin
       CreateIcon;
       NextShape.Shape := 'Icon';
      end;
  11,12 : begin
       CreateEs;
       NextShape.Shape := 'Es';
      end;
 end;
 RandomOrientation;
 DrawNextShape;
 GetAboveTop;
end;

procedure WriteLetter(srd : TStringGrid; ACol, ARow : integer; txt : String);
var
 X1, X2, Y1, Y2 : integer;

begin
 X1 := ACol * srd.DefaultColWidth;
 X2 := (ACol + 1) * srd.DefaultColWidth;
 Y1 := ARow * srd.DefaultRowHeight;
 Y2 := (ARow + 1) * srd.DefaultRowHeight;

 SetTextAlign(srd.Canvas.Handle, TA_CENTER);
 srd.Canvas.Brush.Style := bsClear;
 srd.Canvas.Font.Color  := $000000;
 srd.Canvas.TextOut(X1 + (X2 - X1) div 2, Y1 + (Y2 - Y1) div 2 - Abs(srd.Font.Height div 2) - 1, txt);
 srd.Canvas.Font.Color  := $FFFFFF;
 srd.Canvas.TextOut(X1 + (X2 - X1) div 2, Y1 + (Y2 - Y1) div 2 - Abs(srd.Font.Height div 2), txt);

 srd.Canvas.Font.Color := clBlack;
end;

procedure TWordCity.BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
 if (ACol = (Sender as TStringGrid).Col) and (ARow = (Sender as TStringGrid).Row) then
  begin
   (Sender as TStringGrid).Canvas.Brush.Color := clBlack;
   (Sender as TStringGrid).Canvas.Pen.Color := clBlack;
   (Sender as TStringGrid).Canvas.Rectangle(Rect);
  end;
 if (ACol = (Board as TStringGrid).ColCount - 1) and (ARow = (Board as TStringGrid).RowCount - 1)
  then
   if not GetHasStarted
     then
      WaitingRoomSimple(Board);
 DrawBlock((Sender as TStringGrid), ACol, ARow, clTeal);
end;

procedure TWordCity.DrawBlock(SRD : TStringGrid; C, R : integer; clrBlock : TColor);
var
 D : integer;
begin
 if SRD.Cells[C, R] = '' then exit;
 SRD.Canvas.Brush.Color := clrBlock;
 D := SRD.DefaultColWidth;
 SRD.Canvas.Rectangle(C * D, R * D, (C + 1) * D, (R + 1) * D);
 Draw3DBorder(SRD, C, R);
 WriteLetter(SRD, C, R, SRD.Cells[C, R]);
end;

procedure TWordCity.DrawCurrent;
var
 i : integer;
begin
 for i := 0 to 3 do
  if CurrentShape.Points[i].Y > -1
   then
    Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y] := CurrentShape.Letter[i];
end;

procedure TWordCity.Highscore;
begin
 with qry do
  begin
   Sql.Clear;
   Close;
   SQL.Add('INSERT INTO [Word City]' );
   SQL.Add(GetInsertFields(qry));
   SQL.Add('VALUES("' + Self.GetUserName   + '"');
   SQL.Add(', ' + IntToStr(Score)    );
   SQL.Add(', ' + IntToStr(Target)   );
   SQL.Add(', ' + GetTimeSecs        );
   SQL.Add(', ' + FloatToStr(Date) + ')');
   ExecSQL;
  end;
 Inherited;
 ResetToDefault;
end;

procedure TWordCity.NewGame(Target : Integer);
var
 C, R : integer;
begin
 lsbWordsMade.Items.Clear;
 Self.Target := Target;
 for C := 0 to Board.ColCount do
  for R := 0 to Board.RowCount do
   Board.Cells[C, R] := '';
 score := 0;
 TimePlaying := 0;
 CreateShape;
 SwapEm;
 Timer.Enabled := true;
 State_NewGame(false);
end;

procedure TWordCity.OnBoardKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  function CantMove(Move : String) : boolean;
  var
   i    : integer;
   Vrtl : Array[0..3] of TPoint;
  begin
   Result := true;
   if Move = 'R' then //RIGTH//
    begin
         for i := 0 to 3 do
          begin
           Vrtl[i].X := CurrentShape.Points[i].X + 1;
           Vrtl[i].Y := CurrentShape.Points[i].Y;
          end;
         Result := OverLapping(Vrtl);
    end else
   if Move = 'L' then //LEFT//
    begin
         for i := 0 to 3 do
          begin
           Vrtl[i].X := CurrentShape.Points[i].X - 1;
           Vrtl[i].Y := CurrentShape.Points[i].Y;
          end;
         Result := OverLapping(Vrtl);
    end else
   if Move = 'D' then   //DOWN//
    begin
         for i := 0 to 3 do
          begin
           Vrtl[i].X := CurrentShape.Points[i].X;
           Vrtl[i].Y := CurrentShape.Points[i].Y + 1;
          end;
         Result := OverLapping(Vrtl);
    end else
   if Move = 'U' then    //UP//
    begin
         VirtualCurrent(CurrentShape);
         Result := not OverLapping(VirtualPoints);
    end;

   if not Result
    then
     ClearCurrent;
  end;

var
 i : integer;
begin
 if not CanPlay(false) then exit;
 Timer.Enabled := false;
 case key of
  VK_RIGHT : if not CantMove('R') then for i := 0 to 3 do CurrentShape.Points[i].X := CurrentShape.Points[i].X + 1;
  VK_LEFT  : if not CantMove('L') then for i := 0 to 3 do CurrentShape.Points[i].X := CurrentShape.Points[i].X - 1;
  VK_Down  : if not CantMove('D') then for i := 0 to 3 do CurrentShape.Points[i].Y := CurrentShape.Points[i].Y + 1;
  VK_UP, VK_SPACE : if CantMove('U') then for i := 0 to 3 do
                     begin
                      CurrentShape.Points[i].X := VirtualPoints[i].X;
                      CurrentShape.Points[i].Y := VirtualPoints[i].Y;
                     end;
 end;
 DrawCurrent;
 DrawNextShape;
 Board.Col := 0;
 Timer.Enabled := True;
end;

procedure TWordCity.OnTimer(Sender: TObject);
begin
 if not CanPlay(false) then exit;
 UpdatePos;
 DrawCurrent;
 DrawNextShape;
end;

function TWordCity.OverLapping(var
  VirtualShapePoints: array of TPoint): boolean;
var
 i : integer;
begin
 Result := false;
 for i := 0 to 3 do
  if (CurrentShape.Points[i].Y > -1) and (CurrentShape.Points[i].X > -1)
   then
    Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y] := '';

 for i := 0 to 3 do
  if (VirtualShapePoints[i].Y > -1) then
     if (VirtualShapePoints[i].X > Board.ColCount - 1)
     or (VirtualShapePoints[i].X < 0)
     or (VirtualShapePoints[i].Y > Board.RowCount - 1)
     then
      Result := True
     else if (Board.Cells[VirtualShapePoints[i].X, VirtualShapePoints[i].Y] <> '')
      then
       Result := true;

 if Result
  then
   for i := 0 to 3 do
    if (CurrentShape.Points[i].Y > -1) and (CurrentShape.Points[i].X > -1)
     then
      Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y] := CurrentShape.Letter[i];
end;

procedure TWordCity.Resize(w, h, e: integer);
var
 wsBoard : integer;
begin
 w := w - 16;
 h := h - 16;
 wsBoard    := Min(w - e, h);
 With Board do
  begin
    DefaultColWidth  := wsBoard div (RowCount + 2);
    DefaultRowHeight := wsBoard div (RowCount + 2);

    Width  := wsBoard  - Abs((DefaultColWidth + 2)  * RowCount - wsBoard) + 5;
    Height := wsBoard  - Abs((DefaultRowHeight + 2) * RowCount - wsBoard) + 5;
    Width  := Width div 2 - 5;

    Width  := Width  - Abs(DefaultColWidth  * 10 - Width)  ;
    Height := Height - Abs(DefaultRowHeight * 20 - Height) + 15;

    Left   := w div 2 - Width  div 2 + 8 - e div 2;
    Top    := h div 2 - Height div 2 + 8;

    Font.Size        := wsBoard div (Trunc(RowCount * 2));
  end;
 lblScore.Left    := lsbWordsMade.Left;
 lblScore.Top     := lsbWordsMade.Top + lsbWordsMade.Height + 8;
 NextShapeBoard.Left := lsbWordsMade.Left;
 NextShapeBoard.Top  := 40;
end;

procedure TWordCity.SwapEm;
var
 i : integer;
begin
 CurrentShape.Shape       := NextShape.Shape;
 CurrentShape.Orientation := NextShape.Orientation;
 CurrentShape.Letter      := NextShape.Letter;
 for i := 0 to 3 do
  begin
   CurrentShape.Points[i].X := NextShape.Points[i].X + 3;
   CurrentShape.Points[i].Y := NextShape.Points[i].Y;
  end;
 CreateShape;
end;

procedure TWordCity.UpdatePos;
var RowsChanged : Array[0..3] of Integer; ForgetShape : boolean;
    WordCount: Integer;

    procedure SetRowsChanged;
    var
     i : integer;
     C : integer;
    begin
     for i := 0 to 3 do
      begin
       if ((CurrentShape.Points[i].X > -1) and (CurrentShape.Points[i].Y > -1)) then
       if Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y + 1] <> '' then
        begin
         RowsChanged[i] := CurrentShape.Points[i].Y;
         Continue;
        end else
        for C := CurrentShape.Points[i].Y to Board.RowCount - 1 do
         if Board.Cells[ CurrentShape.Points[i].X, C] = '' then
          begin
           RowsChanged[i] := C;
           Break;
          end;
      end;
    end;

    function IsChangedRow(R : integer) : boolean;
    var
     i : integer;
    begin
     Result := not ForgetShape;
     For i := 0 to 3 do
      if RowsChanged[i] = R
       then
        Result := true;
    end;

    function DropTheRest(WithCheck : boolean) : boolean;
    var
     C, R, i, k, j : integer;
     done    : boolean;
     sword   : string;
    begin
     Result := false;
     SetRowsChanged;
     Repeat
      for C := 0 to Board.ColCount - 1 do
       for R := 0 to Board.RowCount - 2 do
        if Board.Cells[C, R + 1] = '' then
         begin
          Board.Cells[C, R + 1] := Board.Cells[C, R];
          Board.Cells[C, R] := '';
         end;
      done := true;
      for C := Board.ColCount - 1 downto 0 do
       for R := Board.RowCount - 2 downto 0 do
        if (Board.Cells[C, R] <> '') and (Board.Cells[C, R + 1] = '') then
         begin
          done := false;
          break;
         end;
     Until done;

     if WithCheck then
      for R := Board.RowCount - 1 downto 0 do
      if IsChangedRow(R) then
      begin
       for C := 0 to Board.ColCount - 2 do
        begin
         sWord := '';
         for i := 0 to Board.ColCount - 1 do
          if Board.Cells[i, R] <> ''
           then
            sWord := sWord + Board.Cells[i, R]
           else
           if (sWord <> '')
            then
             if length(sWord) = 1
              then
               sWord := '';
         if (sWord = '') or (length(sWord) = 1) then continue;

         for k := C to Board.ColCount - 1 do
         begin
          sWord := '';
          for j := C to k do
           if Board.Cells[j, R] <> ''
            then
             sWord := sWord + Board.Cells[j, R]
            else
             break;
          if sWord = '' then continue;
          qry.Close;
          qry.SQL.Text := 'SELECT word FROM [Word List] WHERE word = "' + sWord + '"';
          qry.Open;
          //lsbWordsMade.Items.Add(sWord);
          if IsAWord(sWord) and (Length(sWord) > 1) then
           begin
           // showmessage(sWord);
            Result := true;
            exit;
           end;
         end;
        end;

      end;
      Board.Refresh;
    end;

    procedure GetScore(sWord : string; Row : integer);
    begin
     Score := Score + Length(sWord) * (Row + 1);
     lsbWordsMade.Items.Add(sWord)
    end;

    procedure RemoveWords;
    var
     C, R, k, j : integer;
     RemoveCells : Array of TPoint;
     sWord : string;
     done : boolean;
    begin
     SetLength(RemoveCells, 0);
     done := false;
     for R := Board.RowCount - 1 downto 0 do
     if IsChangedRow(R) then
      begin
       for C := 0 to Board.ColCount - 2 do
        begin
         sWord := '';
         for k := 0 to Board.ColCount - 1 do
          sWord := sWord + Board.Cells[k, R];
         if sWord = '' then
          begin
           done := true;
           break;
          end;

          for k := C to Board.ColCount - 1 do
          begin
           sWord := '';
           if Board.Cells[k, R] = '' then break;
           for j := C to k do
            if Board.Cells[j, R] <> ''
             then
              sWord := sWord + Board.Cells[j, R]
             else
              break;
           if sWord = '' then break;
           qry.Close;
           qry.SQL.Text := 'SELECT word FROM [Word List] WHERE word = "' + sWord + '"';
           qry.Open;
           if (qry.RecordCount > 0) and (Length(sWord) > 1) then
            begin
             inc(WordCount);
             if Length(sWord) > 4
              then
               frmAchievements.AchievementComplete(That_Takes_Planning);
             for j := C to k do
              if Board.Cells[j, R] <> '' then
               begin
                SetLength(RemoveCells, Length(RemoveCells) + 1);
                RemoveCells[Length(RemoveCells) - 1].X := j;
                RemoveCells[Length(RemoveCells) - 1].Y := R;
               end else
                break;
               GetScore(sWord, R);
            end;
          end;
        end;
       if done then break;
      end;
       ForgetShape := true;
       timer.Enabled := true;
       Board.Refresh;
       for k := Low(RemoveCells) to High(RemoveCells) do
        begin
         DrawBlock(Board, RemoveCells[k].X, RemoveCells[k].Y, clAqua);
         Sleep(50);
         Board.Cells[RemoveCells[k].X, RemoveCells[k].Y]:= '';
        end;
       timer.Enabled := false;
    end;

    procedure DeleteLines;
    var
     C, R : integer;
     IsLine : boolean;
     wholeline : string;
    begin
     for R := 0 to Board.RowCount - 1 do
      begin
       IsLine := True;
       wholeline := '';
       for C := 0 to Board.ColCount - 1 do
        Wholeline := wholeline + Board.Cells[C, R];
       if wholeline = '' then exit;
       for C := 0 to Board.ColCount - 1 do
        if Board.Cells[C, R] = ''
         then
          IsLine := false;
       if IsLine then
        begin
         for C := 0 to Board.ColCount - 1 do
          Board.Cells[C, R] := '';
         Score := Score - 50;
         DropTheRest(false);
        end;
      end;
    end;

   function ReachedTheTop : boolean;
   var
    C : integer;
   begin
    Result := false;
    for C := 0 to Board.ColCount - 1 do
     if Board.Cells[C, 0] <> ''
      then
       Result := True;
   end;

var
 i, C, R : integer;
 b       : boolean;
 vrtl    : Array[0..3] of Tpoint;

begin
 timer.Enabled := false;
 WordCount := 0;

 b := true;
 for i := 0 to 3 do
  begin
   Vrtl[i].X := CurrentShape.Points[i].X;
   Vrtl[i].Y := CurrentShape.Points[i].Y + 1;
  end;

 if OverLapping(Vrtl) then
  begin
   ForgetShape := false;
   While DropTheRest(True) do RemoveWords;
   SwapEm;
   b := false;
  end;

 if WordCount > 1
  then
   frmAchievements.AchievementComplete(Two_Birds_One_Stone);

 if b then
 begin
  ClearCurrent;
  for i := 0 to 3 do CurrentShape.Points[i].Y := CurrentShape.Points[i].Y + 1;
 end;

 for i := 0 to 3 do
 if (CurrentShape.Points[i].Y > - 1) then
 if (Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y + 1] <> '') and (CurrentShape.Points[i].Y = 0) then
  begin
  for C := 0 to Board.ColCount - 1 do
   for R := 0 to Board.RowCount - 1 do
    Board.Cells[C, R] := '';
  DrawCurrent;
  DrawNextShape;
 end;

 DeleteLines;
 if (Score >= Target)
  then
   Highscore;
 lblScore.Caption := 'Score: ' + IntToStr(score);
 timer.Enabled := true;
end;

procedure TWordCity.VirtualCurrent(VirtualShape: TWordCityTile);
var
 stre, infield : integer;
 max           : TPoint;
 i             : integer;
begin
 timer.Enabled := false;

 for i := 0 to 3 do
  begin
   VirtualPoints[i].X := VirtualShape.Points[i].X;
   VirtualPoints[i].Y := VirtualShape.Points[i].Y;
  end;

 max.Y := VirtualPoints[0].Y;
 max.X := VirtualPoints[0].X;
 for i := 1 to 3 do
  if VirtualPoints[i].Y > max.Y then
   begin
    max.Y := VirtualPoints[i].Y;
    max.X := VirtualPoints[i].X;
   end;

 for i := 0 to 3 do
  begin
   VirtualPoints[i].X := VirtualPoints[i].X - Max.X;
   VirtualPoints[i].Y := VirtualPoints[i].Y - Max.Y;
  end;

 for i := 0 to 3 do
  begin
   stre := VirtualPoints[i].X;
   VirtualPoints[i].X := -VirtualPoints[i].Y;
   VirtualPoints[i].Y := stre;
  end;

 for i := 0 to 3 do
  begin
   VirtualPoints[i].X := VirtualPoints[i].X + Max.X;
   VirtualPoints[i].Y := VirtualPoints[i].Y + Max.Y;
  end;


 {< 0}
 infield := VirtualPoints[0].X;
 for i := 1 to 3 do
  if VirtualPoints[i].X < infield then infield := VirtualPoints[i].X;

 if infield < 0
  then
   for i := 0 to 3 do VirtualPoints[i].X := VirtualPoints[i].X + ABS(infield);
 {> colcount - 1}
 infield := VirtualPoints[0].X;
 for i := 1 to 3 do
  if VirtualPoints[i].X > infield then infield := VirtualPoints[i].X;

 if infield > Board.ColCount - 1
  then
   for i := 0 to 3 do VirtualPoints[i].X := VirtualPoints[i].X - infield + Board.ColCount - 1;

 timer.Enabled := true;
end;

procedure TWordCity.LoadGame;
    procedure TypeLineToRow(sText : string; var Row : Integer);
    var
     i : integer;
    begin
     if sText <> '' then
     For i := 0 to Board.ColCount - 1 do
      if sText[i + 1] <> ' '
       then
        Board.Cells[i, Row] := sText[i + 1]
       else
        Board.Cells[i, Row] := '';
     inc(Row);
    end;

    procedure ShapeDetails(var Shape : TWordCityTile; sDetails : string; var ipoint : integer);
    begin
     Shape.Points[ipoint].X := StrToInt(Copy(sDetails, 1, Pos(':', sDetails) - 1                     ));
     Shape.Points[ipoint].Y := StrToInt(Copy(sDetails, Pos(':', sDetails) + 1, Pos('=', sDetails) - 1 - Pos(':', sDetails)));
     Shape.Letter[ipoint]   := Copy(sDetails, Pos('=', sDetails) + 1, Length(sDetails))[1];
     inc(ipoint);
    end;

var
 txt : TextFile;
 sHeader, sLine : string;
 iRow, iShape : integer;
begin
 assignFile(txt, GetGameSaveFile);
 if FileExists(GetGameSaveFile)
  then                                                           
   Reset(txt)
  else begin
   Quit;
   exit;
  end;

 iRow := 0;
 iShape := 0;
 sHeader := 'Board';
 While not eof(txt) do
  begin
   ReadLn(txt, sLine);
   if (sLine = 'CurrentShape') or (sLine = 'NextShape') or (sLine = 'FoundWords') or (sLine = 'Score') or (sLine = 'Time') or (sLine = 'Target') then
    begin
     sHeader := sLine;
     if (sLine = 'CurrentShape') or (sLine = 'NextShape')
      then
       iShape := 0;
     continue;
    end;

   if sHeader = 'Board'
    then
     TypeLineToRow(sLine, iRow)
    else
   if sHeader = 'NextShape'
    then
     ShapeDetails(NextShape, sLine, iShape)
    else
   if sHeader = 'CurrentShape'
    then
     ShapeDetails(CurrentShape, sLine, iShape)
    else
   if sHeader = 'FoundWords'
    then
     lsbWordsMade.Items.Add(sLine)
    else
   if sHeader = 'Score' then
    begin
     Score := StrToInt(sLine);
     lblScore.Caption := 'Score: ' + IntToStr(Score);
    end else
   if sHeader = 'Time'
    then
     TimePlaying := StrToInt(sLine)
    else
   if sHeader = 'Target'
    then
     Target := StrToInt(sLine);
  end;
 DrawCurrent;
 DrawNextShape;
 State_NewGame(true);
 Timer.Enabled := True;
 CloseFile(txt);
end;

procedure TWordCity.SaveGame;
var
 txt : TextFile;
 C, R, i : integer;
 sRow : string;
begin
 if (not GetHasStarted) then exit;
 AssignFile(txt, GetGameSaveFile);
 Rewrite(txt);

 for i := 0 to 3 do
  if CurrentShape.Points[i].Y > -1
   then
    Board.Cells[CurrentShape.Points[i].X, CurrentShape.Points[i].Y] := '';

 for R := 0 to Board.RowCount - 1 do
  begin
   sRow := '';
   for C := 0 to Board.ColCount - 1 do
    if Board.Cells[C, R] <> ''
     then
      sRow := sRow + Board.Cells[C, R]
     else
      sRow := sRow + ' ';
   Writeln(txt, sRow);
  end;

 WriteLn(txt, 'CurrentShape');
 for i := 0 to 3 do
  WriteLn(txt, IntToStr(CurrentShape.Points[i].X) + ':' + IntToStr(CurrentShape.Points[i].Y) + '=' + CurrentShape.Letter[i]);

 WriteLn(txt, 'NextShape');
 for i := 0 to 3 do
  WriteLn(txt, IntToStr(NextShape.Points[i].X) + ':' + IntToStr(NextShape.Points[i].Y) + '=' + NextShape.Letter[i]);

 WriteLn(txt, 'FoundWords');
 for i := 0 to lsbWordsMade.Items.Count - 1 do
  WriteLn(txt, lsbWordsMade.Items[i]);

 WriteLn(txt, 'Score');
 WriteLn(txt, IntToStr(Score));

 WriteLn(txt, 'Target');
 WriteLn(txt, IntToStr(Target));

 WriteLn(txt, 'Time');
 WriteLn(txt, IntToStr(TimePlaying));

 CloseFile(txt);
end;

procedure TWordCity.Quit;
begin
 Inherited;
 ResetToDefault;
end;

procedure TWordCity.ResetToDefault;
var
 C, R, i: integer;
begin
 for i := 0 to 3 do
  begin
   CurrentShape.Points[i].X := -1;
   CurrentShape.Points[i].Y := -1;
  end;
 for C := 0 to Board.ColCount - 1 do
  for R := 0 to Board.RowCount - 1 do
   Board.Cells[C, R] := '';
 for C := 0 to NextShapeBoard.ColCount - 1 do
  for R := 0 to NextShapeBoard.RowCount - 1 do
   NextShapeBoard.Cells[C, R] := '';
 lsbWordsMade.Items.Clear;
 lblScore.Caption := '';
 Target := 0;
 Score := 0;
 Board.Refresh;
 NextShapeBoard.Refresh;
end;

procedure TWordCity.DrawNextShape;
var
 C, R, i, min : integer;
begin
 for C := 0 to NextShapeBoard.ColCount - 1 do
  for R := 0 to NextShapeBoard.RowCount - 1 do
   NextShapeBoard.Cells[C, R] := '';

 min := NextShape.Points[0].Y;
 for i := 1 to 3 do
  if min > NextShape.Points[i].Y
   then
    min := NextShape.Points[i].Y;

 for i := 0 to 3 do
  NextShape.Points[i].Y := NextShape.Points[i].Y + ABS(min);

 min := NextShape.Points[0].X;
 for i := 1 to 3 do
  if min > NextShape.Points[i].X
   then
    min := NextShape.Points[i].X;

 for i := 0 to 3 do
 if NextShape.Points[i].X - ABS(min) > -1 then
  NextShape.Points[i].X := NextShape.Points[i].X - ABS(min) ;

 for i := 0 to 3 do
  if NextShape.Points[i].Y > -1 then
  NextShapeBoard.Cells[NextShape.Points[i].X, NextShape.Points[i].Y] := NextShape.Letter[i];
end;

end.
