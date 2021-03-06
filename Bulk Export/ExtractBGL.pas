unit ExtractBGL;

interface
uses
  ExtractCommon,
  Windows,
  Graphics;


function GetExtractVersion: Integer; stdcall;
procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;
function CheckFeature(const index, Feature: Integer): Integer; stdcall;

implementation

uses
  ExtractHelpers,
  Controls,
  frmBGLConfig,
  Forms,
  SysUtils,
  OmniXMLUtils,
  OmniXML,
  Classes;


const
  BGLXML = 0;

  keySeparateClientFiles = 'SeparateClientFiles';
  keyExtractPath = 'ExtractPath';
  keyExtractCode = 'ExtractCode';
  keyCodedOnly   = 'CodedOnly';

var // General Extract vars
   MyFont: TFont;

   OutputFileName: string;
   FilePerClient: Boolean;
   CodedOnly: Boolean;

   //Export Specific
   CurrentClientCode: string;
   CurrentAccount: string;
   CurrentContra: string;
   DefaultCode: string;
   DateText: string;

var
   FExtractFieldHelper: TExtractFieldHelper;

function  ExtractFieldHelper: TExtractFieldHelper;
begin
   if not Assigned(FExtractFieldHelper) then
      FExtractFieldHelper := TExtractFieldHelper.Create;

   Result := FExtractFieldHelper;
end;


//*****************************************************************************
//
//    REQUIRED EXPORTED FUNCTIONS
//
//*****************************************************************************

function GetExtractVersion: Integer; stdcall;
begin
   Result :=  Version_1;
end;

function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;
begin
   Result := False;
   case Index of
   BGLXML : begin
          EType.Index := BGLXML;
          EType.Code  := BGLXMLcode;
          EType.Description := 'BGL XML';
          EType.ExtractClass := ClassBase;
          Result := True;
      end;
   end;
end;

//*****************************************************************************
//
//    File Handeling
//
//*****************************************************************************

var
  FOutputDocument: IXMLDocument;
  BaseNode: IxmlNode;
  TransactionsNode: IxmlNode;

function OutputDocument :IXMLDocument;
begin
   if FOutputDocument = nil then begin
      FOutputDocument := CreateXMLDoc;
   end;

   Result := FOutputDocument;
end;


procedure StartFile;
begin
   OutputDocument.LoadXML(''); // Clear
   BaseNode := EnsureNode(OutputDocument,'BGL_Import_Export');
   SetNodeTextStr(BaseNode,'Supplier','BankLink');
   SetNodeTextStr(BaseNode,'Product','Simple Fund');
   SetNodeTextStr(BaseNode,'Import_Export_Version','3.4');

   TransactionsNode := nil;
end;

procedure SaveFile(Filename: string);
begin
   OutputDocument.Save(FileName,ofIndent);
end;


//*****************************************************************************
//
//   CONFIGUATION
//
//*****************************************************************************

function GetPrivateProfileText(anApp, AKey, Default, Inifile: string; bufsize: Integer = 400): string;
var LB: PChar;
begin
   Result := Default;
   if (Length(IniFile) = 0)
   or (Length(AnApp) = 0)
   or (Length(AKey) = 0) then
      Exit;

   GetMem(LB, bufsize);
   try
      GetPrivateProfileString(pchar(AnApp),pChar(AKey),pchar(Default),LB,bufsize,Pchar(IniFile));
      Result := string(LB);
   finally
      FreeMem(LB,bufsize);
   End;
End;

function FindExtractPath(Session: TExtractSession): string;
begin
   // Does not have a default, so I know if it has been set
   Result := '';
   if Session.IniFile <> nil then
     case Session.Index of
     BGLXML : Result :=  GetPrivateProfileText(BGLXMLcode,keyExtractPath, '', string(Session.IniFile));
     end;
end;

function GetExtractPath(Session: TExtractSession): string;
begin
   // Forces a default, so we have a strarting point
   Result := FindExtractPath(Session);

   if Result = '' then
      Result := ExtractFilePath(Application.ExeName) + 'BGl.xml';
end;

