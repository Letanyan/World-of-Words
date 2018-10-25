unit Admin_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Grids, DBGrids, ExtCtrls, DB, ADODB, StdCtrls, jpeg, ButtonHandling_Module;

type
  TfrmAdmin = class(TForm)
    dtsAdmin: TDataSource;
    qryAdmin: TADOQuery;
    pnlResults: TPanel;
    dbgResults: TDBGrid;
    ADOConnection1: TADOConnection;
    pnlTools: TPanel;
    tmrTables: TTimer;
    tmrStatement: TTimer;
    imgToolTab: TImage;
    imgAdd: TImage;
    imgDelete: TImage;
    pnlQuery: TPanel;
    rgpType: TRadioGroup;
    memStatement: TMemo;
    pnlRunQuery: TPanel;
    pnlStatement: TPanel;
    pnlTables: TPanel;
    lblTables: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblTablesClick(Sender: TObject);
    procedure tmrTablesTimer(Sender: TObject);
    procedure tmrStatementTimer(Sender: TObject);
    procedure rgpTypeClick(Sender: TObject);
    procedure dbgResultsKeyPress(Sender: TObject; var Key: Char);
    procedure dbgResultsCellClick(Column: TColumn);
    procedure memStatementChange(Sender: TObject);
    procedure imgAddClick(Sender: TObject);
    procedure imgDeleteClick(Sender: TObject);
    procedure pnlRunQueryClick(Sender: TObject);
    procedure pnlStatementClick(Sender: TObject);
    procedure memStatementKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure memStatementKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    lsbTables: TListBox;
    CurrentTable, CurrentField: string;
    LastHeight, LastWidth: Integer;
    btnAdd, btnDelete: TThemeButton;
    CustomScript: String;
    Fields: TStringList;
    isLetter: boolean;

    function  SimulateResize(iLeft: integer): Integer;
    procedure InsertItem(sItem: string);
    procedure ShowTable;
    procedure TableClick(Sender: TObject);
    function  GetFieldNames(WithBrackets: Boolean): string;
    procedure SetFields(sTable: String);
  end;

var
  frmAdmin: TfrmAdmin;

implementation

uses
 AccountManagment_Controller;

{$R *.dfm}

procedure TfrmAdmin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 frmAccountManagment.Show;
end;

procedure TfrmAdmin.TableClick(Sender: TObject);
begin
 CurrentTable := TListBox(Sender).Items[TListBox(Sender).ItemIndex];
 lblTables.Caption := CurrentTable;
 ShowTable;
 lblTablesClick(nil);
end;

procedure TfrmAdmin.FormResize(Sender: TObject);
var
 SpaceAvailable: Integer;
begin
 SpaceAvailable := pnlStatement.Left - (pnlTables.Left + pnlTables.Width);
 if pnlTables.Left + pnlTables.Width + SpaceAvailable div 2 - imgAdd.Width < 136 then
  begin
   pnlStatement.Left := 193;
   pnlStatement.Width := ClientWidth - 201;
  end;
 if pnlStatement.Height + 8 > ClientHeight then
  pnlStatement.Height := ClientHeight - 16;


 imgAdd.Left    := pnlTables.Left + pnlTables.Width + SpaceAvailable div 2 - imgAdd.Width;
 imgDelete.Left := pnlTables.Left + pnlTables.Width + SpaceAvailable div 2;
 if imgAdd.Left < 136 then
  begin
   imgAdd.Left := 136;
   imgDelete.Left := 160;
  end;
 tmrStatement.Enabled := true;
end;

procedure TfrmAdmin.FormCreate(Sender: TObject);
begin
 lsbTables := TListBox.Create(nil);
 LastHeight := 200;
 With lsbTables do
  begin
   Parent := pnlTables;
   Left   := 8;
   Top    := 28;
   Align  := alClient;
   Color := clSilver;
   OnClick := TableClick;
   Hide;
  end;

 btnAdd    := TThemeButton.Create(imgAdd, 'Plus', 'ico');
 btnDelete := TThemeButton.Create(imgDelete, 'Minus', 'ico');
 ADOConnection1.GetTableNames(lsbTables.Items, False);
end;

procedure TfrmAdmin.lblTablesClick(Sender: TObject);
begin
 if pnlStatement.Caption = 'Hide'
  then
   pnlStatementClick(nil);

 if pnlTables.Caption = 'Select Table' then
  begin
   pnlTables.Caption := 'Cancel';
   lsbTables.Show;
   lsbTables.Width  := pnlTables.Width - 16;
   lsbTables.Height := pnlTables.Height - 36;
  end else
   pnlTables.Caption := 'Select Table';

 tmrTables.Enabled := True;
end;

