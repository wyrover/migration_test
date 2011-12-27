unit MemorisationsObj;
//------------------------------------------------------------------------------
{
   Title:       Memorisations List

   Description:

   Author:      Matthew Hopkins, Michael Foot   Nov 2003

   Remarks:     Replaces the memorisation records list with a list of
                objects
}
//------------------------------------------------------------------------------

interface

uses
  Classes,
  BKConst,
  BKDefs,
  BKMDIO,
  IOStream,
  ECollect,
  AuditMgr,
  SYDEFS;

type
  //Note: Audit ID's for memorisation lines can be generated by the
  //SystemAuditMgr (Master memorisations), or the ClientAuditMgr.
  //This means that the Audit ID's have to be assigned to mlAudit_Record_ID
  //before the memorisation line is inserted into the list.
  TMemorisationLinesList = class( TExtdCollection)
   protected
     procedure FreeItem( Item : Pointer ); override;
     function FindRecordID(ARecordID: integer): pMemorisation_Line_Rec;
   private
     FAuditMgr: TAuditManager;
     FLoading : Boolean;
   public
     constructor Create(AAuditMgr: TAuditManager);
     function MemorisationLine_At( Index : LongInt ): pMemorisation_Line_Rec;
     function Insert(Item: Pointer): integer; override;
     procedure FreeAll; override;
     procedure SaveToStream( Var S : TIOStream );
     procedure LoadFromStream( Var S : TIOStream );
     procedure UpdateCRC(var CRC : Longword);
     procedure CheckIntegrity;
     procedure DoAudit(AMemorisationLinesListCopy: TMemorisationLinesList;
                       AParentID: integer;
                       var AAuditTable: TAuditTable);
     procedure SetAuditInfo(P1, P2: pMemorisation_Line_Rec;
                            AParentID: integer;
                            var AAuditInfo: TAuditInfo);
  end;

  TMemorisation = class
     mdFields : pMemorisation_Detail_Rec;
     mdLines  : TMemorisationLinesList;
   private
     FAuditMgr: TAuditManager;
   public
     constructor Create(AAuditMgr: TAuditManager);
     destructor Destroy; override;
     function  mdLinesCount : integer;
     function  FirstLine : pMemorisation_Line_Rec;
     function  IsDissected : boolean;
     function  DateText : string;
     procedure SaveToStream( Var S : TIOStream );
     procedure LoadFromStream( Var S : TIOStream );
     procedure UpdateCRC(var CRC : Longword);
  end;

  TMemsArray = Array[0..255] of TMemorisation;

  TMemorisations_List = class( TExtdSortedCollection)
   protected
      procedure FreeItem(Item : Pointer); override;
      function FindRecordID(ARecordID: integer): TMemorisation;
   private
      LastSeq : integer;
      FLoading: Boolean;
      FAuditMgr: TAuditManager;
      procedure Resequence;
   public
      mxFirstByEntryType : TMemsArray;
      mxLastByEntryType : TMemsArray;
      constructor Create(AAuditMgr: TAuditManager); overload;
      constructor Create; overload;
      function Compare(Item1,Item2 : Pointer): Integer; override;
      procedure Insert(Item : Pointer); override;
      procedure FreeAll; override;
      procedure Insert_Memorisation(m : TMemorisation; NewAuditID: boolean = True); virtual;
      function  Memorisation_At(Index : longint) : TMemorisation;
      procedure SwapItems(m1 : TMemorisation; m2: TMemorisation);
      procedure LoadFromStream(var S : TIOStream);
      procedure SaveToStream(var S: TIOStream);
      procedure DumpMasters;
      procedure UpdateCRC( var CRC : Longword);
      function  GetCurrentCRC : LongWord;
      procedure CheckIntegrity;
      procedure UpdateLinkedLists;
      procedure DoAudit(AMemorisationListCopy: TMemorisations_List;
                        AParentID: integer; var AAuditTable: TAuditTable);
      procedure SetAuditInfo(P1, P2: pMemorisation_Detail_Rec;
                             AParentID: integer; var AAuditInfo: TAuditInfo);
      property AuditMgr: TAuditManager read FAuditMgr;
  end;

//****************************************************************
//The following classes get replaced by SystemMemorisationList.pas
//Still needed for upgrades.

