unit HighScoreFilter_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ComCtrls, ExtCtrls, ADODB, DB, DateUtils,
  ButtonHandling_Module, Achievements_Module, Achievements_Controller;

type
 TScoreFilter = class
  Private
   BASICqry        : string;
   SQLqry          : string;
   qryName         : string;

   FOnChange: TNotifyEvent;

   tmrExecute      : TTimer;

   DBTable         : TADOTable;
   HolderParent    : TScrollBox;
   imgShow         : TImage;
   btnShow         : TThemeButton;
   cmbGameList     : TComboBox;
   btnSave         : TButton;
   btnAddRemove    : TButton;
   cmbSavedQueries : TComboBox;
   LastGameList    : Integer;
   cmbSavetables   : TComboBox;
   pnlHolders      : Array of TPanel;
   imgHoldersBack  : Array of TImage;
   cmbFields       : Array of TComboBox;
   cmbOperators    : array of TComboBox;
   edtInputInfo    : array of TEdit;
   edtInputInfoBT  : array of TEdit;
   lblAndBT        : array of TLabel;
   dtkPicker       : array of TDateTimePicker;
   dtkPickerBT     : array of TDateTimePicker;
   cmbTimeValues   : array of TComboBox;
   btnAddNewClause : Array of TButton;
   btnRemoveClause : Array of TButton;

   { Show }
   scxShowHolder   : TScrollBox;
   NumberofShownFields : Integer;
   HasAggregateFunc : Boolean;
   { Select }
   pnlSelect       : TPanel;
   lblSelected     : TLabel;
   pnlItems        : Array of TPanel;
   cmbFunction     : Array of TComboBox;
   cmbSelected     : Array of TComboBox;
   edtAsFunctioned : Array of TEdit;
   btnAddSelect    : Array of TButton;
   btnRemoveSelect : Array of TButton;

   { Where }
   CurrentCmbField : Integer;
   CurrentClause   : Integer;
   NumberofClauses : integer;

   { Where }
   procedure GetOperators;
   procedure New_MainController;
   procedure New_pnlHolder;
   procedure New_cmbFields;
   procedure New_cmbOperators;
   procedure New_edtInfoBox;
   procedure New_edtInfoBoxBT;
   procedure New_lblAndBT;
   procedure New_dtkPicker;
   procedure New_dtkPickerBT;
   procedure New_TimeValues;
   procedure New_AddRemoveBtns;


   { Show }
   procedure ShowClick(Sender : TObject);
   procedure OnCompChange;
   procedure CreateShowItems;
   procedure ChangeWidthofSelect;
   function  GetGROUPBYstr : String;

   { select }
   procedure New_pnlItems;
   procedure New_cmbFunction;
   procedure New_cmbSelected;
   procedure New_edtAsFunctioned;
   procedure New_btnAddSelect;
   procedure New_btnRemoveSelect;

   procedure cmbFunctionChange(Sender : TObject);
   procedure cmbSelectedChange(Sender : TObject);
   procedure edtAsFunctionedChange(Sender : TObject);

   procedure btnAddSelectClick(sender : TObject);
   procedure btnRemoveSelectClick(sender: TObject);
   { Where }
   procedure Add_OR_RemoveClick(Sender : TObject);
   procedure cmbFieldsOnChange(Sender : TObject);
   procedure cmbOperatorsOnChange(Sender : TObject);
   procedure btnAddNewClauseOnClick(Sender : TObject);
   procedure btnRemoveClauseOnClick(Sender : TObject);
   procedure edtInputBoxChange(Sender : TObject);
   procedure edtInputBoxBTChange(Sender : TObject);
   procedure dtkPickerChange(sender : TObject);
   procedure dtkPickerBTChange(Sender : TObject);
   procedure cmbTimeValuesChange(Sender : TObject);
   procedure btnSaveClick(Sender : TObject);
   procedure cmbSavedTablesChange(Sender : TObject);
   procedure cmbQuerySavedLoad(Sender : TObject);
   procedure cmbGameListEnter(Sender: TObject);

   procedure DefaultSetUp;

   procedure SQLCheck;

   procedure SaveBASICQuery;
   function GetFields: string;
   procedure   ClearUp;
  Public
   CurrentFilter : string;
   Changed       : boolean;

   property OnChange: TNotifyEvent Read FOnChange Write FOnChange;
   procedure   Resize;
   procedure   Newfilter(Sender : TObject);
   procedure   GameTableChanged(Sender : TObject);
   function    GetQuery(Order : String) : String;
   procedure   Refresh;
   function    ConvertBASICoptoSQLop(cond, op : string) : string;
   procedure   BuildQueryBASIC;
   procedure   BuildQuerySQL;
   procedure   RefreshGameList;

   procedure   SaveQueries(sName : string); overload;
   procedure   SaveQueries; overload;
   procedure   LoadQuery(sName : string);
   procedure   LoadQueryNames(List : TStrings; tbl : string);
   procedure   DeleteQueries(clx : TCheckListBox);
   function    DeleteQuery: boolean;
   function    GetGameName: string;

   Constructor Create(Holder : TScrollBox; tbl : TADOTable; tmr : TTimer);
   Destructor  Free;
 end;

implementation

uses Math;

{ TScoreFilter }

procedure TScoreFilter.ClearUp;
var
 i : integer;
begin
 for i := Low(btnAddSelect)    to High(btnAddSelect)    do FreeAndNil(btnAddSelect[i]);
 for i := Low(btnRemoveSelect) to High(btnRemoveSelect) do FreeAndNil(btnRemoveSelect[i]);
 for i := Low(cmbFunction)     to High(cmbFunction)     do FreeAndNil(cmbFunction[i]);
 for i := Low(cmbSelected)     to High(cmbSelected)     do FreeAndNil(cmbSelected[i]);
 for i := Low(edtAsFunctioned) to High(edtAsFunctioned) do FreeAndNil(edtAsFunctioned[i]);
 for i := Low(pnlItems)        to High(pnlItems)        do FreeAndNil(pnlItems[i]);

 for i := Low(cmbFields)       to High(cmbFields)       do FreeAndNil(cmbFields[i]);
 for i := Low(cmbOperators)    to High(cmbOperators)    do FreeAndNil(cmbOperators[i]);
 for i := Low(edtInputInfo)    to High(edtInputInfo)    do FreeAndNil(edtInputInfo[i]);

 for i := Low(dtkPicker)       to High(dtkPicker)       do FreeAndNil(dtkPicker[i]);
 for i := Low(cmbTimeValues)   to High(cmbTimeValues)   do FreeAndNil(cmbTimeValues[i]);

 for i := Low(btnAddNewClause) to High(btnAddNewClause) do FreeAndNil(btnAddNewClause[i]);
 for i := Low(btnRemoveClause) to High(btnRemoveClause) do FreeAndNil(btnRemoveClause[i]);

 for i := Low(imgHoldersBack)  to High(imgHoldersBack)  do FreeAndNil(imgHoldersBack[i]);
 for i := Low(pnlHolders)      to High(pnlHolders)      do FreeAndNil(pnlHolders[i]);


 SetLength(btnAddSelect, 0);
 SetLength(btnRemoveSelect, 0);
 SetLength(cmbFunction, 0);
 SetLength(cmbSelected, 0);
 SetLength(edtAsFunctioned, 0);
 SetLength(pnlItems, 0);

 SetLength(cmbFields, 0);
 SetLength(cmbOperators, 0);
 SetLength(edtInputInfo, 0);

 SetLength(dtkPicker, 0);
 SetLength(cmbTimeValues, 0);

 SetLength(btnAddNewClause, 0);
 SetLength(btnRemoveClause, 0);

 SetLength(imgHoldersBack, 0);
 SetLength(pnlHolders, 0);
end;

constructor TScoreFilter.Create(Holder : TScrollBox; tbl : TADOTable; tmr : TTimer);
begin
 tmrExecute   := tmr;
 HolderParent := Holder;
 DBTable      := tbl;
 New_MainController;
 CreateShowItems;
 btnAddSelectClick(Holder);
 NumberofClauses := 0;
 NumberofShownFields := 0;
 LastGameList := 1;
 CurrentFilter   := '';
 Changed         := false;
 GameTableChanged(cmbGameList);
end;

function ChangeWidthcmb(const cmb: TComboBox): integer;
var
 i  : integer;
 nw : integer;
 BMP: TBitmap;
begin
 Try
   Result := cmb.Width;
   BMP := TBitmap.Create;
   BMP.Canvas.Font.Height := 22;
   for i := 0 to cmb.Items.Count -1 do
    begin
     nw := BMP.Canvas.TextWidth(cmb.Items[i]) + 16;
     if nw > Result then Result := nw;
    end;
 finally
   FreeAndNil(BMP);
 end;
end;

procedure TScoreFilter.btnSaveClick(Sender : TObject);
begin
 BuildQueryBASIC;
 if CurrentFilter = ''
  then
   SaveQueries(InputBox('Query Name', 'What do you want to save it as', ''))
  else
   SaveQueries;
