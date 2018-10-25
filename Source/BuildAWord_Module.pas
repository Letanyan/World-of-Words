unit BuildAWord_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ExtCtrls, StdCtrls, HangManGame_Module, DB, Grids,
  DBGrids, ADODB, DBCtrls, Spin, WordSearch_Module, BoardGames_Board__Module,
  jpeg, Math, Sorting, Achievements_Module, Achievements_Controller;

const
   LetterValues : Array['A'..'Z'] of Integer =  //Used For Scoring
   (
     1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10
   );

   TripleWords      : Array[0..7] of TPoint =
    (
     (X : 0 ; Y : 0),  //TL  //1A
     (X : 7 ; Y : 0),  //TC  //8A
     (X : 14; Y : 0),  //TR  //15A
     (X : 0 ; Y : 7),  //ML  //1H
     (X : 14; Y : 7),  //MR  //15H
     (X : 0 ; Y : 14), //BL  //1O
     (X : 7 ; Y : 14), //BC  //8O
     (X : 14; Y : 14)  //BC  //15O
    );
   DoubleLetters    : Array[0..23] of TPoint =
    (
     (X : 3 ; Y : 0),   //4A
     (X : 11; Y : 0),   //12A
     (X : 6 ; Y : 2),   //7C
     (X : 8 ; Y : 2),   //9C
     (X : 0 ; Y : 3),   //1D
     (X : 7 ; Y : 3),   //8D
     (X : 14; Y : 3),   //15D
     (X : 2 ; Y : 6),   //3G
     (X : 6 ; Y : 6),   //7G
     (X : 8 ; Y : 6),   //9G
     (X : 12; Y : 6),   //13G
     (X : 3 ; Y : 7),   //4H
     (X : 11; Y : 7),   //12H
     (X : 2 ; Y : 8),   //3I
     (X : 6 ; Y : 8),   //7I
     (X : 8 ; Y : 8),   //9I
     (X : 12; Y : 8),   //13I
     (X : 0 ; Y : 11),  //1L
     (X : 7 ; Y : 11),  //8L
     (X : 14; Y : 11),  //15L
     (X : 6 ; Y : 12),  //7M
     (X : 8 ; Y : 12),  //9M
     (X : 3 ; Y : 14),  //4O
     (X : 11; Y : 14)   //12O
    );
   DoubleWords      : Array[0..15] of TPoint =
   (
    (X : 1 ; Y : 1),  //2B
    (X : 13; Y : 1),  //14B
    (X : 2 ; Y : 2),  //3C
    (X : 12; Y : 2),  //13C
    (X : 3 ; Y : 3),  //4D
    (X : 11; Y : 3),  //12D
    (X : 4 ; Y : 4),  //5E
    (X : 10; Y : 4),  //11E
    (X : 4 ; Y : 10), //5K
    (X : 10; Y : 10), //11K
    (X : 3 ; Y : 11), //4L
    (X : 11; Y : 11), //12L
    (X : 2 ; Y : 12), //3M
    (X : 12; Y : 12), //13M
    (X : 1 ; Y : 13), //2N
    (X : 13; Y : 13)  //14NB
   );
   TripleLetters    : Array[0..11] of TPoint =
   (
    (X : 5 ; Y : 1),  //6B
    (X : 9 ; Y : 1),  //10B
    (X : 1 ; Y : 5),  //2F
    (X : 5 ; Y : 5),  //6F
    (X : 9 ; Y : 5),  //10F
    (X : 13; Y : 5),  //14F
    (X : 1 ; Y : 9),  //2J
    (X : 5 ; Y : 9),  //6J
    (X : 9 ; Y : 9),  //10J
    (X : 13; Y : 9),  //14J
    (X : 5 ; Y : 13), //6N
    (X : 9 ; Y : 13) //10N
   );

type
 TTile = class
  Public
   pnlTile        : TPanel;
   lblLetter      : TLabel;
   lblLetterValue : TLabel;
   Constructor Create(ownr : TPanel);
   procedure   ChangeLetter(Letter : string);  //As Well as the value caption
 end;

 TMovableTile = Record
  X, Y, lbl : integer;
 end;

 TBuildAWord = class(TBoard)
  protected
   frm              : TForm;
   Board            : TStringGrid;
   CurrentLetter    : char;
   PlacedLetters    : Array of TMovableTile;    //Current Players Letters
   NumLettersUsed   : integer;            //Number of letters on board for current player
  // CharLettersUsed  : array of char;      //Current Letters On Board
   TileNumber       : integer;
   LetterPickedUp   : TMovableTile;
   LetterTray       : Array[1..4] of array[1..7] of char; //the letters on the 4 players trays
   TotalPlayers     : Integer;
   CurrentScore     : Integer;
   FirstPlayerOver  : Integer;

   Mode             : Char;    //how to tell how to end the game
   Scores           : Array[1..4] of integer;
   HoldingTile      : TTile;    //floating tile waiting to be placed
   Tiles            : array[1..7] of TTile; //current players tiles
  // iLettersonBoard  : integer;
   LettersOnBoard   : array of TPoint;   //All points used and confirmed
   LetterCount      : array['A'..'Z'] of Integer; //how many letters are left
   BonusTiles       : Array[0..60] of TPoint; //All bonus tiles
   CurrentUser      : Integer;
   Turns            : integer;
   Users            : array[1..4] of string;

   procedure   TileDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   procedure   TileMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
   procedure   TileUp  (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

   procedure   BoardUp  (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   procedure   BoardMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
   procedure   BoardDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

   procedure   SetDefaultBonusTiles;

   function  RandomLetter : char;


   procedure SetCurLetter(c : char);
   procedure MoveTile(frm : TForm);

   function  NumberOfLettersActualyOnBoard: integer;
   function  GetCurrentPlayersWord(GoAcross : boolean) : string;
   function  GoAcrossOrNot: Char;
   function  CurrentWordinCorrectPosition : boolean;
   function  GetStem(C, R: Integer; GoAcross: Char; FindBonus: Boolean): string;
   function  GetStartPoint(GoAcross: Char): TPoint;
    function GetStartPos: integer;
   function  AllWordsExist: boolean;
   procedure PlaceLetterOnBoard(col, row : integer; Tile : TTile);
   procedure NextUser(CorrectWord: boolean);
   function  GetPlayerScore: Integer;
   procedure BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);

   procedure SetNextUsersTiles;
   procedure RandomLetters;
   procedure RemoveCurrentWord;
   procedure ReplaceLetters;
   function  TypeOfCell(C, R: integer): String;
  protected
   procedure HighScore; Override;
  public
   constructor Create(frm : TForm; trayHolder, brdHolder : TPanel; srd: TStringGrid);

   procedure GetScore(lbl : TLabel);

   procedure Quit; Override;
   procedure ResetToDefault;

   procedure NewGame(ownr : TPanel; u1, u2, u3, u4 : string; Mode : integer);
   procedure SaveGame; Override;
   procedure LoadGame; Override;

   procedure Repick;
   procedure Recall;
   procedure SkipTurn;

   procedure ResizeBoard(ownr : TPanel);

   procedure CheckWord;
 end;

implementation

{ TTile }

constructor TTile.Create(ownr: TPanel);
begin
 pnlTile            := TPanel.Create(ownr);
 pnlTile.Parent     := ownr;
 pnlTile.Align      := alLeft;
 pnlTile.Width      := ownr.Height;
 pnlTile.Color      := $009DDCE1;
 //pnlTile.BevelInner := bvLowered;

 lblLetterValue             := TLabel.Create(ownr);
 lblLetterValue.Parent      := pnlTile;
 lblLetterValue.Transparent := true;
 lblLetterValue.Caption     := '';
 lblLetterValue.Left        := pnlTile.Width  - lblLetterValue.Width;
 lblLetterValue.Top         := pnlTile.Height - lblLetterValue.Height;
 lblLetterValue.Font.Color  := $00006C21;
 lblLetterValue.Font.Name   := 'Lucida Fax';
 lblLetterValue.Font.Size   := 10;
 lblLetterValue.Alignment   := taRightJustify;


 lblLetter             := TLabel.Create(ownr);
 lblLetter.Parent      := pnlTile;
 lblLetter.Caption     := '';
 lblLetter.Transparent := true;
 lblLetter.Left        := 0;
 lblLetter.Top         := 0;
 lblLetter.Align       := alClient;
 lblLetter.Font.Color  := $00006C21;
 lblLetter.Font.Name   := 'Lucida Fax';
 lblLetter.Font.Size   := 15;
end;

procedure TTile.ChangeLetter(Letter: string);
begin
 lblLetter.Caption := Letter;
 lblLetterValue.Caption := IntToStr(LetterValues[Letter[1]]);
end;

{ TBuildAWord }

function WordScore(s : string) : integer;
var
 i : integer;
 c : char;
 bonus : char;
 tripWordcnt : integer;
 doubWordcnt : integer;
begin
 Result := 0;
 tripWordcnt := 0;
 doubWordcnt := 0;
 bonus := ' ';
 for i := 1 to length(s) do
  begin
   c := Uppercase(s)[i];
   if c in ['A'..'Z'] then
    begin
     if bonus = '+'  //Double Letter
      then
       Result := Result + LetterValues[c] * 2
      else
     if bonus = '*'  //Triple Letter
      then
       Result := Result + LetterValues[c] * 3
      else
     if bonus = ' '  //Nothing
      then
       Result := Result + LetterValues[c];

     bonus := ' ';
    end else
    if c in ['+', '*']  //double or triple letter
     then
      bonus := c
     else
      if c = '^'    //store double word for later
       then
        inc(doubWordcnt)
       else
      if c = '!'   //store triple word for later
       then
        inc(tripWordcnt);
  end;

  for i := 1 to doubWordcnt do
   Result := Result * 2;

  for i := 1 to tripWordcnt do
   Result := Result * 3;
end;

procedure TBuildAWord.RemoveCurrentWord; //if word was not valid
var
 i : integer;
begin
 for i := 1 to NumLettersUsed do
 if (PlacedLetters[i].X > -1) and (PlacedLetters[i].Y > -1) then
  begin
   if Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y] <> '' //if there's a letter
    then
     Inc(LetterCount[Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y][1]]); //increase the used letter count for that letter
   Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y] := '';
   PlacedLetters[i].X := -1;
   PlacedLetters[i].Y := -1;
  end;
 NumLettersUsed := 0;