procedure TfrmAdmin.tmrTablesTimer(Sender: TObject);
begin
 if pnlTables.Caption = 'Cancel' then
  begin
   if pnlTables.Width < 150
    then
     pnlTables.Width := pnlTables.Width + 4;

   if (pnlTables.Height < 230) and (pnlTables.Height < ClientHeight - 10)
    then
     pnlTables.Height := pnlTables.Height + 8;

   if ( pnlTables.Width >= 200 ) and ( (pnlTables.Height >= 230) or (pnlTables.Height >= ClientHeight - 10) )then
    begin
     tmrTables.Enabled := false;
     pnlTables.Width := 200;
     pnlTables.Height := 230;
    end;
  end else
  begin
   if pnlTables.Width > 121
    then
     pnlTables.Width := pnlTables.Width - 4;

   if pnlTables.Height > 25
    then
     pnlTables.Height := pnlTables.Height - 8;

   if ( pnlTables.Width <= 121 ) and ( pnlTables.Height <= 25 ) then
    begin
     lsbTables.Hide;
     tmrTables.Enabled := false;
     pnlTables.Width := 121;
     pnlTables.Height := 25;
    end;
  end;
  FormResize(nil); 
end;

procedure TfrmAdmin.tmrStatementTimer(Sender: TObject);
var
 iHSpeed: Integer;
begin
 iHSpeed := LastHeight  div 20;

 if pnlStatement.Caption = 'Hide' then
  begin
   if (pnlQuery.Height + iHSpeed < LastHeight) and (pnlQuery.Height + iHSpeed < ClientHeight - 128)
    then
     pnlQuery.Height := pnlQuery.Height + iHSpeed
    else
     if LastHeight < ClientHeight - 128
      then
       pnlQuery.Height := LastHeight
      else
       pnlQuery.Height := ClientHeight - 128;

   if( pnlQuery.Height >= LastHeight ) then
    begin
     tmrStatement.Enabled := false;
     pnlQuery.Height := LastHeight;
    end;
  end else
  begin
   if pnlQuery.Height > 0
    then
     pnlQuery.Height := pnlQuery.Height - iHSpeed;

   if ( pnlQuery.Height <= 0 ) then
    begin
     tmrStatement.Enabled := false;
     pnlQuery.Height := 0;
    end;
  end;
 FormResize(nil);
end;

procedure TfrmAdmin.rgpTypeClick(Sender: TObject);
begin
 if memStatement.Focused then exit;
 memStatement.Clear;

 With memStatement.Lines do
  case rgpType.ItemIndex of
   0 : begin
        Add('DELETE');
        Add('FROM [' + CurrentTable + ']');
        Add('WHERE');
       end;

   1 : begin
        Add('INSERT INTO [' + CurrentTable + ']');
        Add(GetFieldNames(True));
        Add('VALUES ()');
       end;

   2 : begin
        Add('SELECT ' + GetFieldNames(False));
        Add('FROM [' + CurrentTable + ']');
       end;

   3 : begin
        Add('UPDATE [' + CurrentTable + ']');
        Add('SET');
        Add('WHERE');
       end;
 end;

 memStatement.SetFocus;
end;

procedure TfrmAdmin.ShowTable;
begin
 qryAdmin.Close;
 qryAdmin.SQL.Text := 'SELECT * FROM [' + CurrentTable + ']';
 qryAdmin.Open;
end;

procedure TfrmAdmin.dbgResultsKeyPress(Sender: TObject; var Key: Char);
begin
 if (CurrentTable = 'User Account') and (CurrentField = 'User Name')
  then
   Key := UpCase(Key);
end;

procedure TfrmAdmin.dbgResultsCellClick(Column: TColumn);
begin
 CurrentField := Column.FieldName;
end;

procedure TfrmAdmin.InsertItem(sItem: string);
var
 sMemo: String;
 iPlace: integer;
begin
 sMemo  := memStatement.Text;
 iPlace := memStatement.SelStart + length(sItem) + 1;
 Insert(sItem, sMemo, memStatement.SelStart + 1);
 memStatement.Text := sMemo;
 memStatement.SetFocus;
 memStatement.SelStart := iPlace;
end;

function TfrmAdmin.SimulateResize(iLeft: integer): Integer;
var
 SpaceAvailable: Integer;
begin
 SpaceAvailable := iLeft - (pnlTables.Left + pnlTables.Width);
 Result         := pnlTables.Left + pnlTables.Width + SpaceAvailable div 2 - imgAdd.Width;
end;

procedure TfrmAdmin.memStatementChange(Sender: TObject);
var
 sMemo: string;
begin
 sMemo := UpperCase(memStatement.Text);
 if Pos('DELETE', sMemo) > 0
  then
   rgpType.ItemIndex := 0
  else
 if Pos('INSERT INTO', sMemo) > 0
  then
   rgpType.ItemIndex := 1
  else
 if Pos('SELECT', sMemo) > 0
  then
   rgpType.ItemIndex := 2
  else
 if Pos('UPDATE', sMemo) > 0
  then
   rgpType.ItemIndex := 3;
end;

procedure TfrmAdmin.imgAddClick(Sender: TObject);
begin
 if CurrentTable = '' then exit;
 qryAdmin.Close;
 qryAdmin.SQL.Text := 'INSERT INTO [' + CurrentTable + '] DEFAULT VALUES';
 qryAdmin.ExecSQL;
 ShowTable;