type
  //extends the client memorisations object by adding the ability to save
  TMaster_Memorisations_List = Class( TMemorisations_List )
  private
    FPrefix : BankPrefixStr;
    FFilename : String;
    FsymxLast_Updated: Int64;
    FsymxLast_CRC: LongWord;
    function LoadFromFile : boolean;
    procedure SetsymxLast_Updated(const Value: Int64);
    procedure SetsymxLast_CRC(const Value: LongWord);

    procedure UpgradeMasterMemFileToLatestVersion( VersionFound : integer);
    procedure Refresh;  //reloads the list if needed
  public
    constructor Create( ACode : BankPrefixStr );
    property symxLast_Updated : Int64 read FsymxLast_Updated write SetsymxLast_Updated;
    property symxLast_CRC : LongWord read FsymxLast_CRC write SetsymxLast_CRC;
    function SaveToFile : boolean;
    procedure QuickRead; //Read without locking Used by Migrator only
    procedure Insert_Memorisation(m : TMemorisation; NewAuditID: boolean = True); override;
   end;

type
   TMaster_Mem_Lists_Collection = Class( TExtdSortedCollection )
      constructor Create;
      function  Compare(Item1,Item2 : Pointer): Integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   public
      Function  System_Memorised_Transaction_List_At( Index : Integer ) : TMaster_Memorisations_List;
      Function  FindPrefix( CONST ACode: BankPrefixStr ): TMaster_Memorisations_List;

      function  ReloadSystemMXList( BankPrefix : BankPrefixStr) : boolean;
   end;

type
  TSystemMemorisationListHeader = packed record
    smCRC : Longword;
    smPrefix : String[6];
    smInstitutionID : integer;
    smInstitutionCode : string[6];
    smFile_Version : integer;
    smSpare : Array [0..31] of byte;
  end;

var
  Master_Mem_Lists_Collection : TMaster_Mem_Lists_Collection = nil;

implementation

uses
  Malloc,
  SysUtils,
  bkDateUtils,
  BK5Except,
  BKCRC,
  BKDbExcept,
  BKMLIO,
  LogUtil,
  mxFiles32,
  StStrs,
  CrcFileUtils,
  winutils,
  Tokens,
  SYAUDIT,
  BKAUDIT;

const
  DebugMe : Boolean = FALSE;
  UnitName = 'MemorisationsObj';

{ TMemorisationLinesList }

procedure TMemorisationLinesList.CheckIntegrity;
var
  i : Integer;
begin
  for i := First to Last do
    with MemorisationLine_At(i)^ do;
end;

constructor TMemorisationLinesList.Create(AAuditMgr: TAuditManager);
begin
  inherited Create;

  FLoading := False;
  FAuditMgr := AAuditMgr;
end;

procedure TMemorisationLinesList.DoAudit(AMemorisationLinesListCopy: TMemorisationLinesList;
  AParentID: integer; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pMemorisation_Line_Rec;
  AuditInfo: TAuditInfo;
begin
  if FAuditMgr is TClientAuditManager then
    AuditInfo.AuditType := arMemorisations
  else
    AuditInfo.AuditType := arMasterMemorisations;
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Memorisation_Line;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := nil;
    if Assigned(AMemorisationLinesListCopy) then //Sub list - may not be assigned
      P2 := AMemorisationLinesListCopy.FindRecordID(P1.mlAudit_Record_ID);
    AuditInfo.AuditRecord := New_Memorisation_Line_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(AMemorisationLinesListCopy) then begin //Sub list - may not be assigned
    for i := 0 to AMemorisationLinesListCopy.ItemCount - 1 do begin
      P2 := AMemorisationLinesListCopy.Items[i];
      P1 := FindRecordID(P2.mlAudit_Record_ID);
      AuditInfo.AuditRecord := New_Memorisation_Line_Rec;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;
end;

function TMemorisationLinesList.FindRecordID(
  ARecordID: integer): pMemorisation_Line_Rec;
const
  ThisMethodName = 'TMemorisationLinesList.FindRecordID';
var
  i : LongInt;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, ARecordID]));
  Result := NIL;
  if (itemCount = 0 ) then Exit;

  for I := 0 to Pred( itemCount ) do
    with MemorisationLine_At( I )^ do
      if mlAudit_Record_ID = ARecordID then begin
        Result := MemorisationLine_At( I );
        if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
          Exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

