unit HangmanGame_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ExtCtrls, StdCtrls, DB, Grids,
  DBGrids, ADODB, DBCtrls, BoardGames_Board__Module,
  Achievements_Module, Achievements_Controller;

type
 THangman = class(TBoard)
  private
    Word, UserWord : string;
    UnUsedLetters, UsedLetters : string;
    Lives, Difficulty, WordAddress : integer;

    lblHangmanWord : TLabel;
    lblUsedLetters : Array['A'..'Z'] of TLabel;
    imgHangman     : TImage;

    procedure CreateLetters(lbl : TLabel);
    procedure LabelClick(sender : TObject);



    function GetLives : integer;

    procedure DrawHangman;
    procedure DrawStand;
    procedure DrawHead;
    procedure DrawBody;
    procedure DrawLLeg;
    procedure DrawRLeg;
    procedure DrawLArm;
    procedure DrawRArm;

    procedure CheckLetter(letter : char);

    procedure CleanUp;
  protected
    procedure HighScore; Override;
  public
    constructor Create(img : TImage; lbl : TLabel);
    procedure   ResetToDefault;

    function GetWord : string;

    procedure FreeLetter;
    function GetUserWord : string;
    function GetUserWordC: string;

    procedure SaveGame; Override;
    procedure LoadGame; Override;

    procedure Quit; Override;
    procedure CheckWin;
    procedure Newgame(MinLet, MaxLet : byte);
    procedure Resize(pnlWidth : Integer);
 end;

implementation

uses Math, StrUtils;

{ Hangman }

procedure THangman.DrawHead;
var
 w, h : integer;
begin
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 imgHangman.Canvas.Brush.Style := bsClear;
 with imgHangman.Canvas do
  begin
   Ellipse(imgHangman.Width - 335, 45, imgHangman.Width - 305, 80);
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;    
end;

procedure THangman.DrawBody;
var
 w, h : integer;
begin
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 with imgHangman.Canvas do
  begin
   MoveTo(imgHangman.Width - 320, 80);//move to neck
   LineTo(imgHangman.Width - 320, 110);//draw body
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;
end;

procedure THangman.DrawLLeg;
var
 w, h : integer;
begin
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 with imgHangman.Canvas do
  begin
   MoveTo(imgHangman.Width - 320, 110);
   LineTo(imgHangman.Width - 310, 135);
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;
end;

procedure THangman.DrawRLeg;
var
 w, h : integer;
begin
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 with imgHangman.Canvas do
  begin
   MoveTo(imgHangman.Width - 320, 110);
   LineTo(imgHangman.Width - 330, 135);
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;
end;

procedure THangman.DrawLArm;
var
 w, h : integer;
begin
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 with imgHangman.Canvas do
  begin
   MoveTo(imgHangman.Width - 320, 80);
   LineTo(imgHangman.Width - 310, 105);
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;
end;

procedure THangman.DrawRArm;
var
 w, h : integer;
begin
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 with imgHangman.Canvas do
  begin
   MoveTo(imgHangman.Width - 320, 80);
   LineTo(imgHangman.Width - 330, 105);
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;
end;

procedure THangman.DrawStand;
var
 w, h : integer;
begin
 imgHangman.Align := alNone;
 w := imgHangman.Width;
 h := imgHangman.Height;
 imgHangman.Width := 825;
 imgHangman.Height := 200;
 with imgHangman.Canvas do
  begin
   Pen.Width := 2;
  // Pen.Color := $F0F0F0;
  // Brush.Color := clBtnFace;
  // Rectangle(0, 0, img.Width, img.Height);
   pen.Color := $FFFFFF;

   MoveTo(280, imgHangman.Height - 30 - 30);               //start at B L
   LineTo(imgHangman.Width - 280, imgHangman.height - 30 - 30);  // draw base line at B R
   MoveTo(imgHangman.Width div 2, imgHangman.Height - 30 - 30); //start at B M
   LineTo(imgHangman.Width div 2, 25);            // draw the stands body
   LineTo(imgHangman.Width - 320, 25);           // draw head
   LineTo(imgHangman.Width - 320, 45);          // draw the little hook
  end;
 imgHangman.Width := w;
 imgHangman.Height := h;
 imgHangman.Align := alClient;
