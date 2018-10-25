unit GameSettings_Module;

interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Spin, jpeg, HangManGame_Module, ADODB,
  WordSearch_Module, UserInfo_Module, BuildAWord_module;

Type
  TGameSettings = class
   private
    FHowTo: String;
    procedure SetHowTo(const Value: String);
   protected
    procedure ChangeObjPos(obj : TControl; l, t, w, h : integer);
   public
    GamePlaying : String;
    property HowTo: String read FHowTo write SetHowTo;
    constructor Create(game : string);
  end;

  THangmanSettings = class(TGameSettings)
   sedMinLetters : TSpinEdit;
   sedMaxLetters : TSpinEdit;
   lblMinLetters : TLabel;
   lblMaxLetters : TLabel;

   Constructor Create(frm : TForm);
   Destructor  Free;
   Procedure   StartGame(hm : THangman; qry : TADOQuery; imgBoard : TIMage; lblWord : TLabel);
  end;

  TWordCitySettings = class(TGameSettings)
   lblTarget : TLabel;
   sedTarget: TSpinEdit;

   Constructor Create(frm : TForm);
   Destructor  Free;
  end;

  TBuildAWordSettings = class(TGameSettings)
   currentUser : string;

   tblUserName  : TADOTable;
   UserCheck    : TUserAccount;

   lblUserName2 : TLabel;
   cmbUserName2 : TComboBox;

   lblPassword2 : TLabel;
   edtPassword2 : TEdit;

   lblUserName3 : TLabel;
   cmbUserName3 : TComboBox;

   lblPassword3 : TLabel;
   edtPassword3 : TEdit;

   lblUserName4 : TLabel;
   cmbUserName4 : TComboBox;

   lblPassword4 : TLabel;
   edtPassword4 : TEdit;

   lblMode      : TLabel;
   cmbMode      : TComboBox;

   procedure   cmbUserNameChange(Sender: TObject);
   Constructor Create(frm : TForm; tbl : TADOTable; curUser : string);
   Destructor  Free;
   function    StartNewGame(qry : TADOQuery) : Boolean;
   procedure   SetUserNames(var u2, u3, u4: string);
  end;

  TWordSearchSettings = Class(TGameSettings)
   Private
    Procedure sedChanged(Sender : TObject);
   Public
    MaxChange : TNotifyEvent;

    sedDimensions : TSpinEdit;
    sedMinLetters : TSpinEdit;
    sedMaxLetters : TSpinEdit;
    sedTotalWords : TSpinEdit;

    lblDimensions : TLabel;
    lblMinLetters : TLabel;
    lblMaxLetters : TLabel;
    lblTotalWords : TLabel;

    Constructor Create(frm : TForm);
    Destructor  Free;
  end;

 TFindEmSettings = Class(TGameSettings)
  form : TForm;
  { Mode }
  lblMode : TLabel;
  cmbMode : TComboBox;
  { Time }
  lblTime : TLabel;
  cmbTime : TComboBox;
  { Dimension }
  lblDimensions : TLabel;
  sedDimensions : TSpinEdit;
  { Score }
  lblScore : TLabel;
  sedScore : TSpinEdit;
  { Limit of Words }
  lblWordLim : TLabel;
  sedWordLim : TSpinEdit;

  Time         : string;
  ScoreToReach : Integer;
  WordLimit    : Integer;

  Constructor Create(frm : TForm);
  Destructor  Free;
  procedure   cmbModeChange(Sender : TObject);
  procedure   sedScoreChange(Sender : TObject);
  procedure   sedWordLimChange(Sender : TObject);
  procedure   cmbTimeChange(Sender : TObject);
 end;

 TBuildEmSettings = Class(TFindEmSettings)
  Constructor Create(frm : TForm);
 end;

 TCrossWordSettings = Class(TGameSettings)
  private
    procedure cmbGameNameChange(Sender : TObject);
  public
  lblGameName : TLabel;
  cmbGameName : TComboBox;
  GameName    : string;

  Constructor Create(frm : TForm);
  Destructor  Free;
 end;

 TAnagramSettings = Class(TGameSettings)
   sedDifficulty : TSpinEdit;
   lblDifficulty : TLabel;

   Constructor Create(frm: TForm);
   Destructor  Free;
 end;

 TBreakBuildSettings = Class(TGameSettings)
   sedTime: TSpinEdit;
   lblTime: TLabel;

   Constructor Create(frm: TForm);
   Destructor  Free;
 end;

 TWordRace = Class(TFindEmSettings)

  lblTime: TLabel;
  cmbTime: TComboBox;

  Constructor Create(frm: TForm);
  Destructor  Free;
 end;

