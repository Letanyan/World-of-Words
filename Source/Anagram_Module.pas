unit Anagram_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Grids, DBGrids, ExtCtrls, DB, ADODB, StdCtrls, jpeg,
  BoardGames_Board__Module, ButtonHandling_Module, CheckLst, Tools_Module,
  Achievements_Module, Achievements_Controller;

type
  TWordSet = Record
    sWord    : string;
    bDone    : Boolean;
    WordsMade: TStringList;
    AllWords : TStringList;
  end;

  TOverUse = record
   cLetter: Char;
   iPos   : Integer;
  end;

  TAllWords = Class(TThread)  //Used to find the total number of words that can be made
    private
     FWord  : string;
     qry    : TADOquery;
     Results: TStringList;
     procedure Update;
     function  Overusage(sInput: string): Boolean;
    protected
     procedure   execute; Override;
    public
     Constructor Create(lst: TstringList; sWord: string);
     Destructor  Destroy; Override;
  end;

  TAnagram = Class(TBoard)
   Private
    lblWordSet, lblScore, lblLives, lblWordCount: TLabel;
    edtInput                                    : TEdit;
    clxWords                                    : TCheckListBox;
    imgWordNavigator                            : TThemeButton;

    WordSet          : String;
    Original         : string;   //Word derived from
    Difficulty       : integer;
    MinLet, MaxLet   : Integer;
    CurrentWordSet   : Integer;
    CurrentWordInSet : Integer;  //Words found in the current set
    InASet           : integer;  //If viewing words made then has that address else -1
    WordsCompleted   : Integer;
    WordSets         : Array of TWordSet;
    OverUsedLetters  : Array of TOverUse;
    lives            : Integer;
    FAllWordSetter   : TAllWords;

    procedure LoadIntoCLX(k: integer);
    procedure WordWasCorrect;
    procedure WordWasWrong;
    procedure WordAlreadyMade;
    procedure InvalidLetters;
    function  IsInWordMade(iWordSet, iPosForAllWords: Integer): boolean;
    function  GetWordsMadeCountLabel(iPos: integer): string;
    function DuplicateWord(sInput: string): boolean;
    function MoreThanLetterCount(sInput: string): boolean;
    function OnlyLetters(s: string): boolean;
   protected
    function  GetWordSet: string;
    function  GetWordScore: integer;
    procedure SetScore;
    procedure HighScore; Override;
   Public
    Constructor Create(lblW, lblS, lblL, lblWC: TLabel; img: TThemeButton; edt: TEdit; clx: TCheckListBox);

    property AllWordSetter: TAllWords Read FAllWordSetter Write FAllWordSetter;

    procedure SaveGame; Override;
    procedure LoadGame; Override;
    procedure NewGame(Difficulty: Integer);
    procedure NextWordSet;
    procedure BackWordSet;
    procedure CheckWord;
    procedure clxWordSetClick(Sender: TObject);
    procedure Resize(pnlHolder: TPanel; imgCheck, imgNext: TImage; bevel: integer);
    procedure ResetToDefault;
    procedure Quit; Override;
    function  GetLetter(X: integer): string;

    function  GetTimeElapsed: string; Override;
    function  Running: Boolean;  //Returns true if still finding all words (because if closed then all words cant be found when reopened)
    function  GetCurrentWordSet: string;
  end;

implementation

uses Math;

{ TAnagram }

procedure TAnagram.BackWordSet;
var
 i: integer;
begin
 if InASet <> -1 then
  begin
   imgWordNavigator.Dir := 'Words Made';
   InASet := -1;
   clxWords.Items.Clear;
   for i := 0 to Length(WordSets) - 1 do
    begin
     clxWords.Items.Add(WordSets[i].sWord);
     clxWords.Checked[i] := WordSets[i].bDone;
    end;
  end else
  begin
   imgWordNavigator.Dir := 'Back';
   clxWords.ItemIndex := CurrentWordSet;
   clxWordSetClick(nil);
  end;
end;

