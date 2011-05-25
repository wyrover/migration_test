unit AuditReportOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ReportDefs, ComCtrls, AuditMgr, DateSelectorFme,
  OSFont, ClientSelectFme, SYDEFS, ExtCtrls;

type
  TAuditReportType = (arSystem, arClient, arTest);
  TAuditSelection = (byAll, byClient, byTransactionType, byTransactionID);

  TAuditReportOptions = class(TObject)
  private
//    FClientSelectOptions: TClientSelectOptions;
    FDateTo: integer;
    FDateFrom: integer;
    FDestination: TReportDest;
    FAuditReportType: TAuditReportType;
    FTransactionID: integer;
    FTransactionType: Byte;
    FAuditSelection: TAuditSelection;
    FClientCode: string;
//    procedure SetClientSelectOptions(const Value: TClientSelectOptions);
    procedure SetDateFrom(const Value: integer);
    procedure SetDateTo(const Value: integer);
    procedure SetDestination(const Value: TReportDest);
    procedure SetAuditReportType(const Value: TAuditReportType);
    procedure SetTransactionID(const Value: integer);
    procedure SetTransactionType(const Value: Byte);
    procedure SetAuditSelection(const Value: TAuditSelection);
  public
    constructor Create;
    destructor Destroy; override;
//    function ClientInSelection(AClient: Pointer): Boolean;
    function AuditRecordInSelection(AAuditRecord: TAudit_Trail_Rec): Boolean;
    property ClientCode: string read FClientCode;
    property DateFrom : integer read FDateFrom write SetDateFrom;
    property DateTo   : integer read FDateTo write SetDateTo;
//    property ClientSelectOptions: TClientSelectOptions read FClientSelectOptions write SetClientSelectOptions;
    property Destination: TReportDest read FDestination write SetDestination;
    property AuditReportType: TAuditReportType read FAuditReportType write SetAuditReportType;
    property TransactionType: Byte read FTransactionType write SetTransactionType;
    property TransactionID: integer read FTransactionID write SetTransactionID;
    property AuditSelection: TAuditSelection read FAuditSelection write SetAuditSelection;
  end;

  TfrmAuditReportOption = class(TForm)
    PageControl1: TPageControl;
    tsSystem: TTabSheet;
    tsClient: TTabSheet;
    tsTesting: TTabSheet;
    Label11: TLabel;
    Label12: TLabel;
    ListView5: TListView;
    cbAuditTypes: TComboBox;
    btnByTxnType: TButton;
    Edit7: TEdit;
    btnByTxnID: TButton;
    btnSaveToCSV: TButton;
    btnCancel: TButton;
    ClientSelect: TFmeClientSelect;
    GroupBox2: TGroupBox;
    fmeDateSelector1: TfmeDateSelector;
    GroupBox3: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    ComboBox2: TComboBox;
    Edit2: TEdit;
    GroupBox4: TGroupBox;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    pnlSelectClient: TPanel;
    pnlSelectDate: TPanel;
    pnlSelectTransaction: TPanel;
    pnlButtons: TPanel;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    cbClientFileCodes: TComboBox;
    gbxReportPeriod: TGroupBox;
    DateSelector: TfmeDateSelector;
    GroupBox1: TGroupBox;
    rbSytemTransactionType: TRadioButton;
    rbSytemTransactionID: TRadioButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Button1: TButton;
    btnPrint: TButton;
    btnFile: TButton;
    btnPreview: TButton;
    procedure btnSaveToCSVClick(Sender: TObject);
    procedure btnByTxnTypeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnByTxnIDClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbSytemTransactionTypeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FBtnPressed : integer;
    function Validate: Boolean;
    procedure DisplayAuditRecords;
    procedure LoadAuditTypes(AAuditReportType: TAuditReportType);
    procedure LoadClientFileCodes;
    procedure DisplayAuditRecsByAuditType(AAuditType: TAuditType);
    procedure DisplayAuditRecsByTransactionID(ARecordID: integer);
  public
    { Public declarations }
  end;

  function GetAuditReportOptions(var AuditReportOptions: TAuditReportOptions): boolean;

implementation

uses
  Globals,
  bkXPThemes;

{$R *.dfm}