implementation

uses Math;

{ TGameSettings }

procedure TGameSettings.ChangeObjPos(obj: TControl; l, t, w, h: integer);
begin
 With Obj do
 begin
  Left   := l;
  Top    := t;
  if w <> 0 then width  := w;
  if w <> 0 then Height := h;
 end;
end;


constructor TGameSettings.Create(game: string);
begin
 GamePlaying := game;
end;

procedure TGameSettings.SetHowTo(const Value: String);
begin
  FHowTo := Value;
end;

{ THangmanSettings }

constructor THangmanSettings.Create(frm: TForm);
begin
 sedMinLetters := TSpinEdit.Create(frm);
 sedMinLetters.Parent := frm;

 sedMaxLetters := TSpinEdit.Create(frm);
 sedMaxLetters.Parent := frm;

 lblMinLetters := TLabel.Create(frm);
 lblMinLetters.Parent := frm;

 lblMaxLetters := TLabel.Create(frm);
 lblMaxLetters.Parent := frm;

 frm.Constraints.MaxHeight :=  250;
 frm.Constraints.MinHeight :=  250;

 ChangeObjPos(lblMaxLetters, 16, 56 , 103, 25);
 ChangeObjPos(lblMinLetters, 16, 104, 103, 25);

 ChangeObjPos(sedMaxLetters, 136, 56 , 121, 25);
 ChangeObjPos(sedMinLetters, 136, 104, 121, 25);


 sedMinLetters.MinValue := 3;
 sedMinLetters.MaxValue := 24;
 sedMinLetters.Value    := 4;

 sedMaxLetters.MaxValue := 25;
 sedMaxLetters.MinValue := 4;
 sedMaxLetters.Value    := 7;

 lblMinLetters.Caption := 'Min Letters';
 lblMaxLetters.Caption := 'Max Letters';

 lblMinLetters.Transparent := true;
 lblMaxLetters.Transparent := true;

 frm.Constraints.MaxHeight := 240;
end;

destructor THangmanSettings.Free;
begin
 sedMinLetters.Free;
 sedMaxLetters.Free;
 lblMinLetters.Free;
 lblMaxLetters.Free;
end;

procedure THangmanSettings.StartGame(hm : THangman; qry : TADOQuery; imgBoard : TIMage; lblWord : TLabel);
begin
 hm.Newgame(sedMinLetters.value, sedMaxLetters.Value);
 lblWord.Caption := hm.GetUserWord;
 //hm.DrawStand;
end;

{ TBuildAWord }

