unit RecommendedMemsV2;

interface

uses
  // Note: MyClient may not be fully loaded, don't use Globals
  Classes,
  SysUtils,

  utObj32,
  utList32,
  cpObj32,
  cmObj32,
  cmList32,
  rmObj32,
  rmList32,
  ECollect,

  baObj32,
  baList32,
  
  LogUtil;

type
  {-----------------------------------------------------------------------------
    TLCS
  -----------------------------------------------------------------------------}
  TLCS = class(TObject)
  private
    fStartData: boolean;
    fDetails: string;
    fEndData: boolean;

  public
    procedure Assign(const aFrom: TLCS);

    function  HasStartOrEnd: boolean;

    function  Compare(const aOther: TLCS): boolean;

    function  ToString: string;

    procedure SetData(const aStartData: boolean; const aDetails: string;
                const aEndData: boolean);

    property  StartData: boolean read fStartData write fStartData;
    property  Details: string read fDetails write fDetails;
    property  EndData: boolean read fEndData write fEndData;
  end;


  {-----------------------------------------------------------------------------
    TCandidateString
  -----------------------------------------------------------------------------}
  TCandidateString = class(TObject)
  private
    fBankAccountNumber: string;
    fAccount: string;
    fEntryType: byte;
    fLCS: TLCS;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure Assign(const aFrom: TCandidateString);
    function  Copy: TCandidateString;

    function  Compare(const aOther: TCandidateString): boolean;

    property  BankAccountNumber: string read fBankAccountNumber
                write fBankAccountNumber;
    property  Account: string read fAccount write fAccount;
    property  EntryType: byte read fEntryType write fEntryType;
    property  LCS: TLCS read fLCS;
  end;


  {-----------------------------------------------------------------------------
    TCandidateStringlist
  -----------------------------------------------------------------------------}
  TCandidateStringList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

  public
    procedure AddOrMerge(const aValue: TCandidateString;
                const aCheckAccount: boolean);

    procedure Assign(const aFrom: TCandidateStringList);

    function  Compare(const aOther: TCandidateStringList): boolean;

    function  FindLCS(const aStartData: boolean; const aDetails: string;
                const aEndData: boolean): boolean; overload;
    function  FindLCS(const aLCS: TLCS): boolean; overload;

    function  FindString(const aValue: TCandidateString): boolean;

    function  GetString(const aIndex: integer): TCandidateString;
    property  Strings[const aIndex: integer]: TCandidateString read GetString;
                default;

    procedure CopyRelevantLCSTo(const aOther: TCandidateStringList;
                const aCheckAccount: boolean);

    procedure LogData;
  end;


  {-----------------------------------------------------------------------------
    TCandidateStringTreeItem
  -----------------------------------------------------------------------------}
  TCandidateStringTreeItem = class(TObject)
  private
    fEntryType: byte;
    fCandidateStrings: TCandidateStringList;

  public
    constructor Create(const aFrom: TCandidateString);
    destructor  Destroy; override;

  public
    property  EntryType: byte read fEntryType;
    property  CandidateStrings: TCandidateStringList read fCandidateStrings;
  
  end;


  {-----------------------------------------------------------------------------
    TCandidateStringTree
  -----------------------------------------------------------------------------}
  TCandidateStringTree = class(TList)
  public
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

    function  GetTreeItem(const aIndex: integer): TCandidateStringTreeItem;
    property  TreeItems[const aIndex: integer]: TCandidateStringTreeItem 
                read GetTreeItem; default;

    function  IndexOf(const aValue: TCandidateString): integer;
                
    procedure AddOrMerge(const aValue: TCandidateString;
                const aCheckAccount: boolean);

    procedure CopyRelevantLCSTo(const aOther: TCandidateStringList;
                const aCheckAccount: boolean);
  end;


  {-----------------------------------------------------------------------------
    TCandidateGroup
  -----------------------------------------------------------------------------}
  TCandidateGroup = class
  private
    fBankAccountNumber: string;
    fAccount: string;
    fEntryType: byte;

    // Do NOT FreeAndNil Items from here, because they are owned by another class
    fCandidates: TList;

  public
    constructor Create(const aBankAccountNumber: string; const aAccount: string;
                  const aEntryType: byte);
    destructor  Destroy; override;

    property  BankAccountNumber: string read fBankAccountNumber;
    property  Account: string read fAccount;
    property  EntryType: byte read fEntryType;

    procedure Add(const aCandidate: TCandidate_Mem);

    function  GetCount: integer;
    property  Count: integer read GetCount;

    procedure GetCandidateStrings(const aRow: integer; const aRowOther: integer;
                const aCandidateStrings: TCandidateStringList);
  end;


  {-----------------------------------------------------------------------------
    TCandidateGroupList
  -----------------------------------------------------------------------------}
  TCandidateGroupList = class(TList)
  private
    fGroupIndex: integer;
    fCandidateIndex: integer;
    fCandidateOtherIndex: integer;

  public
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

    function  GetGroup(const aIndex: integer): TCandidateGroup;
    property  Groups[const aIndex: integer]: TCandidateGroup read GetGroup;

    function  Find(const aBankAccountNumber: string; const aAccount: string;
                const aEntryType: byte; var aIndex: integer): boolean;

    // Setup index
    function  GetFirst: boolean;
    function  GetNext: boolean;

    // Process one candidate according to the index
    procedure GetCandidateStrings(const aCandidateStrings: TCandidateStringList);

    procedure LogData;
  end;


  
  {-----------------------------------------------------------------------------
    TMemsV2 state
  -----------------------------------------------------------------------------}
  TMemsV2State = (
    mstUnInitialised,
    mstProcessing,
    mstRefinement,
    mstFinished
  );


  {-----------------------------------------------------------------------------
    TMemsV2
  -----------------------------------------------------------------------------}
  TMemsV2 = class(TObject)
  private
    fState: TMemsV2State;
    
    // Note: place holders, do not delete
    fBankAccounts: TBank_Account_List;
    fCandidates: TCandidate_Mem_List;
    fRecommended: TRecommended_Mem_List;

    fGroups: TCandidateGroupList;
    fCandidateStrings: TCandidateStringList;
    fRefinementStrings: TCandidateStringList;

  public
    constructor Create(const aBankAccounts: TBank_Account_List;
                  const aCandidates: TCandidate_Mem_List;
                  const aRecommended: TRecommended_Mem_List);
    destructor  Destroy; override;

    // Run functions
    procedure Reset;
    function  AllowedToRun: boolean;
    // Returns true if there is more to process
    function  DoProcessing: boolean;

  private
    // Main functions for getting candidate strings
    procedure GroupCandidateMems;
    procedure GetCandidateStrings;
    procedure EliminateCandidateStrings;
    function  RefineCandidateStrings: boolean;
    procedure AddCandidateStringsToRecommended;

    // Additional helper functions
    function  MoreThanOneAccount(const aDetails: string;
                var aAccount: string): boolean;
    function  LessThanMinimumCount(const aDetails: string): boolean;
    function  FindRecommended(const aRecommended: TRecommended_Mem): boolean;

  public
    property  Candidates: TCandidate_Mem_List read fCandidates;
    property  Recommended: TRecommended_Mem_List read fRecommended;
  end;


  {-----------------------------------------------------------------------------
    LCS
  -----------------------------------------------------------------------------}
  function  FindLCS(const aFirst: string; const aSecond: string;
              var aStartData: boolean; var aDetails: string;
              var aEndData: boolean): boolean;

  function  LongestCommonSubstring(const aS1: string; const aS2: string): string;

  function  FindLCSInLCS(const aLCS1: TLCS; const aLCS2: TLCS;
              var aStartData: boolean; var aDetails: string;
              var aEndData: boolean): boolean;


