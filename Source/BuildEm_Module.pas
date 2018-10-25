unit BuildEm_Module;

interface

uses
 Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ADODB, ComCtrls, Math, StdCtrls, ExtCtrls, Spin,
  BoardGames_Board__Module, FindEm_Module, Achievements_Module, Achievements_Controller;

type
  TBuildEm = class(TFindEm)
   Protected
    function Straight: Boolean;

    procedure BoardOnDrawCell(Sender: TObject;
                              ACol, ARow: Integer;
                              Rect: TRect;
                              State: TGridDrawState); Override;

    procedure BoardMouseMove(Sender: TObject;
                            Shift: TShiftState;
                            X, Y: Integer);

    procedure BoardMouseDown(Sender: TObject;
                             Button: TMouseButton;
                             Shift : TShiftState;
                             X, Y  : Integer);  Override;

    procedure BoardMouseUp(Sender: TObject;
                           Button: TMouseButton;
                           Shift : TShiftState;
                           X, Y  : Integer);  Override;
   public
    Constructor Create(srd: TStringGrid; lblT, lblW, lblS: TLabel); Override;
    procedure HighLightSelectedWord; Override;
  end;

implementation

{ TBuildEm }

procedure TBuildEm.BoardMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not CanPlay(False) then exit;
 SetLength(CellsPicked, 1);
 Board.MouseToCell(X, Y, CellsPicked[0].X, CellsPicked[0].Y);
 lblWord.Caption := ' Your Word: ' + GetCurrentWord + ' = ' + IntToStr(GetWordScore);
end;

procedure TBuildEm.BoardMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 C, R, iX, iY : integer;
begin
 if not CanPlay(False) or (GetAsyncKeyState(VK_LBUTTON) >= 0) then exit;
 Board.MouseToCell(X, Y, C, R);
 if (C and R < 0) then exit;
 iX := CellsPicked[High(CellsPicked)].X;
 iY := CellsPicked[High(CellsPicked)].Y;

 if (C = iX) and (R = iY)
  then
   exit
  else
 if (C = CellsPicked[0].X) and (R = CellsPicked[0].Y)
  then begin
   SetLength(CellsPicked, 1);
   exit;
  end;


 if PointInArray(C, R, CellsPicked) > -1 then
  begin
   SetLength(CellsPicked, PointInArray(C, R, CellsPicked) + 1);
   if not( (CellsPicked[PointInArray(C, R, CellsPicked)].X = iX ) and (CellsPicked[PointInArray(C, R, CellsPicked)].Y = iY) )
    then
     Board.Refresh;
  end else
 if Length(CellsPicked) <= 9
  then
 if (C in [iX-1..iX+1])and(R = iY) or (R in [iY-1..iY+1])and(C = iX) or (C = 1)and(R = iY)and(iX = 0) or (R = 1)and(C = iX)and(iY = 0) then
  begin
     SetLength(CellsPicked, Length(CellsPicked) + 1);
     CellsPicked[Length(CellsPicked) - 1].X := C;
     CellsPicked[Length(CellsPicked) - 1].Y := R;
  end;

 if GetCurrentword <> ''
  then
   lblWord.Caption := ' Your Word: ' + GetCurrentword + ' = ' + IntToStr(GetWordScore)
  else
   lblWord.Caption := ' Your Word: ';
end;

procedure TBuildEm.BoardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure RandomLetters;
     var
      i : integer;
     begin
      for i := 0 to High(CellsPicked) do
       Board.Cells[CellsPicked[i].X, CellsPicked[i].Y] := RandomLetter;
      SetLength(CellsPicked, 1);
     end;
begin
 if not CanPlay(True) then exit;
 if length(GetCurrentWord) < 2 then exit;
 lblWord.Caption := ' Your Word:';
 if IsAWord(GetCurrentword) then
  begin
   Score := Score + GetWordScore;
   RandomLetters;
   if Straight
    then
     frmAchievements.AchievementComplete(Straight_As_An_Arrow);
   if High(CellsPicked) = 9
    then
     frmAchievements.AchievementComplete(As_Long_As_Possible);
   if Pos('B', GetCurrentword) > 0
    then
     if Pos('B', Copy(GetCurrentword, Pos('B', GetCurrentword), MaxInt)) > 0
      then
       frmAchievements.AchievementComplete(Double_Trouble);
   Inc(WordsFound);
  end else
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