procedure TBuildAWordSettings.cmbUserNameChange(Sender: TObject);
    procedure ReOrder;
    var
     iChange: integer;
    begin
     iChange:= 56;  //40
     if TComboBox(Sender).ItemIndex = 0 then
      begin
       if TComboBox(Sender).Tag = 2 then
        begin
         edtPassword2.Hide;
         lblPassword2.Hide;
         cmbUserName3.Top := cmbUserName3.Top - iChange;
         lblUserName3.Top := lblUserName3.Top - iChange;
         edtPassword3.Top := edtPassword3.Top - iChange;
         lblPassword3.Top := lblPassword3.Top - iChange;
        end;
       if TComboBox(Sender).Tag in [2,3] then
        begin
         if TComboBox(Sender).Tag = 3 then
          begin
           edtPassword3.Hide;
           lblPassword3.Hide;
          end;
         cmbUserName4.Top := cmbUserName4.Top - iChange;
         lblUserName4.Top := lblUserName4.Top - iChange;
         edtPassword4.Top := edtPassword4.Top - iChange;
         lblPassword4.Top := lblPassword4.Top - iChange;
        end;
       if TComboBox(Sender).Tag = 4 then
        begin
         edtPassword4.Hide;
         lblPassword4.Hide;
        end;
       lblMode.Top := lblMode.Top - iChange;
       cmbMode.Top := cmbMode.Top - iChange;
       TComboBox(Sender).Parent.Height := TComboBox(Sender).Parent.Height - iChange;
      end else
      begin
       if (TComboBox(Sender).Tag = 2) and (not edtPassword2.Showing) then
        begin
         edtPassword2.Show;
         lblPassword2.Show;
         cmbUserName3.Top := cmbUserName3.Top + iChange;
         lblUserName3.Top := lblUserName3.Top + iChange;
         edtPassword3.Top := edtPassword3.Top + iChange;
         lblPassword3.Top := lblPassword3.Top + iChange;

         cmbUserName4.Top := cmbUserName4.Top + iChange;
         lblUserName4.Top := lblUserName4.Top + iChange;
         edtPassword4.Top := edtPassword4.Top + iChange;
         lblPassword4.Top := lblPassword4.Top + iChange;

         lblMode.Top := lblMode.Top + iChange;
         cmbMode.Top := cmbMode.Top + iChange;
         TComboBox(Sender).Parent.Height := TComboBox(Sender).Parent.Height + iChange;
        end;
       if (TComboBox(Sender).Tag  = 3) and (not edtPassword3.Showing) then
        begin
         edtPassword3.Show;
         lblPassword3.Show;
         cmbUserName4.Top := cmbUserName4.Top + iChange;
         lblUserName4.Top := lblUserName4.Top + iChange;
         edtPassword4.Top := edtPassword4.Top + iChange;
         lblPassword4.Top := lblPassword4.Top + iChange;
         lblMode.Top := lblMode.Top + iChange;
         cmbMode.Top := cmbMode.Top + iChange;
         TComboBox(Sender).Parent.Height := TComboBox(Sender).Parent.Height + iChange;
        end;
       if (TComboBox(Sender).Tag = 4) and (not edtPassword4.Showing) then
        begin
         edtPassword4.Show;
         lblPassword4.Show;
         lblMode.Top := lblMode.Top + iChange;
         cmbMode.Top := cmbMode.Top + iChange;
         TComboBox(Sender).Parent.Height := TComboBox(Sender).Parent.Height + iChange;
        end;
      end;
    end;

begin
 ReOrder;
 if TComboBox(Sender).ItemIndex = 1 then
  Case TComboBox(sender).Tag of
   2 : begin
        lblPassword2.Caption := 'User Name:';
        edtPassword2.PasswordChar := #0;
        edtPassword2.Color := clWhite;
       end;
   3 : begin
        lblPassword3.Caption := 'User Name:';
        edtPassword3.PasswordChar := #0;
        edtPassword2.Color := clWhite;
       end;
   4 : begin
        lblPassword4.Caption := 'User Name:';
        edtPassword4.PasswordChar := #0;
        edtPassword2.Color := clWhite;
       end;
  end else
  Case TComboBox(sender).Tag of
   2 : begin
        lblPassword2.Caption := 'Password:';
        edtPassword2.PasswordChar := '*';
        edtPassword2.Color := clWhite;
       end;
   3 : begin
        lblPassword3.Caption := 'Password:';
        edtPassword3.PasswordChar := '*';
        edtPassword3.Color := clWhite;
       end;
   4 : begin
        lblPassword4.Caption := 'Password:';
        edtPassword4.PasswordChar := '*';
        edtPassword4.Color := clWhite;
       end;
  end;
end;

constructor TBuildAWordSettings.Create(frm: TForm; tbl : TADOTable; curuser : string);

    procedure LoadUserNames(cmb : TComboBox);
    begin
     cmb.Items.Clear;
     cmb.Items.add('No Player');
     cmb.Items.add('Guest');
     tblUserName.Open;
     tblUserName.First;
     While not tblUserName.Eof do
      begin
       if UpperCase(curUser) <> tblUserName.FieldValues['User Name']
        then
         cmb.Items.Add(tblUserName.FieldValues['User Name']);
       tblUserName.Next;
      end;
     tblUserName.Close;
    end;