procedure TMemorisationLinesList.FreeAll; 
var
  i : integer;
begin
  for I := First to Last do
    FreeItem(At(I));
  SetCount(0);
end;

procedure TMemorisationLinesList.FreeItem(Item: Pointer);
begin
  if BKMLIO.IsAMemorisation_Line_Rec(Item) then begin
    BKMLIO.Free_Memorisation_Line_Rec_Dynamic_Fields( pMemorisation_Line_Rec( Item)^ );
    SafeFreeMem( Item, Memorisation_Line_Rec_Size );
  end;
end;

function TMemorisationLinesList.Insert(Item: Pointer): integer;
begin
  if (not FLoading) and Assigned(FAuditMgr) then
    pMemorisation_Line_Rec(Item).mlAudit_Record_ID := FAuditMgr.NextAuditRecordID;

  Result := inherited Insert(Item);
end;

procedure TMemorisationLinesList.LoadFromStream(var S: TIOStream);
const
  ThisMethodName = 'TMemorisationLinesList.LoadFromStream';
var
  Token    : Byte;
  pML       : pMemorisation_Line_Rec;
  msg      : string;
begin
  FLoading := True;
  try
    Token := S.ReadToken;
    while ( Token <> tkEndSection ) do begin
      case Token of
        tkBegin_Memorisation_Line :
          begin
            pML := New_Memorisation_Line_Rec;
            BKMLIO.Read_Memorisation_Line_Rec(pML^, S);
            inherited Insert(pML);
          end;
      else
        begin { Should never happen }
          Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
          LogUtil.LogMsg(lmError, UnitName, Msg );
          raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
        end;
      end; { of Case }
      Token := S.ReadToken;
    end;
  finally
    FLoading := False;
  end;
end;

function TMemorisationLinesList.MemorisationLine_At(
  Index: Integer): pMemorisation_Line_Rec;
var
  P : Pointer;
begin
  Result := nil;
  P := At(Index);
  if (BKMLIO.IsAMemorisation_Line_Rec(P)) then
    Result := P;
end;

procedure TMemorisationLinesList.SaveToStream(var S: TIOStream);
var
  i : Integer;
begin
  S.WriteToken(tkBeginMemorisationLinesList);
  for i := First To Last do
    BKMLIO.Write_Memorisation_Line_Rec(MemorisationLine_At(i)^, S);
  S.WriteToken(tkEndSection);
end;

