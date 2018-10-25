unit ToolBox_Controller;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, ExtCtrls, StdCtrls, jpeg, tools_Module, TabSetManagment_Module,
  ComCtrls, Gauges, Achievements_Controller, Achievements_Module;

type

  TfrmToolBox = class(TForm)
    lsbSuggestions: TListBox;
    pnlRefrence: TPanel;
    imgRefrenceBAck: TImage;
    imgSelectedRefrence: TImage;
    lblHangman: TLabel;
    lblThesaurus: TLabel;
    lblDictionary: TLabel;
    lblAnagram: TLabel;
    memRef: TMemo;
    pnlSearch: TPanel;
    imgSearchBack: TImage;
    lblSearch: TLabel;
    pnlBack: TPanel;
    pnlForward: TPanel;
    pnlSeperator: TPanel;
    tmrMoveSelTab: TTimer;
    tmrMoveTabs: TTimer;
    qryBuiltRef: TADOQuery;
    imgSuggestionBack: TImage;
    pnlBevel: TPanel;
    tmrProcessing: TTimer;
    pgbProcessing: TProgressBar;
    edtSearch: TEdit;
    procedure TabDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TabUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure lsbSuggestionsClick(Sender: TObject);
    procedure edtSearchEnter(Sender: TObject);
    procedure tmrMoveTabsTimer(Sender: TObject);
    procedure tmrMoveSelTabTimer(Sender: TObject);
    procedure edtSearchKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure pnlBackClick(Sender: TObject);
    procedure pnlForwardClick(Sender: TObject);
    procedure lblSearchClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrProcessingTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     TabSet : TTAbSet;
     Tools   : TToolBox;

     iHistory: Integer;
     sHistory: Array of String;

     CurrentRef : TLabel;
     procedure ChangeRefrence(ref : string; UpdatHistory: boolean);
     procedure DictionaryLayout;
     procedure SolverLayout;
     procedure ExecuteSearchSolve;
     procedure UpdateHistory;
     procedure LoadHistory;
  end;

var
  frmToolBox: TfrmToolBox;

implementation

uses Game_Controller;

{$R *.dfm}

procedure TfrmToolBox.ChangeRefrence(ref: string; UpdatHistory: boolean);
begin
 ref := Trim(ref);
 if CurrentRef <> nil
  then
   CurrentRef.Font.Color := clSilver;
 if ref = 'Dictionary' then
  begin
   CurrentRef := lblDictionary;
   DictionaryLayout;
  end else
 if ref = 'Thesaurus' then
  begin
   CurrentRef := lblThesaurus;
   DictionaryLayout;
  end else
 if ref = 'Hangman Solver' then
  begin
   CurrentRef := lblHangman;
   SolverLayout;
  end else
 if ref = 'Anagram Solver' then
  begin
   CurrentRef := lblAnagram;
   SolverLayout;
  end;
 CurrentRef.Font.Color := clWhite;
 if Assigned(CurrentRef) then
  begin
   Tools.ChangeSource(memRef, CurrentRef.Caption, edtSearch.Text);
   if UpdatHistory
    then
     UpdateHistory;
  end;
 tmrMoveSelTab.Enabled := true;
end;

procedure TfrmToolBox.TabDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 TabSet.MouseDown(Sender, Mouse.CursorPos.X);
 tmrMoveTabs.Enabled := false;
end;

procedure TfrmToolBox.TabMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 TabSet.MouseMove(Sender, tmrMoveTabs, mouse.CursorPos.X);
end;

procedure TfrmToolBox.TabUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not TabSet.MovedTabsEnough(tmrMoveTabs, pnlRefrence.Width, Mouse.CursorPos.X, TLabel(Sender), False) then
  begin
   ChangeRefrence(TLabel(Sender).Caption, True);
   ExecuteSearchSolve;
  end;
end;

procedure TfrmToolBox.FormCreate(Sender: TObject);
var
 Tabs : array[1..4] of TLabel;
begin
 Tools := TToolBox.Create(qryBuiltRef, lsbSuggestions);
 ChangeRefrence(lblDictionary.Caption, False);
 iHistory := -1;
 SetLength(sHistory, 0);
 Tabs[1] := lblDictionary;
 Tabs[2] := lblThesaurus;
 Tabs[3] := lblHangman;
 Tabs[4] := lblAnagram;
 TabSet := TTabSet.Create(tabs, imgSelectedRefrence, lblDictionary);
end;

procedure TfrmToolBox.lsbSuggestionsClick(Sender: TObject);
begin
 Tools.GetDefinition(memRef, lsbSuggestions.Items[lsbSuggestions.ItemIndex]);
end;