begin
 tblUserName := tbl;
 UserCheck := TUserAccount.Create;
 currentUser := curUser;

 {Player 2}

 lblUserName2 := TLabel.Create(frm);
 ChangeObjPos(lblUserName2, 45, 56, 110, 25);

 cmbUserName2 := TComboBox.Create(frm);
 ChangeObjPos(cmbUserName2, 136, 56, 129, 33);

 lblPassword2 := TLabel.Create(frm);
 ChangeObjPos(lblPassword2, 32, 96, 95, 25);

 edtPassword2 := TEdit.Create(frm);
 ChangeObjPos(edtPassword2, 136, 96, 129, 33);

 with lblUserName2 do
  begin
   Parent := frm;
   Transparent := true;
   Caption := 'Account:';
  end;

 with cmbUserName2 do
  begin
   Parent := frm;
   name := 'cmbUserName1';
   LoadUserNames(cmbUserName2);
   ItemIndex := 0;
   Tag := 2;
   OnChange := cmbUserNameChange;
  end;

 with lblPassword2 do
  begin
   Parent := frm;
   Transparent := true;
   Caption := 'Password:';
   Alignment := taRightJustify;
  end;

 with edtPassword2 do
  begin
   Parent := frm;
   Text := '';
   PasswordChar := '*';
  end;

 {Player 3}

 lblUserName3 := TLabel.Create(frm);
 ChangeObjPos(lblUserName3, 45, 152, 110, 25);

 cmbUserName3 := TComboBox.Create(frm);
 ChangeObjPos(cmbUserName3, 136, 152, 129, 33);

 lblPassword3 := TLabel.Create(frm);
 ChangeObjPos(lblPassword3, 32, 192, 95, 25);

 edtPassword3 := TEdit.Create(frm);
 ChangeObjPos(edtPassword3, 136, 192, 129, 33);

 with lblUserName3 do
  begin
   Parent := frm;
   Transparent := true;
   Caption := 'Account:';
  end;

 with cmbUserName3 do
  begin
   Parent := frm;
   name := 'cmbUserName2';
   LoadUserNames(cmbUserName3);
   ItemIndex := 0;
   Tag := 3;
   OnChange := cmbUserNameChange;
  end;

 with lblPassword3 do
  begin
   Parent := frm;
   Transparent := true;
   Caption := 'Password:';
   Alignment := taRightJustify;
  end;

 with edtPassword3 do
  begin
   Parent := frm;
   Text := '';
   PasswordChar := '*';
  end;

 {Player 4}

 lblUserName4 := TLabel.Create(frm);
 ChangeObjPos(lblUserName4, 45, 248, 110, 25);

 cmbUserName4 := TComboBox.Create(frm);
 ChangeObjPos(cmbUserName4, 136, 248, 129, 33);

 lblPassword4 := TLabel.Create(frm);
 ChangeObjPos(lblPassword4, 32, 288, 95, 25);

 edtPassword4 := TEdit.Create(frm);
 ChangeObjPos(edtPassword4, 136, 288, 129, 33);

 with lblUserName4 do
  begin
   Parent := frm;
   Transparent := true;
   Caption := 'Account:';
  end;

 with cmbUserName4 do
  begin
   Parent := frm;
   name := 'cmbUserName3';
   LoadUserNames(cmbUserName4);
   ItemIndex := 0;
   Tag := 4;
   OnChange := cmbUserNameChange;
  end;

 with lblPassword4 do
  begin
   Parent := frm;
   Transparent := true;
   Caption := 'Password:';
   Alignment := taRightJustify;
  end;

 with edtPassword4 do
  begin
   Parent := frm;
   Text := '';
   PasswordChar := '*';
  end;

 { Mode }
 lblMode := TLabel.Create(frm);
 ChangeObjPos(lblMode, 70, 344, 95, 25);

 cmbMode := TComboBox.Create(frm);
 ChangeObjPos(cmbMode, 136, 344, 129, 33);

 with lblMode do
  begin
   Parent := frm;
   Caption := 'Mode:';
   Transparent := true;
  end;

 With cmbMode do
  begin
   Parent := frm;
   Items.add('75-Point');
   Items.Add('150-Point');
   Items.Add('8-Turn');
   Items.Add('12-Turn');
   ItemIndex := 0;
  end;

 //frm.Constraints.MaxHeight :=  485;
 //frm.Constraints.MinHeight :=  485;
 frm.Height := 485;

 cmbUserNameChange(cmbUserName2);
 cmbUserNameChange(cmbUserName3);
 cmbUserNameChange(cmbUserName4);
{ frm.Constraints.MaxWidth  :=  295;
 frm.Constraints.MinWidth  :=  295;    }

end;

destructor TBuildAWordSettings.Free;
begin
 FreeAndNil(lblUserName2);
 FreeAndNil(lblPassword2);
 FreeAndNil(cmbUserName2);
 FreeAndNil(edtPassword2);

 FreeAndNil(lblUserName3);
 FreeAndNil(lblPassword3);
 FreeAndNil(cmbUserName3);
 FreeAndNil(edtPassword3);

 FreeAndNil(lblUserName4);
 FreeAndNil(lblPassword4);
 FreeAndNil(cmbUserName4);
 FreeAndNil(edtPassword4);

 FreeAndNil(lblMode);
 FreeAndNil(cmbMode);