type
  {-----------------------------------------------------------------------------
    Logging
  -----------------------------------------------------------------------------}
  TLogMethod = procedure(const aMsg: string) of object;

  procedure SetLog(const aLogMethod: TLogMethod);


implementation

uses
  // Note: MyClient may not be fully loaded, don't use Globals
  Math,
  bkConst,
  StDate,
  BKDEFS,
  Windows,
  MMSystem,
  Controls,
  Forms,
  DebugTimer;

{-------------------------------------------------------------------------------
  Logging
-------------------------------------------------------------------------------}
const
  UnitName = 'RecommendedMemsV2';
var
  DebugMe: boolean;
  u_Log: TLogMethod;

//------------------------------------------------------------------------------
procedure SetLog(const aLogMethod: TLogMethod);
begin
  u_Log := aLogMethod;

  DebugMe := true;
end;

//------------------------------------------------------------------------------
procedure Log(const aMsg: string);
begin
  if assigned(u_Log) then
    u_Log(aMsg)
  else
    LogUtil.LogMsg(lmDebug, UnitName, aMsg);
end;


{-------------------------------------------------------------------------------
  TLCS
-------------------------------------------------------------------------------}
function FindLCSInLCS(const aLCS1: TLCS; const aLCS2: TLCS;
  var aStartData: boolean; var aDetails: string; var aEndData: boolean
  ): boolean;
begin
  result := FindLCS(aLCS1.Details, aLCS2.Details, aStartData,
    aDetails, aEndData);

  if not result then
    exit;

  // Keep wildcards intact
  aStartData := (aStartData or aLCS1.StartData or aLCS2.StartData);
  aEndData := (aEndData or aLCS1.EndData or aLCS2.EndData);
end;


{-------------------------------------------------------------------------------
  TLCS
-------------------------------------------------------------------------------}
procedure TLCS.Assign(const aFrom: TLCS);
begin
  // Copy fields
  fStartData := aFrom.fStartData;
  fDetails := aFrom.fDetails;
  fEndData := aFrom.fEndData;
end;

//------------------------------------------------------------------------------
function TLCS.HasStartOrEnd: boolean;
begin
  result := (fStartData or fEndData);
end;

//------------------------------------------------------------------------------
function TLCS.Compare(const aOther: TLCS): boolean;
begin
  result :=
    (StartData = aOther.StartData) and
    (Details = aOther.Details) and
    (EndData = aOther.EndData);
end;

//------------------------------------------------------------------------------
function TLCS.ToString: string;
begin
  result := '';

  if fStartData then
    result := result + '*';

  result := result + fDetails;

  if fEndData then
    result := result + '*';
end;

//------------------------------------------------------------------------------
procedure TLCS.SetData(const aStartData: boolean; const aDetails: string;
  const aEndData: boolean);
begin
  fStartData := aStartData;
  fDetails := aDetails;
  fEndData := aEndData;
end;


{-------------------------------------------------------------------------------
  TCandidateString
-------------------------------------------------------------------------------}
constructor TCandidateString.Create;
begin
  inherited;

  fLCS := TLCS.Create;
end;

//------------------------------------------------------------------------------
destructor TCandidateString.Destroy;
begin
  FreeAndNil(fLCS);

  inherited; // LAST
end;

//------------------------------------------------------------------------------
procedure TCandidateString.Assign(const aFrom: TCandidateString);
begin
  fBankAccountNumber := aFrom.fBankAccountNumber;
  fAccount := aFrom.fAccount;
  fEntryType := aFrom.fEntryType;
  fLCS.Assign(aFrom.LCS);
end;

//------------------------------------------------------------------------------
function TCandidateString.Copy: TCandidateString;
begin
  result := TCandidateString.Create;
  result.Assign(self);
end;