procedure TAnagram.CheckWord;
var
 sedt: string;
begin
 if not CanPlay(True) then exit;
 sedt := edtInput.Text;
 if not OnlyLetters(sedt) then
  begin
   MessageDlg('You may only use letters in this game', mtError, [mbOK], 1);
   exit;
  end else
 if MoreThanLetterCount(sedt) then
  begin
   InvalidLetters;
   exit;
  end else
 if IsAWord(edtInput.Text) then
  begin
   if DuplicateWord(sedt) then
    begin
     WordAlreadyMade;
     exit;
    end;
   CurrentWordInSet := WordSets[CurrentWordSet].WordsMade.Count;
   WordSets[CurrentWordSet].WordsMade.Add(UpperCase(edtInput.Text));
   if sedt = Original
    then
     frmAchievements.AchievementComplete(You_Found_It);
   SetScore;
   Inc(WordsCompleted);
   lblScore.Caption := 'Score: ' + IntToStr(Score - GetWordScore) + ' + ' + IntToStr(GetWordScore);
   lblScore.Refresh;
   WordWasCorrect;
   lblScore.Caption := 'Score: ' + IntToStr(Score);
   LoadIntoCLX(CurrentWordSet);
  end else
  begin
   WordWasWrong;
   dec(Lives);
   lblLives.Caption := 'Lives: ' + IntToStr(Lives);
   if Lives = 0 then
    begin
     HighScore;
    end;
  end;
  lblWordCount.Caption := GetWordsMadeCountLabel(CurrentWordSet);
  edtInput.SetFocus;
end;

constructor TAnagram.Create(lblW, lblS, lblL, lblWC: TLabel; img: TThemeButton; edt: TEdit; clx: TCheckListBox);
begin
 Inherited Create;
 SetGameName('Anagrams');
 lblWordSet := lblW;
 lblScore   := lblS;
 lblLives   := lblL;
 lblWordCount := lblWC;
 imgWordNavigator := img;
 edtInput   := edt;
 clxWords   := clx;
 clxWords.OnClick := clxWordSetClick;
 State_Create(False);
end;

function TAnagram.GetWordScore: integer;
begin
  Result := Length(edtInput.Text) * (CurrentWordInSet + 1);
end;

function TAnagram.GetWordSet: string;
var
 i: integer;
begin
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [Word List] WHERE len(Word) BETWEEN ' + IntToStr(MinLet) + ' AND ' + IntToStr(MaxLet);
 qry.Open;
 qry.RecNo := Random(qry.RecordCount);
 Result := UpperCase(qry.FieldValues['Word']);

 Original := Result;
 WordSet := '';
 for i := 1 to length(Result) do
  Insert(Result[i], WordSet, Random(Length(Result)));

 i := 1;
 While i < Length(WordSet) do
  begin
   Insert(' ', WordSet, i + 1);
   inc(i, 2);
  end;

 Result := WordSet;
end;

procedure TAnagram.HighScore;
begin
 qry.Close;
 with qry.SQL do
  begin
   Clear;
   Add('INSERT INTO Anagrams');
   Add( GetInsertFields(qry));
   Add('VALUES(');
   Add('"' + GetUserName + '", ');
   Add(IntToStr(WordsCompleted) + ', ');
   Add(IntToStr(Difficulty)+ ', ');
   Add(IntToStr(Score) + ', ');
   Add(GetTimeSecs + ', ');
   Add(FloatToStr(Date) + ')' );
  end;
 qry.ExecSQL;
 Inherited;
end;

procedure TAnagram.InvalidLetters;
    function EnglishLetter(sCount: string): string;
    begin
     if Length(sCount) = 1
      then
       Result := 'letter '
      else
       Result := 'letters ';
    end;

var
 i: Integer;
 sNotInSet, sOverused: string;