end;

procedure TBuildAWordSettings.SetUserNames(var u2, u3, u4: string);

    procedure SetOne(cmb: TComboBox; edt: TEdit; var u: string);
    begin
     if (cmb.ItemIndex = 1) then
      begin
       if edt.Text = ''
        then
         u := 'Guest ' + IntToStr(cmb.tag)
        else
         u := edt.Text; 
      end else
      if cmb.ItemIndex > -1
       then
        u := cmb.Items[cmb.ItemIndex];
    end;

begin
 SetOne(cmbUserName2, edtPassword2, u2);
 SetOne(cmbUserName3, edtPassword3, u3);
 SetOne(cmbUserName4, edtPassword4, u4);
end;

function TBuildAWordSettings.StartNewGame(qry : TADOquery) : boolean;

    procedure NotCorrect(cmb : TComboBox; edt : TEdit);
    begin
     if cmb.ItemIndex > 1 then
      if not UserCheck.CorrectPassword(cmb.Items[cmb.Itemindex] + '=' + edt.Text) then
       begin
        edt.Color := $007171FF;
        result := false;
       end;
    end;

begin
 Result := true;

 NotCorrect(cmbUserName2, edtPassword2);
 NotCorrect(cmbUserName3, edtPassword3);
 NotCorrect(cmbUserName4, edtPassword4);

end;

{ TWordSearchSettings }

procedure TWordSearchSettings.sedChanged(Sender: TObject);
begin
 if Sender is TSpinEdit
  then
   if TSpinEdit(Sender).Name = 'sedMinLetters'
    then
     Parameters(sedMinLetters, sedMaxLetters, sedDimensions, sedTotalWords, 'S')
    else
   if TSpinEdit(Sender).Name = 'sedMaxLetters'
    then
     Parameters(sedMinLetters, sedMaxLetters, sedDimensions, sedTotalWords, 'L')
    else
     Parameters(sedMinLetters, sedMaxLetters, sedDimensions, sedTotalWords, ' ');
end;