//------------------------------------------------------------------------------
function TCandidateString.Compare(const aOther: TCandidateString): boolean;
begin
  result :=
    (BankAccountNumber = aOther.BankAccountNumber) and
    (Account = aOther.Account) and
    (EntryType = aOther.EntryType) and
    LCS.Compare(aOther.LCS);
end;


{-------------------------------------------------------------------------------
  TCandidateStringList
-------------------------------------------------------------------------------}
procedure TCandidateStringList.Notify(Ptr: Pointer; Action: TListNotification);
var
  varDelete: TObject;
begin
  inherited;

  if (Action <> lnDeleted) then
    exit;

  varDelete := TObject(Ptr);
  FreeAndNil(varDelete);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.AddOrMerge(const aValue: TCandidateString;
  const aCheckAccount: boolean);
var
  i: integer;
  Candidate: TCandidateString;
begin
  if DebugMe then
    CreateDebugTimer('TCandidateStringList.AddOrMerge');

  // Note: At this point we're the owner of aValue

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);

    // BankAccountNumber different?
    if (Candidate.BankAccountNumber <> aValue.BankAccountNumber) then
      continue;

    // Note: no need to check the Account Code during refinement
    if aCheckAccount then
    begin
      // Account different?
      if (Candidate.Account <> aValue.Account) then
        continue;
    end;

    // EntryType different?
    if (Candidate.EntryType <> aValue.EntryType) then
      continue;

    // Different Details?
    if (Candidate.LCS.Details <> aValue.LCS.Details) then
      continue;

    // Merge the wildcards
    Candidate.LCS.StartData := (Candidate.LCS.StartData or aValue.LCS.StartData);
    Candidate.LCS.EndData := (Candidate.LCS.EndData or aValue.LCS.EndData);

    // We've merged the two candidate strings, so we have to delete this one
    aValue.Free;

    // Stop searching
    exit;
  end;

  if DebugMe then
    Log('Add: ' + aValue.LCS.ToString + ', ' + IntToStr(Integer(self)));

  // New entry
  Add(aValue);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.Assign(const aFrom: TCandidateStringList);
var
  i: integer;
  Source: TCandidateString;
  Copy: TCandidateString;
begin
  ASSERT(assigned(aFrom));

  Clear;

  for i := 0 to aFrom.Count-1 do
  begin
    Source := aFrom[i];

    Copy := Source.Copy;

    Add(Copy);
  end;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.Compare(const aOther: TCandidateStringList
  ): boolean;
var
  i: integer;
  Candidate: TCandidateString;
begin
  if (Count <> aOther.Count) then
  begin
    result := false;
    exit;
  end;

  // Note: Compare both ways, e.g. ABCD and DCBA are similar arrays

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);
    if not aOther.FindLCS(Candidate.LCS) then
    begin
      result := false;
      exit;
    end;
  end;

  for i := 0 to aOther.Count-1 do
  begin
    Candidate := aOther[i];
    if not FindLCS(Candidate.LCS) then
    begin
      result := false;
      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindString(const aValue: TCandidateString
  ): boolean;
var
  i: integer;
  Candidate: TCandidateString;
begin
  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);

    // Match?
    if Candidate.Compare(aValue) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindLCS(const aStartData: boolean;
  const aDetails: string; const aEndData: boolean): boolean;
var
  i: integer;
  CandidateString: TCandidateString;
begin
  for i := 0 to Count-1 do
  begin
    CandidateString := GetString(i);
    if (CandidateString.LCS.StartData = aStartData) and
       (CandidateString.LCS.Details = aDetails) and
       (CandidateString.LCS.EndData = aEndData) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindLCS(const aLCS: TLCS): boolean;
begin
  result := FindLCS(aLCS.StartData, aLCS.Details, aLCS.EndData);
end;

//------------------------------------------------------------------------------
function TCandidateStringList.GetString(const aIndex: integer): TCandidateString;
begin
  result := TCandidateString(Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.CopyRelevantLCSTo(
  const aOther: TCandidateStringList; const aCheckAccount: boolean);
var
  i: integer;
  iLowest: integer;
  Candidate: TCandidateString;
  iLength: integer;
  New: TCandidateString;
begin
  iLowest := MaxInt;

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);
    iLength := Length(Candidate.LCS.Details);
    iLowest := Min(iLowest, iLength);
  end;

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);
    iLength := Length(Candidate.LCS.Details);

    // Not the highest?
    if (iLength <> iLowest) then
      continue;

    // Add
    New := Candidate.Copy;
    aOther.AddOrMerge(New, aCheckAccount);
  end;
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.LogData;
var
  i: integer;
  CandidateString: TCandidateString;
  sAccount: string;
  sEntryType: string;
begin
  if not DebugMe then
    exit;

  Log('');
  Log('Candidate Strings:');

  for i := 0 to Count-1 do
  begin
    CandidateString := GetString(i);

    if (CandidateString.Account = '') then
      sAccount := 'Uncharted'
    else
      sAccount := CandidateString.Account;

    sEntryType := IntToStr(CandidateString.EntryType);

    Log(sAccount + '/' + sEntryType + ': ' + CandidateString.LCS.ToString);
  end;
end;


{-------------------------------------------------------------------------------
  TCandidateStringTreeItem
-------------------------------------------------------------------------------}
constructor TCandidateStringTreeItem.Create(const aFrom: TCandidateString);
begin
  fEntryType := aFrom.EntryType;
  fCandidateStrings := TCandidateStringList.Create;
end;

//------------------------------------------------------------------------------
destructor TCandidateStringTreeItem.Destroy;
begin
  FreeAndNil(fCandidateStrings);
  
  inherited;
end;


{-------------------------------------------------------------------------------
  TCandidateStringTree
-------------------------------------------------------------------------------}
procedure TCandidateStringTree.Notify(Ptr: Pointer; Action: TListNotification);
var
  varDelete: TObject;
