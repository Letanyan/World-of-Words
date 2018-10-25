unit Tools_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, TabSetManagment_Module, ComCtrls, DB,
  ADODB;

type
 TSolverAndFinder = Class(TThread)
  Private
   qry: TADOQuery;
   FResults: TStringList;
   FListBox: TListBox;
   WordSet: string;
   FType: string;
   procedure Update;

   procedure AnagramSolver;
   procedure HangmanSolver;
   procedure GetSuggestions;
  Protected
   procedure Execute; Override;
  Public
   Constructor Create(lsbResults: TlistBox; sInput, sType: string);
   Destructor  Destroy; Override;
   property Results: TStringList Read FResults;
  end;

 TToolBox = class
  private
    Source         : string;
    qryBuiltRef    : TADOQuery;
    lsbSuggestions : TListBox;
    FSolverFinder: TSolverAndFinder;

    procedure DictionaryDefinition(OutPutField : TMemo; SearchedWord : string);
    procedure ThesaurusResults(OutPutField : TMemo; SearchedWord : string);
    function  GetOperationComplete: boolean;
  public
    property SolverFinder: TSolverAndFinder Read FSolverFinder Write FSolverFinder;
    Constructor Create(qry : TADOQuery; lsb : TListBox);

    function Running: Boolean;
    property OperationComplete: Boolean Read GetOperationComplete;
    procedure ChangeSource(OutputField : TMemo; NewSource : string; SearchedWord : string);
    procedure GetSuggestion(sUserInput : string; OutputField : TMemo);
    procedure GetDefinition(OutputField   : TMemo ; ChoosenWord  : string);
 end;


 function GetWhereClauseAnagram(WordSet: string): String;


implementation

uses StrUtils;

{ Dictionary }

procedure TToolBox.ChangeSource(OutputField : TMemo; NewSource: string; SearchedWord : string);
begin
 Source := Trim(NewSource);
 GetSuggestion(SearchedWord, OutputField);
end;

constructor TToolBox.Create(qry: TADOQuery; lsb: TLIstBox);
begin
 lsbSuggestions := lsb;
 qryBuiltRef    := qry;
 Source := 'Dictionary';
 SolverFinder := TSolverAndFinder.Create(lsbSuggestions, '', '');
 SolverFinder.Terminate;
end;

procedure TToolBox.GetDefinition(OutputField: TMemo;
  ChoosenWord: string);
begin
 if source = 'Dictionary'
  then
   DictionaryDefinition(OutputField, ChoosenWord)
  else
 if source = 'Thesaurus'
  then
   ThesaurusResults(OutputField, ChoosenWord);
end;

procedure TToolBox.GetSuggestion(sUserInput: string; OutputField : TMemo);
begin
 if Assigned(SolverFinder)
  then
 if not SolverFinder.Terminated then
  begin
   SolverFinder := nil;
  end;

 SolverFinder := TSolverAndFinder.Create(lsbSuggestions, sUserInput, source);

 //GetDefinition(OutputField, lsbSuggestions.Items[lsbSuggestions.ItemIndex]);
end;

procedure TToolBox.DictionaryDefinition(OutPutField : TMemo; SearchedWord : string);
var
 actualWord : string;
 defpos     : integer;
begin
 actualWord := SearchedWord;
 if pos(' [', actualWord) > 0
  then
   defpos := StrToInt( Copy(actualWord, Pos(' [', actualWord) + 2, length(actualWord) - Pos(' [', actualWord) - 2) )
  else
   defpos := 1;
 Delete(actualWord, Pos(' [', actualWord), length(actualWord));
 qryBuiltRef.Close;
 qryBuiltRef.SQL.Text := 'SELECT definition FROM Dictionary WHERE headword = "' + actualWord + '"';
 qryBuiltRef.Open;
 qryBuiltRef.RecNo := defpos;
 OutPutField.Text := qryBuiltRef.Fields[0].Text;
end;

procedure TToolBox.ThesaurusResults(OutPutField: TMemo; SearchedWord: string);
var
 actualWord : string;
 defpos     : integer;