end;

function OnBonusTile(var bonusTiles : array of TPoint; c, r : Integer; RemoveTile : boolean) : Char;
var
 i : integer;
begin
 Result := ' ';
 for i := Low(BonusTiles) to High(BonusTiles) do
  if (bonusTiles[i].X = c) and (bonusTiles[i].Y = r) then
   Begin
    if i in [0..7]
     then
      Result := '!'   //triple word
     else
    if i in [8..31]
     then
      Result := '+'    //double letter
     else
    if (i in [32..47]) or (i = 60)
     then
      Result := '^'    //double Word
     else
    if i in [48..59]
     then
      Result := '*';   //triple word
    if RemoveTile then // if its not just to check if there is a bonus tile then remove the bonus
     begin
      bonusTiles[i].X := -1;
      bonusTiles[i].Y := -1;
     end;
   end;
end;

function TBuildAWord.GetCurrentPlayersWord(GoAcross: boolean): string;
var
 lowest, highest, i, first : integer;
begin
 Result := '';
 if GoAcross then
  begin
   First := 1;
   lowest := 0;
   for i := 1 to NumLettersUsed do
   if PlacedLetters[i].X > -1 then
   begin
    lowest := PlacedLetters[i].X;
    break;
   end;

   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].X > -1
     then
    if lowest > PlacedLetters[i].X
     then lowest := PlacedLetters[i].X;

   Highest := PlacedLetters[1].X;
   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].X > -1
     then
    if Highest < PlacedLetters[i].X
     then Highest := PlacedLetters[i].X;

   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].X and PlacedLetters[i].Y > -1 then
     begin
      First := i;
      break;
     end;

   for i := lowest to highest do
    if Board.Cells[i, PlacedLetters[First].Y] = ''
     then
      Result := Result + ' '
     else
      Result := Result + Board.Cells[i, PlacedLetters[First].Y];
  end else
  begin
   First := 1;
   lowest := 0;
   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].Y > -1 then
    begin
     lowest := PlacedLetters[i].Y;
     break;
    end;

   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].Y > -1
     then
    if lowest > PlacedLetters[i].Y
     then lowest := PlacedLetters[i].Y;

   Highest := PlacedLetters[1].Y;
   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].Y > -1
     then
    if Highest < PlacedLetters[i].Y
     then Highest := PlacedLetters[i].Y;

   for i := 1 to NumLettersUsed do
    if PlacedLetters[i].X and PlacedLetters[i].Y > -1 then
     begin
      First := i;
      break;
     end;

   for i := lowest to highest do
    if Board.Cells[PlacedLetters[First].X, i] = ''
     then
      Result := Result + ' '
     else
      Result := Result + Board.Cells[PlacedLetters[First].X, i];
  end;
end;

function TBuildAWord.GetStem(C, R: Integer; GoAcross: Char; FindBonus: Boolean): string;
var
 BonusType: string;
begin
 Result := '';
 Repeat
  if GoAcross = 'F'
   then
    dec(C)
   else
    dec(R);
  if C or R < 0 then break;
 Until Board.Cells[C, R] = '';

 Repeat
  if GoAcross = 'F'
   then
    inc(C)
   else
    inc(R);
  if Board.Cells[C, R] <> '' then
   begin
    if FindBonus
     then
      BonusType := OnBonusTile(BonusTiles, C, R, True)
     else
      BonusType := ' ';
    if BonusType = ' '
     then
      Result := Result + Board.Cells[C, R]
     else
      Result := Result + BonusType + Board.Cells[C, R];
   end;
 Until Board.Cells[C, R] = '';
 Result := lowercase(Result);
 if (length(Result) = 2) and (Pos('+', Result) or Pos('*', Result) or Pos('^', Result) or Pos('!', Result) > 0)
  then
   Result := ' ';
end;

function TBuildAWord.GetStartPos: integer;
var
 i : integer;
begin
 Result := -1;
 for i := 1 to NumLettersUsed do
  if PlacedLetters[i].X and PlacedLetters[i].Y > -1 then
   begin
    Result := i;
    exit;
   end;
end;

procedure StartOfWord(srd: TStringGrid; var GivenPoint: TPoint; GoAcross: char; Swap: boolean);
begin
 While srd.Cells[GivenPoint.X, GivenPoint.Y] <> '' do
  begin
   if Swap then
    begin
     if GoAcross = 'T'
      then
       dec(GivenPoint.Y)
      else
       dec(GivenPoint.X);
    end else
   if GoAcross = 'T'
    then
     dec(GivenPoint.X)
    else
     dec(GivenPoint.Y);

   if GivenPoint.X or GivenPoint.Y < 0
    then
     break;
  end;

 if Swap then
  begin
   if GoAcross = 'T'
    then
     inc(GivenPoint.Y)
    else
     inc(GivenPoint.X);
  end else
 if GoAcross = 'T'
  then
   inc(GivenPoint.X)
  else
   inc(GivenPoint.Y);
end;

function TBuildAWord.GetStartPoint(GoAcross: Char): TPoint;
var
 i: integer;
begin
 Result.X := PLacedLetters[GetStartPos].X;
 Result.Y := PLacedLetters[GetStartPos].Y;
 if GoAcross = 'T' then
  begin
   for i := GetStartPos + 1 to NumLettersUsed do
    if PlacedLetters[i].X and PlacedLetters[i].Y > -1 then
     if PlacedLetters[i].X < Result.X then
      if Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y] <> '' then
      begin
       Result.X := PlacedLetters[i].X;
       Result.Y := PlacedLetters[i].Y;
      end;
  end else
  begin
   for i := GetStartPos + 1 to NumLettersUsed do
    if PlacedLetters[i].Y and PlacedLetters[i].X > -1 then
     if PlacedLetters[i].Y < Result.Y then
      if Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y] <> '' then
      begin
       Result.X := PlacedLetters[i].X;
       Result.Y := PlacedLetters[i].Y;
      end;
  end;
end;

function TBuildAWord.AllWordsExist: boolean;

    function MainWordCorrect(StartPoint: TPoint): boolean;
    var
     sWord: string;
    begin
     sWord := '';
     StartOfWord(Board, StartPoint, GoAcrossOrNot, false);
     Repeat
      if Board.Cells[StartPoint.X, StartPoint.Y] <> ''
       then
        sWord := sWord + Board.Cells[StartPoint.X, StartPoint.Y];
      if GoAcrossOrNot = 'T'
       then
        inc(StartPoint.X)
       else
        inc(StartPoint.Y);
     Until Board.Cells[StartPoint.X, StartPoint.Y] = '';
     Result := IsAWord(LowerCase(sWord));
    end;

    function StemsExist(StartPoint: TPoint): boolean;
    begin
     Result := true;
     Repeat
      if length(GetStem(StartPoint.X, StartPoint.Y, GoAcrossOrNot, False)) > 1 then
      if Not IsAWord(GetStem(StartPoint.X, StartPoint.Y, GoAcrossOrNot, False)) then
       begin
        Result := false;
        exit;
       end;
      if GoAcrossOrNot = 'T'
       then
        inc(StartPoint.X)
       else
        inc(StartPoint.Y);
     Until Board.Cells[StartPoint.X, StartPoint.Y] = '';
    end;

var
 point: TPoint;
begin
 point := GetStartPoint(GoAcrossOrNot);
 if (not MainWordCorrect(point)) or (not StemsExist(point))
  then
   Result := false
  else
   Result := true;
end;

function TBuildAWord.NumberOfLettersActualyOnBoard: integer;
var
 i: integer;
begin
 Result := 0;
 For i := GetStartPos to NumLettersUsed do
  if PlacedLetters[i].X and PlacedLetters[i].Y > -1
   then
   inc(Result);
end;

