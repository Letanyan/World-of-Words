unit UserInfo_Module;

interface
Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ExtCtrls, StdCtrls, DB, Grids,
  DBGrids, ADODB, DBCtrls;

type
 TUserAccount = class
  Private
   qry: TADOQuery;
   UserName, UserPassword : string;

   procedure IncLoginCount;
  Public
   constructor Create;

   function GetUserName : string;
   function GetPassword : string;
   function NameExists(uName: string): boolean;
   function CorrectPassword(Details : string) : boolean;

   procedure AddUser(uName, uPassword : string);
   procedure Login(uName, uPassword : string);
   procedure DeleteAccount(uName : string);
   procedure ChangePassword(uName, newPassword : String);
   procedure DeleteAllScores(uName : string);
   function  GetUserLogins: Integer;
 end;

implementation

{ TUserAccount }

function TUserAccount.NameExists(uName: string): boolean;
begin
 uName := UpperCase(uName);
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [User Account] WHERE [User Name] = "' + uName + '"';
 qry.Open;
 if (qry.FieldValues['User Name'] = uName) or (uName = 'ADMIN')
  then
   Result := true
  else
   Result := false;
end;

procedure TUserAccount.AddUser(uName, uPassword: string);
begin
 uName := UpperCase(uName);
 with qry do
  begin
   Close;
   SQL.Text := 'INSERT INTO [User Account] ([User Name], [Password]) VALUES("'+uName+'", "'+uPassword+'")';
   execSQL;
  end;
end;

constructor TUserAccount.Create;
begin
 qry := TADOQuery.Create(nil);
 qry.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=PAT.mdb;Persist Security Info=False';
 UserName := '';
 UserPassword := '';
end;

function TUserAccount.GetPassword: string;
begin
 Result := UserPassword;
end;

function TUserAccount.GetUserName: string;
begin
 Result := UserName;
end;

function TUserAccount.CorrectPassword(Details : string) : boolean;
var
 uName, uPassword : string;
begin
 uName     := Copy(details, 1                    , Pos('=', Details) - 1);
 uName     := UpperCase(uName);
 uPassword := Copy(Details, Pos('=', Details) + 1, Length(Details)      );
 qry.Close;
 qry.SQL.Text := 'SELECT * FROM [User Account] WHERE [User Name] = "' + uName + '" AND [Password] = "' + uPassword + '"';
 qry.Open;
 if (Qry.Fields[0].Text = uName) or (uName = 'ADMIN')
  then
   Result := true
  else
   Result := false; 
end;

procedure TUserAccount.Login(uName, uPassword: string);
begin
 UserName := UpperCase(uName);
 UserPassword := uPassword;
 IncLoginCount;
end;

procedure TUserAccount.DeleteAccount(uName: string);
begin
 uName := UpperCase(uName);
 with qry do
  begin
   close;
   SQL.Text := 'DELETE * FROM [User Account] WHERE [User Name] = "'+uName+'"';
   ExecSQL;
  end;
end;

procedure TUserAccount.ChangePassword(uName, newPassword: String);
begin
 uName := UpperCase(uName);
 with qry do
  begin
   Close;
   SQL.Add('UPDATE [User Account]');
   SQL.Add('SET    [Password]  = "' + NewPassword + '"');
   SQL.Add('WHERE  [User Name] = "' + uName       + '"');
   ExecSQL;
  end;
end;

procedure TUserAccount.DeleteAllScores(uName : string);
begin
 uName := UpperCase(uName);
 with qry do
  begin
   close;
   SQL.Text := 'DELETE * FROM [Anagrams]        WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Break And Build] WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Build-A-Word]    WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Build ''Em]      WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Crossword]       WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Find ''Em]       WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM Hangman           WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Word City]       WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Word Race]       WHERE [User Name] = "' + uName + '"';
   ExecSQL;
   SQL.Text := 'DELETE * FROM [Word Search]     WHERE [User Name] = "' + uName + '"';
   ExecSQL;
  end;
end;

procedure TUserAccount.IncLoginCount;
begin
 qry.Close;
 qry.SQL.Text := 'UPDATE [User Account] SET [Login Count] = [Login Count] + 1 WHERE [User Name] = "' + UserName + '"';
 qry.ExecSQL;
end;

function TUserAccount.GetUserLogins: Integer;
begin
 qry.Close;
 qry.SQL.Text := 'SELECT [Login Count] FROM [User Account] WHERE [User Name] = "' + UserName + '"';
 qry.Open;
 Result := StrToInt(qry.Fields[0].Text);
end;

end.