constructor TWordSearchSettings.Create(frm: TForm);
begin
 sedDimensions        := TSpinEdit.Create(frm);
 sedDimensions.Parent := frm;
 sedDimensions.Name   := 'sedDimensions';

 sedMinLetters        := TSpinEdit.Create(frm);
 sedMinLetters.Parent := frm;
 sedMinLetters.Name   := 'sedMinLetters';

 sedMaxLetters        := TSpinEdit.Create(frm);
 sedMaxLetters.Parent := frm;
 sedMaxLetters.Name   := 'sedMaxLetters';

 sedTotalWords        := TSpinEdit.Create(frm);
 sedTotalWords.Parent := frm;
 sedTotalWords.Name   := 'sedTotalWords';

 {///////}

 lblDimensions        := TLabel.Create(frm);
 lblDimensions.Parent := frm;

 lblMinLetters        := TLabel.Create(frm);
 lblMinLetters.Parent := frm;

 lblMaxLetters        := TLabel.Create(frm);
 lblMaxLetters.Parent := frm;

 lblTotalWords        := TLabel.Create(frm);
 lblTotalWords.Parent := frm;

 frm.Constraints.MaxHeight :=  485;
 frm.Constraints.MinHeight :=  485;
{ frm.Constraints.MaxWidth  :=  300;
 frm.Constraints.MinWidth  :=  300;     }

 ChangeObjPos(lblDimensions, 16, 56 , 0, 0);
 ChangeObjPos(lblMinLetters, 16, 128, 0, 0);
 ChangeObjPos(lblMaxLetters, 16, 200, 0, 0);
 ChangeObjPos(lblTotalWords, 16, 272, 0, 0);

 ChangeObjPos(sedDimensions, 16, 80 , 250, 35);
 ChangeObjPos(sedMinLetters, 16, 152, 250, 35);
 ChangeObjPos(sedMaxLetters, 16, 224, 250, 35);
 ChangeObjPos(sedTotalWords, 16, 296, 250, 35);

 sedDimensions.MinValue := 10;
 sedDimensions.MaxValue := 60;
 sedDimensions.Value    := 10;

 sedMinLetters.MinValue := 3;
 sedMinLetters.MaxValue := 14;
 sedMinLetters.Value    := 3;

 sedMaxLetters.MinValue := 4;
 sedMaxLetters.MaxValue := 15;
 sedMaxLetters.Value    := 5;

 sedTotalWords.MinValue := 3;
 sedTotalWords.MaxValue := 15;
 sedTotalWords.Value    := 5;

 lblDimensions.Caption := 'Dimensions:';
 lblMinLetters.Caption := 'Minimum Letters:';
 lblMaxLetters.Caption := 'Maximum Letters:';
 lblTotalWords.Caption := 'Total Words:';

 lblDimensions.Transparent := true;
 lblMinLetters.Transparent := true;
 lblMaxLetters.Transparent := true;
 lblTotalWords.Transparent := true;

 sedDimensions.OnChange := sedChanged;
 sedMinLetters.OnChange := sedChanged;
 sedMaxLetters.OnChange := sedChanged;
 sedTotalWords.OnChange := sedChanged;

end;

destructor TWordSearchSettings.Free;
begin
 sedDimensions.Free;
 sedMinLetters.Free;
 sedMaxLetters.Free;
 sedTotalWords.Free;
 lblDimensions.Free;
 lblMinLetters.Free;
 lblMaxLetters.Free;
 lblTotalWords.Free;
end;

{ TFindEmSettings }

procedure TFindEmSettings.cmbModeChange(Sender: TObject);
var
 mode : string;
begin
 FreeAndNil(lblScore);
 FreeAndNil(sedScore);
 FreeAndNil(lblTime);
 FreeAndNil(cmbTime);
 FreeAndNil(lblWordLim);
 FreeAndNil(sedWordLim);

 form.Constraints.MaxHeight :=  405;
 form.Constraints.MinHeight :=  405;
 form.Constraints.MaxWidth  :=  300;
 form.Constraints.MinWidth  :=  300;

 mode := TComboBox(sender).Items[TComboBox(sender).ItemIndex];

 if (mode = 'Classic') or (mode = 'On a Schedule') then   //Create Time
  begin
   lblTime := TLabel.Create(form);
   cmbTime := TComboBox.Create(form);

   ChangeObjPos(lblTime, 24, 232, 46, 25);
   ChangeObjPos(cmbTime, 24, 264, 225, 33);

   with lblTime do
    begin
     Parent      := form;
     Caption     := 'Time';
     Transparent := true;
    end;

   with cmbTime do
    begin
     Parent := form;
     Items.Add('1 Minute');
     Items.Add('2 Minutes');
     Items.Add('3 Minutes');
     Items.Add('4 Minutes');
     Items.Add('5 Minutes');
     Items.Add('10 Minutes');
     Items.Add('15 Minutes');
     Items.Add('20 Minutes');
     Items.Add('30 Minutes');
     OnChange := cmbTimeChange;
     ItemIndex := 1;
    end;
    Time := '2 minutes';
  end;
 if (mode = 'On a Schedule') or (mode = 'Puzzle') then              //Create Score
  begin
   lblScore := TLabel.Create(form);
   sedScore := TSpinEdit.Create(form);

   ChangeObjPos(lblScore, 24, 320, 54, 25);
   ChangeObjPos(sedScore, 24, 354, 225, 33);

   with lblScore do
    begin
     Parent      := form;
     Caption     := 'Score To Reach';
     Transparent := true;
    end;

   with sedScore do
    begin
     Parent    := form;
     MaxValue  := 500;
     MinValue  := 25;
     OnChange  := sedScoreChange;
     Value     := 50;
    end;
   ScoreToReach := 50;
   form.Constraints.MaxHeight :=  485;
   form.Constraints.MinHeight :=  485;
  end;
 if (mode = 'Puzzle') then                 //Create Word Limit
  begin
   lblWordLim := TLabel.Create(form);
   sedWordLim := TSpinEdit.Create(form);

   ChangeObjPos(lblWordLim, 24, 232, 46, 25);
   ChangeObjPos(sedWordLim, 24, 264, 225, 33);

   with lblWordLim do
    begin
     Parent      := form;
     Caption     := 'Word Limit';
     Transparent := true;
    end;

   with sedWordLim do
    begin
     Parent    := form;
     MaxValue  := 50;
     MinValue  := 5;
     OnChange  := sedWordLimChange;
     Value     := 10;
    end;

   WordLimit := 10;
  end;
end;

procedure TFindEmSettings.cmbTimeChange(Sender: TObject);
begin
 Time := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex];
