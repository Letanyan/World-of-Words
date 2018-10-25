unit Tutorial_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TCard = class
  Private
    pnlCard: TPanel;
    lblInstructions: TLabel;
    imgBackground, imgInstruction: TImage;
    FInstructions, FDirectory: string;
    procedure SetInstructions(Value: string);
  Public
    property Directory: string Read FDirectory;
    property Instructions: string Read FInstructions Write SetInstructions;
    Constructor Create(prnt: TWinControl);
    Destructor Free;
  end;

implementation

{ TCard }

constructor TCard.Create(prnt: TWinControl);
begin
  pnlCard := TPanel.Create(nil);
  with pnlCard do
   begin
    Parent := prnt;
    Align  := alLeft;
    Left   := MaxInt;
    Width  := 289;
    Caption := '';
   end;


  imgBackground := TImage.Create(nil);
  with imgBackground do
   begin
    Parent := pnlCard;
    Align := alClient;
    Picture.LoadFromFile('Resources\SetBackGround.jpg');
    Stretch := True;
   end;

  imgInstruction := TImage.Create(nil);
  with imgInstruction do
   begin
    Parent := pnlCard;
    Width  := 257;
    Height := 257;
    Top    := 8;
    Left   := 16;
    Stretch := True;
   end;

  lblInstructions := TLabel.Create(nil);
  With lblInstructions do
   begin
    Parent := pnlCard;
    AutoSize := false;
    Width := 257;
    Font.Height := 20;
    Font.Color := clWhite;
    Alignment := taCenter;
    Transparent := True;
    Left := 8;
    Top  := 285;
    Anchors := [akLeft, akTop];
   end;
end;

destructor TCard.Free;
begin
 FreeAndNil(imgBackground);
 FreeAndNil(imgInstruction);
 FreeAndNIl(lblInstructions);
 FreeAndNIl(pnlCard);
end;

procedure TCard.SetInstructions(Value: string);
begin
  FInstructions := Copy(Value, Pos('-', Value) + 1, MaxInt);
  FDirectory    := Copy(Value, 1, Pos('-', Value) - 1);
  imgInstruction.Picture.LoadFromFile('Resources\Tutorial\' + FDirectory + '.jpg');
  lblInstructions.Caption := Instructions;
end;

end.