function GetAuditReportOptions(var AuditReportOptions: TAuditReportOptions): boolean;
var
  frmAuditReportOption: TfrmAuditReportOption;
  Margin: integer;
begin
  Result := False;
  frmAuditReportOption := TfrmAuditReportOption.Create(Application.MainForm);
  try
    with frmAuditReportOption do begin
      DisplayAuditRecords;
      LoadAuditTypes(AuditReportOptions.AuditReportType);
      case AuditReportOptions.AuditReportType of
        arSystem :
          begin
            //System
            Caption := frmAuditReportOption.tsSystem.Caption;
            pnlSelectClient.Visible := False;
          end;
        arClient :
          begin
            //Client
            Caption := tsClient.Caption;
            pnlSelectClient.Visible := True;
//            PageControl1.ActivePage := tsClient;
//            Margin := PageControl1.Margins.Left + tsClient.Margins.Left +
//                      tsClient.Left + GroupBox2.Left;
//            Width := Margin + GroupBox2.Width + Margin;
//            Height := (Height - ClientHeight) + Button2.Top +
//                      Button2.Height + Margin;
          end;
      end;

      PageControl1.ActivePage := tsSystem;
      Margin := PageControl1.Margins.Left +
                tsSystem.Margins.Left +
                tsSystem.Left +
                gbxReportPeriod.Left;
      Width := Margin + gbxReportPeriod.Width + Margin;
