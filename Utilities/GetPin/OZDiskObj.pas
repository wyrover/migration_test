unit OZDiskObj;

// ----------------------------------------------------------------------------
interface uses NFDiskObj,
  dbObj,
  BaseDisk,
  Classes;
// ----------------------------------------------------------------------------

type
  TOZDisk = class(TNewFormatDisk)
  protected
    function SaveToRT86Stream: TMemoryStream;
    procedure LoadFromRT86Stream(var RT86Stream: TMemoryStream);
    function GetZipStream(const FileName: string): TMemoryStream;
  private
  public
    procedure Validate; override;
    function CanAddAccount: Boolean; override;
    function CanAddTransaction: Boolean; override;
    procedure SaveToFileOF(const FileName: string; const Attachments: TStringList); override;
    function LoadFromFileOF(const FileName: string;
      const AttachmentDir: string;
      const GetAttachments: Boolean): TStringList; override;
    { ------------------------------------------------------------------------ }
    procedure NewDisk(ClientCode, ClientName: string; CreatDate: integer;
      FileName, TrueFileName: string; DiskNo, SeqNo: integer);
    procedure AddAccount(Number, OriginalNumber, Name, FileCode, CostCode, BankCode,
      BankName, Currency: string;
      OpBalance: Int64; IsNew: Boolean;
      accLRN,instID: integer;
      FrequencyID: integer;
      InternalAccNumber: string='');
    procedure AddTransaction(var DBA: TDisk_Bank_Account;
      TransID: Integer; TransType: Byte;
      Amount, GSTAmount, Quantity: Int64; EffDate, OrigDate: Integer;
      TypeCode, DefaultCode, Reference, Narration: string);
  end;

  // ----------------------------------------------------------------------------
implementation uses SysUtils,
  OZTypes,
  DiskUtils,
  VCLZip,
  CRC32,
  CRCFileUtils,
  StDate,
  StDateSt,
  StStrS,
  CryptX,
  dtList,
  FHDEFS, (* ProcUtils, *)
  FHDTIO,
  FHExceptions,
  NFUtils;
// ----------------------------------------------------------------------------

const
  MaxAccounts = 255;
  MaxTransactions = 8000;

  { TOZDisk }

function TOZDisk.CanAddAccount: Boolean;
begin
  raise Exception.Create('TOZDisk.CanAddAccount should never be called');
  (*
  if dhFields.dhCountry_Code <> whAustralia then
    raise FHDataValidationException.CreateFmt('TOZDisk.CanAddAccount: Invalid country code %d',
      [dhFields.dhCountry_Code]);
  Result := (dhAccount_List.ItemCount < MaxAccounts) and (dhFields.dhNo_of_Transactions <
    MaxTransactions);
  *)
end;
// ----------------------------------------------------------------------------

function TOZDisk.CanAddTransaction: Boolean;
begin
  if dhFields.dhCountry_Code <> whAustralia then
    raise FHDataValidationException.CreateFmt('TOZDisk.CanAddTransaction: Invalid country code %d',
      [dhFields.dhCountry_Code]);
  (*
  Result := (dhAccount_List.ItemCount <= MaxAccounts) and (dhFields.dhNo_of_Transactions <
    MaxTransactions);
  *)
  result:=True;
end;
//------------------------------------------------------------------------------

function TOZDisk.GetZipStream(const FileName: string): TMemoryStream;

const
  ChunkSize = 8192;
  ProcName = 'TOZDisk.GetZipStream';
var
  ID: OZDiskIDRec;
  Buffer: Pointer;
  CRC: Integer;
  SaveCRC: Integer;
  ZipStream: TMemoryStream;
  FileStream: TMemoryStream;
  NumRead: Integer;
  NumWritten: Integer;