procedure TMemorisationLinesList.SetAuditInfo(P1, P2: pMemorisation_Line_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Memorisation Line']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.mlAudit_Record_ID;
//    AAuditInfo.AuditOtherInfo := AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
//                                 Format('%s=%d', ['ParentID', AParentID]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.mlAudit_Record_ID;
//    AAuditInfo.AuditParentID := AParentID;
    if Memorisation_Line_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.mlAudit_Record_ID;
//    AAuditInfo.AuditParentID := AParentID;
    P1.mlAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKMLIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Memorisation_Line_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TMemorisationLinesList.UpdateCRC(var CRC: Longword);
var
  i : Integer;
begin
  for i := First to Last do
    BKCRC.UpdateCRC(MemorisationLine_At(i)^, CRC)
end;

{ TMemorisation }

constructor TMemorisation.Create(AAuditMgr: TAuditManager);
begin
  inherited Create;

//  FillChar( mdFields, Sizeof( mdFields ), 0 );
//  with mdFields do
//  begin
//    mdRecord_Type := tkBegin_Memorisation_Detail;
//    mdEOR := tkEnd_Memorisation_Detail;
//  end;

  FAuditMgr := AAuditMgr;
  mdFields := New_Memorisation_Detail_Rec;
  mdLines := TMemorisationLinesList.Create(FAuditMgr);
end;

function TMemorisation.DateText: string;
begin
   Result := '';
   if mdFields.mdFrom_Date > 0 then begin
      Result := 'From ' + bkDate2Str(mdFields.mdFrom_Date);
   end;

   if mdFields.mdUntil_Date > 0 then begin
      if result > '' then result := Result + ',';
      Result := 'Until ' + bkDate2Str(mdFields.mdUntil_Date);
   end;
end;

destructor TMemorisation.Destroy;
begin
  mdLines.Free;
  Free_Memorisation_Detail_Rec_Dynamic_Fields(mdFields^);
  inherited Destroy;
end;

function TMemorisation.FirstLine: pMemorisation_Line_Rec;
begin
  if mdLines.ItemCount > 0 then
    result := mdLines.MemorisationLine_At(0)
  else
    result := nil;
end;

function TMemorisation.IsDissected: boolean;
begin
  result := mdLines.ItemCount > 1;
end;

procedure TMemorisation.LoadFromStream(var S: TIOStream);
const
  ThisMethodName = 'TMemorisation.LoadFromStream';
var
  Token    : Byte;
  msg      : string;
begin
   Token := tkBegin_Memorisation_Detail;
   repeat
      case Token of
         tkBegin_Memorisation_Detail :
           BKMDIO.Read_Memorisation_Detail_Rec(mdFields^, S);
         tkBeginMemorisationLinesList :
           mdLines.LoadFromStream(S);
      else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   until Token = tkEndSection;
end;

function TMemorisation.mdLinesCount: integer;
begin
  result := mdLines.ItemCount;
end;

procedure TMemorisation.SaveToStream(var S: TIOStream);
begin
  BKMDIO.Write_Memorisation_Detail_Rec(mdFields^, S);
  mdLines.SaveToStream(S);
  S.WriteToken(tkEndSection);
end;

procedure TMemorisation.UpdateCRC(var CRC: Longword);
begin
  BKCRC.UpdateCRC(mdFields^, CRC);
  mdLines.UpdateCRC(CRC);
end;

{ TMemorisations_List }

procedure TMemorisations_List.CheckIntegrity;
//test that records are correct
//          sequence is correct
//          master mems are sorted first
var
  i : Integer;
  AMemorisation : TMemorisation;
  NoMoreMasterMemsExpected : boolean;

  LastMasterSequenceNo : integer;
  LastClientSequenceNo : integer;

begin
  LastMasterSequenceNo := -1;
  LastClientSequenceNo := -1;
  NoMoreMasterMemsExpected := false;

  for i := First to Last do
    begin
      AMemorisation := Memorisation_At(i);

      //check sequence numbers
      if AMemorisation.mdFields.mdFrom_Master_List then
        begin
          if LastMasterSequenceNo = -1 then
            begin
              //cant check first item
              LastMasterSequenceNo := AMemorisation.mdFields.mdSequence_No;
            end
          else
            begin
              //make sure this seq no is greater than last
              if not ( AMemorisation.mdFields.mdSequence_No > LastMasterSequenceNo) then
                Raise EDataIntegrity.CreateFmt( 'Memorisation List Sequence wrong at index %d.  SeqNo= %d Last=%d',
                                      [i, AMemorisation.mdFields.mdSequence_No, LastMasterSequenceNo]);

              LastMasterSequenceNo := AMemorisation.mdFields.mdSequence_No;
            end;
        end
      else
        begin
          if LastClientSequenceNo = -1 then
            begin
              //cant check first item
              LastClientSequenceNo := AMemorisation.mdFields.mdSequence_No;
              NoMoreMasterMemsExpected := True;
            end
          else
            begin
              //make sure this seq no is greater than last
              if not ( AMemorisation.mdFields.mdSequence_No > LastClientSequenceNo) then
                Raise EDataIntegrity.CreateFmt( 'Memorisation List Sequence wrong at index %d.  SeqNo= %d Last=%d',
                                      [i, AMemorisation.mdFields.mdSequence_No, LastClientSequenceNo]);

              LastClientSequenceNo := AMemorisation.mdFields.mdSequence_No;
            end;
        end;

      if ( AMemorisation.mdFields.mdFrom_Master_List and  NoMoreMasterMemsExpected) then
        Raise EDataIntegrity.CreateFmt( 'Master Memorisation found after normal memorisation. index= %d', [ i]);

      AMemorisation.mdLines.CheckIntegrity;
  end;
end;

function TMemorisations_List.Compare(Item1, Item2: Pointer): Integer;
begin
  // We want to put the master MX at the start of the list so they get accessed last
  if TMemorisation(Item1).mdFields.mdFrom_Master_List and not ( TMemorisation(Item2).mdFields.mdFrom_Master_List ) then Compare := -1 else
  if TMemorisation(Item2).mdFields.mdFrom_Master_List and not ( TMemorisation(Item1).mdFields.mdFrom_Master_List ) then Compare := 1 else
  if TMemorisation(Item1).mdFields.mdSequence_No < TMemorisation(Item2).mdFields.mdSequence_No then Compare := -1 else
  if TMemorisation(Item1).mdFields.mdSequence_No > TMemorisation(Item2).mdFields.mdSequence_No then Compare := 1 else
  Compare := 0;
end;

constructor TMemorisations_List.Create;
begin
  //Client not needed for Master mem list
  Create(nil); 
end;

constructor TMemorisations_List.Create(AAuditMgr: TAuditManager);
begin
  inherited create;
  FAuditMgr := AAuditMgr;
  Duplicates := false;
  LastSeq := 0;
end;

procedure TMemorisations_List.DoAudit(AMemorisationListCopy: TMemorisations_List;
  AParentID: integer; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pMemorisation_Detail_Rec;
  AuditInfo: TAuditInfo;
  Memorisation: TMemorisation;
  M1, M2: TMemorisation;
begin
  if FAuditMgr is TClientAuditManager then
    AuditInfo.AuditType := arMemorisations
  else
    AuditInfo.AuditType := arMasterMemorisations;
//  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Memorisation_Detail;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := TMemorisation(Items[i]).mdFields;
    P2 := nil;
    Memorisation := nil;
    if Assigned(AMemorisationListCopy) then //Sub list - may not be assigned
      Memorisation := AMemorisationListCopy.FindRecordID(P1.mdAudit_Record_ID);
    if Assigned(Memorisation) then
      P2 := Memorisation.mdFields;
    AuditInfo.AuditRecord := New_Memorisation_Detail_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(AMemorisationListCopy) then begin //Sub list - may not be assigned
    for i := 0 to AMemorisationListCopy.ItemCount - 1 do begin
      P2 := TMemorisation(AMemorisationListCopy.Items[i]).mdFields;
      Memorisation := FindRecordID(P2.mdAudit_Record_ID);
      P1 := nil;
      if Assigned(Memorisation) then
        P1 := Memorisation.mdFields;
      AuditInfo.AuditRecord := New_Memorisation_Detail_Rec;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;

  //Test - audit each memorisation line
  for I := 0 to Pred(itemCount) do begin
    M1 := Items[i];
    M2 := nil;
    if Assigned(AMemorisationListCopy) then
      M2 := AMemorisationListCopy.FindRecordID(M1.mdFields.mdAudit_Record_ID);
    if Assigned(M1) then
      if Assigned(M2) then
        TMemorisation(M1).mdLines.DoAudit(M2.mdLines,
                                          TMemorisation(M1).mdFields.mdAudit_Record_ID,
                                          AAuditTable)
      else
        TMemorisation(M1).mdLines.DoAudit(nil,
                                          TMemorisation(M1).mdFields.mdAudit_Record_ID,
                                          AAuditTable);
  end;
end;

procedure TMemorisations_List.DumpMasters;
//remove any memorisations that were copied from the Master Memorisations
var
  i : LongInt;
begin
  for i := Last downto First do
    with Memorisation_At( i ) do
      if mdFields.mdFrom_Master_List then
        AtFree( i );
end;

function TMemorisations_List.FindRecordID(ARecordID: integer): TMemorisation;
const
  ThisMethodName = 'TMemorisations_List.FindRecordID';
var
  i : LongInt;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, ARecordID]));
  Result := NIL;
  if (itemCount = 0 ) then Exit;

  for I := 0 to Pred( ItemCount ) do
    with Memorisation_At( I ) do
      if mdFields.mdAudit_Record_ID = ARecordID then begin
        Result := Memorisation_At( I );
        if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
          Exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

