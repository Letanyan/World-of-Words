unit TabSetManagment_Module;

interface

uses
 Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TTabSet = class
   private
    Tabs         : array of TLabel;
    imgSelTab    : TImage;
    lblSelTab    : TLabel;
    XDown, XUp   : integer;
    lblLeft      : integer;
    MaxWidth     : integer;

  //  procedure SetSelTab(lbl : TLabel);
   public
    procedure TimerMove(tmr : TTimer; ParentW : integer);
    procedure MouseDown(Sender : TObject; MousePosX : integer);
    procedure MouseMove(Sender : TObject; tmr : TTimer; MousePosX : integer);
    function  MovedTabsEnough(tmr : TTimer; ParentW, MousePosX : integer; lblSelTab : TLabel; Ignore: Boolean) : boolean;
  //  function D176(R, G, B : integer): TColor;

    procedure Resize(tmr : TTimer; ParentW : integer);
    procedure SetUpTabs;
    Constructor Create (SetOfTabs : array of TLabel; img : TImage; seltab : TLabel);
  end;

  procedure HighlightTab(SelTab : TLabel; SelImage : TImage; tmrUsed : TTimer);

implementation

uses StrUtils;

procedure HighlightTab(SelTab : TLabel; SelImage : TImage; tmrUsed : TTimer);
var
 speedW, speedL : Integer;
 OKWidth, OKLeft : Boolean;
begin
 OKLeft  := false;
 OKWidth := false;
 with SelImage do
  begin
    SpeedL := ABS(Left  - SelTab.Left)  div 15 + 2;
    speedW := ABS(Width - SelTab.Width) div 5 + 2;

    if Left < SelTab.Left then
     begin
      Left := Left + SpeedL;
      if Left >= SelTab.Left
       then
        OKLeft := True;
     end else
     begin
      Left := Left - SpeedL;
      if Left <= SelTab.Left
       then
        OKLeft := True;
     end;

    if Width < SelTab.Width then
     begin
      Width := Width + SpeedW;
      if Width >= SelTab.Width
       then
        OKWidth := True;
     end else
     begin
      Width := Width - SpeedW;
      if Width <= SelTab.Width
       then
        OKWidth := True;
     end;

   if (OKWidth and OKLeft) then
    begin
     tmrUsed.Enabled := false;
     Left  := SelTab.Left;
     Width := SelTab.Width;
    end;
 end;

end;

{ TTabSet }
Constructor TTabSet.Create(SetOfTabs: array of TLabel; img : TImage; seltab : TLabel);
var
 i : integer;
begin
 SetLength(Tabs, Length(SetOfTabs));
 MaxWidth := 0;
 for i := Low(SetofTabs) to High(SetOfTabs) do
  begin
   Tabs[i] := SetOfTabs[i];
   MaxWidth := MaxWidth + Tabs[i].Width + 8;
   SetOfTabs[i].Font.Color := clSilver;
   SetOfTabs[i].Top := 0;
   if i = Low(SetOftabs)
    then
     SetOfTabs[i].Left := 0
    else
     SetOfTabs[i].Left := SetOfTabs[i - 1].left + SetOfTabs[i - 1].Width + 8;
  end;
 imgSelTab := img;
 lblSelTab := selTab;
 lblSelTab.Font.Color := clWhite;
 XDown := -1;
end;

procedure TTabSet.MouseMove(Sender : TObject; tmr : TTimer; MousePosX : integer);
var
 lblMoved, i : integer;
begin
 if XDown > -1 then
  begin
    TLabel(Sender).Left := lblLeft + (MousePosX - XDown);
    lblMoved := 1;
    for i := Low(Tabs) to High(Tabs) do
     if Tabs[i].Caption = TLabel(Sender).Caption
      then
       lblMoved := i;

    for i := lblMoved + 1 to High(Tabs) do
     Tabs[i].Left := Tabs[i - 1].Left + Tabs[i - 1].Width + 8;

    for i := lblMoved - 1 downto Low(Tabs) do
     Tabs[i].Left := Tabs[i + 1].Left - Tabs[i].Width - 8;

    imgSelTab.Left := lblSelTab.Left;

    if (Mouse.CursorPos.X > GetParentForm(lblSelTab).Left + GetParentForm(lblSelTab).Width)
      or (Mouse.CursorPos.X < GetParentForm(lblSelTab).Left) then
       begin
        XDown := -1;
        tmr.Enabled := true;
       end;
  end;