end;

constructor TFindEmSettings.Create(frm : TForm);
begin
 form := frm;

 lblMode := TLabel.Create(frm);
 cmbMode := TComboBox.Create(frm);

 ChangeObjPos(lblMode, 24, 56, 46, 25);
 ChangeObjPos(cmbMode, 24, 88, 225, 33);

 with lblMode do
  begin
   Parent      := frm;
   Caption     := 'Mode';
   Transparent := true;
  end;

 with cmbMode do
  begin
   Parent := frm;
   Items.Add('Classic');         //Get points until time runs out
   Items.Add('On a Schedule');   //Get to a certain score before time runs out
   Items.Add('Puzzle');          //Get to a certain score with limited words
   OnChange := cmbModeChange;
   ItemIndex := 0;
  end;


 lblDimensions := TLabel.Create(frm);
 sedDimensions := TSpinEdit.Create(frm);

 ChangeObjPos(lblDimensions, 24, 144, 106, 25);
 ChangeObjPos(sedDimensions, 24, 176, 225, 35);

 with lblDimensions do
  begin
   Parent      := frm;
   Caption     := 'Dimensions';
   Transparent := true;
  end;

 with sedDimensions do
  begin
   Parent    := frm;
   MaxValue  := 5;
   MinValue  := 3;
   Value     := 4;
  end;

 lblTime := TLabel.Create(form);
 cmbTime := TComboBox.Create(form);

 ChangeObjPos(lblTime, 24, 232, 46, 25);
 ChangeObjPos(cmbTime, 24, 264, 225, 33);

 with lblTime do
  begin
   Parent      := form;
   Caption     := 'Time';
   Transparent := true;
  end;

 with cmbTime do
  begin
   Parent := form;
   Items.Add('1 Minute');
   Items.Add('2 Minutes');
   Items.Add('3 Minutes');
   Items.Add('4 Minutes');
   Items.Add('5 Minutes');
   Items.Add('10 Minutes');
   Items.Add('15 Minutes');
   Items.Add('20 Minutes');
   Items.Add('30 Minutes');
   OnChange := cmbTimeChange;
   ItemIndex := 1;
  end;

 frm.Constraints.MaxHeight :=  405;
 frm.Constraints.MinHeight :=  405;

 ScoreToReach := 0;
 WordLimit    := 0;
 Time := '2 minutes';
end;

destructor TFindEmSettings.Free;
begin
 FreeAndNil(lblMode);
 FreeAndNil(cmbMode);
 FreeAndNil(lblTime);
 FreeAndNil(cmbTime);
 FreeAndNil(lblDimensions);
 FreeAndNil(sedDimensions);
 FreeAndNil(lblScore);
 FreeAndNil(sedScore);
 FreeAndNil(lblWordLim);
 FreeAndNil(sedWordLim);
end;

procedure TFindEmSettings.sedScoreChange(Sender: TObject);
var
 s: string;
 i: integer;
begin
 s := TSpinEdit(sender).Text;
 val(s, ScoreToReach, i);
end;

procedure TFindEmSettings.sedWordLimChange(Sender: TObject);
begin
 WordLimit := TSpinEdit(Sender).Value;
end;

{ TCrossWordSettings }

procedure TCrossWordSettings.cmbGameNameChange(Sender: TObject);
begin
 if cmbGameName.ItemIndex > -1
  then
   GameName := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex]
  else
   GameName := '';
end;

constructor TCrossWordSettings.Create;
    procedure getCrosswordNames(List : TStrings);
    var
     txt : TextFile;
     s   : string;
    begin
     AssignFile(txt, 'Templates.crswrd');
     if FileExists('Templates.crswrd')
      then
       Reset(txt)
      else
       exit;
     while not eof(txt) do
      begin
       readLn(txt, s);
       if s <> ''
        then
       if s[1] = '-'
        then
         List.Add(Copy(s, 2, length(s)));
      end;
    end;

begin
 lblGameName := TLabel.Create(frm);
 cmbGameName := TComboBox.Create(frm);

 ChangeObjPos(lblGameName, 24, 56, 100, 25);
 ChangeObjPos(cmbGameName, 24, 88, 233, 33);

 With lblGameName do
  begin
   parent := frm;
   Caption := 'Name';
   Transparent := true;
  end;

 With cmbGameName do
  begin
   parent := frm;
   getCrosswordNames(cmbGameName.Items);
   ItemIndex := 0;
   OnChange := cmbGameNameChange;
  end;

 frm.Constraints.MaxHeight := 300;
 frm.Constraints.MinHeight := 300;

 GameName := 'Level 1';

 frm.Constraints.MaxHeight := 240;
