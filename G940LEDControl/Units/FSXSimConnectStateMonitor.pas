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
    FSimulator: TFSXSimConnectSimulator;
    FSimulatorLock: TCriticalSection;

    procedure DoSetCurrentState(const Value: TFSXSimConnectState);
    procedure DoSetSimulator(const Value: TFSXSimConnectSimulator);
  protected
    property CurrentStateLock: TCriticalSection read FCurrentStateLock;
    property SimulatorLock: TCriticalSection read FCurrentStateLock;
    property Observers: TInterfaceList read FObservers;
  public
    constructor Create;
    destructor Destroy; override;

    class function Instance: TFSXSimConnectStateMonitor;
    class procedure SetCurrentState(AState: TFSXSimConnectState);
    class procedure SetSimulator(ASimulator: TFSXSimConnectSimulator);

    procedure Attach(AObserver: IFSXSimConnectStateObserver);
    procedure Detach(AObserver: IFSXSimConnectStateObserver);

    property CurrentState: TFSXSimConnectState read FCurrentState write DoSetCurrentState;
    property Simulator: TFSXSimConnectSimulator read FSimulator write DoSetSimulator;
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


class procedure TFSXSimConnectStateMonitor.SetSimulator(ASimulator: TFSXSimConnectSimulator);
begin
  Instance.DoSetSimulator(ASimulator);
end;


constructor TFSXSimConnectStateMonitor.Create;
begin
  inherited Create;

  FCurrentStateLock := TCriticalSection.Create;
  FSimulatorLock := TCriticalSection.Create;
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
  if Value <> FCurrentState then
  begin
    CurrentStateLock.Acquire;
    try
      FCurrentState := Value;
    finally
      CurrentStateLock.Release;
    end;

    for observer in Observers do
      (observer as IFSXSimConnectStateObserver).ObserveStateUpdate(CurrentState);
  end;
end;


procedure TFSXSimConnectStateMonitor.DoSetSimulator(const Value: TFSXSimConnectSimulator);
var
  observer: IInterface;

begin
  if Value <> FSimulator then
  begin
    CurrentStateLock.Acquire;
    try
      FSimulator := Value;
    finally
      CurrentStateLock.Release;
    end;

    for observer in Observers do
      (observer as IFSXSimConnectStateObserver).ObserveSimulatorUpdate(Simulator);
  end;
end;

initialization
  FSXSimConnectStateInstance := TFSXSimConnectStateMonitor.Create;

finalization
  FreeAndNil(FSXSimConnectStateInstance);

end.