end;

procedure TTabSet.MouseDown(Sender : TObject; MousePosX: integer);
begin
 XDown     := MousePosX;
 lblLeft   := TLabel(Sender).Left;
end;

function TTabSet.MovedTabsEnough(tmr : TTimer; ParentW, MousePosX : integer; lblSelTab : TLabel; Ignore: Boolean) : boolean;
begin
 if (Tabs[Low(Tabs)].Left > 0)
  then
   tmr.Enabled := true;

 if (Tabs[High(Tabs)].Left + Tabs[High(Tabs)].width < ParentW)
  then
   if Tabs[Low(Tabs)].left < 0
    then
     tmr.Enabled := True;

 XUp := MousePosX;
 if XDown = XUp
  then
   Result := false
  else
   Result := true;

 if not Result or Ignore then
  begin
   tmr.Enabled := false;
   Self.lblSelTab := lblSelTab;
  end;
 XDown := -1;
end;

procedure TTabSet.TimerMove(tmr: TTimer; ParentW : integer);
var
 i : integer;
begin
 if Tabs[Low(Tabs)].left > 0     //If all Labels Are To the right
  then
   for i := High(Tabs) downto Low(Tabs) do Tabs[i].Left := Tabs[i].left - (Tabs[Low(Tabs)].Left div 10) - 1
  else
 if (Tabs[High(Tabs)].Left + Tabs[High(Tabs)].width + 16 >= ParentW)
  then
   tmr.Enabled := false;

 if (Tabs[High(Tabs)].Left + Tabs[High(Tabs)].width + 16 < MaxWidth)
  then
   if Tabs[Low(Tabs)].left < 1   //If All tabs to the left but there is more space
  then begin
   if ParentW < MaxWidth
    then    //if there is NOT more space than length of tabs
     for i := Low(Tabs) to High(Tabs) do Tabs[i].Left := Tabs[i].left + (ParentW - (Tabs[High(Tabs)].Left + Tabs[High(Tabs)].Width)) div 10 + 1
    else   //if there is more space for tabs to fill
     for i := High(Tabs) downto Low(Tabs) do Tabs[i].Left := Tabs[i].left + Abs(Tabs[Low(Tabs)].Left div 10) + 1
  end else
   tmr.Enabled := false;

 if Assigned(lblSelTab)
  then
   imgSelTab.Left := lblSelTab.Left;
end;

procedure TTabSet.SetUpTabs;
var
 i : integer;
begin
 for i := Low(Tabs) to High(Tabs) do
   if i = Low(Tabs)
    then
     Tabs[i].Left := 0
    else
     Tabs[i].Left := Tabs[i - 1].left + Tabs[i - 1].Width + 8;
end;

procedure TTabSet.Resize(tmr : TTimer; ParentW: integer);
var
 i : integer;
begin
 tmr.Enabled := false;
 if Assigned(Tabs[Low(Tabs)])
  then
 if Tabs[Low(Tabs)].Left <= 0 then
  begin
   if Tabs[High(Tabs)].Left + Tabs[High(Tabs)].Width < ParentW
    then
     While (Tabs[High(Tabs)].Left + Tabs[High(Tabs)].Width < ParentW) and (Tabs[Low(Tabs)].left < 0) do
      for i := High(Tabs) downto Low(Tabs) do Tabs[i].Left := Tabs[i].left + 1;
   if (Assigned(imgSelTab)) and (Assigned(lblSelTab)) then
    begin
     imgSelTab.Left  := lblSelTab.Left;
     imgSelTab.Width := lblSelTab.Width;
    end;
  end;
end;
         {
function TTabSet.D176(R, G, B: integer): TColor;
begin

end;      }

end.