end;

procedure TfrmAdmin.imgDeleteClick(Sender: TObject);
begin
 dbgResults.SelectedRows.Delete;
end;

procedure TfrmAdmin.pnlRunQueryClick(Sender: TObject);
begin
 CustomScript := memStatement.Text;
 lblTables.Caption := 'Select Table';
 qryAdmin.Close;
 qryAdmin.SQL.Text := memStatement.Text;
 if rgpType.ItemIndex in [0, 1, 3] then
  begin
   qryAdmin.ExecSQL;
   ShowTable;
   CustomScript := '';
  end else
   qryAdmin.Open;
 pnlStatement.Caption := 'Statement';
 pnlStatementClick(nil);
 if CustomScript <> ''
  then
   memStatement.Text := CustomScript;
end;

procedure TfrmAdmin.pnlStatementClick(Sender: TObject);
begin
 if pnlTables.Caption = 'Cancel'
  then
   lblTablesClick(nil);

 if pnlStatement.Caption = 'Statement' then
  begin
   rgpTypeClick(nil);
   pnlStatement.Caption := 'Hide';
  end else
   pnlStatement.Caption := 'Statement'; 

 tmrStatement.Enabled := True;
end;

function TfrmAdmin.GetFieldNames(WithBrackets: Boolean): string;
var
 strings: TStringList;
 i: integer;
 sBackup: string;
begin
 if CurrentTable = '' then
  Result := '()'
 else
 try
   strings := TStringList.Create;
   sBackup := qryAdmin.SQL.Text;
   qryAdmin.Close;
   qryAdmin.SQL.Text := 'SELECT * FROM [' + CurrentTable + ']';
   qryAdmin.Open;
   qryAdmin.GetFieldNames(strings);
   Result := '(';
   for i := 0 to strings.Count - 1 do
    Result := Result + ', [' + strings[i] + ']';
   Result := Result + ')';
   if Pos('ID', Result) > 0 then
    begin
     Delete(Result, 2, 2);
     Delete(Result, 2, Pos(',', Result));
    end else
     Delete(Result, 2, 2);
   qryAdmin.Close;
   qryAdmin.SQL.Text := sBackup;
   if not WithBrackets then
    begin
     Delete(Result, 1, 1);
     Delete(Result, Length(Result), 1);
    end;
 finally
  FreeAndNil(strings);
 end;
end;

procedure TfrmAdmin.SetFields(sTable: String);
var
 sBackup: string;
begin
 Fields := TStringList.Create;
 sBackup := qryAdmin.SQL.Text;
 qryAdmin.Close;
 qryAdmin.SQL.Text := 'SELECT * FROM [' + sTable + ']';
 qryAdmin.Open;
 qryAdmin.GetFieldNames(Fields);
 qryAdmin.Close;
 qryAdmin.SQL.Text := sBackup;
end;

procedure TfrmAdmin.memStatementKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);

    function GetCurrentWord: string;   //get current typed word
    var
     i: integer;
     s: string;
    begin
     i := memStatement.SelStart;
     s := '';
     Result := '';
     While not (memStatement.Text[i] in [#13, '[', '(']) and (i > 1) do
      begin
       s := s + memStatement.Text[i];
       dec(i);
      end;

     s := Trim(s);

     for i := Length(s) downto 1 do
      Result := Result + s[i];
    end;

    function FindPrediction: string;
    var
     i: integer;
     sCurrent: string;
    begin
     sCurrent := UpperCase(GetCurrentWord);
     for i := 0 to Fields.Count - 1 do
      if Pos(sCurrent, UpperCase(Fields[i])) = 1 then
       begin
        Result := Copy(Fields[i], Length(sCurrent) + 1, Length(Fields[i]));
        Exit;
       end;
    end;

    function CountTillBracket: integer; //Find the length of the predicted text
    var
     i: integer;
    begin
     i := memStatement.SelStart;
     While not(memStatement.Text[i] in [']', ')', '"']) do
      inc(i);
      dec(i);
     Result := i - memStatement.SelStart;
    end;

    procedure InputPrediction;    //add prediction and highlight
    var
     s: string;
     i: integer;
     prediction: string;
    begin
     s := memStatement.Text;
     i := memStatement.SelStart;
     prediction := FindPrediction;
     Insert(Prediction, s, i + 1);
     memStatement.Text := s;
     memStatement.SelStart := i;
     memStatement.SelLength := CountTillBracket;
     memStatement.SetFocus;
    end;

begin
 if isLetter and (CurrentTable <> '') and not(Key in [VK_BACK, VK_RETURN, VK_LEFT, VK_UP, VK_DOWN, VK_RIGHT, VK_SPACE, VK_SHIFT]) then
  begin
   SetFields(CurrentTable);
   InputPrediction;
  end;
end;

procedure TfrmAdmin.memStatementKeyPress(Sender: TObject; var Key: Char);
begin
 isLetter := key in ['a'..'z', 'A'..'Z'];
end;

end.