begin
  inherited;

  if (Action <> lnDeleted) then
    exit;

  varDelete := TObject(Ptr);
  FreeAndNil(varDelete);
end;

//------------------------------------------------------------------------------
function TCandidateStringTree.GetTreeItem(const aIndex: integer
  ): TCandidateStringTreeItem;
begin
  result := TCandidateStringTreeItem(Items[aIndex]);
end;

//------------------------------------------------------------------------------
function TCandidateStringTree.IndexOf(const aValue: TCandidateString): integer;
var
  i: integer;
  TreeItem: TCandidateStringTreeItem;
begin
  for i := 0 to Count-1 do
  begin
    TreeItem := TreeItems[i];

    // Found?
    if (TreeItem.EntryType = aValue.EntryType) then
    begin
      result := i;

      exit;
    end;
  end;

  result := -1;
end;

//------------------------------------------------------------------------------
procedure TCandidateStringTree.AddOrMerge(const aValue: TCandidateString;
  const aCheckAccount: boolean);
var
  iIndex: integer;
  TreeItem: TCandidateStringTreeItem;
begin
  iIndex := IndexOf(aValue);

  // New?
  if (iIndex = -1) then
  begin
    TreeItem := TCandidateStringTreeItem.Create(aValue);
    Add(TreeItem);
  end
  else
    TreeItem := TreeItems[iIndex];

  TreeItem.CandidateStrings.AddOrMerge(aValue, aCheckAccount);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringTree.CopyRelevantLCSTo(
  const aOther: TCandidateStringList; const aCheckAccount: boolean);
var
  i: integer;
  TreeItem: TCandidateStringTreeItem;
begin
  for i := 0 to Count-1 do
  begin
    TreeItem := TreeItems[i];

    TreeItem.CandidateStrings.CopyRelevantLCSTo(aOther, aCheckAccount);
  end;
end;


{-------------------------------------------------------------------------------
  TCandidateGroup
-------------------------------------------------------------------------------}
constructor TCandidateGroup.Create(const aBankAccountNumber: string;
  const aAccount: string; const aEntryType: byte);
begin
  fBankAccountNumber := aBankAccountNumber;
  fAccount := aAccount;
  fEntryType := aEntryType;

  fCandidates := TList.Create;
end;

//------------------------------------------------------------------------------
destructor TCandidateGroup.Destroy;
begin
  FreeAndNil(fCandidates);

  inherited; // LAST
end;

//------------------------------------------------------------------------------
procedure TCandidateGroup.Add(const aCandidate: TCandidate_Mem);
begin
  ASSERT(assigned(aCandidate));

  fCandidates.Add(aCandidate);
end;

//------------------------------------------------------------------------------
function TCandidateGroup.GetCount: integer;
begin
  result := fCandidates.Count;
end;

//------------------------------------------------------------------------------
procedure TCandidateGroup.GetCandidateStrings(const aRow: integer;
  const aRowOther: integer; const aCandidateStrings: TCandidateStringList);
const
  MANUAL = [cbManual, cbManualPayee, cbECodingManual, cbECodingManualPayee, cbManualSuper];
  AUTOMATIC = [cbMemorisedC, cbAnalysis, cbAutoPayee, cbMemorisedM, cbCodeIT];
  MANUAL_AUTOMATIC = MANUAL + AUTOMATIC;
var
  Candidate: TCandidate_Mem;
  CandidateOther: TCandidate_Mem;

  bCandidateManual: boolean;
  bCandidateManualAuto: boolean;
  bCandidateOtherManual: boolean;
  bCandidateOtherManualAuto: boolean;

  bStartData: boolean;
  sDetails: string;
  bEndData: boolean;

  New: TCandidateString;
begin
  if DebugMe then
    CreateDebugTimer('TCandidateGroup.GetCandidateStrings');

  ASSERT(aRowOther > aRow);
  ASSERT(aRow < fCandidates.Count);
  ASSERT(aRowOther < fCandidates.Count);

  // Get candidates
  Candidate := TCandidate_Mem(fCandidates[aRow]);
  CandidateOther := TCandidate_Mem(fCandidates[aRowOther]);

  ASSERT(Candidate.cmFields.cmBank_Account_Number = BankAccountNumber);
  ASSERT(CandidateOther.cmFields.cmBank_Account_Number = BankAccountNumber);
  ASSERT(Candidate.cmFields.cmAccount <> '');
  ASSERT(Candidate.cmFields.cmAccount = Account);
  ASSERT(CandidateOther.cmFields.cmAccount <> '');
  ASSERT(CandidateOther.cmFields.cmAccount = Account);
  ASSERT(Candidate.cmFields.cmType = EntryType);
  ASSERT(CandidateOther.cmFields.cmType = EntryType);

  // Determine manual/automatic status
  bCandidateManual := (Candidate.cmFields.cmCoded_By in MANUAL);
  bCandidateManualAuto := (Candidate.cmFields.cmCoded_By in MANUAL_AUTOMATIC);
  bCandidateOtherManual := (CandidateOther.cmFields.cmCoded_By in MANUAL);
  bCandidateOtherManualAuto := (CandidateOther.cmFields.cmCoded_By in MANUAL_AUTOMATIC);

  // Not right combination of Manual/Auto?
  if not ((bCandidateManual and bCandidateOtherManualAuto) or
          (bCandidateOtherManual and bCandidateManualAuto)) then
  begin
    exit;
  end;

  // Can't find longest string?
  if not FindLCS(Candidate.GetStatementDetailsLowerCase,
    CandidateOther.GetStatementDetailsLowerCase, bStartData, sDetails,
    bEndData) then
  begin
    exit;
  end;

  // No start or end tag?
  if not (bStartData or bEndData) then
    exit;

  // Create new candidate string
  New := TCandidateString.Create;
  New.fBankAccountNumber := BankAccountNumber;
  New.Account := Account;
  New.EntryType := EntryType;
  New.LCS.SetData(bStartData, sDetails, bEndData);

  // Add
  aCandidateStrings.AddOrMerge(New, {aCheckAccount=}true);
