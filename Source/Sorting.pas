unit Sorting;

interface

uses Math;

procedure Swap(var SetofData: Array of Real; i: Integer); Overload;
procedure Swap(var SetofData: Array of Integer; i: Integer); Overload;
procedure Swap(var SetofData: Array of String; i: Integer); Overload;

procedure BubbleSort(var SetofData: Array of Real); Overload;
procedure BubbleSort(var SetofData: Array of Integer); Overload;
procedure BubbleSort(var SetofData: Array of String); Overload;

procedure Bubble_Sort(var SetofData: Array of Real); Overload;
procedure Bubble_Sort(var SetofData: Array of Integer); Overload;
procedure Bubble_Sort(var SetofData: Array of String); Overload;

implementation

procedure Swap(var SetofData: Array of Real; i: Integer); Overload;
var
 rStore: Real;
begin
 rStore           := SetofData[i - 1];
 SetofData[i - 1] := SetofData[i];
 SetofData[i]     := rStore;
end;

procedure Swap(var SetofData: Array of Integer; i: Integer); Overload;
var
 iStore: Integer;
begin
 iStore           := SetofData[i - 1];
 SetofData[i - 1] := SetofData[i];
 SetofData[i]     := iStore;
end;

procedure Swap(var SetofData: Array of String; i: Integer); Overload;
var
 sStore: String;
begin
 sStore           := SetofData[i - 1];
 SetofData[i - 1] := SetofData[i];
 SetofData[i]     := sStore;
end;

procedure BubbleSort(var SetofData: Array of Real);
var
 i, j : integer;
begin
 for i := 1 to High(SetofData) do
  if SetofData[i] > SetofData[i - 1] then
   for j := i downto 1 do
    if SetofData[j] > SetofData[j - 1]
     then
      Swap(SetOfData, j);
end;

procedure BubbleSort(var SetofData: Array of Integer);
var
 i, j: integer;
begin
 for i := 1 to High(SetofData) do
  if SetofData[i] > SetofData[i - 1] then
   for j := i downto 1 do
    if SetofData[j] > SetofData[j - 1]
     then
      Swap(SetofData, j);
end;

procedure BubbleSort(var SetofData: Array of String);
var
 i, j: integer;
begin
 for i := 1 to High(SetofData) do
  if SetofData[i] > SetofData[i - 1] then
   for j := i downto 1 do
    if SetofData[j] > SetofData[j - 1]
     then
      Swap(SetOfData, j);
end;

procedure Bubble_Sort(var SetofData: Array of Real); Overload;
var
 n, i, newn: integer;
begin
 n := Length(SetofData);
 Repeat
  newn := 1;
  for i := 1 to n-1 do
   if SetofData[i-1] > SetofData[i] then
    begin
     Swap(setOfData, i);
     newn := i
    end;
  n := newn
 Until n = 0;
end;

procedure Bubble_Sort(var SetofData: Array of Integer); Overload;
var
 n, i, newn: integer;
begin
 n := Length(SetofData);
 Repeat
  newn := 1;
  for i := 1 to n-1 do
   if SetofData[i-1] > SetofData[i] then
    begin
     Swap(setOfData, i);
     newn := i
    end;
  n := newn
 Until n = 0;
end;

procedure Bubble_Sort(var SetofData: Array of String); Overload;
var
 n, i, newn: integer;
begin
 n := Length(SetofData);
 Repeat
  newn := 1;
  for i := 1 to n-1 do
   if SetofData[i-1] > SetofData[i] then
    begin
     Swap(setOfData, i);
     newn := i
    end;
  n := newn
 Until n = 0;
end;

end.