end;

procedure TScoreFilter.Add_OR_RemoveClick(Sender : TObject);
begin
 if (btnAddRemove.Caption = '+') and (Sender <> nil) then
  begin
   btnAddNewClauseOnClick(TButton(Sender));
   TButton(Sender).Caption := '-';
  end else
  begin
   tmrExecute.Enabled := false;
   ClearUp;
   CurrentClause := 1;
   NumberofClauses := 0;
   NumberofShownFields := 0;
   TButton(Sender).Caption := '+';
  end;
 OnCompChange;
end;

procedure TScoreFilter.cmbSavedTablesChange(Sender : TObject);
begin
 if (TComboBox(Sender).ItemIndex > -1)
  then begin
   LoadQueryNames(cmbSavedQueries.Items, cmbSavetables.Items[cmbSavetables.ItemIndex]);
   SendMessage(cmbSavedQueries.Handle, CB_SETDROPPEDWIDTH, ChangeWidthcmb(cmbSavedQueries), 0);
  end;
 OnCompChange;
end;

procedure TScoreFilter.cmbQuerySavedLoad(Sender : TObject);
begin
 if cmbGameList.ItemIndex = 0 then
  begin
   if DeleteQuery
    then
     LoadQueryNames(cmbSavedQueries.Items, cmbSavetables.Items[cmbSavetables.ItemIndex]);
  end else
 if (TComboBox(sender).ItemIndex > -1) then
  begin
   if cmbSavetables.ItemIndex = 0
    then
     LoadQuery(TComboBox(Sender).Items[TComboBox(Sender).ItemIndex])
    else
     LoadQuery(cmbSavetables.Items[cmbSavetables.ItemIndex] + '.' + TComboBox(Sender).Items[TComboBox(Sender).ItemIndex]);
   cmbSavetables.Hide;
   cmbSavedQueries.Hide;
   btnSave.Show;
   btnAddRemove.Show;
   btnAddRemove.Caption := '+';
  end;
 OnCompChange;
 Changed := false;
end;

procedure TScoreFilter.cmbGameListEnter(Sender: TObject);
begin
 LastGameList := cmbGameList.ItemIndex;
end;

procedure TScoreFilter.ShowClick(Sender: TObject);
begin
 if cmbGameList.ItemIndex in [0, 1] then exit;
 scxShowHolder.Top     := 41;
 scxShowHolder.Visible := not scxShowHolder.Visible;
 frmAchievements.AchievementComplete(The_Eye_Shows_All);
 OnCompChange;
end;

procedure TScoreFilter.New_MainController;
var
 pnlMain : TPanel;
 lblInstruction : TLabel;
 imgBackground : TImage;
begin
 pnlMain :=  TPanel.Create(HolderParent);
 With pnlMain do
  begin
   Parent := HolderParent;
   Align  := alTop;
   Height := 41;
   BevelInner := bvNone;
   BevelOuter := bvNone;
   Caption := '';
  end;

 imgBackground := TImage.Create(HolderParent);
 With imgBackground do
  begin
   Parent := pnlMain;
   Align  := alClient;
   Picture.LoadFromFile('Resources/TabBar.jpg');
   Stretch := true;
  end;

 imgShow := TImage.Create(HolderParent);
 With imgShow do
  begin
   Parent := pnlMain;
   Width  := 25;
   Height := 25;
   Left   := 8;
   Top    := 8;
   Picture.LoadFromFile('Resources/ShowEye.ico');
   OnClick := ShowClick;
  end;
 btnShow := TThemeButton.Create(imgShow, 'ShowEye', 'ico'); 

 lblInstruction := TLAbel.Create(HolderParent);
 With lblInstruction do
  begin
   Font.Color := clWhite;
   Font.Size  := -15;
   Transparent := true;
   Parent  := pnlMain;
   Left    := 57;
   Top     := 8;
   Caption := 'Game: ';
  end;

 cmbGameList := TComboBox.Create(HolderParent);
 With cmbGameList do
  begin
   Parent := pnlMain;
   Left   := 112;
   Top    := 8;
   Width  := 200;
   Items.Add('Delete Query...');
   Items.Add('Load Query...');
   Items.add('Anagrams');
   Items.add('Break And Build');
   Items.add('Build-A-Word');
   Items.add('Build ''Em');
   Items.add('Crossword');
   Items.add('Find ''Em');
   Items.add('Hangman');
   Items.Add('Word City');
   Items.Add('Word Race');
   Items.add('Word Search');
   OnChange := GameTableChanged;
   OnEnter  := cmbGameListEnter;
   ItemIndex := 2;
  // GameTableChanged(nil);
  end;

 btnAddRemove := TButton.Create(HolderParent);
 With btnAddRemove do
  begin
   Parent  := pnlMain;
   Caption := '+';
   Width   := 25;
   Height  := 25;
   Top     := 8;
   Left    := pnlMain.Width - 33;
   Anchors := [akRight, akTop];
   OnClick := Add_OR_RemoveClick;
  end;

 btnSave := TButton.Create(HolderParent);
 With btnSave do
  begin
   Parent  := pnlMain;
   Caption := 'Save';
   Width   := 100;
   Height  := 25;
   Top     := 8;
   Left    := btnAddRemove.Left - 108;
   OnClick := btnSaveClick;
   Anchors := [akRight, akTop];
  end;

 cmbSavetables := TComboBox.Create(HolderParent);
 With cmbSavetables do
  begin
   Parent := pnlMain;
   Left   := 320;
   Top    := 8;
   Width  := 200;
   Items.Add('All');
   Items.add('Anagrams');
   Items.add('Break & Build');
   Items.add('Build-A-Word');
   Items.add('Build ''Em');
   Items.add('Crossword');
   Items.add('Find ''Em');
   Items.add('Hangman');
   Items.Add('Word City');
   Items.Add('Word Race');
   Items.add('Word Search');
   ItemIndex := 0;
   OnChange := cmbSavedTablesChange;
   Hide;
  end;

 cmbSavedQueries := TComboBox.Create(HolderParent);
 With cmbSavedQueries do
  begin
   Parent := pnlMain;
   Left   := 528;
   Top    := 8;
   Width  := 200;
   LoadQueryNames(Items, 'All');
   SendMessage(cmbSavedQueries.Handle, CB_SETDROPPEDWIDTH, ChangeWidthcmb(cmbSavedQueries), 0);
   OnChange := cmbQuerySavedLoad;
   Hide;
  end;

end;

procedure TScoreFilter.CreateShowItems;
var
 imgBackGround, imgSelBack : TImage;
begin
 scxShowHolder := TScrollBox.Create(HolderParent);
 with scxShowHolder do
  begin
   Parent  := HolderParent;
   Align   := alTop;
   Height  := 50;
   Visible := false;
   Color   := clBlack;
   HorzScrollBar.Visible := True;
   HorzScrollBar.Tracking := True;
   VertScrollBar.Visible := false;
  end;

 pnlSelect := TPanel.Create(scxShowHolder);
 With pnlSelect do
  begin
   Parent := scxShowHolder;
   Top := 0;
   Left := 0;
   Width := scxShowHolder.Width;
   Height := 41;
   Caption := '';
   BevelOuter := bvNone;
   Font.Color := clWhite;
   Font.Size := 15;
  end;

 imgSelBack := TImage.Create(pnlSelect);
 With imgSelBack do
  begin
   Parent  := pnlSelect;
   Align   := alClient;
   Align   := alNone;
   Anchors := [akLeft, akTop, akBottom, akRight];
   Width   := pnlSelect.Width;
   Height  := 41;
   Stretch := True;
   Picture.LoadFromFile('Resources/MiniMenuBar.jpg');
  end;

 lblSelected := TLabel.Create(pnlSelect);
 With lblSelected do
  begin
   Parent    := pnlSelect;
   font.Name := 'Courier New';
   Caption   := ' Show ';
   Align     := alLeft;
   Transparent := true;
  end;

 imgBackGround := TImage.Create(scxShowHolder);
 With imgBackGround do
  begin
   Parent := scxShowHolder;
   Align := alClient;
   Stretch:= False;
   Picture.LoadFromFile('Resources/MenuBar.jpg');
  end;
end;

destructor TScoreFilter.Free;
begin
 ClearUp;
end;

procedure TScoreFilter.GetOperators;
var
 fld : string;
begin
 DBTable.Close;
 fld := cmbFields[CurrentClause].Items[cmbFields[CurrentClause].ItemIndex];
 cmbOperators[CurrentClause].Items.Clear;
 DBTable.TableName := cmbGameList.Items[cmbGameList.ItemIndex];
 DBTable.Open;
 if fld = '' then exit;

 if DBTable.FieldByName(fld).DataType  = ftWideString then
  With cmbOperators[CurrentClause].Items do
   begin
    Add('is equal too');
    Add('contains');
    Add('begins with');
    Add('ends with');
    Add('matches');
  end else
 if DBTable.FieldByName(fld).DataType  = ftInteger then
  With cmbOperators[CurrentClause].Items do
   begin
    Add('equals');
    Add('is greater than');
    Add('is less than');
    Add('is not');
    Add('in range of');
   end else
  if DBTable.FieldByName(fld).DataType  = ftDateTime then
   with cmbOperators[CurrentClause].Items do
    begin
     Add('within last');
     Add('exactly');
     Add('before');
     Add('after');
     Add('today');
     Add('yesterday');
     Add('this week');
     Add('this month');
     Add('this year');
     Add('between');
    end;