end;


{-------------------------------------------------------------------------------
  TCandidateGroupList
-------------------------------------------------------------------------------}
procedure TCandidateGroupList.Notify(Ptr: Pointer; Action: TListNotification);
var
  varDelete: TCandidateGroup;
begin
  inherited;

  if (Action <> lnDeleted) then
    exit;

  varDelete := TCandidateGroup(Ptr);
  FreeAndNil(varDelete);
end;

//------------------------------------------------------------------------------
function TCandidateGroupList.GetGroup(const aIndex: integer): TCandidateGroup;
begin
  result := TCandidateGroup(Items[aIndex]);
end;

//------------------------------------------------------------------------------
function TCandidateGroupList.Find(const aBankAccountNumber: string;
  const aAccount: string; const aEntryType: byte; var aIndex: integer): boolean;
var
  i: integer;
  varAccount: TCandidateGroup;
begin
  for i := 0 to Count-1 do
  begin
    varAccount := Items[i];

    // Match?
    if (varAccount.BankAccountNumber = aBankAccountNumber) and
       (varAccount.Account = aAccount) and
       (varAccount.EntryType = aEntryType) then
    begin
      result := true;
      aIndex := i;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TCandidateGroupList.GetFirst: boolean;
begin
  // Nothing to do?
  if (Count = 0) then
  begin
    result := false;
    exit;
  end;

  // Setup index
  fGroupIndex := 0;
  // Always at least one candidate per group
  fCandidateIndex := 0;
  fCandidateOtherIndex := 0;

  // We want (0, 0, 1), so we let GetNext do this
  result := GetNext;
end;

//------------------------------------------------------------------------------
function TCandidateGroupList.GetNext: boolean;
var
  Group: TCandidateGroup;
begin
  ASSERT((0 <= fGroupIndex) and (fGroupIndex < Count));
  Group := GetGroup(fGroupIndex);
  ASSERT((0 <= fCandidateIndex) and (fCandidateIndex < Group.Count));
  ASSERT((0 <= fCandidateOtherIndex) and (fCandidateOtherIndex < Group.Count));

  // Next candidate other
  Inc(fCandidateOtherIndex);

  // Last candidate other?
  while (fCandidateOtherIndex = Group.Count) do
  begin
    // Next candidate
    Inc(fCandidateIndex);

    // Last candidate?
    if (fCandidateIndex = Group.Count) then
    begin
      // Next group
      Inc(fGroupIndex);

      // Last group?
      if (fGroupIndex = Count) then
      begin
        result := false;
        exit;
      end;

      Group := GetGroup(fGroupIndex);

      fCandidateIndex := 0;
    end;

    // Always searching new ones, not old ones or self (because of A-B = B-A)
    fCandidateOtherIndex := fCandidateIndex + 1;
  end;

  ASSERT((0 <= fGroupIndex) and (fGroupIndex < Count));
  ASSERT((0 <= fCandidateIndex) and (fCandidateIndex < Group.Count));
  ASSERT((0 <= fCandidateOtherIndex) and (fCandidateOtherIndex < Group.Count));

  result := true;
end;

//------------------------------------------------------------------------------
procedure TCandidateGroupList.GetCandidateStrings(
  const aCandidateStrings: TCandidateStringList);
var
  Group: TCandidateGroup;
begin
  // Get group
  ASSERT((0 <= fGroupIndex) and (fGroupIndex < Count));
  Group := GetGroup(fGroupIndex);
  ASSERT((0 <= fCandidateIndex) and (fCandidateIndex < Group.Count));
  ASSERT((0 <= fCandidateOtherIndex) and (fCandidateOtherIndex < Group.Count));

  // One candidate row at the time
  Group.GetCandidateStrings(fCandidateIndex, fCandidateOtherIndex,
    aCandidateStrings);
end;

//------------------------------------------------------------------------------
procedure TCandidateGroupList.LogData;
var
  i: integer;
  Group: TCandidateGroup;
begin
  if not DebugMe then
    exit;

  Log('BankAccountNumber/Account/EntryType groups:');

  for i := 0 to Count-1 do
  begin
    Group := TCandidateGroup(Get(i));

    Log(Group.BankAccountNumber + '/' + Group.Account + '/' + IntToStr(Group.EntryType));
  end;
end;


{-------------------------------------------------------------------------------
  TMemsV2
-------------------------------------------------------------------------------}
constructor TMemsV2.Create(const aBankAccounts: TBank_Account_List; 
  const aCandidates: TCandidate_Mem_List;
  const aRecommended: TRecommended_Mem_List);
begin
  ASSERT(assigned(aBankAccounts));
  ASSERT(assigned(aCandidates));
  ASSERT(assigned(aRecommended));

  fBankAccounts := aBankAccounts;
  fCandidates := aCandidates;
  fRecommended := aRecommended;

  fGroups := TCandidateGroupList.Create;
  fCandidateStrings := TCandidateStringList.Create;
  fRefinementStrings := TCandidateStringList.Create;

  Reset;
end;

//------------------------------------------------------------------------------
destructor TMemsV2.Destroy;
begin
  FreeAndNil(fGroups);
  FreeAndNil(fCandidateStrings);
  FreeAndNil(fRefinementStrings);

  inherited; // LAST
end;

//------------------------------------------------------------------------------
procedure TMemsV2.Reset;
begin
  fState := mstUnInitialised;

  fGroups.Clear;
  fCandidateStrings.Clear;
  fRefinementStrings.Clear;