end;

function LetterPos(letter : char) : integer;
var
  c : char;
  i : integer;
begin
 i := 0;
 Result := 1;
 for c := 'A' to 'Z' do
  begin
   inc(i);
   if c = letter
    then
     result := i;
  end;
end;

procedure THangman.CheckLetter(letter: char);
var
 i : integer;
 correctletter, hasletter : boolean;
begin
 if (lives > 0) and (UserWord <> '') then
  begin
    letter := UpCase(Letter);
    correctletter := false;

    hasletter := false;
    for i := 1 to length(UsedLetters) do
    if letter = UsedLetters[i] then
     hasletter := true;

    if hasletter then
     begin
      MessageDlg('You''ve Already Used This Letter', mtInformation, mbOKCancel, 1);
      Exit;
     end;

    if not hasletter then
    if UsedLetters = ''
    then
     UsedLetters := letter
    else
     UsedLetters := UsedLetters + ', ' + letter;

    for i := 1 to length(word) do
    if word[i] = letter then
     begin
      UserWord := StuffString(UserWord, i, 1, letter);
      correctletter := true;
     end;

    if correctletter
    then
     UnUsedLetters := StringReplace(UnUsedLetters, letter, '', [])
    else
    if not hasletter then
     begin
      dec(lives);
      imgHangman.Align := alNone;
      case lives of
       5 : DrawHead;
       4 : DrawBody;
       3 : DrawLLeg;
       2 : DrawRLeg;
       1 : DrawLArm;
       0 : DrawRLeg;
      end;
      imgHangman.Align := alClient;
    end;

  end else
 if UserWord = '' then
  MessageDlg('Press New Game To Start a New Game', mtInformation, mbOKCancel, 1); 
end;

function SetUsedLetters : string;
var
 c : char;
begin
 Result := '';
 for c := 'A' to 'Z' do
  Result := Result + c;
end;

function ContainChars(s : string; chars : String) : boolean;
var
 i : integer;
begin
 Result := false;
 for i := 1 to Length(chars) do
  if Pos(chars[i], s) > 0
   then
    Result := true;
end;

function GetWordPos(qry : TADOQuery;  MinLet, MaxLet : byte) : integer;
var
 i : integer;
begin
 Randomize;
 Repeat
  i := Random(qry.RecordCount);
  qry.Open;
  qry.RecNo := i;
  Result := i;
  i := Length(qry.FieldValues['Headword']);
 Until (i in [MinLet..MaxLet]) and (not ContainChars(qry.FieldValues['Headword'], '- /'));
end;

function SetWord(word : string) : String;
var
 i : integer;
begin
 Result := UpperCase(word);

 i := 2;
 Repeat
  insert('  ', Result, i);
  inc(i, 3);
 Until i > length(Result);
  Result := ' ' + Result + ' ';
end;

function SetUserWord(word : string) : string;
var
 i : integer;
begin
 Result := '';
 for i := 0 to length(word) do
  if word[i] in ['A'..'Z']
   then
    Result := Result + ' _ ';

end;

procedure THangman.Newgame(MinLet, MaxLet : byte);
var
 i : integer;
begin
 UnUsedLetters := SetUsedLetters;
 UsedLetters   := '';

 qry.Close;
 qry.SQL.Text := 'SELECT Headword FROM Dictionary';
 qry.Open;

 WordAddress   := GetWordPos(qry, MinLet, MaxLet);
 qry.RecNo     := WordAddress;
 Word          := SetWord(qry.FieldValues['Headword']);

 UserWord    := SetUserWord(word);
 Lives       := 6;
 Val(IntToStr(MinLet) + '.' + IntToStr(MaxLet), Difficulty, i);
 TimePlaying := 0;

 imgHangman.Picture.LoadFromFile('Resources\Chalkboard No Frame.bmp');
 CleanUp;
 CreateLetters(lblHangmanWord);
 Resize(lblHangmanWord.Parent.Width);
 imgHangman.Align := alNone;
 DrawStand;
 imgHangman.Align := alClient;
 State_NewGame(false);
