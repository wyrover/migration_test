unit LogMigrater;

interface

uses
   Migraters,
   logTables,
   MigrateActions;

type

TLogMigrater = class (TMigrater)
  private
    FUserActionLogTable: TUserActionLogTable;
    function GetUserActionLogTable: TUserActionLogTable;

  public
   destructor Destroy; override;
   function ClearData(ForAction: TMigrateAction): Boolean; override;
   property UserActionLogTable: TUserActionLogTable read GetUserActionLogTable;
end;


implementation

uses
    logger,
    SysUtils;

{ TLogMigrater }

function TLogMigrater.ClearData(ForAction: TMigrateAction): Boolean;
var MyAction: TMigrateAction;
begin
    Result := false;
    MyAction := ForAction.InsertAction('Clear logs');
    try
       Connected := true;
       EnableIndexes(MyAction,True);

       DeleteTable(MyAction,'Logs');

       //DeleteTable(MyAction,'AuditLogs');

       //DeleteTable(MyAction,'AuditEntries');

       logger.logMessageProc(Warning,'ALL LOG DATA CLEARED');
       Result := True;
       MyAction.Status := Success;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;

end;

destructor TLogMigrater.Destroy;
begin
  FreeAndNil(FUserActionLogTable);
  inherited;
end;

function TLogMigrater.GetUserActionLogTable: TUserActionLogTable;
begin
    if not Assigned(FUserActionLogTable) then
      FUserActionLogTable := TUserActionLogTable.Create(Connection);
   Result := FUserActionLogTable;
end;

end.