end;

//------------------------------------------------------------------------------
function TMemsV2.AllowedToRun;
const
  MIN_MONTHS = 3;
  MIN_TRANSACTIONS = 150;
var
  dtMonthsAgo: TStDate;
  iCount: integer;
  iBank: integer;
  BankAccount: TBank_Account;
  iTrans: integer;
  Transaction: pTransaction_Rec;
begin
  // Init
  dtMonthsAgo := IncDate(CurrentDate, 0, MIN_MONTHS, 0);
  iCount := 0;

  // Search transactions for criteria
  for iBank := 0 to fBankAccounts.ItemCount-1 do
  begin
    BankAccount := fBankAccounts.Bank_Account_At(iBank);

    for iTrans := 0 to BankAccount.baTransaction_List.ItemCount-1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(iTrans);

      // Transaction date older than three months?
      if (Transaction.txDate_Effective < dtMonthsAgo) then
      begin
        result := true;
        exit;
      end;

      // More than 150 transactions?
      Inc(iCount);
      if (iCount >= MIN_TRANSACTIONS) then
      begin
        result := true;
        exit;
      end;
    end;
  end;

  // Note: Due to the volume of calls, don't Log anything here
  
  result := false;
end;

//------------------------------------------------------------------------------
function TMemsV2.DoProcessing: boolean;
const
  MORE_PROCESSING_TO_DO = true;
  NO_MORE_PROCESSING_TO_DO = false;
  MAX_ITERATION = 10;
var
  iIteration: integer;
begin
  if DebugMe then
    CreateDebugTimer('TMemsV2.DoProcessing');

  result := NO_MORE_PROCESSING_TO_DO;

  // Handle state
  case fState of
    mstUnInitialised:
    begin
      // Allowed to run on current data?
      if AllowedToRun then
      begin
        // Group candidate mems
        GroupCandidateMems;
        if DebugMe then
          fGroups.LogData;

        // Something to process?
        if fGroups.GetFirst then
        begin
          // Update state
          fState := mstProcessing;
          result := MORE_PROCESSING_TO_DO;
        end
        else
        begin
          // Update state
          fState := mstFinished;
          result := NO_MORE_PROCESSING_TO_DO;
        end;
      end
      else
      begin
        // Update state
        fState := mstFinished;
        result := NO_MORE_PROCESSING_TO_DO;
      end;
    end;

    mstProcessing: 
    begin
      // Do one unit of work
      GetCandidateStrings;

      // More to process?
      if fGroups.GetNext then
      begin
        // Update state
        result := MORE_PROCESSING_TO_DO;
      end
      else
      begin
        // Update state
        fState := mstRefinement;
        result := MORE_PROCESSING_TO_DO;
      end;
    end;

    mstRefinement:
    begin
      // Iterate over Eliminate and Refine
      for iIteration := 1 to MAX_ITERATION do
      begin
        if DebugMe then
        begin
          Log('');
          Log('ITERATION: ' + IntToStr(iIteration));
          fCandidateStrings.LogData;
        end;

        EliminateCandidateStrings;

        { Last iteration?
          Note: we don't run RefineCandidateStrings on the last iteration, because
          it will wipe out the Account Codes if it has new values.
        }
        if (iIteration = MAX_ITERATION) then
          break;

        // Candidate strings are the same after refining?
        if not RefineCandidateStrings then
        begin
          if DebugMe then
          begin
            Log('');
            Log('Candidates after refinement are identical');
          end;

          break;
        end;
      end;

      if DebugMe then
      begin
        Log('');
        Log('FINAL RESULT:');
        fCandidateStrings.LogData;
      end;

      // Add final result to recommended mems
      AddCandidateStringsToRecommended;

      // Update state
      fState := mstFinished;
      result := MORE_PROCESSING_TO_DO;
    end;
    
    mstFinished:
    begin
      // Update state
      result := NO_MORE_PROCESSING_TO_DO;
    end;

    else
      ASSERT(false);
  end;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.GroupCandidateMems;
var
  i: integer;
  Candidate: TCandidate_Mem;
  sBankAccountNumber: string;
  sAccount: string;
  byEntryType: byte;
  iFound: integer;
  varAdd: TCandidateGroup;
begin
  if DebugMe then
    CreateDebugTimer('TMemsV2.GroupCandidateMems');

  for i := 0 to Candidates.ItemCount-1 do
  begin
    Candidate := Candidates[i];

    // Uncoded transaction?
    sAccount := Candidate.cmFields.cmAccount;
    if (sAccount = '') then
      continue;

    // DISSECTED?
    if (sAccount = DISSECT_DESC) then
      continue;

    // Add to account
    sBankAccountNumber := Candidate.cmFields.cmBank_Account_Number;
    byEntryType := Candidate.cmFields.cmType;
    if fGroups.Find(sBankAccountNumber, sAccount, byEntryType, iFound) then
      varAdd := fGroups[iFound]
    else
    begin
      varAdd := TCandidateGroup.Create(sBankAccountNumber, sAccount, byEntryType
        );
      fGroups.Add(varAdd);
    end;
    ASSERT(assigned(varAdd));

    varAdd.Add(Candidate);
  end;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.GetCandidateStrings;
begin
  fGroups.GetCandidateStrings(fCandidateStrings);
end;

//------------------------------------------------------------------------------
procedure TMemsV2.EliminateCandidateStrings;
var
  i: integer;
  CandidateString: TCandidateString;
  sDetails: string;
  sAccount: string;