function TBuildAWord.GetPlayerScore: Integer;
    function GetMainWord(StartPoint: TPoint; SwapGoAcross: Boolean): Integer;
    var
     sWord, BonusType: string;
    begin
     sWord := '';
     StartOfWord(Board, StartPoint, GoAcrossOrNot, SwapGoAcross);
     Repeat
      if Board.Cells[StartPoint.X, StartPoint.Y] <> '' then
       begin
        BonusType := OnBonusTile(BonusTiles, StartPoint.X, StartPoint.Y, True);
        if BonusType = ' '
         then
          sWord := sWord + Board.Cells[StartPoint.X, StartPoint.Y]
         else
          sWord := sWord + BonusType + Board.Cells[StartPoint.X, StartPoint.Y]
       end;
      if SwapGoAcross then
       begin
        if GoAcrossOrNot = 'T'
         then
          inc(StartPoint.Y)
         else
          inc(StartPoint.X);
       end else
       if GoAcrossOrNot = 'T'
        then
         inc(StartPoint.X)
        else
         inc(StartPoint.Y);
     Until Board.Cells[StartPoint.X, StartPoint.Y] = '';
     if Length(sWord) > 1
      then
       Result := WordScore(sWord)
      else
       Result := 0;
     if NumLettersUsed = 7
      then begin
       if Length(sWord) > 1 then Result := Result + 50;
       if Pos('!', sWord) > 0
        then
         frmAchievements.AchievementComplete(Master_Planner);
      end;
    end;

    function IsMyLetter(Point: TPoint): boolean;
    var
     i: integer;
    begin
     Result := false;
     for i := GetStartPos to NumLettersUsed do
      if (PlacedLetters[i].X and PlacedLetters[i].Y > -1)
       then
        if (PlacedLetters[i].X = Point.X) and (PlacedLetters[i].Y = Point.Y)
         then
          result := true;
    end;

    function GetStemScore(StartPoint: TPoint): Integer;
    begin
     Result := 0;
     Repeat
      if length(GetStem(StartPoint.X, StartPoint.Y, GoAcrossOrNot, False)) > 1 then
       if IsMyLetter(StartPoint)
        then
         Result := result + WordScore(GetStem(StartPoint.X, StartPoint.Y, GoAcrossOrNot, True));
      if GoAcrossOrNot = 'T'
       then
        inc(StartPoint.X)
       else
        inc(StartPoint.Y);
     Until Board.Cells[StartPoint.X, StartPoint.Y] = '';
    end;
var
 point: TPoint;
begin
 point  := GetStartPoint(GoAcrossOrNot);
 if NumberOfLettersActualyOnBoard > 1
  then
   Result := GetMainWord(point, False) + GetStemScore(point)
  else
   Result := GetMainWord(Point, false) + GetMainWord(Point, True);
 CurrentScore := Result;
end;

procedure TBuildAWord.NextUser;
var
 NextPlayer, PreviousUserScore: string;
 CurrentScoreForCheck: Integer;
