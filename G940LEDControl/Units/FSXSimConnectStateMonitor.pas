unit FSXSimConnectStateMonitor;

interface
uses
  System.Classes,
  System.SyncObjs,

  FSXSimConnectIntf;


type
  TFSXSimConnectStateMonitor = class(TObject)
  private
    FObservers: TInterfaceList;
    FCurrentStateLock: TCriticalSection;
    FCurrentState: TFSXSimConnectState;

    procedure DoSetCurrentState(const Value: TFSXSimConnectState);
  protected
    property CurrentStateLock: TCriticalSection read FCurrentStateLock;
    property Observers: TInterfaceList read FObservers;
  public
    constructor Create;
    destructor Destroy; override;

    class function Instance: TFSXSimConnectStateMonitor;
    class procedure SetCurrentState(AState: TFSXSimConnectState);

    procedure Attach(AObserver: IFSXSimConnectStateObserver);
    procedure Detach(AObserver: IFSXSimConnectStateObserver);

    property CurrentState: TFSXSimConnectState read FCurrentState write DoSetCurrentState;
  end;


implementation
uses
  System.SysUtils;


var
  FSXSimConnectStateInstance: TFSXSimConnectStateMonitor;


{ TFSXSimConnectState }
class function TFSXSimConnectStateMonitor.Instance: TFSXSimConnectStateMonitor;
begin
  Result := FSXSimConnectStateInstance;
end;


class procedure TFSXSimConnectStateMonitor.SetCurrentState(AState: TFSXSimConnectState);
begin
  Instance.DoSetCurrentState(AState);
end;


constructor TFSXSimConnectStateMonitor.Create;
begin
  inherited Create;

  FCurrentStateLock := TCriticalSection.Create;
  FObservers := TInterfaceList.Create;
end;


destructor TFSXSimConnectStateMonitor.Destroy;
begin
  FreeAndNil(FObservers);
  FreeAndNil(FCurrentStateLock);

  inherited Destroy;
end;


procedure TFSXSimConnectStateMonitor.Attach(AObserver: IFSXSimConnectStateObserver);
begin
  Observers.Add(AObserver as IFSXSimConnectStateObserver);
end;


procedure TFSXSimConnectStateMonitor.Detach(AObserver: IFSXSimConnectStateObserver);
begin
  Observers.Remove(AObserver as IFSXSimConnectStateObserver);
end;


procedure TFSXSimConnectStateMonitor.DoSetCurrentState(const Value: TFSXSimConnectState);
var
  observer: IInterface;

begin
  CurrentStateLock.Acquire;
  try
    if Value <> FCurrentState then
    begin
      FCurrentState := Value;

      for observer in Observers do
        (observer as IFSXSimConnectStateObserver).ObserverStateUpdate(CurrentState);
    end;
  finally
    CurrentStateLock.Release;
  end;
end;


initialization
  FSXSimConnectStateInstance := TFSXSimConnectStateMonitor.Create;

finalization
  FreeAndNil(FSXSimConnectStateInstance);

end.