begin
 sOverused := '';
 sNotInSet := '';

  for i := 0 to High(OverUsedLetters) do
   if Pos(OverUsedLetters[i].cLetter, Wordset) = 0
    then
     sNotInSet := sNotInSet + OverUsedLetters[i].cLetter + ', '
    else
     sOverused := sOverused + OverUsedLetters[i].cLetter + '(' + IntToStr(OverUsedLetters[i].iPos) + ')' + ', ';

  Delete(sNotInSet, Length(sNotInSet) - 1, 2);
  Delete(sOverused, Length(sOverused) - 1, 2);

  if sNotInSet <> ''
   then
    ShowMessage('You can''t use the ' + EnglishLetter(sNotInSet) + '"' + sNotInSet + '" as it is not in the letter set');

  if sOverused <> ''
   then
    Showmessage('You can''t use the ' + EnglishLetter(sOverused) + '"' + sOverused + '" as you have overused it');

end;

procedure TAnagram.LoadGame;
var
 Line, Coro : string;
 txt  : TextFile;
 i, k : integer;
begin
 AssignFile(txt, GetGameSaveFile);
 if FileExists(GetGameSaveFile)
  then
   Reset(txt)
  else begin
   //Quit;
   ResetToDefault;
   exit;
  end;
 k := -1;
 While not eof(txt) do
  begin
   ReadLn(txt, Line);
   Coro := Copy(Line, 1, Pos('=', Line) - 1);
   Delete(Line, 1, Pos('=', Line));
   if coro = 'WordSet'
    then
     Wordset := Line
    else
   if coro = 'MaxLet'
    then
     MaxLet := StrToInt(Line)
    else
   if coro = 'MinLet'
    then
     MinLet := StrToInt(line)
    else
   if coro = 'CurrentWordSet'
    then
     CurrentWordSet := StrToInt(Line)
    else
   if coro = 'CurrentWordInSet'
    then
     CurrentWordInSet := StrToInt(Line)
    else
   if coro = 'Difficulty'
    then
     Difficulty := StrToInt(Line)
    else
   if coro = 'InASet'
    then
     InASet := StrToInt(Line)
    else
   if coro = 'TimePlaying'
    then
     TimePlaying := StrToInt(Line)
    else
   if coro = 'Score'
    then
     score := StrToInt(Line)
    else
   if coro = 'Lives'
    then
     Lives := StrToInt(Line)
    else
   if coro = 'edt'
    then
     edtInput.Text := Line
    else
   if coro = 'Original'
    then
     Original := Line
    else
   if coro = 'sWord' then
    begin
      i := StrToInt( Copy( Line, Pos('[', Line) + 1, Pos(']', Line) - 2 ) );
      SetLength(WordSets, i + 1);
      if k <> i then
       begin
        k := i;
        WordSets[i].WordsMade := TStringList.Create;
        WordSets[i].AllWords := TStringList.Create;
       end;
      Delete(Line, 1, Pos(']', Line));
      WordSets[i].sWord := Line;
    end else
   if coro = 'bDone' then
    begin
      i := StrToInt( Copy( Line, Pos('[', Line) + 1, Pos(']', Line) - 2 ) );
      Delete(Line, 1, Pos(']', Line));
      WordSets[i].bDone := Line = 'True';
    end else
   if coro = 'WordsMade' then
    begin
      i := StrToInt(Copy(Line, 2, Pos(']', Line) - 2));
      Delete(Line, 1, Pos(']', Line));
      WordSets[i].WordsMade.Add(Line);
    end else
   if coro = 'AllWords' then
    begin
      i := StrToInt(Copy(Line, 2, Pos(']', Line) - 2));
      Delete(Line, 1, Pos(']', Line));
      WordSets[i].AllWords.Add(Line);
    end;
  end;

 State_NewGame(true);
 lblScore.Caption := 'Score: ' + IntToStr(score);
 lblLives.Caption := 'Lives: ' + IntToStr(Lives);
 lblWordSet.Caption := WordSet;
 lblWordCount.Caption := GetWordsMadeCountLabel(CurrentWordSet);

 clxWords.Items.Clear;
 if InASet = -1 then
  begin
   imgWordNavigator.Dir := ('Words Made');
   for i := 0 to Length(WordSets) - 1 do
    begin
     clxWords.Items.Add(WordSets[i].sWord);
     clxWords.Checked[i] := WordSets[i].bDone;
    end;
  end else
   LoadIntoCLX(InASet);


 CloseFile(txt);