procedure TMemorisations_List.FreeAll;
begin
  inherited;
  LastSeq := 0;
end;

procedure TMemorisations_List.FreeItem(Item: Pointer);
begin
  TMemorisation(Item).Free;
end;

function TMemorisations_List.GetCurrentCRC: LongWord;
var
  CRC : LongWord;
begin
  CRC := 0;
  UpdateCRC( CRC);
  result := CRC;
end;

procedure TMemorisations_List.Insert(Item: Pointer);
const
  ThisMethodName = 'TMemorisations_List.Insert';
var
  Msg : string;
begin
  Msg := Format( '%s : Called Direct', [ ThisMethodName] );
  LogUtil.LogMsg(lmError, UnitName, Msg );
  raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
end;

procedure TMemorisations_List.Insert_Memorisation(m : TMemorisation; NewAuditID: boolean = True);
begin
  Inc( LastSeq );
  M.mdFields.mdSequence_No := LastSeq;

  if NewAuditID and (not FLoading) and Assigned(FAuditMgr) then
    M.mdFields.mdAudit_Record_ID := FAuditMgr.NextAuditRecordID;

  inherited Insert( M );
end;

procedure TMemorisations_List.LoadFromStream(var S: TIOStream);
const
  ThisMethodName = 'TMemorisations_List.LoadFromStream';
