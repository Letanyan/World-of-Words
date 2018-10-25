unit AccountManagment_Controller;

interface

uses
  Windows, Messages, SysUtils, DateUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UserInfo_Module, DB, ADODB, Grids, DBGrids, jpeg,
  ExtCtrls, Mask, Menus, ButtonHandling_Module, BoardGames_Board__Module,
  Achievements_Controller, Achievements_Module, ToolBox_Controller;

type
  TfrmAccountManagment = class(TForm)
    edtUserName: TEdit;
    edtPassword: TEdit;
    qryUser: TADOQuery;
    tblGames: TADOTable;
    imgAccountBack: TImage;
    lblUserName: TLabel;
    lblPassword: TLabel;
    lblHelp: TLabel;
    tmrConfirmPasswordEnter: TTimer;
    tmrConfirmPasswordCancel: TTimer;
    imgHUB: TImage;
    imgRegister: TImage;
    imgLogin: TImage;
    imgConfirm: TImage;
    imgCancel: TImage;
    procedure FormCreate(Sender: TObject);
    procedure lblHelpClick(Sender: TObject);
    procedure LoginKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmrConfirmPasswordEnterTimer(Sender: TObject);
    procedure tmrConfirmPasswordCancelTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgRegisterClick(Sender: TObject);
    procedure imgLoginClick(Sender: TObject);
    procedure imgCancelClick(Sender: TObject);
    procedure imgConfirmClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    User : TUserAccount;

    Password : string;

    btnRegister, btnLogin, btnCancel, btnConfirm: TThemeButton;

    procedure Login;
    procedure NewAccount;
    procedure DeleteAccount;
    procedure SetUserNames;
    procedure SetUserName(brd: TBoard);
    procedure LoadGames;
  end;

var
  frmAccountManagment: TfrmAccountManagment;

implementation

uses Game_Controller, HighScoreUnit_Controller, TabSetManagment_Module, Admin_Controller,
     Tutorial_Controller;

{$R *.dfm}

function CorrectAdminPass : String;
begin
 Result := 'WOW';
end;

procedure TfrmAccountManagment.FormCreate(Sender: TObject);
begin
 User        := TUserAccount.Create;
 btnRegister := TThemeButton.Create(imgRegister, 'Register', 'ico');
 btnLogin    := TThemeButton.Create(imgLogin, 'Login', 'ico');
 btnCancel   := TThemeButton.Create(imgCancel, 'Cancel', 'ico');
 btnConfirm  := TThemeButton.Create(imgConfirm, 'Confirm', 'ico');
end;

{login WHERE}
procedure TfrmAccountManagment.Login;
    procedure LoginAchivement;
    begin
      if User.GetUserLogins >= 10
       then                                                             
        frmAchievements.AchievementComplete(Ten_Logins)
       else
      if User.GetUserLogins >= 50
       then
        frmAchievements.AchievementComplete(Fifty_logins)
       else
      if User.GetUserLogins >= 100
       then
        frmAchievements.AchievementComplete(Hundred_logins);
    end;

begin
 if (UpperCase(edtUserName.Text) = 'ADMIN') then
  if (edtPassword.Text = CorrectAdminPass) then
    begin
     frmAdmin.Show;
     frmAccountManagment.Hide;
     imgCancelClick(Self);
     exit;
    end else
   if (edtPassword.Text <> CorrectAdminPass) then
    begin
     MessageDlg('Wrong Password', mtError, [mbOK], 1);
     exit;
    end;

  User.Login(edtUserName.Text, edtPassword.Text);
  SetUserNames;
  frmToolBox.Show;
  frmWoWGames.LoadGeneralSettings;
  frmAchievements.LoadAchievements(edtUserName.Text);
  frmAchievements.FilterAchievementTiles;
  LoadGames;
  frmWoWGames.Show;
  frmAccountManagment.Hide;
  imgCancelClick(Self);
  LoginAchivement;
end;

