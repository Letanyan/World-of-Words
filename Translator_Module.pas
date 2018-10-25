unit Translator_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ExtCtrls, StdCtrls, HangManGame_Module, DB, Grids,
  DBGrids, ADODB, DBCtrls, DatabaseManagment_Module, Spin, WordSearch_Module,
  jpeg, BuildAWord_Module;

type
 TTranslator = Class
  Private
   tbl : TDBGrid;
   qry : TADOQuery;
   dsr : TDataSource;


   function TranslateOneWord(LanguageFrom, LanguageTo, WordToTranslate : string) : string;
   function TranslateWholeText(LanguageFrom, LanguageTo, TextToTranslate : string) : string;
   function CheckListforSimilar(checky, LanguageFrom, LanguageTo: string) : integer;
  Public
   Constructor Create(grd : TDBGrid; qery : TADOQuery; datasorce : TDataSource);
   procedure   ResizeTextBoxes(pnl : TPanel; mem1, mem2 : TMemo);

   function    AutoDetect(TextFrom, LanguageTo : string) : String;
   function    TranslateText(LanguageFrom, LanguageTo, TextFrom : String) : string;

 end;

implementation

{ TTranslator }

Constructor TTranslator.Create(grd : TDBGrid; qery : TADOQuery; datasorce : TDataSource);
begin
 tbl := grd;
 qry := qery;
 dsr := datasorce;
end;

procedure TTranslator.ResizeTextBoxes(pnl: TPanel; mem1, mem2: TMemo);
begin
 mem1.Width := pnl.Width div 2 - 32;
 mem2.Width := pnl.Width div 2 - 32;
 mem2.Left  := mem1.Width + 40;
end;

function LetterisGreater(c1, c2 : char) : Char;
var
 v1, v2 : Real;
begin
 v1 := Ord(c1);
 v2 := Ord(c2);
 if v1 > v2
  then
   Result := '>'
  else
 if v1 = v2
  then
   Result := '<'
  else
   Result := '<';
end;

function WordPastAlphabeticalOrder(WordBeingChecked, WordBeingCheckedTo : string) : boolean;
var
 i : integer;

begin
 Result := false;
 i := 1;
 While (i < length(WordBeingChecked)) do
  begin
   if (i < length(WordBeingChecked)) and (i < length(WordBeingCheckedTo))
    then
     case LetterisGreater(WordBeingChecked[i], WordBeingCheckedTo[i]) of
      '>' : begin
             Result := true;
             Exit;
            end;
      '<' : Exit;
     end;

   inc(i);
  end;

end;

function TTranslator.TranslateOneWord(LanguageFrom, LanguageTo,
  WordToTranslate: string): string;
begin
 qry.Close;
 qry.SQL.Text := '';
 qry.SQL.Add('SELECT ' + LanguageTo);
 qry.SQL.Add('FROM [Word List]');
 qry.SQL.Add('WHERE ' + LanguageFrom + ' = "' + WordToTranslate + '"');
 qry.Open;
 Result := tbl.SelectedField.Text;
 if result = ''
  then
   Result := WordToTranslate;
end;

function TTranslator.TranslateWholeText(LanguageFrom, LanguageTo,
  TextToTranslate: string): string;
var
 s : string;
 i : integer;
begin
 Result := '';

 TextToTranslate := Trim(TextToTranslate);
 for i := 2 to length(TextToTranslate) do
  if (TextToTranslate[i] = ' ') and (TextToTranslate[i - 1] = ' ')
   then
    Delete(TextToTranslate, i, 1);

 TextToTranslate := TextToTranslate + ' ';

 While length(TextToTranslate) > 0 do
  begin
   i := Pos(' ', TextToTranslate);
   s := Copy(TextToTranslate, 1, i);
   Delete(TextToTranslate, 1, i);
   Result := Result + ' ' + TranslateOneWord(LanguageFrom, LanguageTo, s);
  end;

 Delete(Result, 1, 1);
 for i := 2 to length(Result) do
  if (Result[i] = ' ') and (Result[i - 1] = ' ')
   then
    Delete(Result, i, 1);
end;

function TTranslator.CheckListforSimilar(checky, LanguageFrom, LanguageTo: string): integer;
var
 s : string;
 i : integer;
begin
 Result := 0;

 checky := Trim(checky);
 for i := 2 to length(checky) do
  if (checky[i] = ' ') and (checky[i - 1] = ' ')
   then
    Delete(checky, i, 1);

 checky := checky + ' ';

 While length(checky) > 0 do
  begin
   i := Pos(' ', checky);
   s := Copy(checky, 1, i);
   Delete(checky, 1, i);
   if TranslateOneWord(LanguageFrom, LanguageTo, s) <> s
    then
     Inc(Result);
  end;

  Showmessage(IntToStr(Result) + LanguageFrom);
end;

function TTranslator.AutoDetect(TextFrom, LanguageTo : string): String;
var
 k, m : integer;
 Languages : array of integer;
begin
 SetLength(Languages, 7);
 Languages[1] := CheckListforSimilar(TextFrom, 'English', LanguageTo);
 Languages[2] := CheckListforSimilar(TextFrom, 'Afrikaans', LanguageTo);
 Languages[3] := CheckListforSimilar(TextFrom, 'French', LanguageTo);
 Languages[4] := CheckListforSimilar(TextFrom, 'Italian', LanguageTo);
 Languages[5] := CheckListforSimilar(TextFrom, 'Portuguese', LanguageTo);
 Languages[6] := CheckListforSimilar(TextFrom, 'Spanish', LanguageTo);

 m := Languages[1];
 Result := 'English';
 for k := 2 to 6 do
  begin
   if Languages[k] > m
    then
     case k of
      2 : Result := 'Afrikaans';
      3 : Result := 'French';
      4 : Result := 'Italian';
      5 : Result := 'Portuguese';
      6 : Result := 'Spanish';
     end;
  end;


end;

function TTranslator.TranslateText(LanguageFrom, LanguageTo, TextFrom : String) : String;
begin
 if LowerCase(LanguageFrom) = 'auto-detect'
  then
   LanguageFrom := AutoDetect(TextFrom, LanguageTo);

 Result  := TranslateWholeText(LanguageFrom, LanguageTo, TextFrom);
end;

end.
