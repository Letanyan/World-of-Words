unit Tutorial_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, MPlayer, Gauges, ComCtrls,
  ButtonHandling_Module, Help_Module;

const
  WelcomeInstructions: Array[0..2] of string = (
   'Select a game. Drag the list if certain games are not shown',
   'Press New Game',
   'Set the game up, then press Start Game'
  );

  GeneralInstructions: Array[0..7] of string = (
   'Logout and go back to log in screen',
   'Get more back here to tutorial/help screen',
   'Open the tools screen',
   'View stats of all the games',
   'View your achivements',
   'Start a new game',
   'Quit the game you''re playing',
   'Play/Pause the the game you''re playing'
  );

  AnagramInstructions: Array[0..8] of string = (
   'Type a word here',
   'Using only these letters',
   'Press check when you''re done',
   'Click a word here to see the words you''ve made',
   'Or click here to see the current words made',
   'Click here when you''re stuck',
   'Don''t let this drop to 0',
   'This is your score for the whole game',
   'This shows how many words you still have to make for the current word'
  );

  BreakAndBuildInstructions: Array[0..5] of string = (
   'This is the word you are going to change',
   'Press the delete button under the letter you want to delete',
   'Press the insert button between the letters you want to insert into',
   'This is your original word',
   'Here is where all the words you''ve made are',
   'This is your score'
  );

  BuildAWordInstructions: Array[0..4] of string = (
   'Drag letters from here to the board',
   'Press here when you''re done making your word',
   'If you want to call back all your letters press Recall',
   'Still can''t make a word? then get a new set of letters but lose 10-points',
   'Don''t want to lose 10-points then skip a turn'
  );

  BuildEmInstructions: Array[0..2] of string = (
   'Make words here by dragging your mouse over the letters',
   'This is your current word with its score',
   'This is your score excluding the current word'
  );

  CrosswordInstructions: Array[0..3] of string = (
   'Click here to select the word you want to fill in',
   'Type out the word as you normally would',
   'Press check only when all your words are filled in',
   'Change the font size here to fit in the clues'
  );

  FindEmInstructions: Array[0..4] of string = (
   'Click letters to make a word',
   'Press clear to remove all letters',
   'This is your current word with its score',
   'Press check when you''re done making a word',
   'This is your score excluding the current word'
  );

  HangmanInstructions: Array[0..2] of string = (
   'Select a letter that you think is in the word',
   'If it''s not then you lose a life',
   'Else its placed and shown in your word'
  );

  WordCityInstructions: Array[0..3] of string = (
   'Move the shape into a position to make a word. Up rotates the shapes',
   'Keep in mind the next shape when placing the current one',
   'Here is each word you make',
   'Here is your score for the game'
  );

  WordRaceInstructions: Array[0..4] of string = (
   'Move your car foward to make a word',
   'If your stuck you can shuffle letters',
   'You can see what your word currently is',
   'When your word is made click submit',
   'This is youre score'
  );

  WordSearchInstructions: Array[0..1] of string = (
   'Look at a word you need to find from here',
   'Find the word and drag from it''s starting letter to it''s end letter to pick it'
  );

  SelectAGameInstructions: Array[0..1] of string = (
   'Click on the stats icon',
   'Choose a game from the drop down'
  );

  LoadQueryInstructions: Array[0..3] of string = (
   'Click on the stats icon',
   'Select "Load Query.."',
   'Select a game from the 2nd drop down',
   'Choose the query you want to load from the last drop down'
  );

  DeleteQueryInstructions: Array[0..3] of string = (
   'Click on the stats icon',
   'Select "Delete Query..."',
   'Select a game from the 2nd drop down',
   'Choose the query you want to Delete from the last drop down'
  );

  SelectFieldsInstructions: Array[0..5] of string = (
   'Click on the stats icon',
   'Select a game from the drop down',
   'Click the eye button',
   'Choose the field to show',
   'If you want you can apply a function to that field',
   'Press + the add another field'
  );

  SortingInstructions: Array[0..2] of string = (
   'Click on the stats icon',
   'Choose a game from the drop down',
   'Click a heading to sort by the that field. click again will change from ASC to DESC'
  );

  AddingClausesInstructions: Array[0..5] of string = (
   'Click on the stats icon',
   'Select a game from the drop down',
   'Click + button',
   'Choose the field to evaluate',
   'Select the operan to apply',
   'Input the value you want to apply'
  );

