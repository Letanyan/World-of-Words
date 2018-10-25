unit Achievements_Module;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls;

const
  CLR_GOLD    =  $0048A8C4;
  CLR_SILVER  =  clSilver;
  CLR_BRONZE  =  $002959BC;

  {All The Achievements as constants so no mistakes where made when calling it}

  {Account Managment 4}
    Welcome        = 'Welcome';
    Ten_Logins     = '10 Logins';
    Fifty_logins   = '50 Logins';
    Hundred_logins = '100 Logins';

  {Game Controller 6}
    Stop_The_Mockery = 'Stop the Mockery';
    Look_For_Help    = 'Look for Help';
    Statistician     = 'Statistician';
    Handyman         = 'Handyman';
    Take_A_Break     = 'Take a Break';
    Checking_Out     = 'Checking Out';

  {All Games 6}
    And_So_It_Begins      = 'And so it Begins';
    One_Hour_And_Counting = 'One Hour and Counting';
    One_Day_And_Counting  = 'One Day and Counting';
    One_Week_And_Counting = 'One Week and Counting';
    World_Traveler        = 'World Traveler';
    Quiter                = 'Quiter';

  {Anagram 4}
    You_Found_It           = 'You Found It';
    You_Actually_Found_All = 'You Actually Found All!';
    This_has_Gone_to_Far   = 'This has Gone to Far Now';
    You_Should_Try_Harder  = 'You Should Try Harder';

  {Break And Build 2}
    Thats_Pretty_Big             = 'That''s Pretty Big';
    Youre_Probably_Getting_Stuck = 'You''re Probably Getting Stuck';

  {Build-A-Word 5}
    Get_A_friend        = 'Get a Friend';
    Forever_Alone       = 'Forever Alone';
    Nothing_is_Wasted   = 'Nothing is Wasted';
    Master_Planner      = 'Master Planner';
    First_To_The_Finish = 'First to the Finish';

  {Build ''Em 4}
    Straight_As_An_Arrow = 'Straight as an Arrow';
    As_Long_As_Possible  = 'As Long as Possible';
    Double_Trouble       = 'Double Trouble';

  {Crossword 1}
    One_Check_Wonder = 'One Check Wonder';

  {Find 'Em 2}
    X_Marks_The_Spot = 'X Mark''s the Spot';
    On_The_Boarder   = 'On the Boarder';

  {ToolBox 1}
    Cheaters_Never_Prosper = 'Cheaters Never Prosper';

  {Game Settings 2}
    Worth_A_Reread = 'Worth a Re-Read';
    Never_Mind     = 'Never Mind';

  {Hangman 2}
    Not_A_Drop_of_Blood = 'Not a Drop of Blood';
    Out_Of_The_Norm     = 'Out of the Norm';

  {High Score Controller 1}
    Order_In_Court = 'Order in Court';

  {High Score Filter 6}
    The_Eye_Shows_All      = 'The Eye Shows all';
    Mathematician          = 'Mathematician';
    I_Can_Name_A_Function  = 'I Can Name a Function';
    I_Wanna_See_More       = 'I Wanna See More';
    Thats_More_Than_I_Need = 'That''s More than I Need';
    Picky_Picky            = 'Picky Picky';

  {Word City 2}
    That_Takes_Planning  = 'That Takes Planning';
    Two_Birds_One_Stone  = 'Two Birds with One Stone';

  {Word Race 2}
    Really_Already = 'Really? Already';
    You_Read_It    = 'You Read It';

  {Word Search 2}
    To_The_Limit       = 'To the Limit';
    No_Breathing_Space = 'No Breathing Space';


Type
  TLevel = (Gold, Silver, Bronze);

  TAchievementTile = Class
  private
    pnlTile                   : TPanel;
    lblHeading, lblDescription: TLabel;
    imgComplete, imgLevel     : TImage;
    FComplete                 : boolean;
    FLevel                    : TLevel;
    FHeading, FDescription    : string;

    procedure SetComplete(const Value: boolean);
    procedure SetDescription(const Value: string);
    procedure SetHeading(const Value: string);
    procedure SetLevel(const Value: TLevel);
  public
    Constructor Create(wParent: TScrollBox; lLevel: TLevel; sHeading, sDescription: string);
    Destructor  Free;

    function    GetLevel: string;  //Used for getting the directory of the glowing tick

    procedure   JustCompleted;     //Load the Glowing tick
    procedure   Hide;
    procedure   Show;

    property    Complete   : boolean Read FComplete    Write SetComplete;
    property    Heading    : string  Read FHeading     Write SetHeading;
    property    Description: string  Read FDescription Write SetDescription;
    property    Level      : TLevel  Read FLevel       Write SetLevel;
  end;

implementation

{ TAchievementTile }
constructor TAchievementTile.Create(wParent: TScrollBox; lLevel: TLevel;
  sHeading, sDescription: string);
begin
 pnlTile := TPanel.Create(nil);
 With pnlTile do
  begin
   Parent := wParent;
   Top    := MaxInt;
   Align  := alTop;
   Height := 65;
   case lLevel of
    Gold  : Color := CLR_GOLD;
    Silver: Color := CLR_SILVER;
    Bronze: Color := CLR_BRONZE;
   end;
  end;

 imgLevel := TImage.Create(nil);
 With imgLevel do
  begin
   Parent := pnlTile;
   Align  := alClient;
   Stretch := true;
   Picture.LoadFromFile('Resources\Tile.jpg');
  end;

 imgComplete := TImage.Create(nil);
 With imgComplete do
  begin
   Parent := pnlTile;
   Width  := 49;
   Height := 49;
   Left   := 10;
   Top    := 10;
  end;

 lblHeading := TLabel.Create(nil);
 With lblHeading do
  begin
   Parent      := pnlTile;
   Transparent := True;
   Font.Height := 25;
   Font.Color  := clWhite;
   Left        := 72;
   Top         := 8;
   Caption     := '';
  end;

 lblDescription := TLabel.Create(nil);
 With lblDescription do
  begin
   Parent      := pnlTile;
   Transparent := True;
   Font.Height := 15;
   Font.Color  := clWhite;
   Left        := 72;
   Top         := 40;
   Caption     := '';
  end;

 Heading     := sHeading;
 Description := sDescription;
 Complete    := false;
 Level       := lLevel;
end;

destructor TAchievementTile.Free;
begin
 FreeAndNil(lblHeading);
 FreeAndNil(lblDescription);
 FreeAndNil(imgComplete);
 FreeAndNil(pnlTile);
end;

function TAchievementTile.GetLevel: string;
begin
 case Level of
  Gold: Result := 'Gold';
  Silver: Result := 'Silver';
  Bronze: Result := 'Bronze';
 end;
end;

procedure TAchievementTile.Hide;
begin
 pnlTile.Hide;
end;

procedure TAchievementTile.JustCompleted;
begin
 imgComplete.Picture.LoadFromFile('Resources\Current ' + GetLevel + ' Tick.ico');
end;

procedure TAchievementTile.SetComplete(const Value: boolean);
begin
  FComplete := Value;
  if Value
   then
    imgComplete.Picture.LoadFromFile('Resources\' + GetLevel + ' Tick.ico')
   else
    imgComplete.Picture.LoadFromFile('Resources\' + GetLevel + ' Lock.ico');
end;

procedure TAchievementTile.SetDescription(const Value: string);
begin
  FDescription := Value;
  lblDescription.Caption := Value;
end;

procedure TAchievementTile.SetHeading(const Value: string);
begin
  FHeading := Value;
  lblHeading.Caption := Value;
end;

procedure TAchievementTile.SetLevel(const Value: TLevel);
begin
  FLevel := Value;
end;

procedure TAchievementTile.Show;
begin
 pnlTile.Show;
end;

end.
