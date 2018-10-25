unit HighScoreFilter_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ComCtrls, ExtCtrls, ADODB, DB, DateUtils;

type
 TScoreFilter = class
  Private
   BASICqry        : string;
   SQLqry          : string;
   qryName         : string;

   DBTable         : TADOTable;
   HolderParent    : TScrollBox;
   GameTables      : TComboBox;
   pnlHolders      : Array of TPanel;
   cmbFields       : Array of TComboBox;
   cmbOperators    : array of TComboBox;
   edtInputInfo    : array of TEdit;
   dtkPicker       : array of TDateTimePicker;
   cmbTimeValues   : array of TComboBox;
   btnAddNewClause : Array of TButton;
   btnRemoveClause : Array of TButton;

   CurrentCmbField : Integer;
   CurrentClause   : Integer;
   NumberofClauses : integer;


   procedure GetOperators;
   procedure New_pnlHolder;
   procedure New_cmbFields;
   procedure New_cmbOperators;
   procedure New_edtInfoBox;
   procedure New_dtkPicker;
   procedure New_TimeValues;
   procedure New_AddRemoveBtns;

   procedure cmbFieldsOnChange(Sender : TObject);
   procedure cmbOperatorsOnChange(Sender : TObject);
   procedure btnAddNewClauseOnClick(Sender : TObject);
   procedure btnRemoveClauseOnClick(Sender : TObject);
   procedure edtInputBoxChange(Sender : TObject);
   procedure dtkPickerChange(sender : TObject);
   procedure cmbTimeValuesChange(Sender : TObject);

   procedure DefaultSetUp;

   procedure   SaveSQLQuery;
   procedure   SaveBASICQuery;
  Public
   CurrentFilter : string;
   Changed       : boolean;

   procedure   Newfilter(Sender : TObject);
   procedure   GameTableChanged(Sender : TObject);
   procedure   ClearUp;
   function    GetQuery : String;
   procedure   BuildQueryBASIC;
   procedure   BuildQuerySQL;

   procedure   SaveQueries(sName : string); overload;
   procedure   SaveQueries(clx : TChecklistBox); overload;
   procedure   LoadQuery(sName : string);
   procedure   LoadQueryNames(List : TStrings; tbl : string);
   procedure   DeleteQueries(clx : TCheckListBox);


   Constructor Create(Holder : TScrollBox; tbl : TADOTable; cmbGameNames : TComboBox);
   Destructor  Free;
 end;

implementation

{ TScoreFilter }

procedure TScoreFilter.ClearUp;
var
 i : integer;
begin
 for i := Low(cmbFields)       to High(cmbFields)       do FreeAndNil(cmbFields[i]);
 for i := Low(cmbOperators)    to High(cmbOperators)    do FreeAndNil(cmbOperators[i]);
 for i := Low(edtInputInfo)    to High(edtInputInfo)    do FreeAndNil(edtInputInfo[i]);

 for i := Low(dtkPicker)       to High(dtkPicker)       do FreeAndNil(dtkPicker[i]);
 for i := Low(cmbTimeValues)   to High(cmbTimeValues)   do FreeAndNil(cmbTimeValues[i]);

 for i := Low(btnAddNewClause) to High(btnAddNewClause) do FreeAndNil(btnAddNewClause[i]);
 for i := Low(btnRemoveClause) to High(btnRemoveClause) do FreeAndNil(btnRemoveClause[i]);

 for i := Low(pnlHolders)      to High(pnlHolders)      do FreeAndNil(pnlHolders[i]);
end;

constructor TScoreFilter.Create(Holder : TScrollBox; tbl : TADOTable; cmbGameNames : TComboBox);
begin
 HolderParent := Holder;
 DBTable      := tbl;
 GameTables   := cmbGameNames;
 GameTables.OnChange := GameTableChanged;
 NumberofClauses     := 0;
 CurrentFilter := '';
 Changed := false;
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
 DBTable.TableName := GameTables.Items[GameTables.ItemIndex];
 DBTable.Open;
 if fld = '' then exit;

 if DBTable.FieldByName(fld).DataType  = ftWideString then
  begin
   if fld <> 'Time' then
    With cmbOperators[CurrentClause].Items do
     begin
      Add('matches');
      Add('contains');
      Add('begins with');
      Add('ends with');
      Add('is equal too');
     end else
    With cmbOperators[CurrentClause].Items do
     begin
      Add('equals');
      Add('is greater than');
      Add('is less than');
      Add('is not');
     end;
  end else
 if DBTable.FieldByName(fld).DataType  = ftInteger then
  With cmbOperators[CurrentClause].Items do
   begin
    Add('equals');
    Add('is greater than');
    Add('is less than');
    Add('is not');
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
 ifnotable : string;
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
  begin
    if GameTables.ItemIndex = -1 then
     begin
      ifnotable := InputBox('Game Table', 'Please Type the Game Table you want to Use or choose it from the drop box', '');
      GameTables.ItemIndex := GetItemPosFromText(GameTables, ifnotable);
      if GameTables.ItemIndex = -1 then
       begin
        MessageDlg('No table exist by that name. Try using the Drop Box', mtError, mbOKCancel, 1);
        exit;
       end;
     end;
    ClearUp;
    CurrentClause := 1;
    NumberofClauses := 0;
    btnAddNewClauseOnClick(Sender);
  end;

 CurrentFilter := '';
 Changed := false;