var
  Token    : Byte;
  M        : TMemorisation;
  msg      : string;
begin
  FLoading := True;
  try
   Token := S.ReadToken;
   while ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBeginMemorisationsList: ; // Do nothing
         tkBegin_Memorisation_Detail :
           begin
              M := TMemorisation.Create(FAuditMgr);
              if not Assigned( M ) then
              begin
                 Msg := Format( '%s : Unable to allocate M',[ThisMethodName]);
                 LogUtil.LogMsg(lmError, UnitName, Msg );
                 raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
              end;
              M.LoadFromStream( S );
              Insert_Memorisation( M, False );
           end;
      else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
  finally
    FLoading := False;
  end;
end;

function TMemorisations_List.Memorisation_At(
  Index: Integer): TMemorisation;
begin
  Result := At(Index);
end;

procedure TMemorisations_List.Resequence;
const
  ThisMethodName = 'TMemorisations_List.Resequence';
var
  i :integer;
begin
  for i := First to Last do
    Memorisation_At(i).mdFields.mdSequence_No := (i + 1);
end;

procedure TMemorisations_List.SaveToStream(var S: TIOStream);
var
  i : Integer;
begin
   S.WriteToken( tkBeginMemorisationsList );
   for i := First to Last do
     Memorisation_At(i).SaveToStream(S);
   S.WriteToken( tkEndSection );
end;

