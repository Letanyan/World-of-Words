unit ButtonHandling_Module;

interface

uses forms, windows, SysUtils, StdCtrls, ExtCtrls, Graphics, ComCtrls, Dialogs,
     Classes, Controls;

type
  TThemeButton = class
    private
    btn: TImage;
    FDir: string;
    Ext: string;
    procedure OnButtonDown(Sender: TObject;
                           Button: TMouseButton;
                           Shift: TShiftState;
                           X, Y: Integer);

    procedure OnButtonMove(Sender: TObject;
                           Shift: TShiftState;
                           X, Y: Integer);

    procedure OnButtonUp(Sender: TObject;
                         Button: TMouseButton;
                         Shift: TShiftState;
                         X, Y: Integer);
    procedure SetDir(Dir: string);
    public
    Constructor Create(btn: TImage; Dir: string; Ext: string);
    property Dir: String Read FDir Write SetDir;
  end;

implementation


{ TThemeButton }

constructor TThemeButton.Create(btn: TImage; Dir: string; Ext: string);
begin
 Self.btn := btn;
 Self.Ext := Ext;
 Self.Dir := Dir;
 btn.OnMouseUp := OnButtonUp;
 btn.OnMouseMove := OnButtonMove;
 btn.OnMouseDown := OnButtonDown;
end;

procedure TThemeButton.OnButtonDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 TImage(Sender).Picture.LoadFromFile('Resources/' + Dir + ' Down.' + Ext)
end;

procedure TThemeButton.OnButtonMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if GetAsyncKeyState(VK_LBUTTON) < 0 then
 if (X in [0..TImage(Sender).Width]) and (Y in [0..TImage(Sender).Height])
  then
   TImage(Sender).Picture.LoadFromFile('Resources/' + Dir + ' Down.' + Ext)
  else
   TImage(Sender).Picture.LoadFromFile('Resources/' + Dir + '.' + Ext);
end;

procedure TThemeButton.OnButtonUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 TImage(Sender).Picture.LoadFromFile('Resources/' + Dir + '.' + Ext)
end;

procedure TThemeButton.SetDir(Dir: string);
begin
 Self.FDir := Dir;
 btn.Picture.LoadFromFile('Resources/' + Dir + '.' + Ext)
end;

end.
