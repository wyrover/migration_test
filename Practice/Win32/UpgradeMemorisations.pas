unit UpgradeMemorisations;

interface

uses
  clObj32,
  SysObj32;

procedure UpgradeClient_Memorisation_EntryType(const aClient: TClientObj);

procedure UpgradeAdmin_Memorisation_EntryType(const aAdmin: TSystemObj);


implementation

uses
  SysUtils,
  StrUtils,
  bkConst,
  bkDefs,
  BKMLIO,
  baObj32,
  baList32,
  MemorisationsObj,
  MemUtils,
  baUtils,
  Globals,
  SystemMemorisationList,
  syDefs;

const
  NATIONAL_06 = '06';

{------------------------------------------------------------------------------}
procedure CopyMemorisations(const aMems: TMemorisations_List);
const
  ENTRY_TYPE_FROM = 0;
  ENTRY_TYPE_TO = 49;
var
  iMem: integer;
  Mem: TMemorisation;
  MemCopy: TMemorisation;
begin
  for iMem := 0 to aMems.ItemCount-1 do
  begin
    Mem := aMems.Memorisation_At(iMem);

    // Entry type must be 0:Cheque
    if (Mem.mdFields.mdType <> ENTRY_TYPE_FROM) then
      continue;

    // Must have "match on" criteria
    if not HasMatchOnCriteria(Mem) then
      continue;

    // Create new memorisation, and copy contents
    MemCopy := TMemorisation.Create(Mem.AuditMgr);
    CopyMemorisation(Mem, MemCopy);

    // Change over the entry type
    MemCopy.mdFields.mdType := ENTRY_TYPE_TO;

    // Copy should have no duplicate
    if HasDuplicateMem(MemCopy, aMems) then
    begin
      FreeAndNil(MemCopy);
      continue;
    end;

    // Insert adjusted memorisation
    aMems.Insert_Memorisation(MemCopy);
  end;
end;

{------------------------------------------------------------------------------}
procedure UpgradeClient_Memorisation_EntryType(const aClient: TClientObj);
var
  BankAccounts: TBank_Account_List;
  iBank: integer;
  BankAccount: TBank_Account;
  Mems: TMemorisations_List;
begin
  // New Zealand only
  if (aClient.clFields.clCountry <> whNewZealand) then
    exit;

  BankAccounts := aClient.clBank_Account_List;

  for iBank := 0 to BankAccounts.ItemCount-1 do
  begin
    BankAccount := BankAccounts.Bank_Account_At(iBank);

    // National (06) only
    if not IsSameInstitution(BankAccount, NATIONAL_06) then
      continue;

    Mems := BankAccount.baMemorisations_List;

    CopyMemorisations(Mems);
  end;
end;


{------------------------------------------------------------------------------}
procedure UpgradeAdmin_Memorisation_EntryType(const aAdmin: TSystemObj);
var
  SysMems: TSystem_Memorisation_List;
  iBank: integer;
  SysMem: pSystem_Memorisation_List_Rec;
  Mems: TMemorisations_List;
begin
  // New Zealand only
  if (aAdmin.fdFields.fdCountry <> whNewZealand) then
    exit;

  SysMems := aAdmin.fSystem_Memorisation_List;

  for iBank := SysMems.First to SysMems.Last do
  begin
    SysMem := SysMems.System_Memorisation_At(iBank);

    // National (06) only
    if not IsSameInstitution(SysMem.smBank_Prefix, NATIONAL_06) then
      continue;

    Mems := TMemorisations_List(SysMem.smMemorisations);

    CopyMemorisations(Mems);  
  end;
end;


end.