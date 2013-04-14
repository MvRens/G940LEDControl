unit DebugLogGExperts;

interface
uses
  DebugLog;


type
  TGExpertsDebugLogConsumer = class(TCustomDebugLogConsumer)
  public
    constructor Create;

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


implementation
uses
  Dialogs,
  SysUtils,

  GxDbugIntf;


{ TGExpertsDebugLogConsumer }
constructor TGExpertsDebugLogConsumer.Create;
begin
  if StartDebugWin = 0 then
    raise Exception.Create('Debug log not available; is GExpertsDebugWindow.exe present?');

  Log('G940 LED Control log initialized');
  Separator;
end;


procedure TGExpertsDebugLogConsumer.Log(const AMsg: string);
begin
  SendDebug(AMsg);
end;


procedure TGExpertsDebugLogConsumer.LogFmt(const AMsg: string; const AArgs: array of const);
begin
  SendDebugFmt(AMsg, AArgs);
end;


procedure TGExpertsDebugLogConsumer.LogWarning(const AMsg: string);
begin
  SendDebugWarning(AMsg);
end;


procedure TGExpertsDebugLogConsumer.LogWarningFmt(const AMsg: string; const AArgs: array of const);
begin
  SendDebugFmtEx(AMsg, AArgs, mtWarning);
end;


procedure TGExpertsDebugLogConsumer.LogError(const AMsg: string);
begin
  SendDebug(AMsg);
end;


procedure TGExpertsDebugLogConsumer.LogErrorFmt(const AMsg: string; const AArgs: array of const);
begin
  SendDebugFmtEx(AMsg, AArgs, mtError);
end;


procedure TGExpertsDebugLogConsumer.LogValue(const AIdentifier: string; const AValue: Boolean);
begin
  SendBoolean(AIdentifier, AValue);
end;


procedure TGExpertsDebugLogConsumer.LogValue(const AIdentifier: string; const AValue: TDateTime);
begin
  SendDateTime(AIdentifier, AValue);
end;


procedure TGExpertsDebugLogConsumer.LogValue(const AIdentifier: string; const AValue: Integer);
begin
  SendInteger(AIdentifier, AValue);
end;


procedure TGExpertsDebugLogConsumer.LogMethodEnter(const AMethodName: string);
begin
  SendMethodEnter(AMethodName);
end;


procedure TGExpertsDebugLogConsumer.LogMethodExit(const AMethodName: string);
begin
  SendMethodExit(AMethodName);
end;


procedure TGExpertsDebugLogConsumer.Indent;
begin
  SendIndent;
end;


procedure TGExpertsDebugLogConsumer.UnIndent;
begin
  SendUnIndent;
end;


procedure TGExpertsDebugLogConsumer.Separator;
begin
  SendSeparator;
end;

end.