end;

procedure TAnagram.LoadIntoCLX(k: integer);
var
 i: integer;
begin
 //if not CanPlay(False) then exit;
 if k < 0 then exit;
 imgWordNavigator.Dir := ('Back');
 clxWords.Items.Clear;
 InASet := k;
 if WordSets[k].bDone then
  for i := 0 to WordSets[k].AllWords.Count - 1 do
   begin
    clxWords.Items.Add(WordSets[k].AllWords[i]);
    clxWords.Checked[i] := IsInWordMade(k, i);
   end else
  if not Assigned(AllWordSetter)
   then 
  for i := 0 to WordSets[k].WordsMade.Count - 1 do
   begin
    clxWords.Items.Add(WordSets[k].WordsMade[i]);
    clxWords.Checked[i] := True;
   end;
 if WordSets[k].bDone then
  begin
   clxWords.Items.Add(GetWordsMadeCountLabel(k));
   clxWords.Checked[clxWords.Items.Count - 1] := True;
  end;
end;

procedure TAnagram.clxWordSetClick(Sender: TObject);
var
 k: integer;
begin
 if InASet <> -1 then
  begin
   exit;
  end;
 k := clxWords.ItemIndex;
 if k < 0 then exit;
 InASet := k;
 LoadIntoCLX(k);
end;

procedure TAnagram.NewGame(Difficulty: Integer);
begin
 Self.Difficulty := Difficulty;
 Case Difficulty of
  5 : MaxLet := 7;
  4 : MaxLet := 9;
  3 : MaxLet := 11;
  2 : MaxLet := 13;
  1 : MaxLet := 15;
 end;
 MinLet := MaxLet - (MaxLet div 5) - 1;

 State_NewGame(False);
 SetLength(WordSets, 0);
 CurrentWordInSet := 0;
 clxWords.Items.Clear;
 TimePlaying := 0;
 InASet := -1;
 Score := 0;
 Lives := 3;
 WordsCompleted := 0;
 lblLives.Caption := 'Lives: 3';
 lblScore.Caption := 'Score: 0';
 NextWordSet;
end;

procedure TAnagram.NextWordSet;
begin
 if not CanPlay(True) then exit;
 if Assigned(AllWordSetter)
  then
 if not AllWordSetter.Terminated then
  begin
   MessageDlg('You can''t skip this set just yet', mtInformation, [mbOK], 1);
   exit;
  end;

 if Length(WordSets) > 0 then
 if WordSets[High(WordSets)].WordsMade.Count < WordSets[High(WordSets)].AllWords.Count div 4 * 3 then
  begin
   MessageDlg('You need to make at least ' +
              IntToStr(WordSets[High(WordSets)].AllWords.Count div 4 * 3) +
              ' words to get another set',
              mtInformation,
              [mbOk],
              1
   );
   exit;
  end;

 if Length(WordSets) > 0 then
  begin
   WordSets[Length(WordSets) - 1].sWord := Original + ' (' + RemoveSpaces(WordSet) + ')';
   WordSets[Length(WordSets) - 1].bDone := True;
  end;
 lblWordSet.Caption := GetWordSet;
 SetLength(WordSets, Length(WordSets) + 1);
 CurrentWordSet := Length(WordSets) - 1;
 frmAchievements.AchievementComplete(You_Should_Try_Harder);
 if Length(WordSets) = 20
  then
   frmAchievements.AchievementComplete(This_has_Gone_to_Far);
 WordSets[CurrentWordSet].sWord := RemoveSpaces(WordSet);
 WordSets[CurrentWordSet].bDone := false;
 WordSets[CurrentWordSet].WordsMade := TStringList.Create;
 WordSets[CurrentWordSet].AllWords  := TStringList.Create;
 AllWordSetter := TAllWords.Create(WordSets[CurrentWordSet].AllWords, RemoveSpaces(WordSet));
 lblWordCount.Caption := GetWordsMadeCountLabel(CurrentWordSet);
 CurrentWordInSet := 0;
 clxWords.Items.Add(WordSets[CurrentWordSet].sWord);
 edtInput.Clear;
 InASet := 0;
 BackWordSet;
 edtInput.SetFocus;