end;

procedure TScoreFilter.GameTableChanged(Sender : TObject);
begin
 Newfilter(sender);
end;

function TScoreFilter.GetQuery: String;
begin
 Result := SQLqry;
end;

procedure TScoreFilter.New_pnlHolder;
begin
 SetLength(pnlHolders, NumberofClauses + 1);
 pnlHolders[NumberofClauses] := TPanel.Create(HolderParent);
 With pnlHolders[NumberofClauses] do
  begin
   Parent  := HolderParent;
   Top     := CurrentClause * 150;
   Align   := alTop;
   Caption := '';
   Height  := 150;
   Name    := 'pnlHolders_' + IntToStr(NumberofClauses);
   Caption := '';
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
   Left    := pnlHolders[NumberofClauses].Width - 25;
   Top     := 0;
   Width   := 25;
   Height  := 75;
   Name    := 'btnRemoveClause_' + IntToStr(NumberofClauses);
   Caption := '-';
   OnClick := btnRemoveClauseOnClick;
  end;

 With btnAddNewClause[NumberofClauses] do
  begin
   Parent  := pnlHolders[NumberofClauses];
   Anchors := [akRight,akBottom];
   Left    := pnlHolders[NumberofClauses].Width - 25;
   Top     := 75;
   Width   := 25;
   Height  := 75;
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
   Left     := 10;
   Top      := 10;
   Width    := 240;
   Name     := 'cmbFields_' + IntToStr(NumberofClauses);
   OnChange := cmbFieldsOnChange;
  end;
  DBTable.Close;
  CurrentCmbField    := 0;

  CurrentClause := NumberofClauses;

  DBTable.TableName  := GameTables.Items[GameTables.ItemIndex];
  DBTable.GetFieldNames(cmbFields[NumberofClauses].Items);
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
   Left     := 10;
   Top      := 58;
   Width    := 240;
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
   Left     := 10;
   Top      := 106;
   Width    := 240;
   Name     := 'edtInputInfo_' + IntToStr(NumberofClauses);
   Text     := '';
   OnChange := edtInputBoxChange;
  end;
end;

procedure TScoreFilter.New_dtkPicker;
begin
 SetLength(dtkPicker, NumberofClauses + 1);
 dtkPicker[NumberofClauses] := TDateTimePicker.Create(pnlHolders[NumberofClauses]);
 With dtkPicker[NumberofClauses] do
  begin
   Parent   := pnlHolders[NumberofClauses];
   Left     := 10;
   Top      := 106;
   Width    := 240;
   Name     := 'dtkPicker_' + IntToStr(NumberofClauses);
   OnChange := dtkPickerChange;
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
   Left     := 144;
   Top      := 106;
   Width    := 104;
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
 Changed := True;
end;

procedure TScoreFilter.DefaultSetUp;
begin
  edtInputInfo[CurrentClause].Show;
  edtInputInfo[CurrentClause].Width := 240;
  dtkPicker[CurrentClause].Hide;
  cmbTimeValues[CurrentClause].Hide;
  pnlHolders[CurrentClause].Height := 150;
  btnAddNewClause[CurrentClause].Height := 75;
  btnRemoveClause[CurrentClause].Height := 75;
  btnAddNewClause[CurrentClause].Top    := 75;
  btnRemoveClause[CurrentClause].Top    := 0;
end;

procedure TScoreFilter.cmbOperatorsOnChange(Sender: TObject);
var
 Op : string;
begin
 Op := TComboBox(Sender).Name;
 CurrentClause := StrToInt(Copy(Op, Pos('_', Op) + 1, Length(Op)  ));

 Op := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex];

 DefaultSetUp;
 if (Op = 'within last') or (cmbFields[CurrentClause].Items[cmbFields[CurrentClause].ItemIndex] = 'Time') then
  begin
   edtInputInfo[CurrentClause].Width := 137;
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
   pnlHolders[CurrentClause].Height := 100;
   btnAddNewClause[CurrentClause].Height := 50;
   btnRemoveClause[CurrentClause].Height := 50;
   btnAddNewClause[CurrentClause].Top    := 50;
   btnRemoveClause[CurrentClause].Top    := 0;
   edtInputInfo[CurrentClause].Hide;
   dtkPicker[CurrentClause].Hide;
   cmbTimeValues[CurrentClause].Hide;
  end else
 if (Op = 'between') or (Op = 'in range of') then
  begin
  end;

 Changed := True;
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
 New_dtkPicker;
 New_TimeValues;
 HolderParent.VertScrollBar.Position := CurrentClause * 150;
 Changed := True;