//      Height := (Height - ClientHeight) + btnPreview.Top +
//                btnPreview.Height + Margin;
      Height := (Height - ClientHeight) + pnlButtons.Top +
                pnlButtons.Height + Margin;

      DateSelector.eDateFrom.AsStDate := AuditReportOptions.DateFrom;
      DateSelector.eDateTo.AsStDate := AuditReportOptions.DateTo;
      rbSytemTransactionTypeClick(frmAuditReportOption);

      ShowModal;
      if FBtnPressed in [BTN_PREVIEW, BTN_PRINT, BTN_FILE] then begin
          with AuditReportOptions do begin
            DateFrom  := DateSelector.eDateFrom.AsStDate;
            DateTo    := DateSelector.eDateTo.AsStDate;
            AuditReportOptions.AuditSelection := byTransactionType;
            AuditReportOptions.TransactionType := byte(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
            if rbSytemTransactionID.Checked then
              AuditReportOptions.AuditSelection := byTransactionID;

            if ComboBox1.ItemIndex > 0 then
              AuditReportOptions.TransactionType := TAuditType(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
            if Edit1.Text <> '' then
              AuditReportOptions.TransactionID := StrToInt(Edit1.Text);

            if AuditReportOptions.AuditReportType = arClient then begin
              AuditReportOptions.FClientCode := cbClientFileCodes.Items[cbClientFileCodes.ItemIndex];            
//              ClientSelectOptions.ReportSort := ClientSelect.ReportSort;
//              ClientSelectOptions.RangeOption := ClientSelect.RangeOption;
//              ClientSelectOptions.FromCode := ClientSelect.edtFromCode.Text;
//              ClientSelectOptions.ToCode := ClientSelect.edtToCode.Text;
//              ClientSelectOptions.CodeSelectionList.DelimitedText := ClientSelect.edtSelection.Text;
            end;

            case FBtnPressed of
              BTN_PREVIEW :  Destination := rdScreen;
              BTN_PRINT   :  Destination := rdPrinter;
              BTN_FILE    :  Destination := rdFile;
            else
              Destination := rdNone;
            end;
          end;
          Result := True; 
      end;
    end;
  finally
    frmAuditReportOption.Free;
  end;
end;

{ TfrmAuditReportOption }

procedure TfrmAuditReportOption.btnByTxnIDClick(Sender: TObject);
begin
  DisplayAuditRecsByTransactionID(StrToInt(Edit7.Text));
end;

procedure TfrmAuditReportOption.btnByTxnTypeClick(Sender: TObject);
var
  AuditType: TAuditType;
begin
  //All
  if (cbAuditTypes.ItemIndex = 0) then begin
    DisplayAuditRecords;
    Exit;
  end;
  //Filter audit records by audit type
  AuditType := TAuditType(cbAuditTypes.Items.Objects[cbAuditTypes.ItemIndex]);
  DisplayAuditRecsByAuditType(AuditType);
end;

procedure TfrmAuditReportOption.btnFileClick(Sender: TObject);
begin
//  PageControl1.ActivePage := tsTesting;
//  BorderStyle := bsSizeable;
//  Position := poScreenCenter;
//  Height := 600;
//  Width := 900;
  if not Validate then
     Exit;
  FBtnPressed := BTN_FILE;
  Close;
end;

procedure TfrmAuditReportOption.btnPreviewClick(Sender: TObject);
begin
  FBtnPressed := BTN_PREVIEW;
  Close;
end;

procedure TfrmAuditReportOption.btnSaveToCSVClick(Sender: TObject);
var
  i, j: integer;
  StringList: TStringList;
  AuditRec: string;
begin
  StringList := TStringList.Create;
  try
    for i := 0 to ListView5.Items.Count - 1 do begin
      AuditRec := ListView5.Items[i].Caption;
      for j := 0 to ListView5.Items[i].SubItems.Count - 1 do begin
        AuditRec := AuditRec + ',' + ListView5.Items[i].SubItems[j];
      end;
      StringList.Add(AuditRec);
    end;
    StringList.SaveToFile('SYAudit.csv');
  finally
    StringList.Free
  end;
end;

procedure TfrmAuditReportOption.Button1Click(Sender: TObject);
begin
  FBtnPressed := BTN_NONE;
end;

procedure TfrmAuditReportOption.Button3Click(Sender: TObject);
begin
  if not Validate then
     Exit;
  FBtnPressed := BTN_FILE;
  Close;
end;

procedure TfrmAuditReportOption.DisplayAuditRecords;
var
  i: integer;
  ListItem: TListItem;
begin
  ListView5.Items.Clear;
  with AdminSystem.AuditTable.AuditRecords do
    for i := First to Last do begin
      ListItem := ListView5.Items.Add;
      ListItem.Caption := IntToStr(i);
      AdminSystem.AuditTable.SetAuditStrings(i, ListItem.SubItems);
    end;
end;

procedure TfrmAuditReportOption.DisplayAuditRecsByAuditType(
  AAuditType: TAuditType);
var
  i: integer;
  ListItem: TListItem;
  DB: string;
begin
  ListView5.Items.Clear;
  //Get DB
  DB := SystemAuditMgr.AuditTypeToDBStr(AAuditType);
  //Filter records by audit type
  with AdminSystem.AuditTable.AuditRecords do
    for i := First to Last do begin
      if AdminSystem.AuditTable.AuditRecords.Audit_At(i).atTransaction_Type = AAuditType then begin
        ListItem := ListView5.Items.Add;
        ListItem.Caption := IntToStr(i);
        AdminSystem.AuditTable.SetAuditStrings(i, ListItem.SubItems);
      end;
    end;
end;

procedure TfrmAuditReportOption.DisplayAuditRecsByTransactionID(
  ARecordID: integer);
var
  i: integer;
  ListItem: TListItem;
begin
  ListView5.Items.Clear;
  //System
  with AdminSystem.AuditTable.AuditRecords do
    for i := First to Last do begin
      if AdminSystem.AuditTable.AuditRecords.Audit_At(i).atRecord_ID = ARecordID then begin
        ListItem := ListView5.Items.Add;
        ListItem.Caption := IntToStr(i);
        AdminSystem.AuditTable.SetAuditStrings(i, ListItem.SubItems);
      end;
    end;
end;

procedure TfrmAuditReportOption.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  // #8 is Backspace
  if not (Key in [#8, '0'..'9']) then begin
    // Discard the key
    Key := #0;
  end;
end;

procedure TfrmAuditReportOption.FormCreate(Sender: TObject);
var
  i: integer;
begin
  bkXPThemes.ThemeForm( Self);

//  LoadAuditTypes;
  LoadClientFileCodes;

  for i := 0 to PageControl1.PageCount - 1 do
    PageControl1.Pages[i].TabVisible := False;

  //set date bounds
  DateSelector.InitDateSelect( MinValidDate, MaxValidDate, btnPreview);
  DateSelector.eDateFrom.asStDate := -1;
  DateSelector.eDateTo.asStDate   := -1;
  DateSelector.Last2Months1.Visible := False;
  DateSelector.btnQuik.Visible := true;
end;

procedure TfrmAuditReportOption.FormShow(Sender: TObject);
begin
  if DateSelector.eDateFrom.CanFocus then
    DateSelector.eDateFrom.SetFocus;
end;

procedure TfrmAuditReportOption.LoadAuditTypes(AAuditReportType: TAuditReportType);
var
  i: integer;
begin
  //Test
  cbAuditTypes.Clear;
  cbAuditTypes.Items.Add('<All>');
  for i := atMin to atMax do
    cbAuditTypes.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));

  //Normal
  ComboBox1.Clear;
  ComboBox1.Items.AddObject('<All>', TObject(atAll));
  case AAuditReportType of
    arSystem: for i := atMin to atMax do
                if SystemAuditMgr.AuditTypeToDBStr(i) = 'SY' then
                  ComboBox1.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
    arClient: for i := atMin to atMax do
                if SystemAuditMgr.AuditTypeToDBStr(i) = 'BK' then
                  ComboBox1.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
  end;
  ComboBox1.ItemIndex := 0;

{  //System
  ComboBox1.Clear;
  ComboBox1.Items.AddObject('<All>', TObject(atAll));
  for i := atMin to atMax do
    if SystemAuditMgr.AuditTypeToDBStr(i) = 'SY' then
      ComboBox1.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
  ComboBox1.ItemIndex := 0;

  //Client
  ComboBox2.Clear;
  ComboBox2.Items.AddObject('<All>', TObject(atAll));
  for i := atMin to atMax do
    if SystemAuditMgr.AuditTypeToDBStr(i) = 'BK' then
      ComboBox2.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
  ComboBox2.ItemIndex := 0; }
end;

procedure TfrmAuditReportOption.LoadClientFileCodes;
var
  i: integer;
begin
  cbClientFileCodes.Clear;
  if Assigned(AdminSystem) then
    for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
      cbClientFileCodes.Items.Add(AdminSystem.fdSystem_Client_File_List.Client_File_At(i).cfFile_Code);
end;

procedure TfrmAuditReportOption.rbSytemTransactionTypeClick(Sender: TObject);
begin
  ComboBox1.Enabled := rbSytemTransactionType.Checked;
  Edit1.Enabled := rbSytemTransactionID.Checked;  
end;

function TfrmAuditReportOption.Validate: Boolean;
begin
  Result := False;

  if not DateSelector.ValidateDates(true) then
    Exit;

  if not ClientSelect.Validate(True) then
    Exit;

  Result := True;
end;

{ TAuditReportOptions }

function TAuditReportOptions.AuditRecordInSelection(
  AAuditRecord: TAudit_Trail_Rec): Boolean;
begin
  Result := False;
end;

//function TAuditReportOptions.ClientInSelection(AClient: Pointer): Boolean;
//begin
//  Result := False;
//end;

constructor TAuditReportOptions.Create;
begin

end;

destructor TAuditReportOptions.Destroy;
begin

  inherited;
end;


procedure TAuditReportOptions.SetAuditReportType(const Value: TAuditReportType);
begin
  FAuditReportType := Value;
end;

procedure TAuditReportOptions.SetAuditSelection(const Value: TAuditSelection);
begin
  FAuditSelection := Value;
end;

//procedure TAuditReportOptions.SetClientSelectOptions(
//  const Value: TClientSelectOptions);
//begin
//  FClientSelectOptions := Value;
//end;

procedure TAuditReportOptions.SetDateFrom(const Value: integer);
begin
  FDateFrom := Value;
end;

procedure TAuditReportOptions.SetDateTo(const Value: integer);
begin
  FDateTo := Value;
end;

procedure TAuditReportOptions.SetDestination(const Value: TReportDest);
begin
  FDestination := Value;
end;

procedure TAuditReportOptions.SetTransactionID(const Value: integer);
begin
  FTransactionID := Value;
end;

procedure TAuditReportOptions.SetTransactionType(const Value: Byte);
begin
  FTransactionType := Value;
end;

end.