end;

procedure TAnagram.Quit;
begin
  inherited;
  lblWordSet.Caption := 'Game Over' + #13 + 'Your Last Word Was ' + UpperCase(Original);
  lblWordSet.Left    :=  edtInput.Left + edtInput.Width div 2 - lblWordSet.Width div 2;
  if CurrentWordSet < 0 then exit;
  WordSets[CurrentWordSet].bDone := True;
  if InASet <> -1 then
   begin
    LoadIntoCLX(Length(WordSets) - 1);
    WordSets[Length(WordSets) - 1].sWord := Original + ' (' + RemoveSpaces(WordSet) + ')';
   end else
   begin
    WordSets[Length(WordSets) - 1].sWord := Original + ' (' + RemoveSpaces(WordSet) + ')';
    clxWords.Items[clxWords.Items.Count - 1] := Original + ' (' + RemoveSpaces(WordSet) + ')';
    clxWords.Checked[clxWords.Items.Count - 1] := True;
  end;
end;

procedure TAnagram.ResetToDefault;
begin
  WordSet := '';
  Difficulty := 0;
  MinLet := 0;
  MaxLEt := 0;
  CurrentWordSet := 0;
  CurrentWordInSet := 0;
  InASet := -1;
  WordsCompleted := 0;
  SetLength(WordSet, 0);
  SetLength(OverUsedLetters, 0);
  score := 0;
  Lives := 3;
  lblScore.Caption := 'Score:';
  lblLives.Caption := 'Lives:';
  lblWordCount.Caption := 'Words Made:';
  edtInput.Text := '';
  clxWords.Items.Clear;
  lblWordSet.Caption := 'Press New Game';
end;

procedure TAnagram.Resize(pnlHolder: TPanel; imgCheck, imgNext: TImage; bevel: integer);
begin
 edtInput.Left   := pnlHolder.Width  div 2 - edtInput.Width    div 2 - bevel div 2;
 imgCheck.Left   := pnlHolder.Width  div 2 - imgCheck.Width    div 2 - bevel div 2;
 imgNext .Left   := pnlHolder.Width  div 2 - imgNext.Width     div 2 - bevel div 2;
 lblWordSet.Left := pnlHolder.Width  div 2 - lblWordSet.Width  div 2 - bevel div 2;

 edtInput.Top   := pnlHolder.Height div 2 - edtInput.Height div 2;
 imgCheck.Top   := edtInput.Top  + 56;
 imgNext .Top   := edtInput.Top  + 176;
 lblWordSet.Top := edtInput.Top  - 176;
end;

procedure TAnagram.SaveGame;
var
 GameSave : TextFile;
 i, k : integer;