end;

function GetItemPosFromText(cmb : TComboBox; s : string) : integer;
var
 i : integer;
begin
 Result := -1;
 if Assigned(cmb)
  then
 for i := 0 to cmb.Items.Count - 1 do
  if cmb.Items[i] = s
   then
    Result := i;
end;

procedure TScoreFilter.Newfilter(Sender : TObject);
var
 choice : integer;
begin
 if Changed
  then
   choice := MessageDlg('Are you sure you want to contiue, you will lose any unsaved done, do you want to save', mtConfirmation, mbYesNoCancel, 1)
  else
   choice := mrNo;

 if choice = mrYes
  then
   SaveQueries(CurrentFilter);

 if choice in [mrYes, mrNo] then
  if cmbGameList.ItemIndex = -1 then
   if MessageDlg('Please Select a table to filter', mtInformation, mbOKCancel, 1) = mrOk
    then
     cmbGameList.SetFocus;


 CurrentFilter := '';
 Changed := false;
end;

procedure TScoreFilter.GameTableChanged(Sender : TObject);
var
 savechoice : integer;
begin
 if changed
  then
   savechoice := MessageDlg('You have not saved all changes will be lost. Do you want to save', mtConfirmation, mbYesNoCancel, 1)
  else
   savechoice := mrNo;


 if savechoice = mrYes then
  begin
   BuildQueryBASIC;
   if CurrentFilter <> ''
    then
     SaveQueries
    else
     SaveQueries(InputBox('Query Name', 'What do you want to save it as', ''));
  end;

 if savechoice in [mrNo, mrYes] then
  begin
   if cmbGameList.ItemIndex > -1 then
    begin
     ClearUp;
     CurrentClause := 1;
     NumberofClauses := 0;
     NumberofShownFields := 0;
     scxShowHolder.Hide;
     btnSave.Show;
     btnAddRemove.Show;
     btnAddRemove.Caption := '+';
     cmbSavedQueries.Hide;
     cmbSavetables.Hide;
    end;
   if cmbGameList.ItemIndex in [0, 1] then
    begin
     btnSave.Hide;
     btnAddRemove.Hide;
     cmbSavedQueries.Show;
     cmbSavetables.Show;
     SendMessage(cmbSavedQueries.Handle, CB_SETDROPPEDWIDTH, ChangeWidthcmb(cmbSavedQueries), 0);
    end else
     btnAddSelectClick(sender);
   Changed := False;
   CurrentFilter := '';
   tmrExecute.Enabled := true;
   LastGameList := cmbGameList.ItemIndex;
  end else
 if savechoice = mrCancel
  then
   cmbGameList.ItemIndex := LastGameList;
end;

function TScoreFilter.GetQuery(Order: String): String;
begin
 SQLCheck;
 Result := SQLqry + Order;
end;

procedure TScoreFilter.New_pnlHolder;
begin
 SetLength(pnlHolders, NumberofClauses + 1);
 pnlHolders[NumberofClauses] := TPanel.Create(HolderParent);
 With pnlHolders[NumberofClauses] do
  begin
   Parent  := HolderParent;
   Top     := CurrentClause * 40 + 120;
   Align   := alTop;
   Caption := '';
   Height  := 41;
   BevelInner := bvNone;
   BevelOuter := bvNone;
   Name    := 'pnlHolders_' + IntToStr(NumberofClauses);
   Caption := '';
  end;

 SetLength(imgHoldersBack, NumberofClauses + 1);
 imgHoldersBack[NumberofClauses] := TImage.Create(HolderParent);
 With imgHoldersBack[NumberofClauses] do
  begin
   Parent := pnlHolders[NumberofClauses];
   Align  := alClient;
   Picture.LoadFromFile('Resources/TabBar.jpg');
   Stretch := true;
  end;
end;

procedure TScoreFilter.New_AddRemoveBtns;
begin
 SetLength(btnAddNewClause, NumberofClauses + 1);
 SetLength(btnRemoveClause, NumberofClauses + 1);

 btnAddNewClause[NumberofClauses] := TButton.Create(pnlHolders[NumberofClauses]);
 btnRemoveClause[NumberofClauses] := TButton.Create(pnlHolders[NumberofClauses]);

 With btnRemoveClause[NumberofClauses] do
  begin
   Parent  := pnlHolders[NumberofClauses];
   Anchors := [akTop,akRight];
   Left    := pnlHolders[NumberofClauses].Width - 66;
   Top     := 8;
   Width   := 25;
   Height  := 25;
   Name    := 'btnRemoveClause_' + IntToStr(NumberofClauses);
   Caption := '-';
   OnClick := btnRemoveClauseOnClick;
  end;

 With btnAddNewClause[NumberofClauses] do
  begin
   Parent  := pnlHolders[NumberofClauses];
   Anchors := [akRight,akTop];
   Left    := pnlHolders[NumberofClauses].Width - 33;
   Top     := 8;
   Width   := 25;
   Height  := 25;
   Name    := 'btnAddNewClause_' + IntToStr(NumberofClauses);
   Caption := '+';
   OnClick := btnAddNewClauseOnClick;
  end;
end;