begin
 if CorrectWord then
  begin
   PreviousUserScore := Users[CurrentUser] + ' You Scored ' +
                        IntToStr(CurrentScore) + ' in The Last Turn For a Total Score of ' +
                        IntToStr(Scores[CurrentUser]);
   ReplaceLetters;
   RandomLetters;
  end else
  begin
   RemoveCurrentWord;
   Recall;
   PreviousUserScore := Users[CurrentUser] + ' Sorry You Scored Nothing and Loose a Turn because Your Word Can''t be Found';
  end;

 NumLettersUsed := 0;
 CurrentScoreForCheck := Scores[CurrentUser];
 Inc(CurrentUser);       //next player
 NextPlayer := '';
 if CurrentUser > TotalPlayers then
  begin
   CurrentUser := 1;
   Inc(Turns);
   if CurrentUser = TotalPlayers
    then
     NextPlayer := ''
    else
     NextPlayer := Users[CurrentUser] + ' it''s Your turn';
  end else
   NextPlayer := Users[CurrentUser] + ' it''s Your turn';

 case mode of     //check if player won
  '<' : if CurrentScoreForCheck > 75 then
         begin
          FirstPlayerOver := CurrentUser;
          frmAchievements.AchievementComplete(First_To_The_Finish);
          HighScore;
          Exit;
         end;
  '>' : if CurrentScoreForCheck > 150 then
         begin
          FirstPlayerOver := CurrentUser;
          frmAchievements.AchievementComplete(First_To_The_Finish);
          HighScore;
          Exit;
         end;
  'v' : if turns > 8 then
         begin
          HighScore;
          Exit;
         end;
  '^' : if turns > 12 then
         begin
          HighScore;
          Exit;
         end;
 end;

 RemoveCurrentWord;

 if NextPlayer = ''
  then
   MessageDlg(PreviousUserScore, mtConfirmation, [mbOk], 0)
  else
   MessageDlg(PreviousUserScore + #13#13 + NextPlayer, mtConfirmation, [mbOk], 0);
 SetNextUsersTiles;
end;

procedure TBuildAWord.CheckWord;
var
 AllExist: boolean;
begin
 if not CanPlay(True) then exit;
 if not CurrentWordinCorrectPosition then
  begin
   Showmessage('Your Word is Not In A Suitable Position');
   exit;
  end;
 AllExist := AllWordsExist;
 if AllExist then
  begin
   Scores[CurrentUser] := Scores[CurrentUser] + GetPlayerScore;
   if NumLettersUsed = 7
    then
     frmAchievements.AchievementComplete(Nothing_is_Wasted);
  end;
 NextUser(AllExist);
end;

procedure TBuildAWord.SetDefaultBonusTiles;
var
 i, k : integer;
begin
 for i := 0 to 7 do
   BonusTiles[i] := TripleWords[i];

 k := 8;

 for i := 0 to 23 do
   BonusTiles[i + k] := DoubleLetters[i];

 k := 32;

 for i := 0 to 15 do
   BonusTiles[i + k] := DoubleWords[i];

 k := 48;

 for i := 0 to 11 do
   BonusTiles[i + k] := TripleLetters[i];

 BonusTiles[60].X := 7;
 BonusTiles[60].Y := 7;
end;

constructor TBuildAWord.Create(frm : TForm; trayHolder, brdHolder : TPanel; srd: TStringGrid);
var
 i : integer;
begin
 Inherited Create;
 SetGameName('Build-A-Word');
 TimePlaying := 0;
 CurrentLetter := ' ';
 setLength(PlacedLetters, 8);
 NumLettersUsed := 0;
 State_Create(False);
 for i := 1 to 7 do
  begin
   Tiles[i] := TTile.Create(trayHolder);
   Tiles[i].pnlTile.Hide;
   Tiles[i].lblLetter.Name        := 'lblLetter' + IntToStr(i);
   Tiles[i].lblLetter.OnMouseDown := TileDown;
   Tiles[i].lblLetter.OnMouseMove := TileMove;
   Tiles[i].lblLetter.OnMouseUp   := TileUp;
  end;
 HoldingTile := TTile.Create(brdHolder);
 HoldingTile.pnlTile.Align := alNone;
 HoldingTile.pnlTile.Height := 33;
 HoldingTile.pnlTile.Hide;
 Board := srd;
 Board.OnMouseUp := BoardUp;
 Board.OnMouseDown := BoardDown;
 Board.OnMouseMove := BoardMove;
 Board.OnDrawCell  := BoardOnDrawCell;
 Self.frm := frm;
 Board.DoubleBuffered := true;
 SetDefaultBonusTiles;
end;

procedure TBuildAWord.NewGame(ownr : TPanel; u1, u2, u3, u4 : string; Mode : integer);

 procedure ClearPallete(player : integer);
 var
  i : integer;
 begin
  for i := Low(Tiles) to High(Tiles) do
   begin
    if player <= TotalPlayers
     then
      tiles[i].ChangeLetter(RandomLetter)
     else
      Tiles[i].ChangeLetter(' ');
    LetterTray[player][i] := tiles[i].lblLetter.Caption[1];
    if LetterTray[player][i] <> ' '
     then
      tiles[i].pnlTile.Show
     else
      Tiles[i].pnlTile.Hide;
   end;
 end;

var
 i, k : integer;
begin
 LetterCount['A'] := 9;
 LetterCount['B'] := 2;
 LetterCount['C'] := 2;
 LetterCount['D'] := 4;
 LetterCount['E'] := 12;
 LetterCount['F'] := 2;
 LetterCount['G'] := 3;
 LetterCount['H'] := 2;
 LetterCount['I'] := 9;
 LetterCount['J'] := 1;
 LetterCount['K'] := 1;
 LetterCount['L'] := 4;
 LetterCount['M'] := 2;
 LetterCount['N'] := 6;
 LetterCount['O'] := 8;
 LetterCount['P'] := 2;
 LetterCount['Q'] := 1;
 LetterCount['R'] := 6;
 LetterCount['S'] := 4;
 LetterCount['T'] := 5;
 LetterCount['U'] := 4;
 LetterCount['V'] := 2;
 LetterCount['W'] := 2;
 LetterCount['X'] := 1;
 LetterCount['Y'] := 2;
 LetterCount['Z'] := 1;

 CurrentUser := 1;

 Users[1] := u1;
 Users[2] := u2;
 Users[3] := u3;
 Users[4] := u4;

 TotalPlayers := 4;

 for i := 2 to 4 do
  if Users[i] = 'No Player'
   then
    dec(TotalPlayers);

 if TotalPlayers = 1
  then
   frmAchievements.AchievementComplete(Forever_Alone)
  else
 if TotalPlayers > 1
  then
   frmAchievements.AchievementComplete(Get_A_friend);

 for i := 4 downto 1 do
  ClearPallete(i);

 SetDefaultBonusTiles;

 ResizeBoard(ownr);
 CurrentLetter := ' ';
 NumLettersUsed := 0;
 TimePlaying := 0;
 LetterPickedUp.lbl := -1;
 FirstPlayerOver := -1;
 for i := 1 to High(Scores) do
  Scores[i] := 0;

 for i := 1 to length(PlacedLetters) - 1 do
  begin
   PlacedLetters[i].X := -1;
   PlacedLetters[i].Y := -1;
  end;

 SetLength(LettersOnBoard, 1);

 for i := 0 to Board.ColCount - 1 do
  for k := 0 to Board.RowCount do
   Board.Cells[i, k] := '';

 Turns := 1;
 Case Mode of
  0 : Self.Mode := '<';
  1 : Self.Mode := '>';
  2 : Self.Mode := 'v';
  3 : Self.Mode := '^';
 end;
 State_NewGame(false);
 MessageDlg(Users[1] + ' it''s Your turn', mtConfirmation, [mbOk], 0);
end;

function isConnected(col, row : integer; srd : TStringGrid) : boolean;
begin
 Result := false;

 if (col = 7) and (row = 7) then
  begin
   result := true;
   exit;
  end;

 if col - 1 > -1
  then
   if srd.cells[col - 1, row] <> ''   //N
    then
     Result := true;

 if (row - 1 > -1)
  then
   if srd.cells[col, row - 1] <> ''     //W
    then
     Result := true;

 if (col + 1 < srd.ColCount)
  then
   if srd.cells[col + 1, row] <> ''             //S
    then
     Result := true;

 if (row + 1 < srd.RowCount)
  then
   if srd.cells[col, row + 1] <> ''             //E
    then
     Result := true;

 if srd.Cells[col, row] <> ''
  then
   Result := false;
end;

function isReplacing(Col, Row : Integer; replacy : array of TMovableTile) : boolean;
var
 i : integer;
begin
 Result := false;
 for i := 1 to length(replacy) - 1 do
  if Col and Row > -1 then
  if (replacy[i].X = Col) and (replacy[i].Y = Row)
   then
    Result := true;
end;

function OnStaticTile(Col, Row : integer; Tiles : Array of TPoint): boolean;
var
 i : integer;
begin
 Result := false;
 for i := 1 to High(Tiles) do
  if (Tiles[i].X = Col) and (Tiles[i].Y = Row)
   then
    Result := true;
end;

procedure TBuildAWord.PlaceLetterOnBoard(col, row : integer; Tile : TTile);
    procedure SetReplaced;
    var i: integer;
    begin
     for i := 1 to 7 do
      if (Tiles[i].lblLetter.Caption = Board.Cells[col, row]) and (not Tiles[i].pnlTile.Showing) and (LetterTray[currentUser, i] = Board.Cells[col, row])
       then
        Tiles[i].pnlTile.Show;
    end;
begin
 HoldingTile.pnlTile.Hide;
 if  (CurrentLetter <> ' ') and (CurrentLetter <> '') or isReplacing(col, row, PlacedLetters) then
  begin
   Tile.pnlTile.Hide;
   if OnStaticTile(Col, Row, LettersOnBoard) then
    begin
     Tile.pnlTile.Show;
     Exit;
    end;
   if isReplacing(col, row, PlacedLetters) then
    begin
     SetReplaced;
    end else
     HoldingTile.pnlTile.Hide;

   if (LetterPickedUp.lbl <= -1)and(Not isReplacing(col, row, PlacedLetters))  then
    begin
     inc(NumLettersUsed);
     SetLength(PlacedLetters, NumLettersUsed + 1);
    end;

   Board.Cells[col, row] := CurrentLetter;
   CurrentLetter := ' ';

   if LetterPickedUp.lbl > -1 then
    begin
     PlacedLetters[LetterPickedUp.lbl].X := col;
     PlacedLetters[LetterPickedUp.lbl].Y := row;
     LetterPickedUp.lbl := -1;
    end else
    if Not isReplacing(col, row, PlacedLetters) then
    begin
     PlacedLetters[NumLettersUsed].X := col;
     PlacedLetters[NumLettersUsed].Y := row;
     PlacedLetters[NumLettersUsed].lbl := TileNumber;
     TileNumber := 0;
    end;
  end;
end;

function TBuildAWord.RandomLetter : Char;
  function LettersDone : boolean;
   var
    c : char;
   begin
    Result := false;
    for c := 'A' to 'Z' do
     if LetterCount[c] > 0
      then
       Result := True;
   end;
begin
 Randomize;
 Result := ' ';
 While (Result = ' ') and (LettersDone) do
 Case Random(99) of
  0..8   : if LetterCount['A'] > 0 then Result := 'A';
  9..10  : if LetterCount['B'] > 0 then Result := 'B';
  11..12 : if LetterCount['C'] > 0 then Result := 'C';
  13..16 : if LetterCount['D'] > 0 then Result := 'D';
  17..28 : if LetterCount['E'] > 0 then Result := 'E';
  29..30 : if LetterCount['F'] > 0 then Result := 'F';
  31..33 : if LetterCount['G'] > 0 then Result := 'G';
  34..35 : if LetterCount['H'] > 0 then Result := 'H';
  36..44 : if LetterCount['I'] > 0 then Result := 'I';
  45     : if LetterCount['J'] > 0 then Result := 'J';
  46     : if LetterCount['K'] > 0 then Result := 'K';
  47..50 : if LetterCount['L'] > 0 then Result := 'L';
  51..52 : if LetterCount['M'] > 0 then Result := 'M';
  53..58 : if LetterCount['N'] > 0 then Result := 'N';
  59..66 : if LetterCount['O'] > 0 then Result := 'O';
  67..68 : if LetterCount['P'] > 0 then Result := 'P';
  69     : if LetterCount['Q'] > 0 then Result := 'Q';
  70..75 : if LetterCount['R'] > 0 then Result := 'R';
  76..79 : if LetterCount['S'] > 0 then Result := 'S';
  80..85 : if LetterCount['T'] > 0 then Result := 'T';
  86..89 : if LetterCount['U'] > 0 then Result := 'U';
  90..91 : if LetterCount['V'] > 0 then Result := 'V';
  92..93 : if LetterCount['W'] > 0 then Result := 'W';
  94     : if LetterCount['X'] > 0 then Result := 'X';
  95..96 : if LetterCount['Y'] > 0 then Result := 'Y';
  97..98 : if LetterCount['Z'] > 0 then Result := 'Z';
 end;
 if Result <> ' '
  then
   Dec(LetterCount[Result]);
end;

procedure TBuildAWord.RandomLetters;
var
 i : integer;
begin
 for i := 1 to 7 do
  if not Tiles[i].pnlTile.Visible then
   begin
    Tiles[i].ChangeLetter(RandomLetter);
    LetterTray[CurrentUser][i] := Tiles[i].lblLetter.Caption[1];
    Tiles[i].pnlTile.Show;
   end;
// for i := 1 to 7 do Showmessage(LetterTray[CurrentUser][i]);
end;

procedure TBuildAWord.ResizeBoard(ownr : TPanel);
var
 MinLength : Integer;
begin
 MinLength := Min(ownr.Width, ownr.Height - 65);
 With Board do
  begin
   Width  := MinLength;
   Height := MinLength;

   DefaultColWidth  := MinLength  div ColCount - 2;
   DefaultRowHeight := MinLength  div RowCount - 2;

   Width  := Width  - Abs(DefaultColWidth  * 15 - Width)  + 5;
   Height := Height - Abs(DefaultRowHeight * 15 - Height) + 5;

   Left   := ownr.Width  div 2 - Width  div 2;
   Top    := (ownr.Height - 65) div 2 - Height div 2;

   Font.Size        := max(Width, Height) div (max(RowCount ,ColCount) + Trunc(max(RowCount, ColCount) * 2));
  end;
end;

procedure TBuildAWord.SetCurLetter(c: char);
begin
 CurrentLetter := c;
 HoldingTile.ChangeLetter(c);
 if c = ' ' then exit;
 HoldingTile.pnlTile.Show;
 HoldingTile.pnlTile.Left := Mouse.CursorPos.X - frm.left - 20;
 HoldingTile.pnlTile.Top  := Mouse.CursorPos.Y - frm.top  - 130;
end;

procedure TBuildAWord.MoveTile(frm : TForm);
var
 i, j: integer;
 FurthestRight: Array[1..7] of Integer;
 Address: Array[1..7] of Integer;
begin
 With HoldingTile do
  begin
   pnlTile.Left   := Mouse.CursorPos.X - frm.left - 20;
   pnlTile.Top    := Mouse.CursorPos.Y - frm.Top - 130;
   pnlTile.Width  := Board.DefaultColWidth;
   pnlTile.Height := Board.DefaultRowHeight;
   lblLetter.Font.Size      := Board.Font.Size;
   lblLetterValue.Font.Size := Board.Font.Size;
   lblLetterValue.Left      := HoldingTile.pnlTile.Width - HoldingTile.lblLetterValue.Width;
   lblLetterValue.Top       := HoldingTile.pnlTile.Height - HoldingTile.lblLetterValue.Height;

   if TileNumber in [1..7] then
    Tiles[TileNumber].pnlTile.Left := pnlTile.Left - 10;

   for i := 1 to 7 do
    FurthestRight[i] := Tiles[i].pnlTile.Left;
   BubbleSort(FurthestRight);

   for i := 7 downto 1 do
    for j := 1 to 7 do
     if Tiles[j].pnlTile.left = FurthestRight[i]
      then
       Address[i] := j;

   for i := 1 to 7 do
    if (Tiles[Address[i]].pnlTile.Left > pnlTile.Left - 10) and ((pnlTile.Top > frm.Height - 200) and (pnlTile.Top < frm.Height - 140))
     then
      Tiles[Address[i]].pnlTile.Align := alRight
     else
      Tiles[Address[i]].pnlTile.Align := alLeft;

  end;
end;

procedure TBuildAWord.Quit;
var
 i : integer;
begin
 Inherited;
 for i := 1 to High(Scores) do
  Scores[i] := 0;
 for i := 1 to 7 do Tiles[i].pnlTile.Hide;
  TimePlaying := 0;
 ResetToDefault;
end;

procedure TBuildAWord.HighScore;
    function GetAssociatedUser(iScore: integer): string;
    var
     i: integer;
    begin
     Result := '';
     for i := 1 to TotalPlayers do
      if iScore = Scores[i]
       then
        Result := Users[i];
    end;

var
 i : integer;
 PlayerMessages: Array[1..4] of String;
 PlayerMessage: string;
 ScoreOrder: Array[1..4] of Integer;
begin
 if (not GetHasStarted) then exit;
 Score := Scores[1];
 for i := 1 to TotalPlayers do ScoreOrder[i] := Scores[i];

 for i := 1 to TotalPlayers do
  if GetAssociatedUser(ScoreOrder[i]) <> 'No Player' then
  begin
   qry.Close;
   qry.SQL.Clear;
   qry.SQL.ADD('INSERT INTO [Build-A-Word] ');
   qry.SQL.Add( GetInsertFields(qry));
   qry.SQL.ADD('VALUES(');
   qry.SQL.Add('"' + GetAssociatedUser(ScoreOrder[i]) + '", ');
   qry.SQL.ADD(      IntToStr(i)        + ' , ');
   qry.SQL.ADD(      IntToStr(Turns)    + ' , ');
   qry.SQL.Add(      GetTimeSecs        + ' , ');
   qry.SQL.ADD(      IntToStr(ScoreOrder[i]) + ' , ');
   qry.SQL.ADD(      FloatToStr(Date)   + ')');
   qry.ExecSQL;
  end;

 BubbleSort(ScoreOrder);
 For i := 1 to TotalPlayers do
  PlayerMessages[i] := GetAssociatedUser(ScoreOrder[i]) + ' With ' + IntToStr(ScoreOrder[i]) + ' Points';

 PlayerMessages[1] := 'First: '   + PlayerMessages[1];
 PlayerMessages[2] := 'Secound: ' + PlayerMessages[2];
 PlayerMessages[3] := 'Third: '   + PlayerMessages[3];
 PlayerMessages[4] := 'Fourth: '  + PlayerMessages[4];
 PlayerMessage := '';
 For i := 1 to TotalPlayers do
  PlayerMessage := PlayerMessage + #13#13 + PlayerMessages[i];

 Showmessage(PlayerMessage);
 Inherited HighScore;
end;

procedure TBuildAWord.GetScore(lbl : TLabel);
var
 smode : string;
begin
 //lbl.Caption := ' :) ';
 if (lbl.Caption <> ' . ') and (lbl.caption <> ' .. ')
    then
     lbl.Caption := ' . '
    else
   if lbl.Caption <> ' .. '
    then
     lbl.Caption := ' .. '
    else
   if lbl.Caption <> ' ... '
    then
     lbl.caption := ' ... '
    else
     lbl.Caption := ' . ';

 if not CanPlay(False) then exit;

 GetTimeElapsed;
 if not (CurrentUser in [1..4]) then exit;
 if mode = 'v'
  then
   smode := '8'
  else
 if mode = '^'
  then
   smode := '12'
  else
 if mode = '<'
  then
   smode := '75'
  else
 if mode = '>'
  then
   sMode := '150';

 if Mode in ['v', '^']
  then
   lbl.Caption := Users[CurrentUser] + '''s Score in Turn ' + IntToStr(turns) + '/' + smode + ' is ' + IntToStr(Scores[CurrentUser])
  else
 if mode in ['>', '<']
  then
   lbl.Caption := Users[CurrentUser] + '''s Score in Turn ' + IntToStr(Turns) + ' is ' + IntToStr(Scores[currentUser]) + '/' + smode
  else
   lbl.Caption := 'Press New Game'
end;

procedure TBuildAWord.ReplaceLetters;
var
 i, iCount : integer;
begin
 iCount := High(LettersOnBoard);
 for i := 1 to NumLettersUsed do
 if PlacedLetters[i].X and PlacedLetters[i].Y > - 1 then
  begin
   inc(iCount);
   SetLength(LettersOnBoard, iCount + 1);
   LettersOnBoard[iCount].X := PlacedLetters[i].X;
   LettersOnBoard[iCount].Y := PlacedLetters[i].Y;
   PlacedLetters[i].X := -1;
   PlacedLetters[i].Y := -1;
  end;
end;

procedure TBuildAWord.TileDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not CanPlay(false) then exit;
 SetCurLetter(TLabel(Sender).Caption[1]);
 TileNumber := StrToInt(TLabel(Sender).Name[Length(TLabel(Sender).Name)]);
 Tiles[TileNumber].pnlTile.Hide;
end;

procedure TBuildAWord.TileMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not CanPlay(false) then exit;
 if (TileNumber in [1..7]) and (GetAsyncKeyState(VK_LBUTTON) < 0)
  then
   MoveTile(frm);
end;

procedure TBuildAWord.TileUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 ps : TGridCoord;

 i, j: integer;
 FurthestRight: Array[1..7] of Integer;
 Address: Array[1..7] of Integer;
begin
 if not CanPlay(true) then exit;

 ps := Board.MouseCoord(HoldingTile.pnlTile.Left - Board.Left + HoldingTile.pnlTile.Width  div 2,
                        HoldingTile.pnlTile.Top  - Board.Top  + HoldingTile.pnlTile.Height div 2);


 if (ps.X and ps.Y > -1)
  then
   PlaceLetterOnBoard(ps.X, ps.Y, Tiles[StrToInt(TLabel(sender).Name[length(TLabel(sender).Name)])])
  else begin
   Tiles[StrToInt(TLabel(sender).Name[length(TLabel(sender).Name)])].pnlTile.Show;
   HoldingTile.pnlTile.Hide;

   With HoldingTile do
    begin
     if TileNumber in [1..7] then
      Tiles[TileNumber].pnlTile.Left := pnlTile.Left - 10;

     for i := 1 to 7 do
      FurthestRight[i] := Tiles[i].pnlTile.Left;
     BubbleSort(FurthestRight);

     for i := 7 downto 1 do
      for j := 1 to 7 do
       if Tiles[j].pnlTile.left = FurthestRight[i]
        then
         Address[i] := j;

     for i := 7 downto 1 do
        Tiles[Address[i]].pnlTile.Align := alLeft;
    end;
  end;
 //TileNumber := -1;
end;

procedure TBuildAWord.BoardUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 ps : TGridCoord;
begin
 if not CanPlay(true) then exit;
 ps := Board.MouseCoord(X, Y);
 if (ps.X and ps.Y > -1) and (not isReplacing(ps.X, ps.Y, PlacedLetters))
  then
   PlaceLetterOnBoard(ps.X, ps.Y, Tiles[TileNumber])
  else
  if LetterPickedUp.lbl > -1 then
  begin
   if isReplacing(ps.X, ps.Y, PlacedLetters) then
    begin
     CurrentLetter := Board.Cells[ps.X, ps.Y][1];
     Board.Cells[ps.X, ps.Y] := HoldingTile.lblLetter.Caption[1];
     Board.Cells[LetterPickedUp.X, LetterPickedUp.Y] := CurrentLetter;
     PlacedLetters[LetterPickedUp.lbl].X := LetterPickedUp.X;
     PlacedLetters[LetterPickedUp.lbl].Y := LetterPickedUp.Y;
    end else
    begin
     Tiles[PlacedLetters[LetterPickedUp.lbl].lbl].pnlTile.Show;
    end;
   LetterPickedUp.lbl := -1;
   SetCurLetter(' ');
   HoldingTile.pnlTile.Hide;
  end;
end;

procedure TBuildAWord.BoardDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  function IsCurrentPlayerWord(X, Y : integer) : boolean;
  var
   i : integer;
  begin
   Result := false;
   for i := 1 to NumLettersUsed do
    if (X = PlacedLetters[i].X) and (Y = PlacedLetters[i].Y)
     then
      Result := True;
  end;

var
 ps : TGridCoord;
 i  : integer;
begin
 if not CanPlay(false) then exit;
 ps := Board.MouseCoord(X, Y);
 if (ps.X > -1) and (ps.Y > -1) then
 if (Board.Cells[ps.X, ps.Y] <> '') and (IsCurrentPlayerWord(ps.X, ps.Y)) then
  begin
   HoldingTile.pnlTile.Show;
   SetCurLetter(Board.Cells[ps.X, ps.Y][1]);
   Board.Cells[ps.X, ps.Y] := '';
   LetterPickedUp.lbl := -1;
   for i := 1 to NumLettersUsed do
    if (PlacedLetters[i].X = ps.X) and (PlacedLetters[i].Y = ps.Y) then
     begin
      LetterPickedUp.lbl := i;
      LetterPickedUp.X   := PlacedLetters[i].X;
      LetterPickedUp.Y   := PlacedLetters[i].Y;
      PlacedLetters[i].X := -1;
      PlacedLetters[i].Y := -1;
      break;
     end;
   //TileNumber := StrToInt(TLabel(Sender).Name[Length(TLabel(Sender).Name)]);
   //Tiles[StrToInt(TLabel(sender).Name[length(TLabel(sender).Name)])].pnlTile.Hide;
  end else
   LetterPickedUp.lbl := -1;
end;

procedure TBuildAWord.BoardMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not CanPlay(false) then exit;
 if (GetAsyncKeyState(VK_LBUTTON) < 0)
  then
   MoveTile(frm);
end;

function GetTextDimension(s: string; size: integer;
  Width: boolean): integer;
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

procedure WriteLetter(srd : TStringGrid; ACol, ARow : integer; txt : String);
    function UntilFit(s: string): integer;
    begin
     Result := 50;
     While GetTextDimension(s, Result, True) > srd.DefaultColWidth - 8 do dec(Result);
    end;
var
 X1, X2, Y1, Y2 : integer;
begin
 X1 := ACol * srd.DefaultColWidth;
 X2 := (ACol + 1) * srd.DefaultColWidth;
 Y1 := ARow * srd.DefaultRowHeight;
 Y2 := (ARow + 1) * srd.DefaultRowHeight;

 SetTextAlign(srd.Canvas.Handle, TA_CENTER);
 srd.Canvas.Brush.Style := bsClear;
 if txt = '3L'
  then
   srd.Canvas.Font.Color := clWhite
  else
  if srd.Canvas.Font.Color = clWhite
   then
    srd.Canvas.Font.Color := clBlack;

 if (length(txt) = 1) and (txt <> '*') then
  begin
   SetTextAlign(srd.Canvas.Handle, TA_LEFT);
   srd.Canvas.Font.Size := srd.Font.Size;
   srd.Canvas.TextOut(X1 + 2, Y1 + 2, txt);
   srd.Canvas.TextOut(
                      X2 - GetTextDimension(IntToStr(LetterValues[txt[1]]), srd.Canvas.Font.Size, True),
                      Y2 - GetTextDimension(IntToStr(LetterValues[txt[1]]), srd.Canvas.Font.Size, False),
                      IntToStr(LetterValues[txt[1]])
                     );
  end else
  if txt <> '*'
   then begin
    srd.Canvas.Font.Size := srd.Font.Size;
    srd.Canvas.TextOut(X1 + (X2 - X1) div 2, Y1 + (Y2 - Y1) div 2 - Abs(srd.Font.Height div 2), txt);
   end else
   begin
    srd.Canvas.Font.Size := UntilFit('*');
    srd.Canvas.TextOut(X1 + (X2 - X1) div 2, Y1 + (Y2 - Y1) div 2 - Abs(srd.Canvas.Font.Size div 2), txt);
   end;

 srd.Canvas.Font.Color := clBlack;
end;

procedure Draw3DBorder(srd : TStringGrid; ACol, ARow : integer);
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

procedure DrawPick(srd : TStringGrid; X1, X2, Y1, Y2, D : integer);
begin
 //Top
 srd.Canvas.MoveTo(X1 + D Div 3, Y1);
 srd.Canvas.LineTo(X1 + D Div 2, Y1 - 4);
 srd.Canvas.LineTo(X2 - D Div 3, Y1);
 srd.Canvas.LineTo(X1 + D div 3, Y1);

 //Bottom
 srd.Canvas.MoveTo(X1 + D Div 3, Y2);
 srd.Canvas.LineTo(X1 + D Div 2, Y2 + 4);
 srd.Canvas.LineTo(X2 - D Div 3, Y2);
 srd.Canvas.LineTo(X1 + D div 3, Y2);

 //Left
 srd.Canvas.MoveTo(X1    , Y1 + D div 3);
 srd.Canvas.LineTo(X1 - 4, Y1 + D div 2);
 srd.Canvas.LineTo(X1    , Y2 - D div 3);
 srd.Canvas.LineTo(X1    , Y1 + D div 3);

 //Rigth
 srd.Canvas.MoveTo(X2    , Y1 + D div 3);
 srd.Canvas.LineTo(X2 + 4, Y1 + D div 2);
 srd.Canvas.LineTo(X2    , Y2 - D div 3);
 srd.Canvas.LineTo(X2    , Y1 + D div 3);
 {
 //Fill
 srd.Canvas.FloodFill(X1 + D div 2, Y1 - 2, $004A761B, fsSurface); //N
 srd.Canvas.FloodFill(X1 + D div 2, Y2 + 2, $004A761B, fsSurface); //S
 srd.Canvas.FloodFill(X1 - 2, Y1 + D div 2, $004A761B, fsSurface); //W
 srd.Canvas.FloodFill(X2 + 2, Y1 + D div 2, $004A761B, fsSurface); //E
 }
end;

procedure DrawDiamond(srd : TStringGrid; X1, X2, Y1, Y2, D : integer);
begin
 srd.Canvas.MoveTo(X1 + D Div 2, Y1 - 4);  //N
 srd.Canvas.LineTo(X2 + 4, Y1 + D div 2);  //E
 srd.Canvas.LineTo(X1 + D Div 2, Y2 + 4);  //S
 srd.Canvas.LineTo(X1 - 4, Y1 + D div 2);  //W
 srd.Canvas.LineTo(X1 + D Div 2, Y1 - 4);  //N
 srd.Canvas.FloodFill(X1 + D div 2, Y1 + D div 2, $004A761B, fsSurface);
end;

procedure DrawBonusTile(srd : TStringGrid; C, R : Integer; Color: TColor; Symbol: string);
var
 X1, X2, Y1, Y2, D : integer;
begin
 srd.Canvas.Font.Color := clBlack;
 D := srd.DefaultColWidth;
 X1 := C * D;
 X2 := (C + 1) * D;
 Y1 := R * D;
 Y2 := (R + 1) * D;

 srd.Canvas.Brush.Color := Color;
 srd.Canvas.Pen  .Color := Color;
 srd.Canvas.Brush.Style := bsSolid;
 srd.Canvas.Rectangle(X1, Y1, X2, Y2);

 //DrawPick(srd, X1, X2, Y1, Y2, D);

 {srd.Canvas.Rectangle(X1 - 2, Y1 + 16, X2 + 4, Y2 - 16);
 srd.Canvas.Rectangle(X1 + 16, Y1 - 2, X2 - 16, Y2 + 4);
 }
 WriteLetter(srd, C, R, Symbol);
end;

procedure DrawTripWord(srd : TStringGrid; ACol, ARow : integer);
begin
 DrawBonusTile(srd, ACol, ARow, clRed, '3W');
end;

procedure DrawDoubleLetter(srd : TStringGrid; ACol, ARow : integer);
begin
 DrawBonusTile(srd, ACol, ARow, clSkyBlue, '2L');
end;

procedure DrawDoubleword(srd : TStringGrid; ACol, ARow : integer);
begin
 DrawBonusTile(srd, ACol, ARow, $00A9C9FE, '2W');
end;

procedure DrawTripleLetter(srd : TStringGrid; ACol, ARow : integer);
begin
 DrawBonusTile(srd, ACol, ARow, clBlue, '3L');
end;

procedure DrawStar(srd : TStringGrid;  X1, X2, Y1, Y2, D : integer);
   procedure DoubleLine(iX, iY, X, Y: integer);
   begin
    With srd.Canvas do
     begin
       Pen.Color := clWhite;
       MoveTo(iX + 1, iY + 1);
       LineTo(X + 1, Y + 1);

       Pen.Color := clBlack;
       MoveTo(iX, iY);
       LineTo(X, Y);
     end;
   end;

var iX, iY: integer;

  procedure SwapValues(OldX, OldY : integer);
  begin
   iX := OldX;
   iY := OldY;
  end;

var
 X, Y : integer;
begin
 With srd.Canvas do
  begin
   X := X1 + D div 2;
   Y := Y1 + 3;
   MoveTo(X, Y);

   SwapValues(X, Y);
   X := X2 - D div 10 * 4;
   Y := Y1 + D div 10 * 4;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X2 - 3;
   Y := Y1 + D div 2;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X2 - D div 10 * 4;
   Y := Y2 - D div 10 * 4;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X1 + D div 2;
   Y := Y2 - 3;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X1 + D div 10 * 4;
   Y := Y2 - D div 10 * 4;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X1 + 3;
   Y := Y1 + D div 2;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X1 + D div 10 * 4;
   Y := Y1 + D div 10 * 4;
   DoubleLine(iX, iY, X, Y);

   SwapValues(X, Y);
   X := X1 + D div 2;
   Y := Y1 + 3;
   DoubleLine(iX, iY, X, Y);
  end;
end;

procedure DrawCenter(srd : TStringGrid);
var
 X1, X2, Y1, Y2 : integer;
begin
 X1 := 7 * srd.DefaultColWidth;
 X2 := 8 * srd.DefaultColWidth;
 Y1 := 7 * srd.DefaultRowHeight;
 Y2 := 8 * srd.DefaultRowHeight;

 srd.Canvas.Brush.Color := $00A9C9FE;
 srd.Canvas.Pen  .Color := $00A9C9FE;
 srd.Canvas.Brush.Style := bsSolid;
 srd.Canvas.Rectangle(X1, Y1, X2, Y2);

 //DrawPick(srd, X1, X2, Y1, Y2, srd.DefaultColWidth);
 //DrawStar(srd, X1, X2, Y1, Y2, srd.DefaultColWidth);

 WriteLetter(srd, 7, 7, '*');
end;

procedure DrawATile(srd : TStringGrid; ACol, ARow : integer);
var
 X1, X2, Y1, Y2 : integer;
 c              : char;
begin
 X1 := ACol * srd.DefaultColWidth;
 X2 := (ACol + 1) * srd.DefaultColWidth;
 Y1 := ARow * srd.DefaultRowHeight;
 Y2 := (ARow + 1) * srd.DefaultRowHeight;
 if srd.cells[ACol, ARow] <> ''
  then
   c  := srd.cells[ACol, ARow][1]
  else
   c := ' ';

 //Draw3DBorder(srd, ACol, ARow);

 srd.Canvas.Brush.Color := $009DDCE1;
 srd.Canvas.Pen  .Color := $009DDCE1;
 srd.Canvas.Brush.Style := bsSolid;
 srd.Canvas.Rectangle(X1, Y1, X2, Y2);

 srd.Canvas.Brush.Color := $009DDCE1;
 srd.Canvas.Pen  .Color := $009DDCE1;
 srd.Canvas.Font .Color := $00006C21;

 WriteLetter(srd, ACol, ARow, c);
end;

function TBuildAWord.TypeOfCell(C, R: integer): String;
var
 i: integer;
begin
 if C and R = 7
  then
   Result := '*';

 if PointInArray(C, R, TripleWords) > -1
  then
   Result := 'TW'
  else
 if PointInArray(C, R, DoubleWords) > -1
  then
   Result := 'DW'
  else
 if PointInArray(C, R, TripleLetters) > -1
  then
   Result := 'TL'
  else
 if PointInArray(C, R, DoubleLetters) > -1
  then
   Result := 'DL';
   

 for i := 1 to High(LettersOnBoard) do //Static Letters
 if (LettersOnBoard[i].X <> -1) or (LettersOnBoard[i].Y <> -1) then
  begin
   if (C = LettersOnBoard[i].X) and (R = LettersOnBoard[i].Y)
    then
     Result := Board.Cells[C, R];
  end;

 for i := 1 to High(PlacedLetters) do //Floating Letters
 if (PlacedLetters[i].X <> -1) or (PlacedLetters[i].Y <> -1) then
  begin
   if (C = PlacedLetters[i].X) and (R = PlacedLetters[i].Y)
    then
     Result := Board.Cells[C, R];
  end;
end;

procedure TBuildAWord.BoardOnDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if TypeOfCell(ACol, ARow) = '*'
   then
    DrawCenter(Board)
   else
  if TypeOfCell(ACol, ARow) = 'TW'
   then
    DrawTripWord(Board, ACol, ARow)
   else
  if TypeOfCell(ACol, ARow) = 'TL'
   then
    DrawTripleLetter(Board, ACol, ARow)
   else
  if TypeOfCell(ACol, ARow) = 'DW'
   then
    DrawDoubleword(Board, ACol, ARow)
   else
  if TypeOfCell(ACol, ARow) = 'DL'
   then
    DrawDoubleLetter(Board, ACol, ARow)
   else
   if TypeOfCell(ACol, ARow) <> ''
    then
     if TypeOfCell(ACol, ARow)[1] in ['A'..'Z', 'a'..'z']
      then
       DrawATile(Board, ACol, ARow);

  Draw3DBorder(Board, ACol, ARow);     
end;

procedure TBuildAWord.Repick;
var
 i : integer;
begin
 if not CanPlay(True) then exit;
 if MessageDlg('Are you sure you want to repick your letters. You Will Lose 10 Points',
                mtConfirmation,
                [mbOK, mbCancel],
                1) = mrOK
  then begin
   RemoveCurrentWord;
   for i := 1 to 7 do
    Tiles[i].pnlTile.Show;
   for i := 1 to 7 do
    begin
     Tiles[i].pnlTile.Show;
     Tiles[i].ChangeLetter(RandomLetter);
     LetterTray[CurrentUser][i] := Tiles[i].lblLetter.Caption[1];
     if LetterTray[CurrentUser][i] = ' '
      then
       Tiles[i].pnlTile.Hide;

    end;

   Scores[CurrentUser] := Scores[CurrentUser] - 10;
  end;

end;

procedure TBuildAWord.Recall;
var
 i : integer;
begin
 if not CanPlay(True) then exit;
 For i := 1 to 7 do
  if Tiles[i].lblLetter.Caption <> ' '
   then
    Tiles[i].pnlTile.Show;
 For i := 1 to NumLettersUsed do
 if (PlacedLetters[i].X and PlacedLetters[i].Y > -1)
  then
   Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y] := '';
 NumLettersUsed := 0;
 SetLength(PlacedLetters, NumLettersUsed);
