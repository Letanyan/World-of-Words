unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TStringArray = Array of String;

  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const Rows = 2;

implementation

{$R *.dfm}

procedure QuickSort(var Strings: TStringArray; Start, Stop: Integer);
var
  Left: Integer;
  Right: Integer;
  Mid: Integer;
  Pivot: string;
  Temp: string;
begin
  Left  := Start;
  Right := Stop;
  Mid   := (Start + Stop) div 2;

  if mid > High(Strings) then exit;

  Pivot := Strings[mid];
  repeat
    while Strings[Left] < Pivot do Inc(Left);
    while Pivot < Strings[Right] do Dec(Right);
    if Left <= Right then
    begin
      Temp           := Strings[Left];
      Strings[Left]  := Strings[Right]; // Swops the two Strings
      Strings[Right] := Temp;
      Inc(Left);
      Dec(Right);
    end;
  until Left > Right;

  if Start < Right then QuickSort(Strings, Start, Right); // Uses
  if Left < Stop then QuickSort(Strings, Left, Stop);     // Recursion
end;
{--------------------------------------------------------------------}

function BinSearch(Strings: TStringArray; SubStr: string): Integer;
var
  First: Integer;
  Last: Integer;
  Pivot: Integer;
  Found: Boolean;
begin
  First  := Low(Strings); //Sets the first item of the range
  Last   := High(Strings); //Sets the last item of the range
  Found  := False; //Initializes the Found flag (Not found yet)
  Result := -1; //Initializes the Result

  //If First > Last then the searched item doesn't exist
  //If the item is found the loop will stop
  while (First <= Last) and (not Found) do
  begin
    //Gets the middle of the selected range
    Pivot := (First + Last) div 2;
    //Compares the String in the middle with the searched one
    if Strings[Pivot] = SubStr then
    begin
      Found  := True;
      Result := Pivot;
    end
    //If the Item in the middle has a bigger value than
    //the searched item, then select the first half
    else if Strings[Pivot] > SubStr then
      Last := Pivot - 1
        //else select the second half
    else
      First := Pivot + 1;
  end;
end;
{--------------------------------------------------------------------}


procedure TForm1.Button1Click(Sender: TObject);

     function MetCondition(sSeq: string; c: char): boolean;
     var
      i: integer;
      ic: char;
     begin
       Result := true;
       if (c = 'F') or (Length(sSeq) = 1)
        then
         exit;

       if c = 'U'
        then
         ic := 'D'
        else
         ic := 'U';

       Result := True;
       for i := Length(sSeq) downto 1 do
        if (sSeq[i] = ic) then
         begin
          Result := false;
          exit;
         end else
         if sSeq = 'F'
          then
           exit;

     end;

var  Seq: TStringArray;

     function IsRepeat(s: string): boolean;
     var
      i: integer;
     begin
      QuickSort(Seq, 0, High(Seq));

      Result := BinSearch(Seq, s) > -1;
     { for i := 0 to High(Seq) do
       if s = Seq[i] then
        begin
         Result := true;
         exit;
        end;    }
     end;

     function IsPointless(s: string): boolean;
     begin
     case rows of
      5: Result := (Pos('UUUUU', s) > 0)
                or (Pos('DDDDD', s) > 0)
                or (Pos('UD', s) > 0)
                or (Pos('DU', s) > 0)
                or (Pos('UUUUFU', s) > 0)
                or (Pos('DDDDFD', s) > 0);
     4: Result := (Pos('UUUU', s) > 0)
                or (Pos('DDDD', s) > 0)
                or (Pos('UD', s) > 0)
                or (Pos('DU', s) > 0)
                or (Pos('UUUFU', s) > 0)
                or (Pos('DDDFD', s) > 0);
     3: Result := (Pos('UUU', s) > 0)
                or (Pos('DDD', s) > 0)
                or (Pos('UD', s) > 0)
                or (Pos('DU', s) > 0)
                or (Pos('UUFU', s) > 0)
                or (Pos('DDFD', s) > 0);
     2: Result := (Pos('UU', s) > 0)
                or (Pos('DD', s) > 0)
                or (Pos('UD', s) > 0)
                or (Pos('DU', s) > 0)
                or (Pos('UFU', s) > 0)
                or (Pos('DFD', s) > 0);
     end;
     end;

     function MakeSeq: String;
     var
      c: char;
      i: integer;
     begin
      Randomize;
      Result := '';
      For i := 1 to 15 do
       begin

        Repeat
         c := ' ';
         case Random(3) of
          0: c := 'U';
          1: c := 'F';
          2: c := 'D';
         end;
        Until MetCondition(Result, c);

        Result := Result + c;
       end;
     end;

var
 i: integer;
 sSeq: string;
begin
 SetLength(Seq, 0);    //48512
 For i:= 1 to 1000 do
  begin
   Repeat
    sSeq := MakeSeq;
   Until (not IsRepeat(sSeq) and not IsPointless(sSeq));

   SetLength(Seq, i);
   Seq[i - 1] := sSeq;

   ListBox1.Items.Add(sSeq);
   Memo1.Lines.Add(sSeq + IntToStr(i));

   Memo1.Lines.SaveToFile('Sequences ' + IntToStr(Rows) +' MEM.txt');
  end;

  ListBox1.Items.SaveToFile('Sequences ' + IntToStr(Rows)+ '.txt');
end;

end.