begin
 if (not GetHasStarted) then exit;
 AssignFile(GameSave, GetGameSaveFile);
 Rewrite(GameSave);

 WriteLn(GameSave, 'WordSet=' + WordSet);
 WriteLn(GameSave, 'MaxLet='  + IntToStr(MaxLet));
 WriteLn(GameSave, 'MinLet='  + IntToStr(MaxLet));
 WriteLn(GameSave, 'CurrentWordSet=' + IntToStr(CurrentWordSet));
 WriteLn(GameSave, 'CurrentWordInSet=' + IntToStr(CurrentWordInSet));
 WriteLn(GameSave, 'InASet=' + IntToStr(InASet));
 WriteLn(GameSave, 'Score=' + IntToStr(Score));
 WriteLn(GameSave, 'Lives=' + IntToStr(Lives));
 WriteLn(GameSave, 'Difficulty=' + IntToStr(Difficulty));
 WriteLn(GameSave, 'TimePlaying=' + IntToStr(TimePlaying));
 WriteLn(GameSave, 'edt=' + edtInput.text);
 WriteLn(GameSave, 'Original=' + Original);

 for i := 0 to Length(WordSets) - 1 do
  begin
   WriteLn(GameSave, 'sWord=[' + IntToStr(i) + ']' + WordSets[i].sWord);
   for k := 0 to WordSets[i].WordsMade.Count - 1 do
    WriteLn(GameSave, 'WordsMade=[' + IntToStr(i) + ']' + WordSets[i].WordsMade[k]);
   WriteLn(GameSave, 'bDone=[' + IntToStr(i) + ']' + BoolToStr(WordSets[i].bDone, True));
   for k := 0 to WordSets[i].AllWords.Count - 1 do
    WriteLn(GameSave, 'AllWords=[' + IntToStr(i) + ']' + WordSets[i].AllWords[k]);
  end;

 CloseFile(GameSave);
end;

procedure TAnagram.SetScore;
begin
 Score := Score + GetWordScore;
end;

procedure TAnagram.WordAlreadyMade;
begin
 ShowMessage('You Already Made This Word' + #13 +
             'Press [Words Made] to view your words made with the current anagram'
             );
end;

procedure TAnagram.WordWasCorrect;
begin
 edtInput.Color := clLime;
 edtInput.Text  := 'CORRECT';
 edtInput.Refresh;
 Sleep(400);
 edtInput.Color := clWhite;
 edtInput.Text  := '';
end;

procedure TAnagram.WordWasWrong;
begin
 edtInput.Color := clRed;
 edtInput.Text  := 'INCORRECT';
 edtInput.Refresh;
 Sleep(400);
 edtInput.Color := clWhite;
 edtInput.Text  := '';
end;

function TAnagram.IsInWordMade(iWordSet, iPosForAllWords: Integer): boolean;
var
 i: integer;
begin
 Result := false;
 for i := 0 to WordSets[iWordSet].WordsMade.Count - 1 do
  if UpperCase(WordSets[iWordSet].WordsMade[i]) = UpperCase(WordSets[iWordSet].AllWords[iPosForAllWords]) then
   begin
    Result := True;
    exit;
   end;
end;


function TAnagram.GetWordsMadeCountLabel(iPos: Integer): string;
begin
 if Assigned(AllWordSetter)
  then
 if not AllWordSetter.Terminated then
  begin
   Result := 'Words Made: ' + IntToStr(WordSets[iPos].WordsMade.Count) + ' / ?';
   exit;
  end;

  Result :=  'Words Made: ' +
             IntToStr(WordSets[iPos].WordsMade.Count) +
             ' / ' +
             IntToStr(WordSets[iPos].AllWords.Count);

 if iPos - 1 > -1 then
 if WordSets[iPos - 1].WordsMade.Count = WordSets[iPos - 1].AllWords.Count
  then
   frmAchievements.AchievementComplete(You_Actually_Found_All);
end;

function TAnagram.GetCurrentWordSet: string;
begin
 Result := RemoveSpaces(WordSet);
end;

function TAnagram.GetTimeElapsed: string;
begin
 if Assigned(AllWordSetter)
  then
   if AllWordSetter.Terminated
    then
     AllWordSetter := nil;
 if not Assigned(AllWordSetter) then
  begin

     if Pos('?', lblWordCount.Caption) > 0
      then
       lblWordCount.Caption := GetWordsMadeCountLabel(CurrentWordSet);
  end;
 Result := Inherited GetTimeElapsed;
end;

function TAnagram.Running: Boolean;
begin
 if AllWordSetter <> nil
  then
   Result := Not AllWordSetter.Terminated
  else
   Result := False;
end;

function TAnagram.DuplicateWord(sInput: string): boolean;
var
 i: integer;
 s: string;
begin
 Result := false;
 s := UpperCase(sInput);
 for i := 0 to WordSets[CurrentWordSet].WordsMade.Count - 1 do
  if WordSets[CurrentWordSet].WordsMade[i] = s
   then
    Result := true;