end;

procedure TBuildAWord.SkipTurn;
var
 i: integer;
begin
 if not CanPlay(True) then exit;
 Inc(CurrentUser);
 if CurrentUser > TotalPlayers then
  begin
   CurrentUser := 1;
   Inc(Turns);
  end;

 for i := 1 to 7 do
  begin
   Tiles[i].ChangeLetter(LetterTray[CurrentUser][i]);
   if LetterTray[CurrentUser][i] <> ' '
    then
     Tiles[i].pnlTile.Show;
  end;

 MessageDlg(Users[CurrentUser] + ' it''s Your turn', mtConfirmation, [mbOk], 0);
end;

function TBuildAWord.CurrentWordinCorrectPosition: boolean;
var
 i, X, Y  : integer;
 GoAcross : boolean;
begin
 Result := False;
 X := -1;
 Y := -1;
 for i := 1 to NumLettersUsed do
  if (PlacedLetters[i].X > -1) and (PlacedLetters[i].Y > -1) then
   begin
    X := placedLetters[i].X;
    Y := PlacedLetters[i].Y;
    break;
   end;
 if X and Y = -1 then exit;

 if NumLettersUsed = 1 then
  if not((X - 1 > -1) and (X + 1 < Board.ColCount) and (Y - 1 > -1) and (Y + 1 < Board.RowCount)) then
   begin
    Result := false;
    Exit;
   end else
  if  (Board.Cells[X - 1, Y] <> '') //Left
   or (Board.Cells[X + 1, Y] <> '') //Right
   or (Board.Cells[X, Y - 1] <> '') // Up
   or (Board.Cells[X, Y + 1] <> '') //Down
  then begin
   Result := true;
   Exit;
  end;

 if GoAcrossOrNot = 'F' //PlacedLetters[first].X = PlacedLetters[secound].X
  then
   GoAcross := False
  else
 if GoAcrossOrNot = 'T' //PlacedLetters[first].Y = PlacedLetters[secound].Y
  then
   GoAcross := true
  else
   Exit;

 Result := Pos(' ', GetCurrentPlayersWord(GoAcross)) = 0;
 
 if GoAcross then
  for i := 2 to NumLettersUsed do
   begin
    if (PlacedLetters[i - 1].Y <> PlacedLetters[i].Y) and ((PlacedLetters[i - 1].Y > -1) and (PlacedLetters[i].Y > -1))
     then
      Result := false;
   end else
  for i := 2 to NumLettersUsed do
   begin
    if (PlacedLetters[i - 1].X <> PlacedLetters[i].X) and ((PlacedLetters[i - 1].X > -1) and (PlacedLetters[i].X > -1))
     then
      Result := false;
   end;