{New User INSERT}
procedure TfrmAccountManagment.tmrConfirmPasswordEnterTimer(
  Sender: TObject);

  procedure IncTop(img: TImage);
  begin
   if img.Top > 100
    then
     img.Top := img.Top - 2;
  end;

begin
 frmAccountManagment.Enabled := false;
 if imgHUB.Top >= imgCancel.Top then
  imgHUB.Top := imgCancel.Top - 1;

 if edtUserName.Left < width
  then
   edtUserName.Left := edtUserName.Left + 5;

 if lblUserName.Left > -lblUserName.Width
  then
   lblUserName.Left := lblUserName.Left - 5;

 if lblPassword.Top > 24
  then
   lblPassword.Top := lblPassword.Top - 1;

 if edtPassword.Width < 313
  then
   edtPassword.Width := edtPassword.Width + 5;

 if edtPassword.Left > 16
  then
   edtPassword.Left := edtPassword.Left - 2;

 edtPassword.Text := '';

 if edtPassword.Top > 52
  then
   edtPassword.Top := edtPassword.Top - 1;

 IncTop(imgRegister);
 if imgRegister.Left < 173 * 2
  then
   imgRegister.Left := imgRegister.Left + 6;
 if imgRegister.Left > 173 * 2 then
  imgRegister.Left := 173 * 2;

 IncTop(imgLogin);
 if imgLogin.Left < 173 * 3
  then
   imgLogin.Left := imgLogin.Left + 6;
 if imgLogin.Left > 173 * 3 then
  imgLogin.Left := 173 * 3;

 IncTop(imgCancel);
 if imgCancel.Left < 0
  then
   imgCancel.Left := imgCancel.Left + 6;
 if imgCancel.Left > 0 then
  imgCancel.Left := 0;

 IncTop(imgConfirm);
 if imgConfirm.Left < 173
  then
   imgConfirm.Left := imgConfirm.Left + 6;
 if imgConfirm.Left > 173 then
  imgConfirm.Left := 173;

 if lblPassword.Caption = 'Confirm Password:' then
  begin
   if lblPassword.Width < 135
    then
     lblPassword.Width := lblPassword.Width + 2;

   if lblPassword.Left >  16
    then
     lblPassword.Left  := lblPassword.Left  - 2;
  end else
  begin
   if lblPassword.Width < 109
    then
     lblPassword.Width := lblPassword.Width + 2;

   if lblPassword.Left >  16
    then
     lblPassword.Left  := lblPassword.Left  - 2;
 end;


 if Height > 170
  then
   Height := Height - 1;

 if imgCancel.Left >= 0 then
  begin
   frmAccountManagment.Enabled := true;
   tmrConfirmPasswordEnter.Enabled := false;
   edtPassword.SetFocus;
   if Caption = 'Registration'
    then
     lblPassword.Caption := 'Confirm Password:'
    else
     lblPassword.Caption := 'New Password'; 
  end;
end;

procedure TfrmAccountManagment.tmrConfirmPasswordCancelTimer(
  Sender: TObject);

  procedure DecTop(img: TImage);
  begin
   if img.Top < 128
    then
     img.Top := img.Top + 2;
  end;

