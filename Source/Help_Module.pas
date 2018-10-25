unit Help_Module;

interface

uses forms, windows, SysUtils, StdCtrls, ExtCtrls, Graphics, ComCtrls, Dialogs,
     Classes;
type
  THelp = class
   Private
    edtSearchBox: TEdit;
    lsbSearchResults: TListbox;
    redResultContent: TRichEdit;
    aHelpContent : Array of String;
    aHelpHeadings: Array of String;

    procedure edtSearchBoxChange(Sender: TObject);
    procedure edtSearchBoxKeyUp(Sender: TObject;
                                var Key: Word;
                                Shift: TShiftState);
    procedure lsbSearchResultsClick(Sender: TObject);
    procedure lsbSearchResultsKeyDown(Sender: TObject;
                                    var Key: Word;
                                    Shift: TShiftState);
   Public
    Constructor Create(edt: TEdit; lsb: TListbox; red: TRichEdit);

  end;

  function GetContent(Heading: string): string;

implementation

function GetContent(Heading: string): string;
var
 txt: TextFile;
 sLine: string;
 inArea: Boolean;
begin
 AssignFile(txt, 'HELP.txt') ;
 if FileExists('HELP.txt')
  then
   Reset(txt)
  else
   exit;

 inArea := false;
 Result := '';
 While not eof(txt) do
  begin
   ReadLn(txt, sLine);
   if sLine = '^' + Heading + ' Set Up' then
    begin
     Delete(sLine, 1, 1);
     inArea := true;
    end else
     if inArea
      then
       if sLine = '~.~'
        then
         Break;
   if inArea
    then
     if sLine = '|'
      then
       Result := Result + #13 + ' '
      else
       if Result = ''
        then
         Result := sLine
        else
         Result := Result + #13 + sLine;
  end;
end;

{ THelp }

constructor THelp.Create(edt: TEdit; lsb: TListbox; red: TRichEdit);
    procedure LoadHelpContent;
    var
     Help : TextFile;
     i    : integer;
     sLine: string;
    begin
     AssignFile(Help, 'HELP.txt');
     if FileExists('HELP.txt')
      then
       Reset(Help)
      else
       exit;

     i := 0;
     While not eof(Help) do
      begin
       ReadLn(Help, sLine);
       if (sLine <> '')
        then
         if (sLine[1] = '^') then
          begin
           inc(i);
           SetLength(aHelpContent, i + 1);
           SetLength(aHelpHeadings, i + 1);
           aHelpContent[i]  := '';
           aHelpHeadings[i] := Copy(sLine, 2, length(sLine));
          end else
          if sLine <> '~.~'
           then
           if sLine = '|'
            then
             aHelpContent[i] := aHelpContent[i] + #13 + ' '
            else
              aHelpContent[i] := aHelpContent[i] + #13 + sLine;
      end;
      CloseFile(Help);
    end;

begin
 edtSearchBox := edt;
 edtSearchBox.OnChange := edtSearchBoxChange;
 edtSearchBox.OnKeyDown  := edtSearchBoxKeyUp;
 lsbSearchResults := lsb;
 lsbSearchResults.OnClick := lsbSearchResultsClick;
 lsbSearchResults.OnKeyDown := lsbSearchResultsKeyDown;
 redResultContent := red;
 LoadHelpContent;
end;

procedure THelp.edtSearchBoxChange(Sender: TObject);

    function FindContent(var Content, Terms: Array of String; var Found : string): boolean;
    var
     i, k : integer;
     cntnt, term : string;
     hasall : boolean;
    begin
     Result := false;
     For i := 1 to High(Content) do
      begin
       hasall := true;
       cntnt :=  lowercase(Content[i]);
       for k := 1 to High(terms) do
        begin
         term  := lowercase(Terms[k]);
         if Pos(term, cntnt) = 0 then hasall := false;
         end;
       if hasall then
        begin
         Result := True;
         Found := Found + IntToStr(i) + ',';
        end;
      end;
    end;

    function LastResortFound(var Content, Terms: Array of String; var Found: string): boolean;
    var
     i, k : integer;
     cntnt, term : string;
    begin
     For i := 1 to High(Content) do
      begin
       cntnt :=  lowercase(Content[i]);
       for k := 1 to High(terms) do
        begin
         term  := lowercase(Terms[k]);
         if Pos(' ' + term + ' ', cntnt) > 0
          then
           Found := Found + IntToStr(i) + ',';
        end;
      end;
     Result := Found <> '';
    end;

    procedure LoadToListBox(var Found: string);
    var
     i : integer;
     s : string;
    begin
     lsbSearchResults.Items.Clear;
     i := 0;
     While Found <> '' do
      begin
       s := Copy(Found, 1, Pos(',', Found) - 1);
       if s = IntToStr(i)
        then
         continue
        else
         i := StrToInt(s);
       Delete(Found, 1, Pos(',', found));
       lsbSearchResults.Items.Add(AHelpHeadings[i]);
       if Pos(',', found) = 0
        then
         exit;
      end;
    end;

var
 Found, Question: string;
 Terms : array of String;
 i : integer;
begin
 Question := Trim(LowerCase(edtSearchBox.Text));
 if Pos(' ', Question) = 0 then
  begin
   SetLength(Terms, 2);
   Terms[1] := Question;
  end;

 i := 0;
 Found := '';
 Question := Question + ' ';
 While Pos(' ', Question) > 0 do
  begin
   inc(i);
   SetLength(Terms, i + 1);
   Terms[i] := Copy(Question, 1, Pos(' ', Question) - 1);
   Delete(Question, 1, Pos(' ', Question));
  end;

 if not FindContent(aHelpHeadings, Terms, Found)   //Search with headings return nothing
  then
   if not FindContent(aHelpContent, Terms, Found)  //Get From actual content
    then
     if not LastResortFound(aHelpHeadings, Terms, Found) //Get from headings (individual words)
      then
       LastResortFound(aHelpContent, Terms, Found);

 LoadToListBox(Found);
end;

procedure THelp.edtSearchBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case key of
  VK_DOWN : begin
             lsbSearchResults.SetFocus;
             if lsbSearchResults.Items.Count > 0
              then
               lsbSearchResults.ItemIndex := 0;
            end;
 end;
end;

procedure THelp.lsbSearchResultsClick(Sender: TObject);
var
 i : integer;
begin
 redResultContent.Clear;
 for i := 1 to High(aHelpHeadings) do
  if lsbSearchResults.Items[lsbSearchResults.ItemIndex] = aHelpHeadings[i]
   then
    redResultContent.Text := aHelpContent[i];
 redResultContent.Lines.Delete(0);
end;

procedure THelp.lsbSearchResultsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 lsbSearchResultsClick(Sender);
 case key of
  VK_UP : begin
           if lsbSearchResults.ItemIndex = 0
            then
             edtSearchBox.SetFocus;
          end;
 end;
end;

end.
