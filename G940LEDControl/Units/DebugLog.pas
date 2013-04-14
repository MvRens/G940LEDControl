unit DebugLog;

interface
type
  TCustomDebugLogConsumer = class(TObject)
  public
    procedure LogValue(const AIdentifier: string; const AValue: Boolean); overload; virtual; abstract;
    procedure LogValue(const AIdentifier: string; const AValue: TDateTime); overload; virtual; abstract;
    procedure LogValue(const AIdentifier: string; const AValue: Integer); overload; virtual; abstract;

    procedure Log(const AMsg: string); virtual; abstract;
    procedure LogFmt(const AMsg: string; const AArgs: array of const); virtual; abstract;

    procedure LogWarning(const AMsg: string); virtual; abstract;
    procedure LogWarningFmt(const AMsg: string; const AArgs: array of const); virtual; abstract;

    procedure LogError(const AMsg: string); virtual; abstract;
    procedure LogErrorFmt(const AMsg: string; const AArgs: array of const); virtual; abstract;

    procedure LogMethodEnter(const AMethodName: string); virtual; abstract;
    procedure LogMethodExit(const AMethodName: string); virtual; abstract;

    procedure Indent; virtual; abstract;
    procedure UnIndent; virtual; abstract;
    procedure Separator; virtual; abstract;
  end;


  procedure SetDebugLogConsumer(AConsumer: TCustomDebugLogConsumer);
  procedure ClearDebugLogConsumer;

  function Debug: TCustomDebugLogConsumer;


implementation
uses
  SysUtils;


var
  DebugLogConsumer: TCustomDebugLogConsumer;


type
  TNullDebugLogConsumer = class(TCustomDebugLogConsumer)
  public
    procedure Log(const AMsg: string); override;
    procedure LogFmt(const AMsg: string; const AArgs: array of const); override;

    procedure LogWarning(const AMsg: string); override;
    procedure LogWarningFmt(const AMsg: string; const AArgs: array of const); override;

    procedure LogError(const AMsg: string); override;
    procedure LogErrorFmt(const AMsg: string; const AArgs: array of const); override;

    procedure LogValue(const AIdentifier: string; const AValue: Boolean); overload; override;
    procedure LogValue(const AIdentifier: string; const AValue: TDateTime); overload; override;
    procedure LogValue(const AIdentifier: string; const AValue: Integer); overload; override;

    procedure LogMethodEnter(const AMethodName: string); override;
    procedure LogMethodExit(const AMethodName: string); override;

    procedure Indent; override;
    procedure UnIndent; override;
    procedure Separator; override;
  end;



procedure SetDebugLogConsumer(AConsumer: TCustomDebugLogConsumer);
begin
  if (not Assigned(DebugLogConsumer)) or (AConsumer <> DebugLogConsumer) then
  begin
    FreeAndNil(DebugLogConsumer);

    if Assigned(AConsumer) then
      DebugLogConsumer := AConsumer
    else
      DebugLogConsumer := TNullDebugLogConsumer.Create;
  end;
end;


procedure ClearDebugLogConsumer;
begin
  SetDebugLogConsumer(nil);
end;


function Debug: TCustomDebugLogConsumer;
begin
  Result := DebugLogConsumer;
end;


{ TNullDebugLogConsumer }
procedure TNullDebugLogConsumer.Log(const AMsg: string);
begin
end;


procedure TNullDebugLogConsumer.LogFmt(const AMsg: string; const AArgs: array of const);
begin
end;


procedure TNullDebugLogConsumer.LogWarning(const AMsg: string);
begin
end;


procedure TNullDebugLogConsumer.LogWarningFmt(const AMsg: string; const AArgs: array of const);
begin
end;


procedure TNullDebugLogConsumer.LogError(const AMsg: string);
begin
end;


procedure TNullDebugLogConsumer.LogErrorFmt(const AMsg: string; const AArgs: array of const);
begin
end;


procedure TNullDebugLogConsumer.LogValue(const AIdentifier: string; const AValue: Boolean);
begin
end;


procedure TNullDebugLogConsumer.LogValue(const AIdentifier: string; const AValue: TDateTime);
begin
end;


procedure TNullDebugLogConsumer.LogValue(const AIdentifier: string; const AValue: Integer);
begin
end;


procedure TNullDebugLogConsumer.LogMethodEnter(const AMethodName: string);
begin
end;


procedure TNullDebugLogConsumer.LogMethodExit(const AMethodName: string);
begin
end;


procedure TNullDebugLogConsumer.Indent;
begin
end;


procedure TNullDebugLogConsumer.UnIndent;
begin
end;


procedure TNullDebugLogConsumer.Separator;
begin
end;


initialization
  ClearDebugLogConsumer;

finalization
  FreeAndNil(DebugLogConsumer);

end.