end;

procedure TScoreFilter.btnRemoveClauseOnClick(Sender: TObject);
var
 s : string;
begin
 s := TButton(Sender).Name;
 CurrentClause := StrToInt(Copy(s, Pos('_', s) + 1, Length(s)  ));
 pnlHolders[CurrentClause].Hide;
 dec(CurrentClause);
 if CurrentClause = 0 then inc(CurrentClause);
 Changed := True;
end;

procedure TScoreFilter.cmbTimeValuesChange(Sender: TObject);
begin
 Changed := True;
end;

procedure TScoreFilter.dtkPickerChange(sender: TObject);
begin
 Changed := True;
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
end;

procedure TScoreFilter.BuildQueryBASIC;
var
 i, cluases : integer;
 qryField, Op, condition, timeformat : string;
begin
 BASICqry := 'SELECT * ' + 'FROM [' + GameTables.Items[GameTables.ItemIndex] + ']' + ' WHERE ';
 cluases := 0;
 for i := Low(pnlHolders) + 1 to High(pnlHolders) do
  if pnlHolders[i].Showing then
   begin
    inc(cluases);
    qryField := '[' + cmbFields[i].Items[cmbFields[i].ItemIndex] + ']';
    Op       := cmbOperators[i].Items[cmbOperators[i].ItemIndex];
    condition := '';
    if edtInputInfo[i].Showing
     then
      condition := '(' + edtInputInfo[i].Text
     else
    if dtkPicker[i].Showing
     then
      condition := '(' + FormatDateTime('dd/mm/yyyy', dtkPicker[i].DateTime);

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

function ConvertBASICoptoSQLop(cond, op : string) : string;
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
   Result := 'BETWEEN #' + FormatDateTime('dd/mm/yyyy', StrToDate(cond)) + '# AND #' + FormatDateTime('dd/mm/yyyy', Date) + '#'
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
   Result := '= #'+ FormatDateTime('dd/mm/yyyy', Date) + '#'
  else
 if op = 'yesterday'
  then
   Result := '= #'+ DateToStr(Yesterday) + '#'
  else
 if op = 'this week'
  then
   Result := 'BETWEEN #' + FormatDateTime('dd/mm/yyyy', IncWeek(Date, -1)) + '# AND #' + FormatDateTime('dd/mm/yyyy', Date) + '#'
  else
 if op = 'this month'
  then
   Result := 'BETWEEN #' + FormatDateTime('dd/mm/yyyy', IncMonth(Date, -1)) + '# AND #' + FormatDateTime('dd/mm/yyyy', Date) + '#'
  else
 if op = 'this year'
  then
   Result := 'BETWEEN #' + FormatDateTime('dd/mm/yyyy', IncYear(Date, -1)) + '# AND #' + FormatDateTime('dd/mm/yyyy', Date) + '#';
 Showmessage(Result);
end;

function ConvertTimeStringtoTime(tme, tmeformat : string) : String;
var
 itime, i : integer;
 min, sec : string;
begin
 val(tme, itime, i);
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
   min    := Copy(tme, 1               , POS(':', tme) - 1);
   sec    := Copy(tme, POS(':', tme)    + 1, Length(tme));
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

procedure TScoreFilter.BuildQuerySQL;
var
 i : integer;
 qryField, Op, condition, timeformat : string;
begin
 SQLqry := 'SELECT * ' + 'FROM [' + GameTables.Items[GameTables.ItemIndex] + '] WHERE ';
 for i := Low(pnlHolders) + 1 to High(pnlHolders) do
  if pnlHolders[i].Showing then
   begin
    qryField := cmbFields[i].Items[cmbFields[i].ItemIndex];
    Op       := cmbOperators[i].Items[cmbOperators[i].ItemIndex];
    condition := '';
    if edtInputInfo[i].Showing
     then
      condition := edtInputInfo[i].Text
     else
    if (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'exactly') or (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'before') or (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'after')
     then
      condition := FormatDateTime('dd/mm/yyyy', dtkPicker[i].DateTime);

    timeformat := '';
    if (cmbOperators[i].Items[cmbOperators[i].ItemIndex] = 'within last') or (cmbFields[i].Items[cmbFields[i].ItemIndex] = 'Time')
     then
      timeformat := cmbTimeValues[i].Items[cmbTimeValues[i].ItemIndex];

    if timeformat <> ''
     then
      Condition := ConvertTimeStringtoTime(condition, timeformat);

    condition := ConvertBASICoptoSQLop(condition, op);

    if i = low(pnlHolders) + 1
     then
      SQLqry := SQLqry + '([' + qryField + '] ' + condition + ')'
     else
      SQLqry := SQLqry + ' AND ([' + qryField + '] ' + condition + ')'
   end;
   Showmessage(SQLqry);