end;

function TAnagram.MoreThanLetterCount(sInput: string): boolean;
var LetterCount: Array['A'..'Z'] of Integer;

    procedure SetLetterCount;
    var
     c: char;
     i: integer;
    begin
     for c := 'A' to 'Z' do
      LetterCount[c] := 0;

     for i := 1 to Length(WordSet) do
      if WordSet[i] in ['A'..'Z']
       then
        Inc(LetterCount[WordSet[i]]);
    end;
var
 i: integer;
 s: string;
begin
 SetLength(OverUsedLetters, 0);
 SetLetterCount;
 s := sInput;
 Result := False;
 s := UpperCase(s);
 for i := 1 to Length(s) do
  Begin
   Dec(LetterCount[s[i]]);
   if LetterCount[s[i]] < 0 then
    begin
     SetLength(OverUsedLetters, Length(OverUsedLetters) + 1);
     OverUsedLetters[Length(OverUsedLetters) - 1].cLetter := s[i];
     if Pos(s[i], WordSet) > 0
      then
       OverUsedLetters[Length(OverUsedLetters) - 1].iPos  := i
      else
       OverUsedLetters[Length(OverUsedLetters) - 1].iPos  := 0;
     Result := True;
    end;
  end;
end;

function TAnagram.GetLetter(X: Integer): string;
var
 sSet: string;
 k: integer;
begin
 sSet := (lblWordSet.Caption);
 k := X div 14;
 if k in [1..Length(sSet)]
  then
   if sSet[k] = ' '
    then
     if k + 1 < Length(sSet)
      then
       inc(k)
      else
       if k - 1 > 0
        then
         dec(k);

 result := sSet[k];
end;

function TAnagram.OnlyLetters(s: string): boolean;
var
 i: Integer;
begin
 Result := True;
 s := UpperCase(s);
 for i := 1 to Length(s) do
  if not (s[i] in ['A'..'Z']) then
   begin
    Result := False;
    Break;
   end;
end;

{ TAllWords }

constructor TAllWords.Create(lst: TstringList; sWord: string);
begin
  Inherited Create(True);
  FreeOnTerminate := True;
  FWord := sWord;
  Results := lst;
  qry := TADOQuery.Create(nil);
  qry.ConnectionString := DatabaseConnection;
  Resume;
end;

destructor TAllWords.Destroy;
begin
  FreeAndNil(qry);
  inherited;
end;

procedure TAllWords.execute;
begin
   inherited;

   qry.Close;
   qry.SQL.Text := 'SELECT word FROM [Word List] WHERE ' + GetWhereClauseAnagram(FWord);
   qry.Open;
   if qry.RecordCount = 0 then
    begin
     Terminate;
     exit;
    end;

   qry.RecNo := 1;
   While (qry.RecNo < qry.RecordCount) do
    begin
       qry.RecNo := qry.RecNo + 1;
       if terminated then exit;
       Synchronize(Update);
    end;

   Terminate;
end;

function TAllWords.Overusage(sInput: string): Boolean;
var LetterCount: Array['A'..'Z'] of Integer;

    procedure SetLetterCount;
    var
     c: char;
     i: integer;
     s: string;
    begin
     for c := 'A' to 'Z' do
      LetterCount[c] := 0;

     s := UpperCase(FWord);
     for i := 1 to Length(s) do
      Inc(LetterCount[s[i]]);
    end;

var
 i: integer;
 s: string;
begin
 SetLetterCount;
 s := UpperCase(sInput);
 Result := False;
 s := UpperCase(s);
 for i := 1 to Length(s) do
  Begin
   Dec(LetterCount[s[i]]);
   if LetterCount[s[i]] < 0 then
    begin
     Result := True;
     Break;
    end;
  end;
end;

procedure TAllWords.Update;
begin
 if not Overusage(qry.Fields[0].Text)
  then
   Results.Add(qry.Fields[0].Text);
end;

end.
