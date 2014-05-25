unit FrmChartExportToMYOBCashBook;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OSFont,
  StdCtrls,
  ovcbase,
  ovcef,
  ovcpb,
  ovcpf,
  Buttons,
  ExtCtrls,
  stDate;

type
  //----------------------------------------------------------------------------
  TExportChartFrmProperties = class
  private
    fExportBasicChart : boolean;
    fIncludeClosingBalances : boolean;
    fClosingBalanceDate: TStDate;
    fClientCode : string;
    fExportFileLocation : string;
    fAreGSTAccountSetup : boolean;
    fAreOpeningBalancesSetup : boolean;
  public
    property ExportBasicChart : boolean read fExportBasicChart write fExportBasicChart;
    property IncludeClosingBalances : boolean read fIncludeClosingBalances write fIncludeClosingBalances;
    property ClosingBalanceDate: TStDate read fClosingBalanceDate write fClosingBalanceDate;
    property ClientCode : string read fClientCode write fClientCode;
    property ExportFileLocation : string read fExportFileLocation write fExportFileLocation;
    property AreGSTAccountSetup : boolean read fAreGSTAccountSetup write fAreGSTAccountSetup;
    property AreOpeningBalancesSetup : boolean read fAreOpeningBalancesSetup write fAreOpeningBalancesSetup;
  end;

  //------------------------------------------------------------------------------
  TFrmChartExportToMYOBCashBook = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    SaveDialog: TSaveDialog;
    pnlMain: TPanel;
    lblExportText: TLabel;
    radExportFullChart: TRadioButton;
    radExportBasicChart: TRadioButton;
    chkIncludeClosingBalances: TCheckBox;
    lblClosingBalanceDate: TLabel;
    lblSaveEntriesTo: TLabel;
    edtSaveEntriesTo: TEdit;
    btnToFolder: TSpeedButton;
    OvcController: TOvcController;
    dteClosingBalanceDate: TOvcPictureField;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkIncludeClosingBalancesClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnToFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure dteClosingBalanceDateDblClick(Sender: TObject);
  private
    fOkPressed : boolean;
    fExportChartFrmProperties : TExportChartFrmProperties;
  protected
    procedure DoRebranding();
    function ValidateForm : boolean;
  public
    function Execute : boolean;

    property ExportChartFrmProperties : TExportChartFrmProperties read fExportChartFrmProperties write fExportChartFrmProperties;
  end;

  //----------------------------------------------------------------------------
  function ShowChartExport(w_PopupParent: Forms.TForm; aExportChartFrmProperties : TExportChartFrmProperties) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ImagesFrm,
  BKConst,
  YesNoDlg,
  glConst,
  BKHelp,
  GenUtils,
  stDatest,
  ErrorMoreFrm;

//------------------------------------------------------------------------------
function ShowChartExport(w_PopupParent: Forms.TForm; aExportChartFrmProperties : TExportChartFrmProperties) : boolean;
var
  MyDlg : TFrmChartExportToMYOBCashBook;
begin
  MyDlg := TFrmChartExportToMYOBCashBook.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode   := pmExplicit;
    MyDlg.ExportChartFrmProperties := aExportChartFrmProperties;

    BKHelpSetUp(MyDlg, BKH_Export_chart_to_COMPANY_NAME1_Essentials_Cashbook);
    Result := MyDlg.Execute;
  finally
    FreeAndNil(MyDlg);
  end;
end;

{ TFrmChartExportToMYOBCashBook }
//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if fOkPressed then
  begin
    fOkPressed := false;

    CanClose := ValidateForm();
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.chkIncludeClosingBalancesClick(Sender: TObject);
begin
  if chkIncludeClosingBalances.Checked then
  begin
    if not ExportChartFrmProperties.AreGSTAccountSetup then
    begin
      HelpfulErrorMsg('Please enter GST Control accounts for GST rates with a ' +
                      'percentage amount, Other Functions | GST Setup | Rates.',0);
      chkIncludeClosingBalances.Checked := false;
      Exit;
    end;
    if not ExportChartFrmProperties.AreOpeningBalancesSetup then
    begin
      if not (AskYesNo('Opening balances not been set',
                       'Opening balances have not been set under Data Entry | ' +
                       'Opening Balances. Would you like to continue?', dlg_yes, 0) = DLG_YES) then
      begin
        chkIncludeClosingBalances.Checked := false;
        Exit;
      end;
    end;
  end;

  dteClosingBalanceDate.Visible := chkIncludeClosingBalances.Checked;
  lblClosingBalanceDate.Visible := chkIncludeClosingBalances.Checked;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormActivate(Sender: TObject);
begin
  chkIncludeClosingBalancesClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.btnOkClick(Sender: TObject);
begin
  fOkPressed := true;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.btnToFolderClick(Sender: TObject);
begin
  SaveDialog.FileName := edtSaveEntriesTo.Text;
  if SaveDialog.Execute then
    edtSaveEntriesTo.Text := SaveDialog.FileName;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormCreate(Sender: TObject);
begin
  DoRebranding();
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.DoRebranding;
begin
  lblExportText.Caption := 'Export ' + BRAND_FULL_PRACTICE +
                           ' chart of accounts to .CSV file for import into MYOB Essentials Cashbook.';
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.dteClosingBalanceDateDblClick(
  Sender: TObject);
var
  ld: Integer;
begin
  if sender is TOVcPictureField then
  begin
    ld := TOVcPictureField(Sender).AsStDate;
    PopUpCalendar(TEdit(Sender),ld);
    TOVcPictureField(Sender).AsStDate := ld;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportToMYOBCashBook.ValidateForm: boolean;
begin
  if FileExists(edtSaveEntriesTo.Text) then
  begin
    if not (AskYesNo('Overwrite File','The file ' +
                    ExtractFileName(edtSaveEntriesTo.Text) +
                    ' already exists. Overwrite?', dlg_yes, 0) = DLG_YES) then
    begin
      Result := false;
      Exit;
    end;
  end;

  Result := true;
end;

//------------------------------------------------------------------------------
function TFrmChartExportToMYOBCashBook.Execute: boolean;
begin
  fOkPressed := false;
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);

  // Load Default Properties
  if Assigned(ExportChartFrmProperties) then
  begin
    Self.Caption := 'Export ' + ExportChartFrmProperties.ClientCode + '''s Chart of Accounts to MYOB Essentials Cashbook';

    if ExportChartFrmProperties.ExportBasicChart then
      radExportBasicChart.Checked := true
    else
      radExportFullChart.Checked := true;

    chkIncludeClosingBalances.Checked := ExportChartFrmProperties.IncludeClosingBalances;
    dteClosingBalanceDate.AsStDate := ExportChartFrmProperties.ClosingBalanceDate;
    edtSaveEntriesTo.Text := ExportChartFrmProperties.ExportFileLocation;
  end;

  Result := (ShowModal = mrOK);

  // if ok Save Properties
  if Result then
  begin
    if Assigned(ExportChartFrmProperties) then
    begin
      ExportChartFrmProperties.ExportBasicChart := (radExportBasicChart.Checked);
      ExportChartFrmProperties.IncludeClosingBalances := chkIncludeClosingBalances.Checked;
      ExportChartFrmProperties.ClosingBalanceDate := dteClosingBalanceDate.AsStDate;
      ExportChartFrmProperties.ExportFileLocation := edtSaveEntriesTo.Text;
    end;
  end;
end;

end.