end;

procedure TScoreFilter.LoadQuery(sName: string);
var
 txt : TextFile;
 sLine : string;
 Actualqry : string;
 tblName : string;
 i : integer;
 conditions : integer;
 y, m, d : Word;

 field, Op, Condition, tmfrmt : string;
begin
 ClearUp;
 CurrentClause := 1;
 NumberofClauses := 0;

 AssignFile(txt, 'BASIC_Queries.txt');
 if not FileExists('BASIC_Queries.txt') then
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

 Delete(Actualqry, 1, Pos('[', sLine) - 1);


 tblName := Copy(Actualqry, 1, Pos(']', Actualqry));
 delete(Actualqry, 1, 1);
 delete(Actualqry, length(Actualqry), 1);
 delete(tblName, 1, 1);
 delete(tblName, length(tblName), 1);
 GameTables.ItemIndex := GetItemPosFromText(GameTables, tblName);
 DBTable.Close;
 DBTable.TableName := GameTables.Items[GameTables.ItemIndex];
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
     edtInputInfo[i].Text      := Condition;

  end;

 Changed := false; 
end;

procedure TScoreFilter.LoadQueryNames(List : TStrings; tbl : string);
var
 sLine : string;
 txt   : TextFile;
begin
 List.Clear;
 AssignFile(txt, 'BASIC_Queries.txt');
 if not FileExists('BASIC_Queries.txt')
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
 BASIC_Queries : TextFile;
 qry, tblName : string;
begin
 AssignFile(BASIC_Queries, 'BASIC_Queries.txt');
 if FileExists('BASIC_Queries.txt')
  then
   Append(BASIC_Queries)
  else
   Rewrite(BASIC_Queries);
 tblName := Copy(BASICqry, Pos('[', BASICqry) + 1, Pos(']', BASICqry) - 1 - Pos('[', BASICqry));
 qry := tblName + '.' + qryName + BASICqry;
 WriteLn(BASIC_Queries, qry);
 CloseFile(BASIC_Queries);
end;

procedure TScoreFilter.SaveSQLQuery;
var
 SQL_Queries : TextFile;
 qry, tblName : string;
begin
 AssignFile(SQL_Queries, 'SQL_Queries.txt');
 if FileExists('SQL_Queries.txt')
  then
   Append(SQL_Queries)
  else
   Rewrite(SQL_Queries);

 tblName := Copy(SQLqry, Pos('[', SQLqry) + 1, Pos(']', SQLqry) - 1 - Pos('[', SQLqry));
 qry := tblName + '.' + qryName + '{' + SQLqry + '}';
 WriteLn(SQL_Queries, qry);

 CloseFile(SQL_Queries);
end;

procedure TScoreFilter.DeleteQueries(clx: TCheckListBox);
var
 i : integer;
 BASIC_Queries, txt2 : TextFile;
 sLine : string;
 IsToBeDeleted : Boolean;
begin
 AssignFile(BASIC_Queries, 'BASIC_Queries.txt');
 AssignFile(txt2, 'txt2.txt');
 if FileExists('BASIC_Queries.txt') then
  begin
   Reset(BASIC_Queries);
   Rewrite(txt2);
  end else
  begin
   Rewrite(BASIC_Queries);
   Exit;
  end;

 while not eof(BASIC_Queries) do
  begin
   ReadLn(BASIC_Queries, sLine);
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
  CloseFile(BASIC_Queries);
  DeleteFile('BASIC_Queries.txt');
  RenameFile('txt2.txt', 'BASIC_Queries.txt');
  Changed := false;
end;

procedure TScoreFilter.SaveQueries(sName: string);
begin
 qryName := sName;
 if Pos('.', qryName) > 0 then
  Delete(qryName, 1, Pos('.', qryName));
 SaveSQLQuery; ///////////////////////////////
 SaveBASICQuery;
 CurrentFilter := sName;
 Changed := false;
end;

procedure TScoreFilter.SaveQueries(clx: TChecklistBox);
var
 i : integer;
begin
 for i := 0 to clx.Items.Count - 1 do
  clx.Checked[i] := false;
 for i := 0 to clx.Items.Count - 1 do
  if clx.Items[i] = CurrentFilter
   then
    clx.Checked[i] := true;
 DeleteQueries(clx);
 SaveQueries(CurrentFilter);
end;

end.