type
  TfrmTutorial = class(TForm)
    pnlNavigator: TPanel;
    imgNavigator: TImage;
    imgTutorial: TImage;
    lblInstructions: TLabel;
    cmbTutorial: TComboBox;
    tmrShow: TTimer;
    ggeTimer: TGauge;
    tmrProgress: TTimer;
    pnlHelp: TPanel;
    imgHelpBack: TImage;
    redHelp: TRichEdit;
    lsbHelp: TListBox;
    edtHelpSearch: TEdit;
    imgNext: TImage;
    imgPrevious: TImage;
    imgPlayPause: TImage;
    imgHelp: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmbTutorialChange(Sender: TObject);
    procedure tmrShowTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrProgressTimer(Sender: TObject);
    procedure imgPreviousClick(Sender: TObject);
    procedure imgPlayPauseClick(Sender: TObject);
    procedure imgNextClick(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
  private
    { Private declarations }
    InstCard: Integer;
    InstTtrl: String;
    CurrentInst: TStringList;
    procedure SetInstSet(Inst: string; iIndex: Integer);
    function GetDirectory: String;
    function LoadDirectory: boolean;

  public
    { Public declarations }
    Previous: TThemeButton;
    PlayPause: TThemeButton;
    Next: TThemeButton;
    btnHelp: TThemeButton;

    Help: THelp;

    procedure LoadIns(TutName:String; iIndex: Integer);
    procedure CleanUp;
    procedure SwitchTimers(IsOn: Boolean);
  end;

var
  frmTutorial: TfrmTutorial;

implementation

uses Game_Controller;

{$R *.dfm}

{ TfrmTutorial }

function TfrmTutorial.GetDirectory: String;
begin
 Result := 'Resources\Tutorial\' + InstTtrl + '\' + IntToStr(InstCard) + '.jpg';
end;

procedure TfrmTutorial.LoadIns(TutName:String; iIndex: Integer);
begin
 InstCard := 0;
 SwitchTimers(False);
 if iIndex = 1
  then
   Constraints.MaxHeight := 113
  else
   Constraints.MinHeight := 565;
 SetInstSet(TutName, iIndex);
 LoadDirectory;
 PlayPause.Dir := 'Pause Tutorial';
 SwitchTimers(True);
end;

function TfrmTutorial.LoadDirectory: boolean;
begin
 if FileExists(GetDirectory) then
  begin
   Result := True;
   imgTutorial.Picture.LoadFromFile(GetDirectory);
   lblInstructions.Caption := CurrentInst[InstCard];
  end else
  begin
   Result := false;
   SwitchTimers(False);
   if InstCard > 0
    then
     MessageDlg('End of Tutorial', mtInformation, [mbOK], 1);
  end;
end;

procedure TfrmTutorial.SetInstSet(Inst: string; iIndex: Integer);
var
 i: integer;
begin
 InstTtrl := Inst;
 CurrentInst.Clear;
 case iIndex of
  0 : for i := 0 to High(WelcomeInstructions) do
         CurrentInst.Add(WelcomeInstructions[i]);

  1 : for i := 0 to High(GeneralInstructions) do
         CurrentInst.Add(GeneralInstructions[i]);

  2 : for i := 0 to High(AnagramInstructions) do
         CurrentInst.Add(AnagramInstructions[i]);

  3 : for i := 0 to High(BreakAndBuildInstructions) do
         CurrentInst.Add(BreakAndBuildInstructions[i]);

  4 : for i := 0 to High(BuildAWordInstructions) do
         CurrentInst.Add(BuildAWordInstructions[i]);

  5 : for i := 0 to High(BuildEmInstructions) do
         CurrentInst.Add(BuildEmInstructions[i]);

  6 : for i := 0 to High(CrosswordInstructions) do
         CurrentInst.Add(CrosswordInstructions[i]);

  7 : for i := 0 to High(FindEmInstructions) do
         CurrentInst.Add(FindEmInstructions[i]);

  8 : for i := 0 to High(HangmanInstructions) do
         CurrentInst.Add(HangmanInstructions[i]);

  9 : for i := 0 to High(WordCityInstructions) do
         CurrentInst.Add(WordCityInstructions[i]);

  10 : for i := 0 to High(WordRaceInstructions) do
         CurrentInst.Add(WordRaceInstructions[i]);

  11 : for i := 0 to High(WordSearchInstructions) do
         CurrentInst.Add(WordSearchInstructions[i]);

  12 : for i := 0 to High(SelectAGameInstructions) do
         CurrentInst.Add(SelectAGameInstructions[i]);

  13 : for i := 0 to High(LoadQueryInstructions) do
         CurrentInst.Add(LoadQueryInstructions[i]);

  14 : for i := 0 to High(DeleteQueryInstructions) do
         CurrentInst.Add(DeleteQueryInstructions[i]);


  15 : for i := 0 to High(SelectFieldsInstructions) do
         CurrentInst.Add(SelectFieldsInstructions[i]);

  16 : for i := 0 to High(SortingInstructions) do
         CurrentInst.Add(SortingInstructions[i]);


  17 : for i := 0 to High(AddingClausesInstructions) do
         CurrentInst.Add(AddingClausesInstructions[i]);



 end;
end;

procedure TfrmTutorial.FormCreate(Sender: TObject);
begin
 CurrentInst := TStringList.Create;
 SendMessage(cmbTutorial.Handle, CB_SETDROPPEDWIDTH, 200, 0);
 InstCard := -1;
 InstTtrl := '';
 Help := THelp.Create(edtHelpSearch, lsbHelp, redHelp);

 Previous  := TThemeButton.Create(imgPrevious, 'Previous Tutorial', 'jpg');
 PlayPause := TThemeButton.Create(imgPlayPause, 'Play Tutorial', 'jpg');
 Next      := TThemeButton.Create(imgNext, 'Next Tutorial', 'jpg');
 btnHelp   := TThemeButton.Create(imgHelp, 'Help Tutorial', 'jpg');

 pnlHelp.Align := alClient;
 pnlHelp.Hide;
end;

procedure TfrmTutorial.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 SwitchTimers(false);
 frmWoWGames.Show;
end;

procedure TfrmTutorial.cmbTutorialChange(Sender: TObject);
begin
 LoadIns((Sender as TComboBox).Items[TComboBox(Sender).ItemIndex], (Sender as TComboBox).ItemIndex);
end;

procedure TfrmTutorial.tmrShowTimer(Sender: TObject);
begin
 inc(InstCard);
 ggeTimer.Progress := 0;
 if not LoadDirectory then
  begin
   InstCard := -1;
   PlayPause.Dir := 'Play Tutorial';
  end;
end;

procedure TfrmTutorial.CleanUp;
begin
 InstCard := -1;
 InstTtrl := '';
 cmbTutorial.ItemIndex := -1;
 SwitchTimers(False);
 imgTutorial.Picture.LoadFromFile('Resources\Tutorial\Background.jpg');
 if pnlHelp.Showing then imgHelpClick(nil);
end;

procedure TfrmTutorial.FormDestroy(Sender: TObject);
begin
 CurrentInst.Free;
end;

procedure TfrmTutorial.tmrProgressTimer(Sender: TObject);
begin
 ggeTimer.AddProgress(1);
end;

procedure TfrmTutorial.SwitchTimers(IsOn: Boolean);
begin
 tmrShow.Enabled := IsOn;
 tmrProgress.Enabled := IsOn;
 if not IsOn then
  begin
   PlayPause.Dir := 'Play Tutorial';
   ggeTimer.Progress := 0;
  end;
end;

procedure TfrmTutorial.imgPreviousClick(Sender: TObject);
begin
 SwitchTimers(False);
 if InstCard = -1 then exit;
 dec(InstCard);
 if not LoadDirectory then inc(InstCard);
end;

procedure TfrmTutorial.imgPlayPauseClick(Sender: TObject);
begin
 if InstTtrl = '' then exit;
 if PlayPause.Dir = 'Play Tutorial' then
  begin
   PlayPause.Dir := ('Pause Tutorial');
   if InstCard = -1
    then
     InstCard := 0;
   LoadDirectory;
   SwitchTimers(True);
  end else
  begin
   PlayPause.Dir := ('Play Tutorial');
   SwitchTimers(False);
  end;
end;

procedure TfrmTutorial.imgNextClick(Sender: TObject);
begin
 SwitchTimers(False);
 if InstCard = -1 then exit;
 inc(InstCard);
 if not LoadDirectory then dec(InstCard);
end;

procedure TfrmTutorial.imgHelpClick(Sender: TObject);
begin
 lblInstructions.Caption := '';
   SwitchTimers(False);
 if btnHelp.Dir = 'Help Tutorial'  then
  begin
   btnHelp.Dir := 'Close Help';
   pnlHelp.Show;
   cmbTutorial.Hide;
   imgPrevious.Hide;
   imgPlayPause.Hide;
   imgNext.Hide;
   edtHelpSearch.SetFocus;
  end else
  begin
   btnHelp.Dir := 'Help Tutorial';
   pnlHelp.Hide;
   imgNext.Show;
   imgPlayPause.Show;
   imgPrevious.Show;
   cmbTutorial.Show;
  end;
end;

end.