end;

function TBuildAWord.GoAcrossOrNot: Char;
var
 i, first, secound : integer;
begin
 First := -1;
 secound := -1;
 for i := 1 to NumLettersUsed do
  if (PlacedLetters[i].X > -1) and (PlacedLetters[i].Y > -1) then
   begin
    if First = -1
     then
      First := i
     else begin
      Secound := i;
      break;
     end;
   end;

 if PlacedLetters[first].X = PlacedLetters[secound].X
  then
   Result := 'F'
  else
 if PlacedLetters[first].Y = PlacedLetters[secound].Y
  then
   Result := 'T'
  else
   Result := ' ';
end;

procedure TBuildAWord.SetNextUsersTiles;
var
 i: integer;
begin
 For i := 1 to 7 do
  begin
   Tiles[i].ChangeLetter(LetterTray[CurrentUser][i]);
   if Tiles[i].lblLetter.Caption = ''
    then
     Tiles[i].pnlTile.Hide
    else
   if Tiles[i].lblLetter.Caption[1] <> ' '
    then
     Tiles[i].pnlTile.Show
    else
     Tiles[i].pnlTile.Hide;
  end;
end;

procedure TBuildAWord.LoadGame;

    function GetArrPos(var sValue: string): integer;
    var
     sStore: string;
    begin
     sStore := sValue;
     Delete(sStore, 1, 1);
     if Copy(sStore, 1, Pos(']', sStore) - 1) <> ''
      then
       Result := StrToInt(Copy(sStore, 1, Pos(']', sStore) - 1))
      else
       Result := 0; 
     Delete(sValue, 1, Pos(']', sValue));
    end;

    function GetArrPosChar(var sValue: string): Char;
    var
     sStore: string;
    begin
     sStore := sValue;
     Delete(sStore, 1, 1);
     Result := Copy(sStore, 1, Pos(']', sStore) - 1)[1];
     Delete(sValue, 1, Pos(']', sValue));
    end;

    function GetValue(var sValue: string): String;
    begin
     if Pos(':', sValue) > 0 then
      begin
       Result := Copy(sValue, 1, Pos(':', sValue) - 1);
       Delete(sValue, 1, Pos(':', sValue));
      end else
      begin
       Result := Copy(sValue, 1, MaxInt);
       sValue := '';
      end;
    end;