begin
 OutPutField.Lines.Clear;
 actualWord := SearchedWord;
 if pos(' [', actualWord) > 0
  then
   defpos := StrToInt( Copy(actualWord, Pos(' [', actualWord) + 2, length(actualWord) - Pos(' [', actualWord) - 2) )
  else
   defpos := 1;
 Delete(actualWord, Pos(' [', actualWord), length(actualWord));
 qryBuiltRef.Close;
 qryBuiltRef.SQL.Text := 'SELECT synonyms, antonyms FROM Dictionary WHERE headword = "' + actualWord + '"';
 qryBuiltRef.Open;
 qryBuiltRef.RecNo := defpos;

 if qryBuiltRef.Fields[0].Text <> '' then
  begin
   OutPutField.Lines.Add('Synonyms');
   OutPutField.Lines.Add(qryBuiltRef.Fields[0].Text);
  end;

 if qryBuiltRef.Fields[1].Text <> '' then
  begin
   OutPutField.Lines.Add(' ');
   OutPutField.Lines.Add('Antonyms');
   OutPutField.Lines.Add(qryBuiltRef.Fields[1].Text);
  end;
end;

{ TAnagramSolver }

function GetWhereClauseAnagram(WordSet: string): String;
var  LetterCount: Array['A'..'Z'] of Integer;

    function MoreThanLetterCount(s: string): boolean;
    var
     i: integer;
    begin
     Result := False;
     s := UpperCase(s);
     for i := 1 to Length(s) do
      Begin
       Dec(LetterCount[s[i]]);
       if LetterCount[s[i]] < 0 then
        begin
         Result := True;
         exit;
        end;
      end;
    end;


    procedure SetLetterCount;
    var
     c: char;
     i: integer;
    begin
     for c := 'A' to 'Z' do
      LetterCount[c] := 0;

     for i := 1 to Length(WordSet) do
      Inc(LetterCount[WordSet[i]]);
    end;

    function GetWhereClause: string;
    var
     c: char;
    begin
     WordSet := UpperCase(WordSet);
     Result := '';
     for c := 'A' to 'Z' do
      if Pos(c, WordSet) = 0 then
       Result := Result + '(Word NOT LIKE "%' + c + '%") and ';
     Delete(Result, Length(Result) - 4, 5);
     Result := '(' + Result + ') and (LEN(Word) <=' + IntToStr(Length(WordSet)) + ')';
    end;

begin
 Result := GetWhereClause;
end;

procedure TSolverAndFinder.AnagramSolver;
var  LetterCount: Array['A'..'Z'] of Integer;

    procedure SetLetterCount;
    var
     c: char;
     i, k: integer;
    begin
     for c := 'A' to 'Z' do
      LetterCount[c] := 0;

     k := Length(WordSet);

     for i := 1 to k do
      LetterCount[WordSet[i]] := LetterCount[WordSet[i]] + 1;
    end;

    function MoreThanLetterCount(s: string): boolean;
    var
     i: integer;
    begin
     Result := False;
     s := UpperCase(s);
     SetLetterCount;
     for i := 1 to Length(s) do
      Begin
       Dec(LetterCount[s[i]]);
       if LetterCount[s[i]] < 0 then
        begin
         Result := True;
         exit;
        end;
      end;
    end;

    function GetWhereClause: string;
    var
     c: char;
    begin
     WordSet := UpperCase(WordSet);
     Result := '';
     for c := 'A' to 'Z' do
      if Pos(c, WordSet) = 0
       then
        Result := Result + '(Word NOT LIKE "%' + c + '%") and ';
     Delete(Result, Length(Result) - 4, 5);
     Result := '(' + Result + ') and (LEN(Word) <=' + IntToStr(Length(WordSet)) + ')';
    end;


begin
 if Terminated then exit;
 if (WordSet = '') and (Length(WordSet) > 2) then
  begin
   Terminate;
   exit;
  end;
 FListBox.Items.Clear;
 qry.Close;
 qry.SQL.Text := 'SELECT word FROM [Word List] WHERE ' + GetWhereClauseAnagram(WordSet);
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
     Results.Add(qry.Fields[0].Text);
     if terminated then break;
     Synchronize(Update);
  end;

 Terminate;