begin
  if DebugMe then
  begin
    Log('');
    Log('String Elimination:');
  end;

  for i := fCandidateStrings.Count-1 downto 0 do
  begin
    CandidateString := fCandidateStrings[i];
    sDetails := CandidateString.LCS.Details;

    if MoreThanOneAccount(sDetails, sAccount) then
    begin
      if DebugMe then
        Log('More than one account: '+CandidateString.LCS.ToString);
      fCandidateStrings.Delete(i);
      continue;
    end
    else
    begin
      { Note: after refinement the Account Code is gone, so we must join them
        together again here. }
      CandidateString.Account := sAccount;
    end;

    if LessThanMinimumCount(sDetails) then
    begin
      if DebugMe then
        Log('Count less than minimum: '+CandidateString.LCS.ToString);
      fCandidateStrings.Delete(i);
      continue;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMemsV2.MoreThanOneAccount(const aDetails: string;
  var aAccount: string): boolean;
var
  bFirstAccount: boolean;
  sAccountFound: string;
  i: integer;
  Candidate: TCandidate_Mem;
  sAccount: string;
  sDetails: string;
  iPos: integer;
begin
  bFirstAccount := true;

  for i := 0 to fCandidates.ItemCount-1 do
  begin
    Candidate := fCandidates[i];

    // Uncoded? (Coded candidates only)
    sAccount := Candidate.cmFields.cmAccount;
    if (sAccount = '') then
      continue;

    // Position of partial match within details
    sDetails := Candidate.GetStatementDetailsLowerCase;
    iPos := Pos(aDetails, sDetails);
    if (iPos = 0) then
      continue;

    // First time we found an account?
    if bFirstAccount then
    begin
      bFirstAccount := false;
      sAccountFound := sAccount;

      continue;
    end;

    // Different account?
    if (sAccountFound <> sAccount) then
    begin
      if DebugMe then
        Log('More than one account: ' + sAccountFound + ' <> ' + sAccount);

      // More than one account found, stop looking
      result := true;
      exit;
    end;
  end;

  ASSERT(not bFirstAccount, 'There should always be a match');
  aAccount := sAccountFound;

  result := false;
end;

//------------------------------------------------------------------------------
function TMemsV2.LessThanMinimumCount(const aDetails: string): boolean;
const
  MIN_COUNT = 3;
var
  iCount: integer;
  i: integer;
  Candidate: TCandidate_Mem;
  sDetails: string;
  iPos: integer;
begin
  iCount := 0;

  for i := 0 to fCandidates.ItemCount-1 do
  begin
    Candidate := fCandidates[i];

    // Position of partial match within details
    sDetails := Candidate.GetStatementDetailsLowerCase;
    iPos := Pos(aDetails, sDetails);
    if (iPos = 0) then
      continue;

    iCount := iCount + Candidate.cmFields.cmCount;

    { Minimum already met?
      Note: stop searching which prevents searching the entire list. }
    if (iCount >= MIN_COUNT) then
    begin
      result := false;
      exit;
    end;
  end;

  // After having searched all, still below minimum?
  if (iCount < MIN_COUNT) then
  begin
    result := true;
    exit;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TMemsV2.RefineCandidateStrings: boolean;
var
  TempStrings: TCandidateStringTree;
  iRow: integer;
  iRowOther: integer;
  Candidate: TCandidateString;
  CandidateOther: TCandidateString;
  bStartData: boolean;
  sDetails: string;
  bEndData: boolean;
  New: TCandidateString;