end;

destructor TCrossWordSettings.Free;
begin
 FreeAndNil(lblGameName);
 FreeAndNil(cmbGameName);
end;

{ TWordCitySettings }

constructor TWordCitySettings.Create(frm: TForm);
begin
 lblTarget := TLabel.Create(frm);
 with lblTarget do
  begin
   Parent := frm;
   Caption := 'Target Score';
   Transparent := true;
  end;
 ChangeObjPos(lblTarget, 24, 56, 0, 0);

 sedTarget := TSpinEdit.Create(frm);
 with sedTarget do
  begin
   Parent := frm;
   Value     := 500;
   MaxValue  := 5000;
   MinValue  := 100;
   Increment := 10;
  end;
 ChangeObjPos(sedTarget, 24, 88, 233, 33);

 frm.Constraints.MaxHeight := 240;

end;

destructor TWordCitySettings.Free;
begin
 FreeAndNil(sedTarget);
 FreeAndNil(lblTarget);
end;

{ TBuildEmSettings }

constructor TBuildEmSettings.Create(frm: TForm);
begin
 Inherited;
 With sedDimensions do
  begin
   MaxValue := 15;
   MinValue := 5;
   Value := 10;
  end;
end;

{ TAnagramSettings }

constructor TAnagramSettings.Create(frm: TForm);
begin
 sedDifficulty := TSpinEdit.Create(frm);
 sedDifficulty.Parent := frm;

 lblDifficulty := TLabel.Create(frm);
 lblDifficulty.Parent := frm;

 frm.Constraints.MaxHeight :=  250;
 frm.Constraints.MinHeight :=  250;

 ChangeObjPos(lblDifficulty, 16, 56 , 103, 25);

 ChangeObjPos(sedDifficulty, 136, 56 , 121, 25);


 sedDifficulty.MinValue := 1;
 sedDifficulty.MaxValue := 5;
 sedDifficulty.Value    := 5;

 lblDifficulty.Caption := 'Difficulty';

 lblDifficulty.Transparent := true;

 frm.Constraints.MaxHeight := 240;
end;

destructor TAnagramSettings.Free;
begin
  FreeAndNil(sedDifficulty);
  FreeAndNil(lblDifficulty);
end;

{ TBreakBuildSettings }

constructor TBreakBuildSettings.Create(frm: TForm);
begin

 sedTime := TSpinEdit.Create(nil);
 With sedTime do
  begin
   Parent   := frm;
   MinValue := 1;
   MaxValue := 10;
   Value    := 3;
  end;

 ChangeObjPos(sedTime, 136, 56, 121, 25);

 lblTime := TLabel.Create(nil);
 With lblTime do
  begin
   Parent      := frm;
   Transparent := True;
   Caption     := 'Time (Min)';
  end;

 ChangeObjPos(lblTime, 16, 56 , 103, 25);

 frm.Constraints.MaxHeight := 240;
end;

destructor TBreakBuildSettings.Free;
begin
  FreeAndNil(sedTime);
  FreeAndNil(lblTime);
end;

{ TWordRace }

constructor TWordRace.Create(frm: TForm);
begin
 frm.Constraints.MaxHeight :=  240;
 {Time}
 lblTime := TLabel.Create(nil);
 With lblTime do
  begin
   Parent      := frm;
   Transparent := True;
   Caption     := 'Time';
  end;

 ChangeObjPos(lblTime, 16, 56 , 103, 25);

 cmbTime := TComboBox.Create(nil);
 With cmbTime do
  begin
   Parent   := frm;
   Items.Add('1 Minute');
   Items.Add('2 Minutes');
   Items.Add('3 Minutes');
   Items.Add('4 Minutes');
   Items.Add('5 Minutes');
   Items.Add('10 Minutes');
   Items.Add('15 Minutes');
   Items.Add('20 Minutes');
   Items.Add('30 Minutes');
   ItemIndex := 4;
  end;

 ChangeObjPos(cmbTime, 154, 56, 121, 25);
end;

destructor TWordRace.Free;
begin
 FreeAndNil(lblTime);
 FreeAndNil(cmbTime);
end;

end.