procedure TMemorisations_List.SetAuditInfo(P1, P2: pMemorisation_Detail_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Memorisation']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.mdAudit_Record_ID;
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.mdAudit_Record_ID;
//    AAuditInfo.AuditParentID := AParentID;
    if Memorisation_Detail_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.mdAudit_Record_ID;
//    AAuditInfo.AuditParentID := AParentID;
    P1.mdAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKMDIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Memorisation_Detail_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TMemorisations_List.SwapItems(m1,
  m2: TMemorisation);
var
  AtIndex : integer;
begin
  if m1.mdFields.mdSequence_No < m2.mdFields.mdSequence_No then
  begin
    Delete(m2);
    AtIndex := IndexOf(m1);
    AtInsert(AtIndex,m2);
    Resequence;
  end;
end;

procedure TMemorisations_List.UpdateCRC(var CRC: Longword);
var
  i : integer;
begin
  for i := First to Last do
    Memorisation_At(i).UpdateCRC(CRC);
end;

procedure TMemorisations_List.UpdateLinkedLists;
//build a set of linked lists for each entry type,
//used by autocode
var
   i : LongInt;
   O : TMemorisation;
begin
   FillChar( mxFirstByEntryType, Sizeof( mxFirstByEntryType ), 0 );
   FillChar( mxLastByEntryType, Sizeof( mxLastByEntryType ), 0 );

   For i := Last downto First do
   Begin
      O := Memorisation_At( i);
      With O.mdFields^ do
      Begin
         mdNext_Memorisation := NIL;
         If mxFirstByEntryType[ mdType ] = NIL then
           mxFirstByEntryType[ mdType ] := O;

         If mxLastByEntryType[ mdType ]<>NIL then
            mxLastByEntryType[ mdType ].mdFields.mdNext_Memorisation := O;

         mxLastByEntryType[ mdType ] := O;
      end;
   end;
end;

{ TMaster_Memorisations_List }
constructor TMaster_Memorisations_List.Create(ACode: BankPrefixStr);
begin
  Inherited Create;

  FPrefix := ACode;
  FFilename := mxFiles32.MasterFilename( FPrefix);
  symxLast_Updated := 0;
  symxLast_CRC := 0;
end;

procedure TMaster_Memorisations_List.Insert_Memorisation(m: TMemorisation; NewAuditID: boolean = True);
begin
  m.mdFields.mdFrom_Master_List := true;
  if Assigned(FAuditMgr) and NewAuditID then
    M.mdFields.mdAudit_Record_ID := FAuditMgr.NextAuditRecordID;

  inherited;
end;

function TMaster_Memorisations_List.LoadFromFile : boolean;

begin
  result := false;
  //lock master file
  if not mxFiles32.LockMasterFile( FPrefix) then
     Exit;
  try
    QuickRead;

    syMxLast_Updated := WinUtils.GetFileTimeAsInt64( FFilename);
  finally
    //unlock master file
    mxFiles32.UnlockMasterFile( FPrefix);
  end;
end;

procedure TMaster_Memorisations_List.QuickRead;
var
  MasterFileStream : TIOStream;
  Header : TSystemMemorisationListHeader;
  Token : byte;
begin
   //remove all existing lines
    FreeAll;
    MasterFileStream := TIOStream.Create;
    try
      //load into stream
      MasterFileStream.LoadFromFile( FFilename);
      //verify crc
      CRCFileUtils.CheckEmbeddedCRC( MasterFileStream);
      //read header
      MasterFileStream.Position := 0;
      MasterFileStream.Read( Header, SizeOf(TSystemMemorisationListHeader));
      //check file version
      if ( Header.smFile_Version > BKDEFS.BK_FILE_VERSION) then
        raise EIncorrectVersion.Create( 'Master Mem file is for a later version, expected <= ' + inttostr( BKDEFS.BK_FILE_VERSION) +
                                        ', actual ' + inttostr( Header.smFile_Version));
      //check prefix is correct
      Assert( Header.smPrefix = FPrefix, 'Wrong Master Mem file loaded, expected ' + FPrefix + ', actual ' + Header.smPrefix);

      //the save routine writes a token to indicate that this is a mem list
      Token := MasterFileStream.ReadToken;
      Assert( tkBeginMemorisationsList = Token, 'Start Memorisation list token wrong');

      Self.LoadFromStream( MasterFileStream);

      UpgradeMasterMemFileToLatestVersion( Header.smFile_Version);
    finally
      MasterFileStream.Free;
    end;
end;

procedure TMaster_Memorisations_List.Refresh;
//reload this master memorisation list if file time has changed
Var
  TimeNow               : Int64;
Begin
   if not BKFileExists( FFilename) then
     exit;

   TimeNow := WinUtils.GetFileTimeAsInt64( FFilename);
   if TimeNow <> symxLast_Updated then
     begin
       if Self.LoadFromFile then
         Self.syMxLast_Updated := WinUtils.GetFileTimeAsInt64( FFilename);
     end;

   UpdateLinkedLists;
end;

function TMaster_Memorisations_List.SaveToFile : boolean;
//save to temp file, del bak, rename old, rename new
var
  MasterFileStream : TIOStream;
  Header : TSystemMemorisationListHeader;
  TempFilename : string;
  BakFilename : string;
begin
  result := false;
  Self.CheckIntegrity;

  //obtain lock
  if not mxFiles32.LockMasterFile( FPrefix) then
     exit
   else
     result := true;

  //set up file names
  TempFilename := ChangeFileExt( FFilename, '.bak');
  BakFilename := mxFiles32.MasterFileBackupName( FPrefix);

  //write out new temp file
  if BKFileExists( TempFilename) then
    WinUtils.RemoveFile( TempFilename);

  MasterFileStream := TIOStream.Create;
  try
    //initialise header
    FillChar( Header, SizeOf( TSystemMemorisationListHeader), #0);
    Header.smPrefix := FPrefix;
    //use the bkdefs version as this is where the memorisation records are defined
    Header.smFile_Version := bkdefs.BK_FILE_VERSION;
    //smInstitutionID :=
    //smInstitutionCode :=

    MasterFileStream.Write( Header, SizeOf( TSystemMemorisationListHeader));
    Self.SaveToStream( MasterFileStream);
    CrcFileUtils.EmbedCRC( MasterFileStream);

    MasterFileStream.SaveToFile( TempFilename);
  finally
    MasterFileStream.Free;
  end;

  //successfully saved temp file, now do renames
  if BKFileExists( FFilename ) then
  begin
    if BKFileExists( BakFileName ) then
      WinUtils.RemoveFile( BakFilename);

     WinUtils.RenameFileEx( FFilename, BakFileName );
  end;

  //Rename the new .TMP file as .MXL
  if BKFileExists( FFilename ) then
    WinUtils.RemoveFile( FFilename );

  WinUtils.RenameFileEx( TempFileName, FFilename );

  //update last saved
  symxLast_Updated := WinUtils.GetFileTimeAsInt64( FFilename);

  //unlock the file.  This is not inside a try finally because the file
  //should remain locked if something goes wrong
  UnlockMasterFile( FPrefix);
end;

procedure TMaster_Memorisations_List.SetsymxLast_CRC(
  const Value: LongWord);
begin
  FsymxLast_CRC := Value;
end;

procedure TMaster_Memorisations_List.SetsymxLast_Updated(
  const Value: Int64);
begin
  FsymxLast_Updated := Value;
end;

procedure TMaster_Memorisations_List.UpgradeMasterMemFileToLatestVersion( VersionFound : integer);
{var
  Initial_Version : integer;
  Current_Version : integer;}
begin
  //upgrade fields based on file version
  if VersionFound = BKDEFS.BK_FILE_VERSION then
    exit;

  {Initial_Version := VersionFound;
  Current_Version := VersionFound;

  if VersionFound < nn then
  begin
     UpgradeToVersionNN
     Current_Version     := nn
  end;
  }
end;

{ TMaster_Mem_Lists_Collection }

function TMaster_Mem_Lists_Collection.Compare(Item1, Item2: Pointer): Integer;
begin
   Result := StStrS.CompStringS( TMaster_Memorisations_List( Item1).FPrefix, TMaster_Memorisations_List( Item2).FPrefix );
end;

constructor TMaster_Mem_Lists_Collection.Create;
begin
  inherited create;
  Self.Duplicates := false;
end;

function TMaster_Mem_Lists_Collection.FindPrefix(
  const ACode: BankPrefixStr): TMaster_Memorisations_List;
//searchs the list of master mem list objects to find a list with the specified
//prefix
var
  L, H, I, C: Integer;
  P  : TMaster_Memorisations_List;
begin
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;

  repeat
    I := (L + H) shr 1;
    P := System_Memorised_Transaction_List_At( i );
    C := STStrS.CompStringS( ACode, P.FPrefix );
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then Result := P;
end;

procedure TMaster_Mem_Lists_Collection.FreeItem(Item: Pointer);
var
  O : TMaster_Memorisations_List;
begin
  O := TMaster_Memorisations_List( Item );
  O.Free;
end;

function TMaster_Mem_Lists_Collection.ReloadSystemMXList( BankPrefix: BankPrefixStr): boolean;
//returns true if the latest version of the master memorisations for this bank
//prefix have been loaded
var
   Master_List    : TMaster_Memorisations_List;
   MasterFilename : string;
begin
   result := false;

   Master_List := Self.FindPrefix( BankPrefix );
   if not Assigned( Master_List ) then begin
      MasterFilename := mxFiles32.MasterFileName( BankPrefix);

      if BKFileExists( MasterFilename) then begin
         //create a master list entry
         Master_List := TMaster_Memorisations_List.Create( BankPrefix);
         Self.Insert( Master_List);
         Master_List.Refresh;
         result := true;
      end;
   end
   else begin
      Master_List.Refresh;

      result := true;
   end;
end;

function TMaster_Mem_Lists_Collection.System_Memorised_Transaction_List_At(
  Index: Integer): TMaster_Memorisations_List;
begin
  result := TMaster_Memorisations_List( At(Index));
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   Master_Mem_Lists_Collection := TMaster_Mem_Lists_Collection.Create;
   DebugMe := DebugUnit(UnitName);
finalization
   FreeAndNil( Master_Mem_Lists_Collection);

end.