end;

constructor TSolverAndFinder.Create(lsbResults: TlistBox; sInput, sType: string);
begin
  Inherited Create(True);
  FreeOnTerminate := True;
  FResults := TStringList.Create;
  FListBox := lsbResults;
  WordSet := sInput;
  FType := sType;
  qry := TADOQuery.Create(nil);
  qry.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=PAT.mdb;Persist Security Info=False';
  Resume;
end;

destructor TSolverAndFinder.Destroy;
begin
  FreeAndNil(qry);
  FreeAndNil(FResults);
  inherited;
end;

procedure TSolverAndFinder.Execute;
begin
 if FType = 'Anagram Solver'
  then
   AnagramSolver
  else
 if FType = 'Hangman Solver'
  then
   HangmanSolver
  else
 if (FType = 'Dictionary') or (FType = 'Thesaurus')
  then
   GetSuggestions
  else
   Terminate;
end;

procedure TSolverAndFinder.GetSuggestions;
var
 difmean : integer;
begin
 if WordSet = '' then
  begin
   Terminate;
   exit;
  end;
 FListBox.Items.Clear;
 qry.Close;
 qry.SQL.Text := 'SELECT headword FROM Dictionary WHERE headword Like "' + WordSet + '%"';
 qry.Open;
 if qry.RecordCount = 0 then
  begin
   Terminate;
   exit;
  end;
 FListBox.Items.Add(qry.Fields[0].text);
 qry.RecNo := 2;
 difmean := 1;
 While (qry.RecNo < qry.RecordCount) do
  begin
   if Terminated then exit;
   if (FResults[qry.RecNo - 2] = qry.Fields[0].text)
   or (FResults[qry.RecNo - 2] = qry.Fields[0].text + ' ['+IntToStr(difmean)+']')
    then
    begin
     inc(difmean);
     if (FResults[qry.RecNo - 2] = qry.Fields[0].text)
      then
       FResults[qry.RecNo - 2] := FResults[qry.RecNo - 2] + ' [1]';
      FResults.Add(qry.Fields[0].text + ' [' + IntToStr(difmean) + ']' );
      Synchronize(Update);
    end else
    begin
     FResults.Add(qry.Fields[0].text);
     Synchronize(Update);
     difmean := 1;
    end;

   qry.RecNo := qry.RecNo + 1;
  end;

  terminate;
end;

procedure TSolverAndFinder.HangmanSolver;
    function HasUsedLetters(sUsed, sWord: string): Boolean;
    var
     i: integer;
    begin
     Result := false;
     for i := 1 to Length(sUsed) do
      if Pos(sUsed[i], sWord) > 0 then
       begin
        Result := True;
        break;
       end;

    end;
begin
  if (WordSet = '') or (Length(WordSet) < 3) then
  begin
   Terminate;
   exit;
  end;
 FListBox.Items.Clear;
 qry.Close;
 qry.SQL.Text := 'SELECT word FROM [Word List] WHERE Word Like "' + WordSet + '"';
 qry.Open;
 if qry.RecordCount = 0 then
  begin
   Terminate;
   exit;
  end;
 qry.RecNo := 1;
 While (qry.RecNo < qry.RecordCount) do
  begin
     Results.Add(qry.Fields[0].Text);
     qry.RecNo := qry.RecNo + 1;
     if terminated then exit;
     Synchronize(Update);
  end;
     Results.Add(qry.Fields[0].Text);
     qry.RecNo := qry.RecNo + 1;
     if terminated then exit;
     Synchronize(Update);
 Terminate;
end;

procedure TSolverAndFinder.Update;
begin
 if Results.Count - 1 > -1
  then
   FListBox.Items.Add(Results[Results.Count - 1]);
end;

function TToolBox.GetOperationComplete: boolean;
begin
 Result := SolverFinder.Terminated;
end;

function TToolBox.Running: Boolean;
begin
  if SolverFinder <> nil
  then
   Result := Not SolverFinder.Terminated
  else
   Result := False;
end;

end.