var
 BuildAWord: TextFile;
 sLine, sVar : string;
 aPos, aPos2 : integer;
 cPos : char;
begin
 AssignFile(BuildAWord, GetGameSaveFile);
 if FileExists(GetGameSaveFile)
  then
   Reset(BuildAWord)
  else begin
   Quit;
   exit;
  end;
 SetLength(LettersOnBoard, 1);
 While not eof(BuildAWord) do
  begin
   ReadLn(BuildAWord, sLine);
   sVar := Copy(sLine, 1, Pos('=', sLine) - 1);
   delete(sLine, 1, Pos('=', sLine));

   if sVar = 'CurrentLetter' then
    begin
     if sLine = ''
      then
       CurrentLetter := ' '
      else
       CurrentLetter := sLine[1];
    end else
   if sVar = 'PlacedLetters' then
    begin
     aPos := GetArrPos(sLine);
     SetLength(PlacedLetters, aPos + 1);
     PlacedLetters[aPos].X   := StrToInt(GetValue(sLine));
     PlacedLetters[aPos].Y   := StrToInt(GetValue(sLine));
     PlacedLetters[aPos].lbl := StrToInt(GetValue(sLine));
     if PlacedLetters[aPos].X and PlacedLetters[aPos].Y > -1
      then
       Board.Cells[PlacedLetters[aPos].X, PlacedLetters[aPos].Y] := GetValue(sLine);
    end else
   if sVar = 'NumLettersUsed'
    then
     NumLettersUsed := StrToInt(sLine)
    else
   if sVar = 'TileNumber'
    then
     TileNumber := StrToInt(sLine)
    else
   if sVar = 'LetterPickedUp' then
    begin
     LetterPickedUp.X   := StrToInt(GetValue(sLine));
     LetterPickedUp.Y   := StrToInt(GetValue(sLine));
     LetterPickedUp.lbl := StrToInt(GetValue(sLine));
    end else
   if sVar = 'LetterTray' then
    begin
     aPos := GetArrPos(sLine);
     aPos2 := GetArrPos(sLine);
     LetterTray[aPos, aPos2] := sLine[1];
    end else
   if sVar = 'TotalPlayers'
    then
     TotalPlayers := StrToInt(sLine)
    else
   if sVar = 'CurrentScore'
    then
     CurrentScore := StrToInt(sLine)
    else
   if sVar = 'FirstPlayerOver'
    then
     FirstPlayerOver := StrToInt(sLine)
    else
   if sVar = 'Mode'
    then
     Mode := sLine[1]
    else
   if sVar = 'Score'
    then begin
     aPos := GetArrPos(sLine);
     Scores[aPos] := StrToInt(sLine)
    end else
   if sVar = 'LettersOnBoard' then
    begin
     aPos := GetArrPos(sLine);
     SetLength(LettersOnBoard, aPos + 1);
     LettersOnBoard[aPos].X := StrToInt(GetValue(sLine));
     LettersOnBoard[aPos].Y := StrToInt(GetValue(sLine));
     Board.Cells[LettersOnBoard[aPos].X, LettersOnBoard[aPos].Y] := GetValue(sLine);
    end else
   if sVar = 'LetterCount'
    then begin
     cPos := GetArrPosChar(sLine);
     LetterCount[cPos] := StrToInt(sLine)
    end else
   if sVar = 'BonusTiles' then
    begin
     aPos := GetArrPos(sLine);
     BonusTiles[aPos].X := StrToInt(GetValue(sLine));
     BonusTiles[aPos].Y := StrToInt(GetValue(sLine));
    end else
   if sVar = 'CurrentUser'
    then
     CurrentUser := StrToInt(sLine)
    else
   if sVar = 'Turns'
    then
     Turns := StrToInt(sLine)
    else
   if sVar = 'Users'
    then
     Users[GetArrPos(sLine)] := sLine
    else
   if sVar = 'Showing' then
    begin
     aPos := GetArrPos(sLine);
     Tiles[aPos].pnlTile.Visible :=  sLine = 'True';
    end;
  end;

  CloseFile(BuildAword);

  For aPos := 1 to 7 do
   begin
    Tiles[aPos].ChangeLetter(LetterTray[CurrentUser, aPos]);
   end;
  State_NewGame(true);