function DoBGLXMLConfig (var Session: TExtractSession): Integer; stdcall;
var ldlg: TBGLXMLConfig;
begin
   Result := er_Cancel; // Cancel by default
   ldlg := TBGLXMLConfig.Create(nil);
   try
      if Assigned(MyFont) then begin
         ldlg.Font.Assign(MyFont);
      end;
      ldlg.Caption := 'BGL XML Setup';
      ldlg.eFilename.Text := GetExtractPath(Session);
      ldlg.eClearing.Text := GetPrivateProfileText(BGLXMLcode, keyExtractCode,'998', Session.IniFile);
      ldlg.rbSplit.Checked := Bool(GetPrivateProfileInt(BGLXMLcode,keySeparateClientFiles,0,Session.IniFile));
      ldlg.ckCoding.Checked := Bool(GetPrivateProfileInt(BGLXMLcode,keyCodedOnly,0,Session.IniFile));
      if ldlg.ShowModal = mrOK then begin
         WritePrivateProfileString(BGLXMLcode,keyExtractPath,pchar(Trim(ldlg.eFilename.Text)), Session.IniFile);
         WritePrivateProfilestring(BGLXMLcode,keySeparateClientFiles,pchar(intToStr(Integer(ldlg.rbSplit.Checked))),Session.IniFile);

         DefaultCode := Trim(ldlg.eClearing.Text);
         WritePrivateProfileString(BGLXMLcode,keyExtractCode,pchar(DefaultCode), Session.IniFile);

         WritePrivateProfilestring(BGLXMLcode,keyCodedOnly,pchar(intToStr(Integer(ldlg.ckCoding.Checked))),Session.IniFile);
         CodedOnly := ldlg.ckCoding.Checked;
         Result := er_OK; // Extract path is set..
      end;
   finally
      ldlg.Free;
   end;
end;


function CheckFeature(const index, Feature: Integer): Integer; stdcall;
begin
   Result := 0;
   if Index = BGLXML then
      case Feature of
       tf_TransactionID : Result := tr_GUID;
       tf_TransactionType : begin
           if CodedOnly then
               Result := tr_Coded;
       end;

       //tf_BankAccountType : Result := tr_Contra;
       //tf_ClientType = 4;
      end;
end;

//*****************************************************************************
//
//   Local Export Event Helpers
//
//*****************************************************************************


function TrapException (var Session: TExtractSession; value: ProcBulkExport):Integer; stdcall;
begin  // Helper to trap any IO or other exeptions
   try
      Result := Value(Session);
   except
     on E: exception do begin
        Result := er_Abort;
        Session.Data := PChar(E.Message);
     end;
   end;
end;


function CleanTextField(const Value: string): string;
begin
   Result := ExtractFieldHelper.ReplaceQuotesAndCommas
             (
                ExtractFieldHelper.RemoveQuotes(Value)
             );
end;


//*****************************************************************************
//
//   SESSION Start Stop
//
//*****************************************************************************

function BGLSessionStart(var Session: TExtractSession): Integer; stdcall;
begin
   Result := er_OK;
   OutputFileName := FindExtractPath(Session);
   if OutputFileName = '' then
      if DoBGLXMLConfig(Session) = er_OK then
         OutputFileName := FindExtractPath(Session);


   if OutputFileName > '' then begin
      // Can Have a Go...
      FilePerClient := Bool(GetPrivateProfileInt(BGLXMLcode,keySeparateClientFiles,0,Session.IniFile));
      ExtractFieldHelper.SetFields(Session.Data);
      DateText := CleanTextField(ExtractFieldHelper.GetField(f_Date));

      if not FilePerClient then begin
         // Open File for the Whole session..
         OutputFileName := ExtractFilePath(OutputFileName)
                         + CleanTextField(ExtractFieldHelper.GetField(f_Code))
                         + '_BGLXML_'
                         + DateText
                         + '.xml';

         StartFile;
         SaveFile(OutputFileName); // Test if we can write it rather than find out too late
      end;

   end else
      Result := er_Cancel; // User must have canceled
end;



function SessionEnd(var Session: TExtractSession): Integer; stdcall;
begin
   if not FilePerClient  then
      FOutputDocument.Save(OutputFileName,ofIndent);

   FOutputDocument := nil;
   TransactionsNode := nil;
   //EntitiesNode := nil;
   Result := er_OK;
end;

//******************************************************************************
//
//   CLIENT Start Stop
//
//******************************************************************************


