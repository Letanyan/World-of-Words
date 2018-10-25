unit HighScoreUnit_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ADODB, ComCtrls, ImgList, StdCtrls, jpeg,
  ExtCtrls, Menus, CheckLst, HighScoreFilter_Module, Achievements_Module,
  Achievements_Controller;

type
  TfrmHighScores = class(TForm)
    dsrScores: TDataSource;
    qryhighScores: TADOQuery;
    grdScores: TDBGrid;
    scxHighScoreSelection: TScrollBox;
    pnlResize: TPanel;
    tblGames: TADOTable;
    tmrExecute: TTimer;
    imgFilterBack: TImage;
    procedure FormCreate(Sender: TObject);
    procedure grdScoresTitleClick(Column: TColumn);
    procedure tmrExecuteTimer(Sender: TObject);
    procedure pnlResizeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlResizeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlResizeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure pnlResizeEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CurrentTable : string;
    CurrentTab : TLabel;
    ASC : Integer;
    OrderPart : string;
    Filter : TScoreFilter;
    Resizing : boolean;

    procedure FilterChange(Sender: TObject);
    procedure RunQuery;
    procedure CleanUp;
    procedure ChooseHighScoreTable(statement : string);
  end;

var
  frmHighScores: TfrmHighScores;

implementation

uses AccountManagment_Controller, HighScoreFilter_Controller;

{$R *.dfm}

procedure TfrmHighScores.ChooseHighScoreTable(statement : string);
begin
 With qryhighScores do
  begin
   close;
   SQL.Text := statement;
   Open;
  end;
end;

procedure TfrmHighScores.FormCreate(Sender: TObject);
begin
 ASC := 0;
 OrderPart := '';
 CurrentTable := ' Word Search ';
 Filter := TScoreFilter.Create(scxHighScoreSelection, tblGames, tmrExecute);
 Filter.OnChange := FilterChange;
end;

procedure TfrmHighScores.grdScoresTitleClick(Column: TColumn);
var
 Title: String;
begin
 Title := Column.DisplayName;
 if Pos('Max', Title) or Pos('Min', Title) or Pos('Count', Title) or Pos('Sum', Title) or Pos('Avg', Title) > 0
  then
   Delete(Title, 1, Pos(' ', Title));

 if ASC = 0
  then
   OrderPart := ' ORDER BY [' + Title + '] ASC'
  else
 if ASC = 1
  then
   OrderPart := ' ORDER BY [' + Title + '] DESC'
  else
   OrderPart := '';

 if ASC = 0
  then
   ASC := 1
  else
 if ASC = 1
  then
   ASC := 2
  else
   ASC := 0;

 frmAchievements.AchievementComplete(Order_In_Court);
 tmrExecute.Enabled := true;
end;

procedure TfrmHighScores.RunQuery;
begin
 Filter.BuildQuerySQL;
 if Filter.GetQuery(OrderPart) <> 'void'
   then
    ChooseHighScoreTable(Filter.GetQuery(OrderPart));
end;

procedure TfrmHighScores.tmrExecuteTimer(Sender: TObject);
begin
 Try
  RunQuery;
  tmrExecute.Enabled := false;
 Except On E: Exception do
  begin
   tmrExecute.Enabled := false;
   MessageDlg(E.Message, mtError, [], 1);
  end;
 end;
end;

procedure TfrmHighScores.pnlResizeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Resizing := true;
end;

procedure TfrmHighScores.pnlResizeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Resizing := False;
 Filter.Resize;
end;

procedure TfrmHighScores.pnlResizeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 if (Resizing) and (Mouse.CursorPos.Y - frmHighScores.Top - 25 < grdScores.Height) and (Mouse.CursorPos.Y - frmHighScores.Top -25 > 40)
  then
   scxHighScoreSelection.Height := Mouse.CursorPos.Y - frmHighScores.Top - 25;
end;

procedure TfrmHighScores.FormResize(Sender: TObject);
begin
 Filter.Resize;
 if scxHighScoreSelection.Height >= grdScores.Height
  then
   if grdScores.Height - 2 > 40
    then
     scxHighScoreSelection.Height := grdScores.Height - 2
    else
     scxHighScoreSelection.Height := 41;
end;

procedure TfrmHighScores.pnlResizeEnter(Sender: TObject);
begin
 tmrExecute.Enabled := false;
end;

procedure TfrmHighScores.CleanUp;
begin
 Width := Constraints.MinWidth;
 Height := Constraints.MinHeight;
 Left := Screen.Width div 2 - Width div 2;
 Top  := Screen.Height div 2 - Height div 2;
 Filter.Refresh;
end;

procedure TfrmHighScores.FilterChange(Sender: TObject);
begin
 OrderPart := '';
end;

end.