procedure TScoreFilter.New_cmbFields;
begin
 SetLength(cmbFields, NumberofClauses + 1);
 cmbFields[NumberofClauses] := TComboBox.Create(pnlHolders[NumberofClauses]);
 With cmbFields[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 8;
   Top      := 8;
   Width    := 180;
   Name     := 'cmbFields_' + IntToStr(NumberofClauses);
   OnChange := cmbFieldsOnChange;
  end;
  DBTable.Close;
  CurrentCmbField    := 0;

  CurrentClause := NumberofClauses;

  DBTable.TableName  := cmbGameList.Items[cmbGameList.ItemIndex];
  DBTable.GetFieldNames(cmbFields[NumberofClauses].Items);
  cmbFields[NumberofClauses].Items.Delete(0);
  if NumberofClauses <= cmbFields[NumberofClauses].Items.Count
   then
    cmbFields[NumberofClauses].ItemIndex := NumberofClauses - 1
   else
    cmbFields[NumberofClauses].ItemIndex := 0;
  DBTable.Open;
end;

procedure TScoreFilter.New_cmbOperators;
begin
 SetLength(cmbOperators, NumberofClauses + 1);
 cmbOperators[NumberofClauses] := TComboBox.Create(pnlHolders[NumberofClauses]);
 With cmbOperators[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 196;
   Top      := 8;
   Width    := 150;
   Name     := 'cmbOperators_' + IntToStr(NumberofClauses);
   OnChange := cmbOperatorsOnChange;
  end;
  GetOperators;
  cmbOperators[NumberofClauses].ItemIndex := 0;
end;

procedure TScoreFilter.New_edtInfoBox;
begin
 SetLength(edtInputInfo, NumberofClauses + 1);
 edtInputInfo[NumberofClauses] := TEdit.Create(pnlHolders[NumberofClauses]);
 With edtInputInfo[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 354;
   Top      := 8;
   Width    := 150;
   Name     := 'edtInputInfo_' + IntToStr(NumberofClauses);
   Text     := '';
   OnChange := edtInputBoxChange;
  end;
end;

procedure TScoreFilter.New_edtInfoBoxBT;
begin
 SetLength(edtInputInfoBT, NumberofClauses + 1);
 edtInputInfoBT[NumberofClauses] := TEdit.Create(pnlHolders[NumberofClauses]);
 With edtInputInfoBT[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 542;
   Top      := 8;
   Width    := 150;
   Name     := 'edtInputInfoBT_' + IntToStr(NumberofClauses);
   Text     := '';
   OnChange := edtInputBoxBTChange;
   Hide;
  end;
end;

procedure TScoreFilter.New_lblAndBT;
begin
 SetLength(lblAndBT, NumberofClauses + 1);
 lblAndBT[NumberofClauses] := TLabel.Create(pnlHolders[NumberofClauses]);
 With lblAndBT[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 508;
   Top      := 8;
   Font.Color := clWhite;
   Name     := 'lblAndBT_' + IntToStr(NumberofClauses);
   Caption  := 'and';
   Transparent := true;
   Hide;
  end;
end;

procedure TScoreFilter.New_dtkPicker;
begin
 SetLength(dtkPicker, NumberofClauses + 1);
 dtkPicker[NumberofClauses] := TDateTimePicker.Create(pnlHolders[NumberofClauses]);
 With dtkPicker[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 354;
   Top      := 8;
   Width    := 150;
   Name     := 'dtkPicker_' + IntToStr(NumberofClauses);
   OnChange := dtkPickerChange;
   Hide;
  end;
end;

procedure TScoreFilter.New_dtkPickerBT;
begin
 SetLength(dtkPickerBT, NumberofClauses + 1);
 dtkPickerBT[NumberofClauses] := TDateTimePicker.Create(pnlHolders[NumberofClauses]);
 With dtkPickerBT[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 542;
   Top      := 8;
   Width    := 150;
   Name     := 'dtkPickerBT_' + IntToStr(NumberofClauses);
   OnChange := dtkPickerBTChange;
   Hide;
  end;
end;

procedure TScoreFilter.New_TimeValues;
begin
 SetLength(cmbTimeValues, NumberofClauses + 1);
 cmbTimeValues[NumberofClauses] := TComboBox.Create(pnlHolders[NumberofClauses]);
 With cmbTimeValues[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 512;
   Top      := 8;
   Name     := 'cmbTimeValue_' + IntToStr(NumberofClauses);
   OnChange := cmbTimeValuesChange;
   Hide;
  end;
end;

procedure TScoreFilter.cmbFieldsOnChange(Sender: TObject);
var
 s : string;
begin
 s := TComboBox(Sender).Name;
 CurrentClause := StrToInt(Copy(s, Pos('_', s) + 1, Length(s)  ));

 CurrentCmbField := TComboBox(Sender).ItemIndex;
 GetOperators;
 cmbOperators[CurrentClause].ItemIndex := 0;
 cmbOperatorsOnChange(cmbOperators[CurrentClause]);
 OnCompChange;
end;

procedure TScoreFilter.DefaultSetUp;
begin
  edtInputInfo[CurrentClause].Show;
  dtkPicker[CurrentClause].Hide;
  cmbTimeValues[CurrentClause].Hide;
  dtkPickerBT[CurrentClause].Hide;
  lblAndBT[CurrentClause].Hide;
  edtInputInfoBT[CurrentClause].Hide;
end;

procedure TScoreFilter.cmbOperatorsOnChange(Sender: TObject);
var
 Op : string;
 i  : integer;
begin
 Op := TComboBox(Sender).Name;
 i  := TComboBox(Sender).ItemIndex;
 CurrentClause := StrToInt(Copy(Op, Pos('_', Op) + 1, Length(Op)  ));

 Op := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex];

 DefaultSetUp;
 if (Op = 'within last') or (cmbFields[CurrentClause].Items[cmbFields[CurrentClause].ItemIndex] = 'Time') then
  begin
   cmbTimeValues[CurrentClause].Show;
   cmbTimeValues[CurrentClause].Items.Clear;
   if OP = 'within last' then
    with cmbTimeValues[CurrentClause] do
    begin
     Items.Add('days');
     Items.Add('weeks');
     Items.Add('months');
     Items.Add('years');
     ItemIndex := 0;
    end else
    with cmbTimeValues[CurrentClause] do
    begin
     Items.Add('sec');
     Items.Add('min');
     Items.Add('hr');
     Items.Add('min:sec');
     ItemIndex := 3;
    end;
  end else
 if (Op = 'exactly') or (Op = 'before') or (Op = 'after') then
  begin
   edtInputInfo[CurrentClause].Hide;
   cmbTimeValues[CurrentClause].Hide;
   dtkPicker[CurrentClause].Show;
  end else
 if (Op = 'today') or (Op = 'yesterday') or (Op = 'this week') or (Op = 'this month') or (Op = 'this year') then
  begin
   edtInputInfo[CurrentClause].Hide;
   dtkPicker[CurrentClause].Hide;
   cmbTimeValues[CurrentClause].Hide;
  end else
 if (Op = 'between') or (Op = 'in range of') then
  begin
   lblAndBT[CurrentClause].Show;
   if OP = 'between' then
    begin
     edtInputInfo[CurrentClause].Hide;
     dtkPicker[CurrentClause].Show;
     dtkPickerBT[CurrentClause].Show;
    end else
     edtInputInfoBT[CurrentClause].Show;
  end;
 if i < TComboBox(Sender).Items.Count
  then
   TComboBox(Sender).ItemIndex := i;

 OnCompChange;
end;

procedure TScoreFilter.btnAddNewClauseOnClick(Sender: TObject);
begin
 Inc(NumberofClauses);
 Inc(CurrentClause);
 New_pnlHolder;
 New_AddRemoveBtns;
 New_cmbFields;
 New_cmbOperators;
 New_edtInfoBox;
 New_edtInfoBoxBT;
 New_lblAndBT;
 New_dtkPicker;
 New_dtkPickerBT;
 New_TimeValues;
 HolderParent.VertScrollBar.Position := CurrentClause * 225;
 if sender.ClassNameIs('TButton')
  then
   frmAchievements.AchievementComplete(Picky_Picky);
 OnCompChange;
end;

procedure TScoreFilter.btnRemoveClauseOnClick(Sender: TObject);
var
 s : string;
 i : integer;
begin
 s := TButton(Sender).Name;
 CurrentClause := StrToInt(Copy(s, Pos('_', s) + 1, Length(s)  ));
 pnlHolders[CurrentClause].Hide;
 dec(CurrentClause);
 if CurrentClause = 0 then inc(CurrentClause);

 btnAddRemove.Caption := '+';
 for i := Low(pnlHolders) + 1 to High(pnlHolders) do
  if pnlHolders[i].Showing then
   begin
    btnAddRemove.Caption := '-';
    break;
   end;
 OnCompChange;
end;

procedure TScoreFilter.cmbTimeValuesChange(Sender: TObject);
begin
 OnCompChange;
end;

procedure TScoreFilter.dtkPickerChange(sender: TObject);
begin
 OnCompChange;
end;

procedure TScoreFilter.dtkPickerBTChange(Sender: TObject);
begin
 OnCompChange;
end;

procedure TScoreFilter.edtInputBoxChange(Sender: TObject);
var
 currentitem : integer;
 s : string;
begin
 s := TEdit(Sender).Name;
 CurrentClause := StrToInt(Copy(s, Pos('_', s) + 1, Length(s)  ));
 Changed := True;
 currentitem := cmbTimeValues[CurrentClause].ItemIndex;
 if cmbTimeValues[CurrentClause].Showing then
  if cmbOperators[CurrentClause].Items[cmbOperators[CurrentClause].ItemIndex] = 'within last' then
   if TEdit(Sender).Text <> '1' then
     with cmbTimeValues[CurrentClause] do
      begin
       Items.Clear;
       Items.Add('days');
       Items.Add('weeks');
       Items.Add('months');
       Items.Add('years');
       ItemIndex := currentitem;
      end else
      with cmbTimeValues[CurrentClause] do
      begin
       Items.Clear;
       Items.Add('day');
       Items.Add('week');
       Items.Add('month');
       Items.Add('year');
       ItemIndex := currentitem;
      end;
 OnCompChange;
end;

procedure TScoreFilter.edtInputBoxBTChange(Sender: TObject);
begin
 OnCompChange;
end;

procedure TScoreFilter.BuildQueryBASIC;
var
 i, cluases : integer;
 qryField, Op, condition, timeformat : string;
 SelectedFields : String;
 sFunc, sField, alias : string;
begin
 SelectedFields := '';
 if NumberofShownFields > 0 then
 For i := Low(pnlItems) + 1 to High(pnlItems) do
  if pnlItems[i].Showing then
   begin
    sFunc  := '^' + cmbFunction[i].Items[cmbFunction[i].ItemIndex];
    sField := cmbSelected[i].Items[cmbSelected[i].ItemIndex];
    if cmbFunction[i].ItemIndex > 0 then
     begin
      if SelectedFields = ''
       then
        SelectedFields := sfunc + '([' + sField + '])'
       else
        SelectedFields := SelectedFields + ', ' + sFunc + '([' + sField + '])';
     end else
      if SelectedFields = ''
       then
        SelectedFields := '[' + sField + ']'
       else
        SelectedFields := SelectedFields + ', ' + '[' + sField + ']';
    if (edtAsFunctioned[i].Text = '') or (edtAsFunctioned[i].Text = 'Field Name As')
     then
      alias := sFunc + ' ' + sField
     else
      alias := edtAsFunctioned[i].Text;

    if Pos('^', alias) > 0
     then
      Delete(alias, Pos('^', alias), 1);

    if edtAsFunctioned[i].Showing
     then
      if cmbFunction[i].ItemIndex > 0
       then
        insert(' @$ [' + alias + ']', SelectedFields, LastDelimiter(')', SelectedFields) + 1)
       else
        insert(' @$ [' + alias + ']', SelectedFields, LastDelimiter(']', SelectedFields) + 1);
   end;


 if not scxShowHolder.Showing
  then
   SelectedFields := 'ALL'
  else
   SelectedFields := '$(' + SelectedFields + ')$';

 BASICqry := 'SELECT ' + SelectedFields + ' FROM ![' + cmbGameList.Items[LastGameList{cmbGameList.ItemIndex}] + ']!' + ' WHERE ';
 cluases := 0;
 for i := Low(pnlHolders) + 1 to High(pnlHolders) do
  if pnlHolders[i].Showing then
   begin
    inc(cluases);
    qryField := '[' + cmbFields[i].Items[cmbFields[i].ItemIndex] + ']';
    Op       := cmbOperators[i].Items[cmbOperators[i].ItemIndex];
    condition := '';
    if edtInputInfo[i].Showing then
     begin
      if (edtInputInfoBT[i].Showing) or (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'in range of')
       then
        condition := '(' + edtInputInfo[i].Text + '*' + edtInputInfoBT[i].Text
       else
        condition := '(' + edtInputInfo[i].Text;
     end else
    if dtkPicker[i].Showing
     then
      if (dtkPickerBT[i].Showing) or (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'between')
       then
        condition := '(' + FormatDateTime('mm/dd/yyyy', dtkPicker[i].DateTime) + '*' + FormatDateTime('mm/dd/yyyy', dtkPickerBT[i].DateTime)
       else
        condition := '(' + FormatDateTime('mm/dd/yyyy', dtkPicker[i].DateTime);

    timeformat := '';
    if cmbTimeValues[i].Showing then timeformat := '#' + cmbTimeValues[i].Items[cmbTimeValues[i].ItemIndex] + '#)';

    if i = low(pnlHolders) + 1 then
     begin
      if timeformat = ''
       then
        BASICqry := BASICqry + '(' + qryField + ' ' + Op + ' ' + condition + '))'
       else
        BASICqry := BASICqry + '(' + qryField + ' ' + Op + ' ' + condition + ' ' + timeformat + ')';
     end else
      if timeformat = ''
       then
        BASICqry := BASICqry + ' AND (' + qryField + ' ' + Op + ' ' + condition + '))'
       else
        BASICqry := BASICqry + ' AND (' + qryField + ' ' + Op + ' ' + condition + ' ' + timeformat + ')';
   end;

  BASICqry := '{' + BASICqry + '}<'  + IntToStr(cluases) + '>';
end;

function TScoreFilter.ConvertBASICoptoSQLop(cond, op : string) : string;
begin
 if op = 'matches'
  then
   Result := 'LIKE "% ' + cond + ' %"'
  else
 if op = 'contains'
  then
   Result := 'LIKE "%' + cond + '%"'
  else
 if op = 'begins with'
  then
   Result := 'LIKE "' + cond + '%"'
  else
 if op = 'ends with'
  then
   Result := 'LIKE "%' + cond + '"'
  else
 if op = 'is equal too'
  then
   Result := '= "' + cond + '"'
  else
 if op = 'equals'
  then
   Result := '= ' + cond
  else
 if op = 'is greater than'
  then
   Result := '> ' + cond
  else
 if op = 'is less than'
  then
   Result := '< ' + cond
  else
 if op = 'is not'
  then
   Result := '<> ' + cond
  else
 if op = 'within last'
  then
   Result := 'BETWEEN #' + FormatDateTime('mm/dd/yyyy', StrToDate(cond)) + '# AND #' + FormatDateTime('mm/dd/yyyy', Date) + '#'
  else
 if op = 'exactly'
  then
   Result := '= #' + cond + '#'
  else
 if op = 'before'
  then
   Result := '< #' + cond + '#'
  else
 if op = 'after'
  then
   Result := '> #' + cond + '#'
  else
 if op = 'today'
  then
   Result := '= #'+ FormatDateTime('mm/dd/yyyy', Date) + '#'
  else
 if op = 'yesterday'
  then
   Result := '= #'+ FormatDateTime('mm/dd/yyyy', Yesterday) + '#'
  else
 if op = 'this week'
  then
   Result := 'BETWEEN #' + FormatDateTime('mm/dd/yyyy', IncWeek(Date, -1)) + '# AND #' + FormatDateTime('mm/dd/yyyy', Date) + '#'
  else
 if op = 'this month'
  then
   Result := 'BETWEEN #' + FormatDateTime('mm/dd/yyyy', IncMonth(Date, -1)) + '# AND #' + FormatDateTime('mm/dd/yyyy', Date) + '#'
  else
 if op = 'this year'
  then
   Result := 'BETWEEN #' + FormatDateTime('mm/dd/yyyy', IncYear(Date, -1)) + '# AND #' + FormatDateTime('mm/dd/yyyy', Date) + '#'
  else
 if op = 'between'
  then
   Result := 'BETWEEN #' + FormatDateTime('mm/dd/yyyy', dtkPicker[CurrentClause].Date) + '# AND #' + FormatDateTime('mm/dd/yyyy', dtkPickerBT[CurrentClause].Date) + '#'
  else
 if op = 'in range of'
  then
   Result := 'BETWEEN ' + cond + ' AND ' + edtInputInfoBT[CurrentClause].Text;
end;

function ConvertTimeStringtoTime(tme, tmeformat : string) : String;
var
 itime, i : integer;
 min, sec : string;
begin
 val(tme, itime, i);
 Result := '0';
 if tmeFormat = 'sec'
  then
   Result := IntToStr(itime)
  else
 if tmeformat = 'min'
  then
   Result := IntToStr(itime * 60)
  else
 if tmeFormat = 'hr'
  then
   Result := IntToStr(iTime * 3600)
  else
 if tmeFormat = 'min:sec' then
  begin
   if Pos(':', tme) = 0
    then
     if tme <> ''
      then
       tme := tme + ':00'
      else
       tme := '00:00';
   min    := Copy(tme, 1               , POS(':', tme) - 1);
   sec    := Copy(tme, POS(':', tme)    + 1, Length(tme));
   if min = '' then min := '0';
   if sec = '' then sec := '0';
   Result := IntToStr(StrToInt(min) * 60  + StrToInt(sec));
  end else
 if (tmeformat = 'days') or (tmeformat = 'day')
  then
   Result := DateTimeToStr(IncDay(Date, -iTime))
  else
 if (tmeformat = 'weeks') or (tmeformat = 'week')
  then
   Result := DateTimeToStr(IncWeek(Date, -iTime))
  else
 if (tmeformat = 'months') or (tmeformat = 'month')
  then
   Result := DateTimeToStr(IncMonth(Date, -iTime))
  else
 if (tmeformat = 'years') or (tmeformat = 'year')
  then
   Result := DateTimeToStr(IncYear(Date, -iTime));
end;

///////////////////////////////////SQL Build//////////////////////////
procedure TScoreFilter.BuildQuerySQL;
var
 i : integer;
 qryField, Op, condition, timeformat : string;
 SelectedFields, alias : String;
 sFunc, sField : string;
 FirstParamDone: Boolean;
begin
 tmrExecute.Enabled := false;
 if cmbGameList.ItemIndex > 1 then
  begin
   SQLqry := 'SELECT ';
   SelectedFields := '';
   if NumberofShownFields > 0 then
   For i := Low(pnlItems) + 1 to High(pnlItems) do
    if pnlItems[i].Showing then
     begin
      sFunc  := cmbFunction[i].Items[cmbFunction[i].ItemIndex];
      sField := cmbSelected[i].Items[cmbSelected[i].ItemIndex];
      if cmbFunction[i].ItemIndex > 0 then
       begin
        if SelectedFields = ''
         then
          SelectedFields := sfunc + '([' + sField + '])'
         else
          SelectedFields := SelectedFields + ', ' + sFunc + '([' + sField + '])';
       end else
        if SelectedFields = ''
         then
          SelectedFields := '[' + sField + ']'
         else
          SelectedFields := SelectedFields + ', ' + '[' + sField + ']';
      if (edtAsFunctioned[i].Text = '') or (edtAsFunctioned[i].Text = 'Field Name As')
       then
        alias := sFunc + ' ' + sField
       else
        alias := edtAsFunctioned[i].Text;

      if edtAsFunctioned[i].Showing
       then
        if cmbFunction[i].ItemIndex > 0
         then
          insert(' AS [' + alias + ']', SelectedFields, LastDelimiter(')', SelectedFields) + 1)
         else
          insert(' AS [' + alias + ']', SelectedFields, LastDelimiter(']', SelectedFields) + 1);
     end;
   if (not scxShowHolder.Showing) or (NumberofShownFields < 1) then SelectedFields := GetFields;
   SQLqry := SQLqry + SelectedFields + ' FROM [' + cmbGameList.Items[cmbGameList.ItemIndex] + '] ';

   if NumberofClauses > 0 then
    begin
     for i := Low(pnlHolders) + 1 to High(pnlHolders) do
      if pnlHolders[i].Showing then
       begin
        SQLqry := SQLqry + 'WHERE';
        break;
       end;
    end else
    begin
     SQLqry := SQLqry + GetGROUPBYstr;
     Exit;
    end;

   FirstParamDone := False;
   for i := Low(pnlHolders) + 1 to High(pnlHolders) do
    if pnlHolders[i].Showing then
     begin
      CurrentClause := i;
      qryField := cmbFields[i].Items[cmbFields[i].ItemIndex];
      Op       := cmbOperators[i].Items[cmbOperators[i].ItemIndex];
      condition := '';
      if edtInputInfo[i].Showing
       then
        condition := edtInputInfo[i].Text
       else
      if (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'exactly') or (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'before') or (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'after')
       then
        condition := FormatDateTime('mm/dd/yyyy', dtkPicker[i].DateTime);

      timeformat := '';
      if (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'within last') or (cmbFields[i].Items[cmbFields[i].ItemIndex] = 'Time')
       then
        timeformat := cmbTimeValues[i].Items[cmbTimeValues[i].ItemIndex];

      if timeformat <> ''
       then
        Condition := ConvertTimeStringtoTime(condition, timeformat);

      condition := ConvertBASICoptoSQLop(condition, op);
      if condition <> '' then
      if not FirstParamDone then
       begin
        SQLqry := SQLqry + '([' + qryField + '] ' + condition + ')' ;
        FirstParamDone := True;
       end else
        SQLqry := SQLqry + ' AND ([' + qryField + '] ' + condition + ')'
     end;
   if SelectedFields <> '*'
    then
     SQLqry := SQLqry + GetGROUPBYstr;

   tmrExecute.Enabled := True;
  end else
   SQLqry := 'void';
end;

procedure TScoreFilter.LoadQuery(sName: string);
var Actualqry : string;

    procedure LoadSelectedFields;
    var
     SelectedFields : String;
     i, icount : integer;
     sFunc, sAs, sField, sClause : string;
    begin
     if Pos('$(', Actualqry) = 0 then
      begin
       btnAddSelectClick(nil);
       exit;
      end else
       ShowClick(nil);

     NumberofShownFields := 0;
     SelectedFields := Copy(Actualqry, Pos('$(', Actualqry), Pos(')$', Actualqry) - Pos('$(', Actualqry));
     Delete(Actualqry, Pos('$(', Actualqry), Length(SelectedFields) + 2);
     Insert('ALL', Actualqry, Pos('FROM', Actualqry) - 1);
     icount := 1;
     For i := 1 to length(SelectedFields) do
      if SelectedFields[i] = ','
       then
        inc(icount);

     Delete(SelectedFields, 1, 2);
     For i := 1 to iCount do
      begin
       btnAddSelectClick(self);
       if Pos(',', SelectedFields) > 0 then
        begin
         sClause := Copy(SelectedFields, 1, Pos(',', SelectedFields) - 1);
         Delete(SelectedFields, 1, Pos(',', SelectedFields));
        end else
        begin
         sClause := Copy(SelectedFields, 1, Pos(']', SelectedFields));
         Delete(SelectedFields, 1, Pos(']', SelectedFields) + 1);
        end;

       sField := Copy(sClause, Pos('[', sClause) + 1, Pos(']', sClause) - Pos('[', sClause) - 1);
       cmbSelected[i].ItemIndex := GetItemPosFromText(cmbSelected[i], sField);
       cmbSelectedChange(cmbSelected[i]);

       if Pos('^', sClause) > 0 then
        begin
         sfunc := Copy(sClause, Pos('^', sClause) + 1, Pos('(', sClause) - Pos('^', sClause) - 1);
         Delete(sClause, Pos('^', sClause), Pos('(', sClause) - 1);
         cmbFunction[i].ItemIndex := GetItemPosFromText(cmbFunction[i], sFunc);
         pnlItems[i].Width := 400;
         edtAsFunctioned[i].Show;
         //edtAsFunctioned[i].SetFocus;
         HasAggregateFunc := True;
        end;

       if Pos('@$', sClause) > 0 then
        begin
         Delete(sClause, 1, Pos('@$', sClause));
         sAs := Copy(sClause, Pos('[', sClause) + 1, Pos(']', sClause) - Pos('[', sClause) - 1);
         edtAsFunctioned[i].Text := sAs;
        end;

      end;
    end;

var
 txt : TextFile;
 sLine, condition2 : string;
 //Actualqry : string;
 tblName : string;
 i : integer;
 conditions : integer;
 y, m, d : Word;

 field, Op, Condition, tmfrmt : string;
begin
 tmrExecute.Enabled := false;
 ClearUp;
 CurrentClause := 1;
 NumberofClauses := 0;
 NumberofShownFields := 0;

 AssignFile(txt, 'High Score.qry');
 if not FileExists('High Score.qry') then
  begin
   MessageDlg('File Does Not Exist', mtError, mbOKCancel, 1);
   Exit;
  end;
 Reset(txt);
 Actualqry := '';

 While (not Eof(txt)) and (Actualqry = '') do
  begin
   ReadLn(txt, sLine);
   if Copy(sLine, 1, Pos('{', sLine) - 1) = sName then
    begin
     Actualqry := sLine;
     CurrentFilter := sName;
    end;
  end;

  CloseFile(txt);

 tblName := Copy(Actualqry, Pos('![', Actualqry), Pos(']!', Actualqry) - Pos('![', Actualqry));
 delete(tblName, 1, 2);
 cmbGameList.ItemIndex := GetItemPosFromText(cmbGameList, tblName);
 
 LoadSelectedFields;

 Delete(Actualqry, 1, Pos('[', Actualqry) + 1);
 delete(Actualqry, 1, 1);
 delete(Actualqry, length(Actualqry), 1);

 DBTable.Close;
 DBTable.TableName := cmbGameList.Items[cmbGameList.ItemIndex];
 DBTable.Open;
 Delete(Actualqry, 1,  Pos('[', Actualqry) - 1);

 tblName := Copy(Actualqry, Pos('<', Actualqry), length(Actualqry));
 delete(tblName, 1, 1);
 Val(tblName, conditions, i);
 for i := 1 to Conditions do
  begin
   field := Copy(Actualqry, 1, Pos(']', Actualqry));
   delete(Actualqry, 1, Pos(']', Actualqry));
   delete(field, 1, 1);
   delete(field, length(field), 1);

   op := Copy(Actualqry, 1, Pos('(', Actualqry) - 1);
   delete(Actualqry, 1, Pos('(', Actualqry) - 1);
   op := Trim(op);

   Condition := Copy(Actualqry, 1, Pos(')', Actualqry));
   delete(Actualqry, 1, Pos(')', Actualqry) + 1);
   delete(Condition, 1, 1);
   delete(Condition, length(Condition), 1);
   Condition := Trim(Condition);

   if OP = ''
    then
     if (Condition = 'today') or (Condition = 'yesterday') or (Condition = 'this week') or (Condition = 'this month') or (Condition = 'this year')
      then
       OP := Condition;

   btnAddNewClauseOnClick(Self);
   cmbFields[i].ItemIndex    := GetItemPosFromText(cmbFields[i], field);
   cmbFieldsOnChange(cmbFields[i]);
   cmbOperators[i].ItemIndex := GetItemPosFromText(cmbOperators[i], op);
   cmbOperatorsOnChange(cmbOperators[i]);

   Delete(Actualqry, 1, Pos('(', Actualqry));

   if (op = 'within last') or (field = 'Time') then
    begin
     tmfrmt := Copy(Condition, Pos('#', Condition) + 1, length(Condition));
     delete(tmfrmt, length(tmfrmt), 1);
     delete(Condition, Pos(' #', Condition), length(Condition));

     edtInputInfo[i].Text := Condition;
     cmbTimeValues[i].ItemIndex := GetItemPosFromText(cmbTimeValues[i], tmfrmt);
    end else
   if (Op = 'exactly') or (Op = 'before') or (Op = 'after') then
    begin
     d := StrToInt(Copy(Condition, 1, 2));
     m := StrToInt(Copy(Condition, 4, 2));
     y := StrToInt(Copy(Condition, 7, 4));
     dtkPicker[i].DateTime := EncodeDate(y, m, d);
    end else
   if (OP = 'today') or (Op = 'yesterday') or (Op = 'this week') or (Op = 'this month') or (Op = 'this year') then
    begin
    end else
   if (OP = 'between') or(Op = 'in range of') then
    begin
     condition2 := Copy(Condition, Pos('*', Condition) + 1, Length(Condition));
     Condition  := Copy(Condition, 1                      , Pos('*', Condition) - 1);
     if Op = 'between' then
      begin
       dtkPicker[i].Date := StrToDate(Condition);
       dtkPickerBT[i].Date := StrToDate(Condition2);
      end else
      begin
       edtInputInfo[i].Text := Condition;
       edtInputInfoBT[i].Text := condition2;
      end;
    end else
     edtInputInfo[i].Text      := Condition;

  end;

 Changed := false;
 btnAddRemove.Caption := '-';
 tmrExecute.Enabled := true;
end;

procedure TScoreFilter.LoadQueryNames(List : TStrings; tbl : string);
var
 sLine : string;
 txt   : TextFile;
begin
 List.Clear;
 AssignFile(txt, 'High Score.qry');
 if not FileExists('High Score.qry')
  then
   exit
  else
   Reset(txt);
 While not eof(txt) do
  begin
   ReadLn(txt, sLine);
   sLine := Copy(sLine, 1, Pos('{', sLine) - 1);
   if sLine <> ''
    then
     if (Copy(sLine, 1, Pos('.', sLine) - 1) = tbl)
      then
       List.Add(Copy(sLine, Pos('.', sLine) + 1, length(sLine)))
      else
     if tbl = 'All'
      then
       List.Add(sLine);  
  end;
 CloseFile(txt);
end;

procedure TScoreFilter.SaveBASICQuery;
var
 HighScore : TextFile;
 qry, tblName, sLine : string;
 strings: TStringList;
 i: integer;
begin
 tblName := Copy(BASICqry, Pos('![', BASICqry) + 2, Pos(']!', BASICqry) - 2 - Pos('![', BASICqry));
 try
   strings := TStringList.Create;
   AssignFile(HighScore, 'High Score.qry');
   if FileExists('High Score.qry') then
    begin
     Reset(HighScore);
     While not eof(HighScore) do
      begin
       ReadLn(HighScore, sLine);
       if Copy(sLine, 1, Pos('{', sLine) - 1) <> tblName + '.' + qryName
        then
         strings.Add(sLine);
      end;
     Rewrite(HighScore);
     RenameFile('HighScore', 'High Score.qry');
     for i := 0 to strings.Count - 1 do
      WriteLn(HighScore, strings[i]);
    end;
 Finally
   FreeAndNil(strings);
 end;

 if FileExists('High Score.qry')
  then
   Append(HighScore)
  else begin
   Rewrite(HighScore);
   RenameFile('HighScore', 'High Score.qry');
  end;
 qry := tblName + '.' + qryName + BASICqry;
 WriteLn(HighScore, qry);
 CloseFile(HighScore);
 LoadQueryNames(cmbSavedQueries.Items, cmbSavetables.Items[cmbSavetables.ItemIndex]);
 SendMessage(cmbSavedQueries.Handle, CB_SETDROPPEDWIDTH, ChangeWidthcmb(cmbSavedQueries), 0);
end;

procedure TScoreFilter.DeleteQueries(clx: TCheckListBox);
var
 i : integer;
 HighScore, txt2 : TextFile;
 sLine : string;
 IsToBeDeleted : Boolean;
begin
 AssignFile(HighScore, 'High Score.qry');
 AssignFile(txt2, 'txt2.txt');
 if FileExists('High Score.qry') then
  begin
   Reset(HighScore);
   Rewrite(txt2);
  end else
  begin
   Rewrite(HighScore);
   Exit;
  end;

 while not eof(HighScore) do
  begin
   ReadLn(HighScore, sLine);
   IsToBeDeleted := false;
   for i := 0 to clx.Items.Count - 1 do
    if clx.Checked[i]
     then
      if Copy(sLine, Pos('.', sLine) + 1, Pos('{', sLine) - Pos('.', sLine) - 1) = clx.Items[i]
       then
        IsToBeDeleted := True
       else
      if Copy(sLine, Pos('.', sLine) + 1, Pos('{', sLine) - Pos('.', sLine) - 1) = Copy(clx.Items[i], Pos('.', clx.Items[i]) + 1, length(clx.Items[i]))
       then
        IsToBeDeleted := True;

   if not IsToBeDeleted then
    writeLn(txt2, sLine);
  end;

  CloseFile(txt2);
  CloseFile(HighScore);
  DeleteFile('High Score.qry');
  RenameFile('txt2.txt', 'High Score.qry');
  Changed := false;
  LoadQueryNames(cmbSavedQueries.Items, cmbGameList.Items[cmbGameList.ItemIndex]);
  SendMessage(cmbSavedQueries.Handle, CB_SETDROPPEDWIDTH, ChangeWidthcmb(cmbSavedQueries), 0);
end;

procedure TScoreFilter.SaveQueries(sName: string);
begin
 if sName = '' then exit;
 qryName := sName;
 While Pos('.', qryName) > 0 do
  Delete(qryName, 1, Pos('.', qryName));
 SaveBASICQuery;
 CurrentFilter := sName;
 Changed := false;
end;

procedure TScoreFilter.SaveQueries;
var
 i : integer;
 clx : TCheckListBox;
begin
 try
  clx := TCheckListBox.Create(HolderParent);
  clx.Parent := HolderParent;
  LoadQueryNames(clx.Items, 'All'{cmbSavetables.Items[LastGameList]});
  
  for i := 0 to clx.Items.Count - 1 do
   clx.Checked[i] := false;
   for i := 0 to clx.Items.Count - 1 do
    if clx.Items[i] = CurrentFilter
     then
      clx.Checked[i] := true;
   DeleteQueries(clx);
   SaveQueries(CurrentFilter);

 finally
  FreeAndNil(clx);
 end;
end;


procedure TScoreFilter.SQLCheck;
begin
 if Copy(SQLqry, length(SQLqry) - 4, 5) = 'WHERE'
  then
   SQLqry := 'void';

 if Pos('SELECT', SQLqry) = 0
  then
   SQLqry := 'void';

 if Pos('##', SQLqry) OR Pos('= )', SQLqry) OR Pos('AND )', SQLqry) or Pos('%  %', SQLqry) or Pos('%%', SQLqry) or Pos('"%"', SQlqry) or Pos('< )', SQLqry) or Pos('> )', SQLqry) <> 0
  then
   SQLqry := 'void';

 if (Pos('Sum', SQLqry) OR Pos('Avg', SQLqry) OR Pos('Count', SQLqry) OR Pos('Max', SQLqry) OR Pos('Min', SQLqry) > 0) and (Pos('GROUP BY', SQLqry) = 0)
  then begin
   SQLqry := 'void';

  end;
end;

procedure TScoreFilter.btnAddSelectClick(sender: TObject);
begin
 Inc(NumberofShownFields);
 New_pnlItems;
 New_cmbFunction;
 New_cmbSelected;
 New_edtAsFunctioned;
 New_btnAddSelect;
 New_btnRemoveSelect;
 ChangeWidthofSelect;
 scxShowHolder.VertScrollBar.Position := scxShowHolder.VertScrollBar.Size;
 if Sender <> nil
  then
   if Sender.ClassNameIs('TButton')
    then
     frmAchievements.AchievementComplete(I_Wanna_See_More);
 OnCompChange;
end;

procedure TScoreFilter.cmbFunctionChange(Sender: TObject);
var
 i : integer;
begin
 if TComboBox(Sender).ItemIndex > 0 then
  begin
   pnlItems[TComboBox(Sender).Tag].Width := 400;
   edtAsFunctioned[TComboBox(Sender).Tag].Show;
   edtAsFunctioned[TComboBox(Sender).Tag].SetFocus;
   HasAggregateFunc := True;
   frmAchievements.AchievementComplete(Mathematician);
  end else
  begin
   pnlItems[TComboBox(Sender).Tag].Width := 300;
   edtAsFunctioned[TComboBox(Sender).Tag].Hide;
   HasAggregateFunc := False;
   for i := Low(cmbFunction) to High(cmbFunction) do
    if pnlItems[i] <> nil
     then
    if pnlItems[i].Showing and (cmbFunction[i].ItemIndex > 0)
     then
      HasAggregateFunc := True;
  end;
 OnCompChange;
end;

procedure TScoreFilter.cmbSelectedChange(Sender: TObject);
var
 fld : string;
 currentSelection : integer;
begin
 OnCompChange;
 DBTable.Close;
 currentSelection := TComboBox(Sender).Tag;
 fld := cmbSelected[currentSelection].Items[cmbSelected[currentSelection].ItemIndex];
 cmbFunction[currentSelection].Items.Clear;
 DBTable.TableName := cmbGameList.Items[cmbGameList.ItemIndex];
 DBTable.Open;
 if fld = '' then exit;

 if DBTable.FieldByName(fld).DataType  = ftWideString then
  With cmbFunction[currentSelection].Items do
   begin
    Add('Nothing');
    Add('Count');
  end else
 if DBTable.FieldByName(fld).DataType  = ftInteger then
  With cmbFunction[currentSelection].Items do
   begin
    Add('Nothing');
    Add('Avg');
    Add('Count');
    Add('Max');
    Add('Min');
    Add('Sum');
   end else
  if DBTable.FieldByName(fld).DataType  = ftDateTime then
   with cmbFunction[currentSelection].Items do
    begin
     Add('Nothing');
    end;
end;

procedure TScoreFilter.edtAsFunctionedChange(Sender: TObject);
begin
 frmAchievements.AchievementComplete(I_Can_Name_A_Function);
 OnCompChange;
end;

procedure TScoreFilter.New_cmbFunction;
begin
 SetLength(cmbFunction, NumberofShownFields + 1);
 cmbFunction[NumberofShownFields] := TComboBox.Create(pnlItems[NumberofShownFields]);
 With cmbFunction[NumberofShownFields] do
  begin
   Parent := pnlItems[NumberofShownFields];
   Top    := 8;
   Left   := 8;
   Width  := 50;
   Items.Add('None');
   Items.Add('Avg');
   Items.Add('Count');
   Items.Add('Max');
   Items.Add('Min');
   Items.Add('Sum');
   ItemIndex := 0;
   OnChange := cmbFunctionChange;
   Tag := NumberofShownFields;
  end;
end;

procedure TScoreFilter.New_cmbSelected;
begin
 SetLength(cmbSelected, NumberofShownFields + 1);
 cmbSelected[NumberofShownFields] := TComboBox.Create(pnlItems[NumberofShownFields]);
 With cmbSelected[NumberofShownFields] do
  begin
   Parent := pnlItems[NumberofShownFields];
   Top    := 8;
   Left   := 66;
   Width  := 150;
   Tag    := NumberofShownFields;
   OnChange := cmbSelectedChange;
  end;

  DBTable.Close;
  DBTable.TableName  := cmbGameList.Items[cmbGameList.ItemIndex];
  DBTable.GetFieldNames(cmbSelected[NumberofShownFields].Items);
  cmbSelected[NumberofShownFields].Items.Delete(0);
  if NumberofShownFields <= cmbSelected[NumberofShownFields].Items.Count
   then
    cmbSelected[NumberofShownFields].ItemIndex := NumberofShownFields - 1
   else
    cmbSelected[NumberofShownFields].ItemIndex := 0;
  cmbSelectedChange(cmbSelected[NumberofShownFields]);
  DBTable.Open;
end;

procedure TScoreFilter.New_edtAsFunctioned;
begin
 SetLength(edtAsFunctioned, NumberofShownFields + 1);
 edtAsFunctioned[NumberofShownFields] := TEdit.Create(pnlItems[NumberofShownFields]);
 With edtAsFunctioned[NumberofShownFields] do
  begin
   Parent := pnlItems[NumberofShownFields];
   Top    := 8;
   Left   := 224;
   Width  := 100;
   Text   := 'Field Name As';
   OnChange := edtAsFunctionedChange;
   Visible := false;
  end;
end;

procedure TScoreFilter.New_pnlItems;
var
 imgBackground : TImage;
begin
 SetLength(pnlItems, NumberofShownFields + 1);
 pnlItems[NumberofShownFields] := TPanel.Create(pnlSelect);
 With pnlItems[NumberofShownFields] do
  begin
   Parent:= pnlSelect;
   Left  := NumberofShownFields * 400;
   Align := alLeft;
   Width := 300;
   BevelOuter := bvNone;
   Font.Size  := 10;
   Font.Color := clBlack;
  end;

 imgBackground := TImage.Create(pnlItems[NumberofShownFields]);
 With imgBackground do
  begin
   Parent := pnlItems[NumberofShownFields];
   Top := 1;
   Left := 1;
   width := 298;
   Height := 39;
   Anchors := [akLeft, akTop, akBottom, akRight];
   Picture.LoadFromFile('Resources/Undertow.jpg');
   Stretch := True;
  end;
end;

procedure TScoreFilter.btnRemoveSelectClick(sender: TObject);
    function IsOnlyOne : boolean;
    var
     i : integer;
    begin
     Result := true;
     for i := 1 to High(pnlItems) do
      if pnlItems[i].Showing and (i <> TButton(Sender).Tag)
       then
        Result := False;
    end;
begin
 if IsOnlyOne then exit;
 pnlItems[TButton(Sender).Tag].Hide;
 ChangeWidthofSelect;
 if Sender.ClassNameIs('TButton')
  then
   frmAchievements.AchievementComplete(Thats_More_Than_I_Need);
 OnCompChange;
end;

procedure TScoreFilter.New_btnAddSelect;
begin
 SetLength(btnAddSelect, NumberofShownFields + 1);
 btnAddSelect[NumberofShownFields] := TButton.Create(pnlItems[NumberofShownFields]);
 With btnAddSelect[NumberofShownFields] do
  begin
   Parent := pnlItems[NumberofShownFields];
   Top    := 8;
   Left   := pnlItems[NumberofShownFields].Width - 33;
   Width  := 25;
   Height := 25;
   Caption := '+';
   OnClick := btnAddSelectClick;
   Tag    := NumberofShownFields;
   Anchors := [akRight];
  end;
end;

procedure TScoreFilter.New_btnRemoveSelect;
begin
 SetLength(btnRemoveSelect, NumberofShownFields + 1);
 btnRemoveSelect[NumberofShownFields] := TButton.Create(pnlItems[NumberofShownFields]);
 With btnRemoveSelect[NumberofShownFields] do
  begin
   Parent := pnlItems[NumberofShownFields];
   Top    := 8;
   Left   := pnlItems[NumberofShownFields].Width - 66;
   Width  := 25;
   Height := 25;
   Caption := '-';
   OnClick := btnRemoveSelectClick;
   tag    := NumberofShownFields;
   Anchors := [akRight];
  end;
end;

procedure TScoreFilter.Resize;
begin
 ChangeWidthofSelect;
end;

procedure TScoreFilter.ChangeWidthofselect;
var
 i : integer;
begin
 if Length(pnlItems) < 1 then exit;
 pnlSelect.Width := pnlItems[1].Left;
 for i := 1 to High(pnlItems) do
  if pnlItems[i].Showing
   then
    pnlSelect.Width := pnlSelect.Width + pnlItems[i].Width;
 if scxShowHolder.Width > pnlSelect.Width
  then begin
   pnlSelect.Width := scxShowHolder.Width - 5;
   scxShowHolder.Height := 47;
  end else
   scxShowHolder.Height := 60;
end;

procedure TScoreFilter.OnCompChange;
begin
 tmrExecute.Enabled := true;
 Changed := True;
 if Assigned(OnChange)
  then
   OnChange(self);
end;

function TScoreFilter.GetGROUPBYstr: String;
var
 i : integer;
 aggregate : boolean;
begin
 Result := 'GROUP BY';

 aggregate := false;
 for i := 1 to High(cmbFunction) do
  if (cmbFunction[i].ItemIndex > 0) and pnlItems[i].Showing
   then
    aggregate := true;

 if (NumberofShownFields > 0) and aggregate
  then
 for i := 1 to High(cmbFunction) do
  if pnlItems[i].Showing// and (cmbFunction[i].ItemIndex = 0)
   then
    Result := Result + ', [' + cmbSelected[i].Items[cmbSelected[i].ItemIndex] + ']';
 if Pos(',', Result) > 0
  then
   Delete(Result, Pos(',', Result), 1)
  else
   Result := '';
end;

function TScoreFilter.GetFields: string;
var
 strings: TStringList;
 i: integer;
begin
 try
   strings := TStringList.Create;
   DBTable.Close;
   DBTable.TableName := cmbGameList.Items[cmbGameList.ItemIndex];
   DBTable.Open;
   DBTable.GetFieldNames(strings);
   Result := '';
   for i := 0 to strings.Count - 1 do
    Result := Result + ', [' + strings[i] + ']';
   Delete(Result, 1, 2);
   Delete(Result, 2, Pos(',', Result) + 1);
 finally
  FreeAndNil(strings);
 end;
end;

function TScoreFilter.DeleteQuery: boolean;
     function GetName(s: string): string;
     begin
      Result := Copy(s, 1, Pos('{', s) - 1);
     end;

var
 sQueryName, sLine: string;
 sQueries: TStringList;
 HighScore: TextFile;
 i: integer;
begin
 sQueryName := cmbSavedQueries.Items[cmbSavedQueries.ItemIndex];
 if MessageDlg('Are You Sure You Want Delete' + sQueryName, mtConfirmation, [mbYes, mbNo], 1) = mrNo then
  begin
   Result := false;
   exit;
  end else
   Result := True; 

 if cmbSavetables.ItemIndex <> 0
  then
   sQueryName := cmbSavetables.Items[cmbSavetables.ItemIndex] + '.' + sQueryName;
 AssignFile(HighScore, 'High Score.qry');
 if FileExists('High Score.qry')
  then
   Reset(HighScore)
  else begin
   MessageDlg('Error', mtError, [mbOK], 1);
   exit;
  end;

 try
   sQueries := TStringList.Create;
   While not eof(HighScore) do
    begin
     ReadLn(HighScore, sLine);
     sQueries.Add(sLine);
    end;

   Rewrite(HighScore);
   RenameFile('HighScore', 'High Score.qry');
   Append(HighScore);

   for i := 0 to sQueries.Count - 1 do
    if sQueryName <> GetName(sQueries[i])
     then
      WriteLn(HighScore, sQueries[i]);

 Finally
  FreeAndNil(sQueries);
  CloseFile(HighScore);
 end;
end;

procedure TScoreFilter.Refresh;
begin
 Add_OR_RemoveClick(nil);
end;

procedure TScoreFilter.RefreshGameList;
begin
 cmbGameList.ItemIndex := cmbGameList.ItemIndex;
 GameTableChanged(cmbGameList);
end;

function TScoreFilter.GetGameName: string;
begin
 Result := cmbGameList.Items[cmbGameList.ItemIndex];
end;

end.