begin
 frmAccountManagment.Enabled := false;
 if imgHUB.Top <= imgCancel.Top
  then
   imgHUB.Top := imgCancel.top - 1;

 if edtUserName.Left > 104
  then
   edtUserName.Left := edtUserName.Left - 5;

 if lblUserName.Left < 16
  then
   lblUserName.Left := lblUserName.Left + 5;

 if lblPassword.Top < 72
  then
   lblPassword.Top := lblPassword.Top + 1;

 if edtPassword.Width > 225
  then
   edtPassword.Width := edtPassword.Width - 5;

 if edtPassword.Left < 104
  then
   edtPassword.Left := edtPassword.Left + 2;

 edtPassword.Text := '';

 if edtPassword.Top < 72
  then
   edtPassword.Top := edtPassword.Top + 1;

 DecTop(imgRegister);
 if imgRegister.Left > 0
  then
   imgRegister.Left := imgRegister.Left - 4;
 if imgRegister.Left < 0 then
  imgRegister.Left := 0;

 DecTop(imgLogin);
 if imgLogin.Left > 173
  then
   imgLogin.Left := imgLogin.Left - 4;
 if imgLogin.Left < 173 then
  imgLogin.Left := 173;

 DecTop(imgCancel);
 if imgCancel.Left > -346
  then
   imgCancel.Left := imgCancel.Left - 4;
 if imgCancel.Left < -346 then
  imgCancel.Left := -346;

 DecTop(imgConfirm);
 if imgConfirm.Left > -173
  then
   imgConfirm.Left := imgConfirm.Left - 4;
 if imgConfirm.Left < -173 then
  imgConfirm.Left := -173;

 if lblPassword.Width > 73 then
   lblPassword.Width := lblPassword.Width - 2;

 if lblPassword.Left < 26
  then
   lblPassword.Left := lblPassword.Left + 2;

 if frmAccountManagment.ClientHeight < 169 then
   Height := Height + 1;

 if imgCancel.Left <= -346 then
  begin
   frmAccountManagment.Enabled := true;
   tmrConfirmPasswordCancel.Enabled := false;
   if frmAccountManagment.Showing then edtUserName.SetFocus;
  end;
end;

procedure TfrmAccountManagment.NewAccount;
begin
 User.AddUser(edtUserName.Text, edtPassword.Text);
 Login;
 frmAchievements.AchievementComplete(Welcome);
 frmWoWGames.Hide;
 with frmTutorial do
  begin
   CleanUp;
   Show;
   MessageDlg('Close the form to start playing', mtInformation, [mbOk], 1);
  end;
end;

{remove account DELETE}
procedure TfrmAccountManagment.DeleteAccount;

    procedure ActualDelete;
    var
     choice, i : integer;

    begin
     choice := MessageDlg('Do you want to delete all your scores as well', mtConfirmation, mbYesNoCancel, 1);
     if choice in [mrYes, mrNo] then
      begin
       if choice = mrYes
        then
         User.DeleteAllScores(edtUserName.Text);
       User.DeleteAccount(edtUserName.Text);
       edtUserName.Text := '';
       edtPassword.Text := '';
       for i := 0 to 9 do
        DeleteFile(UpperCase(edtUserName.Text) + '-' + GameList[i] + '.GameSave');
      end;
    end;

begin
 if User.NameExists(edtUserName.Text) then
  begin
   if User.CorrectPassword(edtUserName.Text + '=' + edtPassword.Text)
    then
     ActualDelete
    else
     MessageDlg('Please check if you typed your Password in correctly', mtError, [mbOK], 1);
  end else
   MessageDlg('Please check if you typed your user name correctly', mtError, [mbOK], 1);
end;