begin
  (* Profile( 'TOZDisk.GetZipStream' ); *)

  Result := nil;

  if not FileExists(FileName) then
    raise FHException.CreateFmt('%s ERROR: the file %s does not exist', [ProcName, FileName]);
  { Generate the File Header Record }
  FileStream := TMemoryStream.Create;
  try
    FileStream.LoadFromFile(FileName);
    FileStream.Position := 0;
    FileStream.Read(ID, Sizeof(ID));

    if ID.idFileType <> 'OZLink' then
      raise
        FHException.CreateFmt('%s ERROR: the file %s is not an Australian BankLink DOS disk file',
        [ProcName, FileName]);
    if ID.idVersion <> 'V1.0' then
      raise FHException.CreateFmt('%s ERROR: the file %s is for version %s (V1.0 expected)',
        [ProcName, FileName, ID.idVersion]);

    SaveCRC := ID.idCRC;
    CRC := 0;
    ID.idCRC := 0;

    UpdateCRC(CRC, ID, Sizeof(ID));

    ZipStream := TMemoryStream.Create;

    GetMem(Buffer, ChunkSize);
    try
      repeat
        NumRead := FileStream.Read(Buffer^, ChunkSize);
        if NumRead > 0 then
          begin
            UpdateCRC(CRC, Buffer^, NumRead);
            Decrypt(Buffer^, NumRead);
            NumWritten := ZipStream.Write(Buffer^, NumRead);
            if not (NumWritten = NumRead) then
              raise FHException.CreateFmt('%s ERROR: ZipStream write failed', [ProcName]);
          end;
      until NumRead < ChunkSize;
    finally
      FreeMem(Buffer, ChunkSize);
    end;
    if CRC <> SaveCRC then
      raise FHException.CreateFmt('%s ERROR: the file %s is corrupt - invalid CRC', [ProcName,
        FileName]);
    ZipStream.Position := 0;
    Result := ZipStream;
  finally
    FileStream.Free;
  end;
end;

// ----------------------------------------------------------------------------

function TOZDisk.LoadFromFileOF(const FileName, AttachmentDir: string;
  const GetAttachments: Boolean): TStringList;

const
  ProcName = 'TOZDisk.LoadFromFileOF';
var
  ZipStream: TMemoryStream;
  UnZipper: TVclZip;
  DataStream: TMemoryStream;
  FileStream: TMemoryStream;
  i: Integer;
  Index: Integer;
  AttachmentName: string;
  Files: TStringList;