end;

function THangman.GetWord: string;
begin
 Result := Word;
end;

function THangman.GetUserWord : string;
begin
 Result := UserWord;
end;

function THangman.GetLives: integer;
begin
 Result := lives;
end;

constructor THangman.Create(img : TImage; lbl : TLabel);
begin
 Inherited Create;
 SetGameName('Hangman');
 lblHangmanWord := lbl;
 CreateLetters(lbl);

 imgHangman := img;
 State_Create(True);
 //memHangmanWord.OnKeyPress := memHangmanWordKeyPress;

 TimePlaying := 0;
 DrawStand;
end;


procedure THangman.HighScore;
begin
 Score := Trunc(1 / TimePlaying * 1000) + Length(Word) * 10;
 qry.Close;
 qry.SQL.Text := 'INSERT INTO Hangman ' + GetInsertFields(qry) +
                                              'VALUES("' + GetUserName    + '",  '
                                                         + IntToStr(Score)+ ' ,  '
                                                         + GetTimeSecs    + ' , "'
                                                         + Word           + '",  '
                                                         + FloatToStr(Date) + ')';
 qry.ExecSQL;
 Inherited;
end;

procedure THangman.FreeLetter;
var
 RandomLetter : char;
begin
 Repeat
  RandomLetter := Word[RandomRange(1, length(Word))];
 Until (ContainChars(Word, RandomLetter)) and (not ContainChars(UsedLetters, RandomLetter)) and (RandomLetter <> ' ');
 CheckLetter(RandomLetter);

 lblHangmanWord.caption := GetUserWord;
 if (GetLives = 0) or (GetUserWord = GetWord)
  then
   Quit;
end;

procedure THangman.SaveGame;
var
 GameSave : TextFile;
begin
 if (not GetHasStarted) then exit;
 AssignFile(GameSave, GetGameSaveFile);
 Rewrite(GameSave);

 WriteLn(GameSave, 'Word=' + Word);
 WriteLn(GameSave, 'UserWord=' + UserWord);
 WriteLn(GameSave, 'UnUsedLetters=' + UnUsedLetters);
 WriteLn(GameSave, 'UsedLetters=' + UsedLetters);
 WriteLn(GameSave, 'Lives=' + IntToStr(Lives));
 WriteLn(GameSave, 'Difficulty=' + IntToStr(Difficulty));
 WriteLn(GameSave, 'WordAddress=' + IntToStr(WordAddress));
 WriteLn(GameSave, 'TimePlaying=' + IntToStr(TimePlaying));

 CloseFile(GameSave);
end;

procedure THangman.LoadGame;
var
 Line, Coro : string;
 txt  : TextFile;
begin
 AssignFile(txt, GetGameSaveFile);
 if FileExists(GetGameSaveFile)
  then
   Reset(txt)
  else begin
   ResetToDefault;
   exit;
  end;

 While not eof(txt) do
  begin
   ReadLn(txt, Line);
   Coro := Copy(Line, 1, Pos('=', Line) - 1);
   Delete(Line, 1, Pos('=', Line));
   if coro = 'Word'
    then
     Word := Line
    else
   if coro = 'UserWord'
    then
     UserWord := line
    else
   if coro = 'UnUsedLetters'
    then
     UnUsedLetters := Line
    else
   if coro = 'UsedLetters'
    then
     UsedLetters := Line
    else
   if coro = 'Lives'
    then
     Lives := StrToInt(Line)
    else
   if coro = 'Difficulty'
    then
     Difficulty := StrToInt(Line)
    else
   if coro = 'WordAddress'
    then
     WordAddress := StrToInt(Line)
    else
   if coro = 'TimePlaying'
    then
     TimePlaying := StrToInt(Line);
  end;
 DrawHangman;

 CleanUp;
 CreateLetters(lblHangmanWord);

 State_NewGame(true);
 lblHangmanWord.Caption := UserWord;
 CloseFile(txt);