end;

procedure TBuildAWord.SaveGame;
var
 BuildAWord: TextFile;
 i, k: integer;
 c: char;
begin
 if (not GetHasStarted) then exit;
 AssignFile(BuildAWord, GetGameSaveFile);
 Rewrite(BuildAWord);

 WriteLn(BuildAWord, 'CurrentLetter=' + CurrentLetter);
 for i := 1 to High(PlacedLetters) do
  if PlacedLetters[i].X and PlacedLetters[i].Y > -1
   then
    WriteLn(BuildAWord, 'PlacedLetters=['+ IntToStr(i) + ']' + IntToStr(PlacedLetters[i].X) + ':' + IntToStr(PlacedLetters[i].Y) + ':' + IntToStr(PlacedLetters[i].lbl) + ':' + Board.Cells[PlacedLetters[i].X, PlacedLetters[i].Y])
   else
    WriteLn(BuildAWord, 'PlacedLetters=['+ IntToStr(i) + ']' + IntToStr(PlacedLetters[i].X) + ':' + IntToStr(PlacedLetters[i].Y) + ':' + IntToStr(PlacedLetters[i].lbl));
 WriteLn(BuildAWord, 'NumLettersUsed=' + IntToStr(NumLettersUsed));
 WriteLn(BuildAWord, 'TileNumber=' + IntToStr(TileNumber));
 WriteLn(BuildAWord, 'LetterPickedUp=' + IntToStr(LetterPickedUp.X) + ':' + IntToStr(LetterPickedUp.Y) + ':' + IntToStr(LetterPickedUp.lbl));
 for i := 1 to 4 do
  for k := 1 to 7 do
   WriteLn(BuildAWord, 'LetterTray=[' + IntToStr(i) + '][' + IntToStr(k) + ']' + LetterTray[i, k]);
 WriteLn(BuildAWord, 'TotalPlayers=' + IntToStr(TotalPlayers));
 WriteLn(BuildAWord, 'CurrentScore=' + IntToStr(CurrentScore));
 WriteLn(BuildAWord, 'FirstPlayerOver=' + IntToStr(FirstPlayerOver));

 WriteLn(BuildAWord, 'Mode=' + Mode);
 for i := 1 to 4 do
  WriteLn(BuildAWord, 'Score=[' + IntToStr(i) + ']' + IntToStr(Scores[i]));
 for i := 1 to High(LettersOnBoard) do
  WriteLn(BuildAWord, 'LettersOnBoard=[' + IntToStr(i) + ']' + IntToStr(LettersOnBoard[i].X) + ':' + IntToStr(LettersOnBoard[i].Y) + ':' + Board.Cells[LettersOnBoard[i].X, LettersOnBoard[i].Y]);
 for c := 'A' to 'Z' do
  WriteLn(BuildaWord, 'LetterCount=[' + c + ']' + IntToStr(LetterCount[c]));
 for i := 0 to 60 do
  WriteLn(BuildAWord, 'BonusTiles=[' + IntToStr(i) + ']' + IntToStr(BonusTiles[i].X) + ':' + IntToStr(BonusTiles[i].Y) );
 WriteLn(BuildAWord, 'CurrentUser=' + IntToStr(CurrentUser));
 WriteLn(BuildAWord, 'Turns=' + IntToStr(Turns));
 for i := 1 to 4 do
 WriteLn(BuildAWord, 'Users=[' + IntToStr(i) + ']' + Users[i]);
 for i := 1 to 7 do
  WriteLn(BuildaWord, 'Showing=[' + IntToStr(i) + ']' + BoolToStr(Tiles[i].pnlTile.Showing, True));

 CloseFile(BuildAWord);
end;

procedure TBuildAWord.ResetToDefault;
var
 C, R: integer;
begin
 CurrentLetter := ' ';
 SetLength(PlacedLetters, 0);
 NumLettersUsed := 0;
 TileNumber := 0;
 TotalPlayers := 0;
 CurrentScore := 0;
 FirstPlayerOver := -1;
 Mode := ' ';
 Scores[1] := 0;
 Scores[2] := 0;
 Scores[3] := 0;
 Scores[4] := 0;
 SetLength(LettersOnBoard, 0);
 Turns := 0;
 for C := 0 to 14 do
  for R := 0 to 14 do
   Board.Cells[C, R] := '';
   Board.Cells[7, 7] := '*';
end;

end.