procedure TBuildEm.BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
 AlignCenterText(Board, ACol, ARow, Rect, Board.Cells[ACol, ARow]);
end;

constructor TBuildEm.Create(srd: TStringGrid; lblT, lblW, lblS: TLabel);
begin
 Inherited Create;
 SetGameName('Build ''Em');
 Board := srd;
 Board.OnDrawCell  := BoardOnDrawCell;
 Board.OnMouseDown := BoardMouseDown;
 Board.OnMouseUp   := BoardMouseUp;
 Board.OnMouseMove := BoardMouseMove;
 TimePlaying := 0;
 State_Create(False);
 lblTime := lblT;
 lblWord := lblW;
 lblScore:= lblS;
 SetLength(CellsPicked, 0);
end;

function GetTextDimension(s : string; size : integer; Width : boolean) : integer;
var
 cnvs : TBitmap;
begin
 Try
  cnvs := TBitmap.Create;
  cnvs.Canvas.Font.Name := 'Lucida fax';
  cnvs.Canvas.Font.Size := size;
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

procedure TBuildEm.HighLightSelectedWord;
    procedure HighlightPair(Start: integer);
    var
     D, X, Y, iX, iY: integer;
    begin
     D := Board.DefaultColWidth;
     X := CellsPicked[Start].X * D  + D div 2;
     Y := CellsPicked[Start].Y * D  + D div 2;
     iX := CellsPicked[Start + 1].X  * D  + D div 2;
     iY := CellsPicked[Start + 1].Y  * D  + D div 2;
     With Board.Canvas do
      begin
       Pen.Width := D;
       Pen.Color := clBlue;
       MoveTo(X, Y);
       LineTo(iX, iY);
      end;
    end;

    procedure WriteLetter(i: integer);
    var
     X, Y, D: integer;
    begin
     X := CellsPicked[i].X;
     Y := CellsPicked[i].Y;
     D := Board.DefaultColWidth;
     Board.Canvas.Font := Board.Font;
     Board.Canvas.TextOut(X * D + D div 2 - GetTextDimension(Board.Cells[X, Y], Board.Font.Size, True) div 2,
                          Y * D + D div 2 - GetTextDimension(Board.Cells[X, Y], Board.Font.Size, False) div 2,
                          Board.Cells[X, Y]);
    end;

    procedure UnHighLight(Start: integer);
    var
     D, X, Y, iX, iY: integer;
    begin
     D := Board.DefaultColWidth;
     X := CellsPicked[Start].X * D  + D div 2;
     Y := CellsPicked[Start].Y * D  + D div 2;
     iX := CellsPicked[Start + 1].X  * D  + D div 2;
     iY := CellsPicked[Start + 1].Y  * D  + D div 2;
     With Board.Canvas do
      begin
       Pen.Width := D - 2;
       Pen.Color := clWhite;
       if (Y > iY) then
        begin
         MoveTo(X, Y - 1);
         LineTo(iX, iY + 1);
        end else
       if (Y < iY) then
        begin
         MoveTo(X, Y + 1);
         LineTo(iX, iY - 1);
        end else
       if (X > iX) then
        begin
         MoveTo(X - 1, Y);
         LineTo(iX + 1, iY);
        end else
       if (X < iX) then
        begin
         MoveTo(X + 1, Y);
         LineTo(iX - 1, iY );
        end;
       WriteLetter(Start);
       WriteLetter(Start + 1);
      end;

    end;

var
 i : integer;
begin
 if not GetHasStarted
  then
   WaitingRoom(Board)
  else begin
   for i := 0 to High(CellsPicked) - 1 do
      HighLightPair(i);
   for i := 0 to High(CellsPicked) - 1 do
      UnHighLight(i);
  end;
end;

function TBuildEm.Straight: Boolean;
var
 i: integer;
 Horx, Vert: boolean;
begin
 Horx := true;
 Vert := true;
 for i := 0 to High(CellsPicked) do
  if CellsPicked[i].X <> CellsPicked[0].X then
   begin
    Horx := false;
    break;
   end;

 for i := 0 to High(CellsPicked) do
  if CellsPicked[i].Y <> CellsPicked[0].Y then
   begin
    Vert := false;
    break;
   end;

 Result := Vert or Horx;
end;

end.