end;

procedure THangman.Quit;
begin
 Inherited;
 if not GetShowingAnswers
  then
   ResetToDefault;
end;

procedure THangman.CreateLetters(lbl: TLabel);
var
 C : char;
begin
 for C := 'A' to 'Z' do
  begin
   lblUsedLetters[C] := TLabel.Create(lbl.Parent);
   With lblUsedLetters[C] do
    begin
     Parent    := lbl.Parent;
     Caption   := C;
     Top       := 8;
     Transparent  := True;
     Font.Color := clWhite;
     Font.Name  := 'Courier New';
     Font.Size  := 30;
     if C <> 'A'
      then
       Left    := lblUsedLetters[Pred(C)].Left + lblUsedLetters[Pred(C)].Width + 16
      else
       Left    := 16;
     OnClick  := LabelClick;
     Visible  := not ContainChars(UsedLetters, C);
    end;
  end;
end;

procedure THangman.LabelClick(sender: TObject);
begin
 if not CanPlay(True) then exit;
 if not(TLabel(Sender).Caption[1] in ['A', 'E', 'I', 'O', 'U']) and (UsedLetters = '')
  then
   frmAchievements.AchievementComplete(Out_Of_The_Norm);
 CheckLetter(TLabel(sender).Caption[1]);
 lblHangmanWord.caption := GetUserWord;
 if ((GetLives = 0) or (GetUserWord = GetWord)) and (GetUserWord <> '')
  then
   CheckWin;
  TLabel(sender).Visible := false;
end;

procedure THangman.CleanUp;
var
 C : char;
begin
 for C := 'A' to 'Z' do
  FreeAndNil(lblUsedLetters[C]);
end;

procedure THangman.Resize(pnlWidth: Integer);
var
 C : Char;
 i : integer;
begin
 i := 0;
 for C := 'A' to 'Z' do
  begin
    lblUsedLetters[C].Left := pnlWidth div 26 * i;
    inc(i);
  end;

 for C := 'A' to 'Z' do
  lblUsedLetters[C].Left := lblUsedLetters[C].Left + (pnlWidth - lblUsedLetters['Z'].Left - lblUsedLetters['Z'].Width) div 2;
end;

procedure THangman.CheckWin;
    procedure DrawDeadGuy;
    begin
     imgHangman.Align := alNone;
     DrawRArm;
     imgHangman.Align := alClient;
    end;
begin
 if (GetUserWord <> GetWord) then
  begin
   MessageDlg('Sorry You Lost', mtCustom, [mbOK], 1);
   DrawDeadGuy;
   lblHangmanWord.Caption := GetWord;
  end else
  begin
   lblHangmanWord.Caption := GetWord;
   if Lives = 6
    then
     frmAchievements.AchievementComplete(Not_A_Drop_of_Blood);
   HighScore;
  end;
  Quit;
end;

procedure THangman.ResetToDefault;
begin
 Word := '';
 UserWord := '';
 UnUsedLetters := SetUsedLetters;
 UsedLetters := '';
 Lives := 6;
 Difficulty := 0;
 WordAddress := 0;
 lblHangmanWord.Caption := 'Press New Game';
 CleanUp;
 CreateLetters(lblHangmanWord);
 imgHangman.Picture.LoadFromFile('Resources\Chalkboard No Frame.bmp');
 TimePlaying := 0;
 //State_Create(False);
end;

procedure THangman.DrawHangman;
var
 i: integer;
begin
 i := 5;
 imgHangman.Picture.LoadFromFile('Resources\Chalkboard No Frame.bmp');
 DrawStand;
 While i >= Lives do
  begin
    imgHangman.Align := alNone;
    case i of
     5 : DrawHead;
     4 : DrawBody;
     3 : DrawLLeg;
     2 : DrawRLeg;
     1 : DrawLArm;
     0 : DrawRLeg;
    end;
    imgHangman.Align := alClient;
   dec(i);
  end;
end;

function THangman.GetUserWordC: string;
begin
 Result := RemoveSpaces(GetUserWord)
end;

end.