begin
  (* Profile( ProcName ); *)
  Result := nil;

  ZipStream := nil;
  try
    ZipStream := GetZipStream(FileName);
    UnZipper := TVCLZip.Create(nil);
    Files := TStringList.Create;
    try
      UnZipper.ArchiveStream := ZipStream;
      UnZipper.ReadZip;

      for i := 0 to Pred(UnZipper.Count) do
        Files.Add(UnZipper.Filename[i]);
      Index := Files.IndexOf(ExtractFileName(FileName));
      if Index >= 0 then
        begin
          DataStream := TMemoryStream.Create;
          try
            UnZipper.UnZipToStream(DataStream, UnZipper.FullName[Index]);
            DataStream.Position := 0;
            Self.LoadFromRT86Stream(DataStream);
          finally
            DataStream.Free;
          end;
        end
      else
        raise FHException.CreateFmt('%s Error: Couldn''t find any data in the file %s', [ProcName,
          FileName]);

      if GetAttachments then
        begin
          Result := TStringList.Create;
          for i := 0 to Pred(UnZipper.Count) do
            begin
              if UnZipper.FileName[i] <> ExtractFileName(FileName) then
                begin { it's an attachment file }
                  FileStream := TMemoryStream.Create;
                  try
                    UnZipper.UnZipToStream(FileStream, UnZipper.FullName[i]);
                    FileStream.Position := 0;
                    AttachmentName := AttachmentDir + UnZipper.FileName[i];
                    FileStream.SaveToFile(AttachmentName);
                    Result.Add(AttachmentName);
                  finally
                    FileStream.Free;
                  end;
                end;
            end;
        end;

      UnZipper.ArchiveStream := nil;
    finally
      Files.Free;
      UnZipper.Free;
    end;

  finally
    ZipStream.Free;
  end;
end;
//----------------------------------------------------------------------------

function TOZDisk.SaveToRT86Stream: TMemoryStream;

const
  Sec1Info: array[0..16] of Byte = (255, 14, 24, 34, 36, 45, 51, 14, 36, 33, 52, 33, 94, 50, 66, 5,
    0);
  Sec3Info: array[0..16] of Byte = (255, 13, 24, 34, 36, 45, 51, 14, 36, 41, 50, 33, 14, 49, 64, 0,
    0);
  Sec8Info: array[0..16] of Byte = (255, 15, 26, 35, 44, 41, 37, 46, 52, 14, 45, 51, 39, 33, 86,
    49, 8);
  Sec12Info: array[0..16] of Byte = (255, 15, 26, 51, 57, 51, 52, 37, 45, 14, 45, 51, 39, 33, 78,
    49, 8);

var
  OZDiskImage: POZDiskImage;
  EntryNo: Integer;

  function CurrentEntry: POZEntry_Rec;
  var
    BlockNo: Integer;
    SlotNo: Integer;
  begin
    Assert((EntryNo >= 1) and (EntryNo <= 8000));
    BlockNo := ((EntryNo - 1) div 6) + 1;
    SlotNo := ((EntryNo - 1) mod 6) + 1;
    Result := @OZDiskImage^.Entries[BlockNo].Slot[SlotNo];
  end;

var
  Sector: PSector;
  i, t: Integer;
  AcctNo: Integer;
  DBA: TDisk_Bank_Account;
  P: pDisk_Transaction_Rec;
  LastBlock: Integer;
  FileLen: Integer;
begin
  (* Profile( 'TOZDisk.SaveToRT86Stream' ); *)

  Assert(dhFields.dhCountry_Code = whAustralia);
  GetMem(OZDiskImage, Sizeof(TOZDiskImage));
  try
    FillChar(OZDiskImage^, Sizeof(TOZDiskImage), 0);

    { RT86 Directory }
    for i := 0 to 13 do
      begin
        Sector := @OZDiskImage^.RT86Directory[i];
        case i of
          0:
            begin
              Sector^[0] := 160;
              Sector^[1] := 5;
              Sector^[2] := 13;
              Sector^[183] := 255;
            end;
          1: Move(Sec1Info, Sector^, Sizeof(Sec1Info));
          3: Move(Sec3Info, Sector^, Sizeof(Sec3Info));
          8: Move(Sec8Info, Sector^, Sizeof(Sec8Info));
          12: Move(Sec12Info, Sector^, Sizeof(Sec12Info));
        end;
      end;

    with OZDiskImage^.Header do
      begin
        Disk_Version := 'V1.0';
        Disk_ID := 0; { Was the Invoice No }
        Disk_Save_Cnt := 0;
        S2A(dhFields.dhClient_Code, Cust_Code, 10);
        S2A(dhFields.dhClient_Name, Cust_Name, 40);
        Disk_Created := dhFields.dhCreation_Date;
        Disk_NoAccs := dhFields.dhNo_Of_Accounts;
        Disk_NoTrx := dhFields.dhNo_Of_Transactions;
        Disk_Number := dhFields.dhDisk_Number;
        Sequence_No := dhFields.dhSequence_In_Set;
        Number_In_Set := dhFields.dhNo_Of_Disks_In_Set;
        Disk_AccCharges := 0;
        Disk_Charge := 0;
        Disk_Gross := 0;
        Disk_Tax := 0;
        Disk_Net := 0;
        Disk_MonthNo := 0; // not used
        Disk_YearNo := 0; // not used

        S2A(dhFields.dhFile_Name, Disk_Name, 12); { XXXX.nnn }

        if dhFields.dhSequence_In_Set = dhFields.dhNo_Of_Disks_in_Set then
          Last_Disk_In_Set := 'Y'
        else
          Last_Disk_In_Set := 'N'; { Not used in Client System }

        Sequence_No := dhFields.dhSequence_In_Set;
        Number_In_Set := dhFields.dhNo_Of_Disks_in_Set;
        Disk_Number := dhFields.dhDisk_Number;
        Disk_CRC := 0; { Unused }
      end;

    EntryNo := 0;

    for i := dhAccount_List.First to dhAccount_List.Last do
      begin
        DBA := dhAccount_List.Disk_Bank_Account_At(i);
        AcctNo := i + 1;
        with OZDiskImage.Directory[AcctNo] do
          begin
            S2A(DBA.dbFields.dbAccount_Number, Acc_Bank_Code, 20);
            S2A(DBA.dbFields.dbAccount_Name, Acc_Name, 40);
            S2A(DBA.dbFields.dbFile_Code, Acc_File_Code, 8);

            if DBA.dbFields.dbOpening_Balance <> Unknown then
              begin
                Acc_DR_Total := DBA.dbFields.dbOpening_Balance;
                Acc_CR_Total := DBA.dbFields.dbClosing_Balance;
                Acc_Has_Balances := True;
              end
            else
              begin
                Acc_DR_Total := DBA.dbFields.dbDebit_Total;
                Acc_CR_Total := DBA.dbFields.dbCredit_Total; // !!! Check the sign !!!
                Acc_Has_Balances := False;
              end;
            S2A(DBA.dbFields.dbCost_Code, Acc_TC_Code, 10);
            Acc_NoTrx := DBA.dbTransaction_List.ItemCount;
            {
            Acc_New_Fee       : LongInt;
            Acc_Std_Fee       : LongInt;
            Acc_Vol_Fee       : LongInt;
            Acc_Gross         : LongInt;
            }
            Acc_DateFirst := DBA.dbFields.dbFirst_Transaction_Date;
            Acc_DateLast := DBA.dbFields.dbLast_Transaction_Date;
            Acc_eStart := 0;
            Acc_eFinish := 0;
          end;

        for t := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
          begin
            Inc(EntryNo);
            P := DBA.dbTransaction_List.Disk_Transaction_At(t);
            with CurrentEntry^ do
              begin
                dDate := P.dtEffective_Date;
                dType := P.dtEntry_Type;
                S2A(P.dtBank_Type_Code_OZ_Only, dBankTypeCode, 6);
                S2A(P.dtReference, dRefce, 12);
                S2A(P.dtDefault_Code_OZ_Only, dCode, 6);
                dAmount := P.dtAmount;
                S2A(P.dtNarration, dNarration, 40);
              end;

            with OZDiskImage.Directory[AcctNo] do
              begin
                if Acc_eStart = 0 then
                  Acc_eStart := EntryNo;
                Acc_eFinish := EntryNo;
              end;
          end;
      end;

    Result := TMemoryStream.Create;

    LastBlock := ((EntryNo - 1) div 6) + 1;

    FileLen := Sizeof(OZDiskImage.RT86Directory) +
      Sizeof(OZDiskImage.Header) +
      Sizeof(OZDiskImage.Directory) +
      Sizeof(OZDiskImage.SystemMsg) +
      Sizeof(OzDiskImage.ClientMsg) +
      (LastBlock * 512);

    Result.Write(OZDiskImage^, FileLen);
    Result.Position := 0;
  finally
    FreeMem(OZDiskImage);
  end;
end;

// ----------------------------------------------------------------------------

procedure TOZDisk.SaveToFileOF(const FileName: string; const Attachments: TStringList);

const
  ChunkSize = 8192;

var
  i: Integer;
  ID: OZDiskIDRec;
  Buffer: Pointer;
  CRC: Integer;
  RT86Stream: TMemoryStream;
  ZipStream: TMemoryStream;
  FileStream: TMemoryStream;
  NumRead: Integer;
  NumWritten: Integer;
  Zipper: TVclZip;
begin
  (* Profile( 'TOZDisk.SaveToFile' ); *)
  Assert(dhFields.dhCountry_Code = whAustralia);
  { Generate the File Header Record }
  FillChar(ID, Sizeof(ID), 0);
  with ID do
    begin
      idFileType := 'OZLink';
      idClientCode := TrimS(dhFields.dhClient_Code);
      idClientName := TrimTrailS(Copy(dhFields.dhClient_Name, 1, 40));
      idDate := dhFields.dhCreation_Date;
      idFileName := TrimS(dhFields.dhFile_Name);
      idVersion := 'V1.0';
      idSequenceNo := dhFields.dhSequence_In_Set;
      idNoInSet := dhFields.dhNo_Of_Disks_in_Set;
      idLastDisk := (dhFields.dhSequence_In_Set = dhFields.dhNo_Of_Disks_in_Set);
      idDiskNumber := dhFields.dhDisk_Number;
      idCRC := 0;
    end;

  RT86Stream := SaveToRT86Stream;
  try
    ZipStream := TMemoryStream.Create;
    try
      ZipStream.Clear;
      ZipStream.Position := 0;

      Zipper := TVclZip.Create(nil);
      try
        Zipper.StorePaths := False;
        Zipper.ArchiveStream := ZipStream;
        Zipper.ZipFromStream(RT86Stream, ExtractFileName(FileName)); { The data in RT86 format }

        if Assigned(Attachments) then
          begin
            for i := 0 to Pred(Attachments.Count) do
              begin
                FileStream := TMemoryStream.Create;
                try
                  FileStream.LoadFromFile(Attachments[i]);
                  FileStream.Position := 0;
                  Zipper.ZipFromStream(FileStream, ExtractFileName(Attachments[i]))
                finally
                  FileStream.Free;
                end;
              end;
          end;
        ZipStream := TMemoryStream(Zipper.ArchiveStream);
        Zipper.ArchiveStream := nil;
      finally
        Zipper.Free;
      end;

      { The Zip data is now sitting in the ZipStream TMemoryStream
        We need to read this and encrypt it }

      FileStream := TMemoryStream.Create;

      try
        FileStream.Clear;
        FileStream.Position := 0;

        CRC := 0;
        UpdateCRC(CRC, ID, Sizeof(ID));
        FileStream.Write(ID, Sizeof(ID));

        GetMem(Buffer, ChunkSize);
        try
          ZipStream.Position := 0;
          repeat
            NumRead := ZipStream.Read(Buffer^, ChunkSize);
            if NumRead > 0 then
              begin
                Encrypt(Buffer^, NumRead);
                UpdateCRC(CRC, Buffer^, NumRead);
                NumWritten := FileStream.Write(Buffer^, NumRead);
                if not (NumWritten = NumRead) then
                  raise FHException.Create('Error writing to FileStream Memory Stream');
              end;
          until NumRead < ChunkSize;
        finally
          FreeMem(Buffer, ChunkSize);
        end;

        FileStream.Position := 0;
        ID.idCRC := CRC;
        FileStream.Write(ID, Sizeof(ID));
        FileStream.Position := 0;
        FileStream.SaveToFile(FileName);
      finally
        FileStream.Free;
      end;

    finally
      ZipStream.Free;
    end;

  finally
    RT86Stream.Free;
  end;
end;

{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    }

procedure TOZDisk.LoadFromRT86Stream(var RT86Stream: TMemoryStream);

var
  OZDiskImage: POZDiskImage;
  EntryNo: Integer;

  function CurrentEntry: POZEntry_Rec;
  var
    BlockNo: Integer;
    SlotNo: Integer;
  begin
    Assert((EntryNo >= 1) and (EntryNo <= 8000));
    BlockNo := ((EntryNo - 1) div 6) + 1;
    SlotNo := ((EntryNo - 1) mod 6) + 1;
    Result := @OZDiskImage^.Entries[BlockNo].Slot[SlotNo];
  end;

var
  AcctNo: Integer;
  DBA: TDisk_Bank_Account;
  P: pDisk_Transaction_Rec;
  CR, DR: Int64;
begin
  (* Profile( 'TOZDisk.LoadFromRT86Stream' ); *)

  Assert(dhAccount_List.ItemCount = 0);
  Assert(Assigned(RT86Stream));
  Assert(RT86Stream.Size > 0);

  GetMem(OZDiskImage, Sizeof(TOZDiskImage));
  try
    FillChar(OZDiskImage^, Sizeof(TOZDiskImage), 0);
    RT86Stream.Position := 0;
    RT86Stream.Read(OZDiskImage^, RT86Stream.Size);

    EmptyDisk;

    dhFields.dhCountry_Code := whAustralia;
    dhFields.dhVersion := 'RT86 - ' + OZDiskImage.Header.Disk_Version;
    dhFields.dhFile_SubType := NFDataStr;
    dhFields.dhClient_Code := A2S(OZDiskImage.Header.Cust_Code, 10);
    dhFields.dhClient_Name := A2S(OZDiskImage.Header.Cust_Name, 40);
    dhFields.dhCreation_Date := OZDiskImage.Header.Disk_Created;
    dhFields.dhDisk_Number := OZDiskImage.Header.Disk_Number;
    dhFields.dhSequence_In_Set := OZDiskImage.Header.Sequence_No;
    dhFields.dhNo_Of_Disks_in_Set := OZDiskImage.Header.Number_In_Set;
    dhFields.dhNo_Of_Accounts := OZDiskImage.Header.Disk_NoAccs;
    dhFields.dhNo_Of_Transactions := OZDiskImage.Header.Disk_NoTrx;
    dhFields.dhFile_Name := A2S(OZDiskImage.Header.Disk_Name, 12);
    if dhFields.dhDisk_Number<3600 then
      dhFields.dhTrue_File_Name := dhFields.dhFile_Name
    else
      dhFields.dhTrue_File_Name := CorrectFileName(dhFields.dhFile_Name);

    for AcctNo := 1 to OZDiskImage.Header.Disk_NoAccs do
      begin
        with OZDiskImage.Directory[AcctNo] do
          begin
            DBA := TDisk_Bank_Account.Create;
            DBA.dbFields.dbAccount_Number := A2S(Acc_Bank_Code, 20);
            DBA.dbFields.dbAccount_Name := A2S(Acc_Name, 40);
            DBA.dbFields.dbFile_Code := A2S(Acc_File_Code, 8);
            DBA.dbFields.dbCost_Code := A2S(Acc_TC_Code, 10);
            DBA.dbFields.dbOpening_Balance := Unknown;
            DBA.dbFields.dbClosing_Balance := Unknown;

            if Acc_Has_Balances then
              begin
                DBA.dbFields.dbOpening_Balance := Trunc(Acc_Dr_Total);
                DBA.dbFields.dbClosing_Balance := Trunc(Acc_CR_Total);
              end
            else
              begin
                DBA.dbFields.dbDebit_Total := Trunc(Acc_DR_Total);
                DBA.dbFields.dbCredit_Total := Trunc(Acc_CR_Total);
              end;
            dhAccount_List.Insert(DBA);
            CR := 0;
            DR := 0;

            if (Acc_eStart > 0) then
              begin
                for EntryNo := Acc_eStart to Acc_eFinish do
                  begin
                    P := FHDTIO.New_Disk_Transaction_Rec;
                    P.dtEffective_Date := CurrentEntry.dDate;
                    P.dtEntry_Type := CurrentEntry.dType;
                    P.dtAmount := CurrentEntry.dAmount;
                    P.dtBank_Type_Code_OZ_Only := A2S(CurrentEntry.dBankTypeCode, 6);
                    P.dtReference := A2S(CurrentEntry.dRefce, 12);
                    P.dtNarration := A2S(CurrentEntry.dNarration, 40);
                    P.dtDefault_Code_OZ_Only := A2S(CurrentEntry.dCode, 6);
                    P.dtGST_Amount := Unknown;
                    P.dtQuantity := Unknown;

                    DBA.dbTransaction_List.Insert(P);

                    Inc(DBA.dbFields.dbNo_Of_Transactions);

                    if (P.dtEffective_Date < DBA.dbFields.dbFirst_Transaction_Date) or
                      (DBA.dbFields.dbFirst_Transaction_Date = 0) then
                      DBA.dbFields.dbFirst_Transaction_Date := P.dtEffective_Date;
                    if P.dtEffective_Date > DBA.dbFields.dbLast_Transaction_Date then
                      DBA.dbFields.dbLast_Transaction_Date := P.dtEffective_Date;
                    if (dhFields.dhFirst_Transaction_Date = 0) or
                      (dhFields.dhFirst_Transaction_Date > P.dtEffective_Date) then
                      dhFields.dhFirst_Transaction_Date := P.dtEffective_Date;
                    if dhFields.dhLast_Transaction_Date < P.dtEffective_Date then
                      dhFields.dhLast_Transaction_Date := P.dtEffective_Date;

                    if P.dtAmount > 0 then
                      DR := DR + P.dtAmount
                    else
                      CR := CR - P.dtAmount;
                  end; { of Transactions }
              end; { Acc_eStart > 0 );
            { Checks }
            Assert(DBA.dbFields.dbFirst_Transaction_Date = Acc_DateFirst);
            Assert(DBA.dbFields.dbLast_Transaction_Date = Acc_DateLast);
            if (DBA.dbFields.dbOpening_Balance = Unknown) then
              begin
                Assert(DBA.dbFields.dbDebit_Total = DR);
                Assert(DBA.dbFields.dbCredit_Total = CR);
              end
            else
              begin
                DBA.dbFields.dbDebit_Total := DR;
                DBA.dbFields.dbCredit_Total := CR;
              end;
          end; { Scope of OZDirectory[ AcctNo ] }
      end; { of Accounts }
  finally
    FreeMem(OZDiskImage);
  end;
end;
//----------------------------------------------------------------------------

procedure TOZDisk.Validate;
begin
  inherited;

  if dhFields.dhCountry_Code <> whAustralia then
    raise FHDataValidationException.Create('TOZDisk.Validate Error: Wrong country code');
  if dhFields.dhDisk_Number = 0 then
    raise
      FHDataValidationException.Create('TOZDisk.Validate Error: dhDisk_Number is a required field [OZ]');
  if dhFields.dhNo_Of_Disks_in_Set = 0 then
    raise
      FHDataValidationException.Create('TOZDisk.Validate Error: dhNo_of_Disks_In_Set is a required field [OZ]');
  if dhFields.dhSequence_In_Set = 0 then
    raise
      FHDataValidationException.Create('TOZDisk.Validate Error: dhSequence_In_Set is a required field [OZ]');
end;
//------------------------------------------------------------------------------

procedure TOZDisk.NewDisk(ClientCode, ClientName: string; CreatDate: integer;
  FileName, TrueFileName: string; DiskNo, SeqNo: integer);
// New, empty disk
begin
  EmptyDisk; // Cleanup previous disk image

  dhFields.dhCountry_Code := whAustralia; // New header data
  dhFields.dhClient_Code := ClientCode;
  dhFields.dhClient_Name := ClientName;
  dhFields.dhCreation_Date := CreatDate;

  if DiskNo<3600 then
    dhFields.dhFile_Name := FileName
  else
    dhFields.dhFile_Name := StringReplace(FileName,'.','',[rfReplaceAll]);      // remove dot in 4-character extensions

  dhFields.dhFloppy_Desc_NZ_Only := '';
  dhFields.dhTrue_File_Name := TrueFileName;
  dhFields.dhDisk_Number := DiskNo;
  dhFields.dhSequence_In_Set := SeqNo;
  dhFields.dhNo_Of_Disks_in_Set := 0; // Not known yet, to be updated later
  dhFields.dhNo_Of_Accounts := 0; // Disk is empty
  dhFields.dhNo_Of_Transactions := 0; // Disk is empty
  dhFields.dhFirst_Transaction_Date := 0; // Disk is empty
  dhFields.dhLast_Transaction_Date := 0; // Disk is empty
  dhFields.dhVersion := NFVersion;
end;
//------------------------------------------------------------------------------

procedure TOZDisk.AddAccount(Number, OriginalNumber, Name, FileCode, CostCode, BankCode,
  BankName, Currency: string;
  OpBalance: Int64; IsNew: Boolean;
  accLRN,instID: integer;
  FrequencyID: integer;
  InternalAccNumber: string);
// Add new account to current disk.
var
  DBA: TDisk_Bank_Account;
begin
  (*
  if not CanAddAccount then
    raise FHException.Create('No room for new account. Disk is full.');
  *)

  DBA := TDisk_Bank_Account.Create;
  DBA.dbFields.dbAccount_Number := Number;
  DBA.dbFields.dbOriginal_Account_Number := OriginalNumber;
  DBA.dbFields.dbAccount_Name := Name;
  DBA.dbFields.dbContinued_On_Next_Disk := False; // Don't know yet
  DBA.dbFields.dbFile_Code := FileCode;
  DBA.dbFields.dbCost_Code := CostCode;
  DBA.dbFields.dbBank_Prefix := BankCode;
  DBA.dbFields.dbBank_Name := BankName;
  DBA.dbFields.dbCan_Redate_Transactions := False; // Currently always False
  DBA.dbFields.dbOpening_Balance := OpBalance;
  DBA.dbFields.dbClosing_Balance := Unknown; // Calculated when transactions are added
  DBA.dbFields.dbDebit_Total := 0; // No transactions yet
  DBA.dbFields.dbCredit_Total := 0; // No transactions yet
  DBA.dbFields.dbFirst_Transaction_Date := 0; // No transactions yet
  DBA.dbFields.dbLast_Transaction_Date := 0; // No transactions yet
  DBA.dbFields.dbNo_Of_Transactions := 0; // No transactions yet
  DBA.dbFields.dbIs_New_Account := IsNew;
  DBA.dbFields.dbInternal_Account_Number := InternalAccNumber;
  DBA.dbFields.dbAccount_LRN := accLRN;
  DBA.dbFields.dbInstitution_ID := instID;
  DBA.dbFields.dbCurrency := Currency;
  DBA.dbFields.dbFrequency_ID := FrequencyID;

  dhAccount_List.Insert(DBA);
  Inc(dhFields.dhNo_Of_Accounts);
end;
//------------------------------------------------------------------------------

procedure TOZDisk.AddTransaction(var DBA: TDisk_Bank_Account;
  TransID: Integer; TransType: Byte;
  Amount, GSTAmount, Quantity: Int64; EffDate, OrigDate: Integer;
  TypeCode, DefaultCode, Reference, Narration: string);
// Add transaction to specified account.
var
  P: PDisk_Transaction_Rec;
begin
  if not CanAddTransaction then
    raise FHException.Create('No room for new transaction. Disk is full.');

  P := FHDTIO.New_Disk_Transaction_Rec;
  P.dtBankLink_ID := TransID;
  P.dtEntry_Type := TransType;
  P.dtAmount := Amount;
  P.dtGST_Amount := GSTAmount;
  P.dtGST_Amount_Known := GSTAmount <> Unknown;
  P.dtEffective_Date := EffDate;
  P.dtOriginal_Date := OrigDate;
  P.dtReference := Reference;
  P.dtBank_Type_Code_OZ_Only := TypeCode;
  P.dtDefault_Code_OZ_Only := DefaultCode;
  P.dtNarration := Narration;
  P.dtQuantity := Quantity;
  P.dtAnalysis_Code_NZ_Only := ''; // Not used in OZ
  P.dtParticulars_NZ_Only := ''; // Not used in OZ
  P.dtOther_Party_NZ_Only := ''; // Not used in OZ
  P.dtOrig_BB := ''; // Not used in OZ

  DBA.dbTransaction_List.Insert(P);

  Inc(DBA.dbFields.dbNo_Of_Transactions); // Update account and disk totals
  Inc(dhFields.dhNo_Of_Transactions);
  if (dhFields.dhFirst_Transaction_Date = 0) or (dhFields.dhFirst_Transaction_Date > EffDate) then
    dhFields.dhFirst_Transaction_Date := EffDate;
  if (dhFields.dhLast_Transaction_Date < EffDate) then
    dhFields.dhLast_Transaction_Date := EffDate;
  if (DBA.dbFields.dbFirst_Transaction_Date = 0) or (DBA.dbFields.dbFirst_Transaction_Date >
    EffDate) then
    DBA.dbFields.dbFirst_Transaction_Date := EffDate;
  if (DBA.dbFields.dbLast_Transaction_Date < EffDate) then
    DBA.dbFields.dbLast_Transaction_Date := EffDate;

  if Amount < 0 then
    DBA.dbFields.dbCredit_Total := DBA.dbFields.dbCredit_Total - Amount
  else
    DBA.dbFields.dbDebit_Total := DBA.dbFields.dbDebit_Total + Amount;
  if DBA.dbFields.dbOpening_Balance <> Unknown then
    DBA.dbFields.dbClosing_Balance := DBA.dbFields.dbOpening_Balance + DBA.dbFields.dbCredit_Total
      - DBA.dbFields.dbDebit_Total;
end;
//------------------------------------------------------------------------------

end.