procedure TfrmAccountManagment.lblHelpClick(Sender: TObject);
begin
 ShowMessage('How to Register'
             + #13 + 'Type a Username and Password, click register, retype your password and click confirm'
             + #13
             + #13 + 'How to Login'
             + #13 + 'Type your User Name and Password That you registerd with and press login'
             + #13
             + #13 + 'How to Delete an Account'
             + #13 + 'Press Delete Key with the details of the account you want to delete');
end;

procedure TfrmAccountManagment.LoginKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 if key = vk_Return then
  begin
   if imgConfirm.Left < 173 then
    begin
     if edtUserName.Text = ''
      then
       edtUserName.SetFocus
      else
     if edtPassword.Text = ''
      then
       edtPassword.SetFocus
      else
     if not User.CorrectPassword(edtUserName.Text + '=' + edtPassword.Text) then
      begin
       if User.NameExists(edtUserName.Text)
        then begin
         MessageDlg('Please check if you typed your Password in correctly', mtError, [mbOK], 1);
         edtPassword.SetFocus;
        end else
         if MessageDlg('Unable to Find an Account With This Name Would You Like To Create an Account', mtInformation, [mbYes, mbNo], 1) = mrYes
          then
           imgRegisterClick(Sender)
          else
           edtUserName.SetFocus; 
      end else
     if User.NameExists(edtUserName.Text)
      then
       imgLoginClick(Sender);
    end else
     imgConfirmClick(Sender);
  end else
 if key = VK_DELETE
  then
   DeleteAccount;
end;

procedure TfrmAccountManagment.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 if not frmWoWGames.CanClose(True) then
  begin
   Action := caNone;
   exit;
  end;

 With frmWoWGames do
  begin
   FreeAndNil(WordSearch);
   FreeAndNil(HangMan);
   FreeAndNil(BuildAWord);
   FreeAndNil(TabSet);
   FreeAndNil(FindEm);
   FreeAndNil(CrossWord);
   FreeAndNil(wordCity);
   FreeAndNil(BuildEm);
   FreeAndNil(WordRace);
   FreeAndNil(Anagram);
   FreeAndNil(BreakBuild);
  end;
 User.Free;
end;

procedure TfrmAccountManagment.imgRegisterClick(Sender: TObject);
begin
 if Pos('=', edtPassword.Text) <> 0
  then
   MessageDlg('Password Can''t Contain an "=" sign', mtError, mbOKCancel, 1)
  else
 if edtUserName.Text = ''
  then
   MessageDlg('To Register, type your details in first and then click register', mtError, [mbOK], 1)
  else
 if not User.NameExists(edtUserName.Text) then
  begin
   Password := edtPassword.Text;
   lblPassword.Caption := 'Confirm Password:';
   tmrConfirmPasswordCancel.Enabled := false;
   tmrConfirmPasswordEnter.Enabled  := true;
   Caption := 'Registration';
  end else
   MessageDlg('This User Name is Taken Please Choose Another', mtError, [mbOK], 1);
end;

procedure TfrmAccountManagment.imgLoginClick(Sender: TObject);
begin
 if User.NameExists(edtUserName.Text) then
  begin
   if User.CorrectPassword(edtUserName.Text + '=' + edtPassword.Text)
    then
     Login
    else
     MessageDlg('Please check if you typed your Password in correctly', mtError, [mbOK], 1);
  end else
   MessageDlg('Please check if you typed your user name correctly. If you have not registered just type a user name and password to register', mtError, [mbOK], 1);
end;

procedure TfrmAccountManagment.imgCancelClick(Sender: TObject);
begin
 lblPassword.Caption := 'Password:';
 tmrConfirmPasswordCancel.Enabled := true;
 tmrConfirmPasswordEnter.Enabled  := false;
 edtUserName.Text := '';
 Caption := 'Account Management';
end;

procedure TfrmAccountManagment.imgConfirmClick(Sender: TObject);
begin
 if Password = edtPassword.Text
  then
   NewAccount
  else
   MessageDlg('Incorrect Password', mtError, [mbOK], 1); 
end;

procedure TfrmAccountManagment.FormActivate(Sender: TObject);
begin
 edtUserName.SetFocus;
end;

procedure TfrmAccountManagment.SetUserName(brd: TBoard);
begin
 brd.SetUserName(UpperCase(edtUserName.Text));
end;

procedure TfrmAccountManagment.SetUserNames;
begin
 With frmWoWGames do
  begin
   SetUserName(Anagram);
   SetUserName(HangMan);
   SetUserName(WordSearch);
   SetUserName(BuildAWord);
   SetUserName(FindEm);
   SetUserName(CrossWord);
   SetUserName(WordCity);
   SetUserName(BuildEm);
   SetUserName(WordRace);
   SetUserName(BreakBuild);
  end;
end;

procedure TfrmAccountManagment.LoadGames;
begin
 With frmWoWGames do
  begin
   Anagram.LoadGame;
   HangMan.LoadGame;
   WordSearch.LoadGame;
   BuildAWord.LoadGame;
   FindEm.LoadGame;
   CrossWord.LoadGame;
   WordCity.LoadGame;
   BuildEm.LoadGame;
   WordRace.LoadGame;
   BreakBuild.LoadGame;
  end;
end;

end.