procedure TfrmToolBox.edtSearchEnter(Sender: TObject);
begin
 edtSearch.SelectAll;
end;

procedure TfrmToolBox.tmrMoveTabsTimer(Sender: TObject);
begin
 TabSet.TimerMove(tmrMoveTabs, pnlRefrence.Width);
end;

procedure TfrmToolBox.tmrMoveSelTabTimer(Sender: TObject);
begin
 HighlightTab(CurrentRef, imgSelectedRefrence, tmrMoveSelTab);
end;

procedure TfrmToolBox.edtSearchKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key in [VK_DOWN, VK_UP]
  then
   lsbSuggestions.SetFocus
  else
 if key = VK_RETURN then
  begin
   ExecuteSearchSolve;
  end;
end;

procedure TfrmToolBox.DictionaryLayout;
begin
 lsbSuggestions.Align := alLeft;
 lsbSuggestions.Left  := 0;
 pnlSeperator.Left    := lsbSuggestions.Width;

 pnlSeperator.Show;
 memRef.Show;
 lblSearch.Caption := 'Search';
end;

procedure TfrmToolBox.SolverLayout;
begin
 pnlSeperator.Hide;
 memRef.Hide;
 lblSearch.Caption := 'Solve';
 lsbSuggestions.Align := alNone;
 lsbSuggestions.Left := ClientWidth div 2 - lsbSuggestions.Width div 2;
 lsbSuggestions.Height := imgSuggestionBack.Height - 32;
 lsbSuggestions.Top    := imgSuggestionBack.Top + 16;
 lsbSuggestions.Anchors := [akTop, akBottom, akLeft, akRight];
end;

procedure TfrmToolBox.FormResize(Sender: TObject);
begin
 if not memRef.Showing then
  begin
    lsbSuggestions.Left := ClientWidth div 2 - lsbSuggestions.Width div 2;
  end;
end;

procedure TfrmToolBox.UpdateHistory;
begin
 Inc(iHistory);
 SetLength(sHistory, iHistory + 2);
 sHistory[iHistory] := Trim(CurrentRef.Caption) + ':' + edtSearch.text;
end;

procedure TfrmToolBox.LoadHistory;
var
 sTab, sText, sHist: string;
begin
 sHist := sHistory[iHistory];
 sTab  := Copy(sHist, 1, Pos(':', sHist) - 1);
 sText := Copy(sHist, Pos(':', sHist) + 1, MaxInt);
 ChangeRefrence(sTab, False);
 if (sTab = 'Dictionary') or (sTab = 'Thesaurus')
  then
   DictionaryLayout
  else
   SolverLayout;
 edtSearch.Text := sText;
 Tools.GetSuggestion(edtSearch.Text, memRef);
end;

procedure TfrmToolBox.pnlBackClick(Sender: TObject);
begin
 if iHistory > 0 then
  begin
   dec(iHistory);
   LoadHistory;
  end;
end;

procedure TfrmToolBox.pnlForwardClick(Sender: TObject);
begin
 if iHistory < High(sHistory) then
  begin
   inc(iHistory);
   LoadHistory;
  end;
end;

procedure TfrmToolBox.lblSearchClick(Sender: TObject);
begin
 ExecuteSearchSolve;
end;

procedure TfrmToolBox.ExecuteSearchSolve;
begin
 if ((frmWowGames.Anagram.GetCurrentWordSet = edtSearch.Text) and frmWoWGames.Anagram.GetHasStarted and (frmWoWGames.edtAnagramWord.Text <> ''))
     or ((frmWoWGames.HangMan.GetUserWordC = edtSearch.Text) and frmWoWGames.HangMan.GetHasStarted and (frmWoWGames.HangMan.GetUserWordC <> ''))
  then
   frmAchievements.AchievementComplete(Cheaters_Never_Prosper);
 pgbProcessing.Position := 0;
 tmrProcessing.Enabled := true;
 Tools.GetSuggestion(edtSearch.Text, memRef);
 UpdateHistory;
end;

procedure TfrmToolBox.FormDestroy(Sender: TObject);
begin
 Tools.SolverFinder.Terminate;
 Tools.SolverFinder := nil;
end;

procedure TfrmToolBox.tmrProcessingTimer(Sender: TObject);
var
 i: integer;
begin
 if Tools.OperationComplete then
  begin
   for i := 1 to (pgbProcessing.Max - pgbProcessing.Position) div 1000 do
    begin
     pgbProcessing.StepBy(1000);
     Sleep(2);
    end;
   pgbProcessing.Position := 0;
   tmrProcessing.Enabled := false;
   exit;
  end;
 pgbProcessing.StepIt;
end;

end.