function ClientStart(var Session: TExtractSession): Integer; stdcall;
var ClientNode: IXMLNode;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   CurrentClientCode := CleanTextField(ExtractFieldHelper.GetField(f_Code));
   if FilePerClient then begin
      OutputFileName := ExtractFilePath(OutputFileName)
                      + CurrentClientCode
                      + '_BGLXML_'
                      + DateText
                      + '.xml';
      StartFile;
      SaveFile(OutputFileName); // Test if we can write it rather than find out at the end
   end;

   // Build the Entity Details for the Client
   ClientNode := OutputDocument.CreateElement('Entity_Details');
   BaseNode.AppendChild(ClientNode);

   SetNodeTextStr(ClientNode,'Entity_Code',CurrentClientCode);

   TransactionsNode := OutputDocument.CreateElement('Transactions');
   ClientNode.AppendChild(TransactionsNode);

   Result := er_OK;
end;

function ClientEnd (var Session: TExtractSession): Integer; stdcall;
begin
   if FilePerClient then
      SaveFile(OutputFileName);

   Result := er_OK;
end;

//******************************************************************************
//
//   ACCOUNT Start
//
//******************************************************************************

function AccountStart(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   CurrentAccount := CleanTextField(ExtractFieldHelper.GetField(f_Number));
   CurrentContra := CleanTextField(ExtractFieldHelper.GetField(f_ContraCode));
   Result := er_OK;
end;


//******************************************************************************
//
//   TRANSACTION / DISSECTION
//
//******************************************************************************


const // from bkConst // did not want to link it in...
   btBank            = 0; btMin = 0;
   btCashJournals    = 1;
   btAccrualJournals = 2;
   btGSTJournals     = 3;
   btStockJournals   = 4;          //non transferring
   btOpeningBalances = 5;          //non transferring
   btYearEndAdjustments = 6;       //non transferring
   btStockBalances = 7;

procedure WriteBGLFields(var Session: TExtractSession);
var LTrans: IXMLNode;

    procedure AddField(const Name,Value: string);
    begin
       if Value > '' then
          SetNodeTextStr(LTrans,Name,Value);
    end;

    procedure AddTaxClass(const Value: string);
    begin
       if Length(Value) > 0 then
          case Value[1] of
          '1' :AddField('GST_Rate','100%');
          '2' :AddField('GST_Rate','75%');
          //'3' :AddField('GST_Rate','48.5%');  // BGL Spec
          '3' :AddField('GST_Rate','46.5%');    // ATO See case 7664
          '4' :AddField('GST_Rate','0% (ITD)');
          '5' :AddField('GST_Rate','0% (ITA)');
          '6' :AddField('GST_Rate','GST Free');
          else AddField('GST_Rate','N/A');
          end
       else
          AddField('GST_Rate','N/A')
    end;

    procedure AddGuid(const Value: string);
    var id: string;
        i,o : integer;
    begin   //1234567890123456789
       id := '               ';
       o := Length(id);
       for i := Length(Value) downto 1 do begin
          if Value[i] in ['0'..'9', 'A'..'F'] then begin
             id[o] := Value[i];
             dec(o);
             if o < 1 then
                Break; // Thats all we can fit..
          end;
       end;
       AddField('Other_Reference',id);
    end;

    procedure AddCode(const Value: string);
    begin
       if Value = '' then
          AddField('Account_Code',DefaultCode)
       else
          AddField('Account_Code',Value);
    end;

    procedure AddText;
    var Ref, Nar: string;
    begin

        Nar := CleanTextField(ExtractFieldHelper.GetField(f_Narration));
        Ref := CleanTextField(ExtractFieldHelper.GetField(f_ChequeNo));
        if Ref > '' then
           if Nar > '' then
              Ref := Nar + ' BL Ref: ' + Ref
           else
              Ref := 'BL Ref: ' + Ref
        else
           Ref := Nar;

        AddField('Text',Ref);
    end;
begin
   LTrans := TransactionsNode.AppendChild(FOutputDocument.CreateElement('Transaction'));
   with ExtractFieldHelper do begin

     AddField('Transaction_Type','Other Transaction');
     AddField('Account_Code_Type','Simple Fund');

     AddGuid(Uppercase(GetField(f_TransID)));

     AddField('Bank_Account_No',CurrentAccount);

     if Session.AccountType = btBank then
        AddField('Transaction_Source','Bank Statement')
     else
        AddField('Transaction_Source','Journal');

     if Session.AccountType in [btBank,btCashJournals] then
        AddField('Cash','Cash')
     else
        AddField('Cash','Non Cash');

     AddCode(GetField(f_Code));

     AddField('Transaction_Date',GetField(f_Date));


     AddText;

     AddField('Amount',GetField(f_amount));
     AddField('GST',GetField(f_tax));
     AddTaxClass(GetField(f_TaxCode));

     AddField('Quantity',GetField(f_Quantity));

     // Supper fields
     AddField('CGT_Transaction_Date',GetField(f_CGTDate));
     AddField('Franked_Dividend',GetField(f_Franked));
     AddField('UnFranked_Dividend',GetField(f_UnFranked));
     AddField('Imputation_Credit',GetField(f_Imp_Credit));

     AddField('Tax_Free_Distribution',GetField(f_TF_Dist));

     AddField('Tax_Exempt_Distribution',GetField(f_TE_Dist));
     AddField('Tax_Defered_Distribution',GetField(f_TD_Dist));
     AddField('TFN_Credit',GetField(f_TFN_Credit));
     AddField('Foreign_Income',GetField(f_Frn_Income));
     AddField('Foreign_Credit',GetField(f_Frn_Credit));

     AddField('Expenses',GetField(f_OExpences));

     AddField('Indexed_Capital_Gain',GetField(f_CGI));
     AddField('Discount_Capital_Gain',GetField(f_CGD));
     AddField('Other_Capital_Gain',GetField(f_CGO));
     AddField('Member_Component',CleanTextField(GetField(f_MemComp)));

   end;
end;



function Transaction(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   case Session.Index of
   BGLXML:  WriteBGLFields(Session);
   end;
   Result := er_OK;
end;



//*****************************************************************************
//
//    MAIN EXPORTED EXPORT FUNCTION
//
//*****************************************************************************

function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
begin
   Result := er_NotImplemented; // Do not fail u
   case Session.ExtractFunction of

   ef_SessionStart  : case Session.Index of
                        BGLXML: Result := TrapException(Session,BGLSessionStart);
                      end;
   ef_SessionEnd    : Result := TrapException(Session,SessionEnd);

   ef_ClientStart   :Result := TrapException(Session,ClientStart);
   ef_ClientEnd     :Result := TrapException(Session,ClientEnd);
   ef_AccountStart  :Result := TrapException(Session,AccountStart);
   //ef_AccountEnd    :Result := TrapException(Session,Transaction);

   ef_Transaction   :Result := TrapException(Session,Transaction);
   ef_Dissection    :Result := TrapException(Session,Transaction);

   ef_CanConfig    : case Session.Index of
                       BGLXML: begin // Also Doubles as get initial settings...
                            DefaultCode := GetPrivateProfileText(BGLXMLcode, keyExtractCode,'998', Session.IniFile);
                            CodedOnly :=  GetPrivateProfileInt(BGLXMLcode,keyCodedOnly,0,Session.IniFile) = 1;
                            Result := er_OK;
                       end;
                     end;
   ef_DoConfig     : case Session.Index of
                       BGLXML: Result := DoBGLXMLConfig(Session);
                     end;

   end;

end;



//*****************************************************************************
//
//    Optional Export Procedures..
//
//*****************************************************************************


procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
begin
  if ApplicationHandle <> 0 then
     Application.Handle := ApplicationHandle;

  if Assigned(BaseFont) then begin
     if not assigned(MyFont) then
        MyFont := TFont.Create;
     // cannot use assign because the class is not the same.
     MyFont.Name :=  BaseFont.Name;
     MyFont.Height := BaseFont.Height;
  end;
end;


initialization
  FOutputDocument := nil;
  TransactionsNode := nil;
  BaseNode := nil;

  MyFont := nil;
  OutputFileName := '';
  CurrentClientCode := '';
  CurrentAccount := '';
  CurrentContra := '';
finalization
   OutputFileName := '';

   if assigned(MyFont) then begin
      MyFont.Free;
      MyFont := nil;
   end;

   if Application.Handle <> 0 then
      Application.Handle := 0;

   FOutputDocument := nil;
   TransactionsNode := nil;
   BaseNode := nil;
end.
