program Migrator ;

uses
  Forms,
  SYSOBJ32 in '..\Practice\Win32\SYSOBJ32.PAS',
  ADMIN32 in '..\Practice\Win32\ADMIN32.PAS',
  Mainform in 'Mainform.pas' {formMain},
  FromBrowseForm in 'FromBrowseForm.pas' {FromBrowse},
  GuidList in 'GuidList.pas',
  syTables in 'syTables.pas',
  SQLTable in 'SQLTable.pas',
  bkTables in 'bkTables.pas',
  btTables in 'btTables.pas',
  PasswordHash in 'PasswordHash.pas',
  MigrateActions in 'MigrateActions.pas',
  Migraters in 'Migraters.pas',
  ClientMigrater in 'ClientMigrater.pas',
  SystemMigrater in 'SystemMigrater.pas',
  MigrateTable in 'MigrateTable.pas',
  imagesfrm in '..\Practice\Win32\imagesfrm.pas' {AppImages},
  AvailableSQLServers in 'AvailableSQLServers.pas',
  MigrateStats in 'MigrateStats.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TAppImages, AppImages);
  Application.Run;
end.