begin
  if DebugMe then
  begin
    Log('');
    Log('String Refinement:');
  end;

  { Note: the Account Code will be lost during this process, but will be
    recovered again during the string elimination process. New refined strings
    are not checked for a minimum size. }

  TempStrings := TCandidateStringTree.Create;
  try
    for iRow := 0 to fCandidateStrings.Count-1 do
    begin
      TempStrings.Clear;
      
      for iRowOther := 0 to fCandidateStrings.Count-1 do
      begin
        { Note: it's okay to compare against itself, because we want to retain 
          the LCS if there's only one item per EntryType. }
            
        Candidate := fCandidateStrings[iRow];
        CandidateOther := fCandidateStrings[iRowOther];

        // BankAccountNumber mismatch?
        if (Candidate.BankAccountNumber <> CandidateOther.BankAccountNumber) then
          continue;

        // Note: no need to do Account Code

        // Entry type mismatch?
        if (Candidate.EntryType <> CandidateOther.EntryType) then
          continue;

        // Found new longer string?
        if FindLCSinLCS(Candidate.LCS, CandidateOther.LCS, bStartData, sDetails,
          bEndData) then
        begin
          // New LCS
          New := TCandidateString.Create;
          New.BankAccountNumber := Candidate.BankAccountNumber;
          New.Account := Candidate.Account;
          New.EntryType := Candidate.EntryType;
          New.LCS.SetData(bStartData, sDetails, bEndData);
          TempStrings.AddOrMerge(New, {aCheckAccount=}false);
        end
        else
        begin
          // Original LCS
          New := Candidate.Copy;
          TempStrings.AddOrMerge(New, {aCheckAccount=}false);
        end;
      end;

      { Copy the top LCS (longest string, could be multiple) to the refinement
        strings. }
      TempStrings.CopyRelevantLCSTo(fRefinementStrings, {aCheckAccount=}false);
    end;
  finally
    FreeAndNil(TempStrings);
  end;

  // The refinement produces the same candidate strings?
  if fCandidateStrings.Compare(fRefinementStrings) then
  begin
    // Don't iterate anymore
    result := false;
    exit;
  end;

  // Copy refinement strings across to candidate strings
  fCandidateStrings.Clear;
  fCandidateStrings.Assign(fRefinementStrings);
  fRefinementStrings.Clear;

  result := true;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.AddCandidateStringsToRecommended;
var
  i: integer;
  Candidate: TCandidateString;
  New: TRecommended_Mem;
begin
  for i := 0 to fCandidateStrings.Count-1 do
  begin
    Candidate := fCandidateStrings[i];

    // Create new
    New := TRecommended_Mem.Create;
    New.rmFields.rmBank_Account_Number := Candidate.BankAccountNumber;
    New.rmFields.rmAccount := Candidate.Account;
    New.rmFields.rmType := Candidate.EntryType;
    New.rmFields.rmStatement_Details := Candidate.LCS.ToString;

    { Already exists?
      Note: don't use Recommended.Search, because it compares other fields, that
      are always different, as well.
    }
    if FindRecommended(New) then
    begin
      FreeAndNil(New);
      continue;
    end;

    if DebugMe then
      Log('Add suggested mem: ' + New.rmFields.rmStatement_Details);

    try
      fRecommended.Insert(New);
    except
      ; // Ignore, we already did our best to check for duplicates
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMemsV2.FindRecommended(const aRecommended: TRecommended_Mem): boolean;
var
  i: integer;
  RecommendedOther: TRecommended_Mem;
begin
  for i := 0 to Recommended.ItemCount-1 do
  begin
    RecommendedOther := Recommended.Recommended_Mem_At(i);

    // Already exists?
    if (aRecommended.rmFields.rmBank_Account_Number = RecommendedOther.rmFields.rmBank_Account_Number) and
       (aRecommended.rmFields.rmAccount = RecommendedOther.rmFields.rmAccount) and
       (aRecommended.rmFields.rmType = RecommendedOther.rmFields.rmType) and        
       (aRecommended.rmFields.rmStatement_Details = RecommendedOther.rmFields.rmStatement_Details) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;


{-------------------------------------------------------------------------------
  FindLCS
-------------------------------------------------------------------------------}
function FindLCS(const aFirst: string; const aSecond: string;
  var aStartData: boolean; var aDetails: string; var aEndData: boolean
  ): boolean;
var
  iPos1: integer;
  iPos2: integer;
  iLastPos1: integer;
  iLastPos2: integer;
  iLength1: integer;
  iLength2: integer;
begin
  if DebugMe then
    CreateDebugTimer('FindLCS');

  // Longest match
  aDetails := LongestCommonSubstring(aFirst, aSecond);
  if (aDetails = '') then
  begin
    result := false;
    exit;
  end;

  // Data BEFORE the Details?
  iPos1 := Pos(aDetails, aFirst);
  iPos2 := Pos(aDetails, aSecond);
  aStartData := (iPos1 > 1) or (iPos2 > 1);

  // Data AFTER the Details?
  iLastPos1 := iPos1 + Length(aDetails) - 1;
  iLastPos2 := iPos2 + Length(aDetails) - 1;
  iLength1 := Length(aFirst);
  iLength2 := Length(aSecond);
  aEndData := (iLastPos1 < iLength1) or (iLastPos2 < iLength2);

  result := true;
end;


{$IFDEF DEBUG_LCS}
function CompareStringSection(const aFirst: string; const aFirstIndex: integer;
  const aSecond: string; const aSecondIndex: integer; const aCount: integer
  ): boolean;
var
  i: integer;
  chFirst: char;
  chSecond: char;
begin
  for i := 0 to aCount-1 do
  begin
    chFirst := aFirst[aFirstIndex + i];
    chSecond := aSecond[aSecondIndex + i];
    if (chFirst <> chSecond) then
    begin
      result := false;

      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function LongestCommonSubstringOld(const aS1: string; const aS2: string): string;
const
  MIN_LENGTH = 3;
var
  I, J, K: Integer;
  LSubString: String;
begin
  if DebugMe then
    CreateDebugTimer('LongestCommonSubstringOld');

  Result := '';
  for I := 1 to Length(aS1) do for J := 1 to Length(aS2) do
  begin
    K := MIN_LENGTH;
    while (K <= Length(aS1)) and (K <= Length(aS2)) do
    begin
      if CompareStringSection(aS1, I, aS2, J, K) then
      begin
        LSubString := Copy(aS1, I, K);
      end else
      begin
        if Length(LSubString) > Length(Result) then Result := LSubString;
        LSubString := '';
      end;
      if Length(LSubString) > Length(Result) then Result := LSubString;
      LSubString := '';
      Inc(K);
    end;
  end;

  result := Trim(result);
  if (Length(result) < MIN_LENGTH) then
    result := '';
end;
{$ENDIF}


{-------------------------------------------------------------------------------
  Based on LCS Java algorithm from WikiBooks

  http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_substring
-------------------------------------------------------------------------------}
function LongestCommonSubstring(const aS1: string; const aS2: string): string;
const
  MIN_LENGTH = 3;
var
  iStart: integer;
  iMax: integer;
  i: integer;
  j: integer;
  iCount: integer;
begin
  if DebugMe then
    CreateDebugTimer('LongestCommonSubstring');

  iStart := 1;
  iMax := 0;

  for i := 1 to Length(aS1) do
  begin
    for j := 1 to Length(aS2) do
    begin
      iCount := 0;
      while (aS1[i + iCount] = aS2[j + iCount]) do
      begin
        Inc(iCount);
        if ((i + iCount) > Length(aS1)) or ((j + iCount) > Length(aS2)) then
          break;
      end;

      if (iCount > iMax) then
      begin
        iStart := i;
        iMax := iCount;
      end;
    end;
  end;

  result := Copy(aS1, iStart, iMax);
  result := Trim(result);
  if (Length(result) < MIN_LENGTH) then
    result := '';

{$IFDEF DEBUG_LCS}
  ASSERT(result = LongestCommonSubstringOld(aS1, aS2), aS1 + ', ' + aS2 + ' = ' + result + ' <> ' + LongestCommonSubstringOld(aS1, aS2));
{$ENDIF}
end;


{-------------------------------------------------------------------------------
  Initialization
-------------------------------------------------------------------------------}
initialization
begin
  DebugMe := DebugUnit(UnitName);
end;


end.