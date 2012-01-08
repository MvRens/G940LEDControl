unit LEDStateConsumer;

interface
uses
  OtlComm,
  OtlTaskControl,

  LEDFunctionMap,
  LEDStateProvider;


const
  MSG_CLEAR_FUNCTIONS = 1;
  MSG_SET_FUNCTION = 2;
  MSG_INITIALIZE_PROVIDER = 3;
  MSG_FINALIZE_PROVIDER = 4;
  MSG_PROCESS_MESSAGES = 5;
  MSG_FINALIZE = 6;

  MSG_RUN_IN_MAINTHREAD = 7;

  MSG_CONSUMER_OFFSET = MSG_RUN_IN_MAINTHREAD;

  TIMER_PROCESSMESSAGES = 1;

  
type
  { This interface name made me giggle. Because it's true. }
  IRunInMainThread = interface
    ['{68B8F2F7-ED40-4078-9D99-503D7AFA068B}']
    procedure Execute;
  end;
  

  TLEDStateConsumer = class(TOmniWorker, ILEDStateConsumer)
  private
    FFunctionMap: TLEDFunctionMap;
    FStateMap: TLEDStateMap;
    FProvider: TLEDStateProvider;
    FTimerSet: Boolean;
    FChanged: Boolean;
    FUpdateCount: Integer;
  protected
    procedure MsgClearFunctions(var msg: TOmniMessage); message MSG_CLEAR_FUNCTIONS;
    procedure MsgSetFunction(var msg: TOmniMessage); message MSG_SET_FUNCTION;
    procedure MsgInitializeProvider(var msg: TOmniMessage); message MSG_INITIALIZE_PROVIDER;
    procedure MsgFinalizeProvider(var msg: TOmniMessage); message MSG_FINALIZE_PROVIDER;
    procedure MsgProcessMessages(var msg: TOmniMessage); message MSG_PROCESS_MESSAGES;
    procedure MsgFinalize(var msg: TOmniMessage); message MSG_FINALIZE;

    procedure Cleanup; override;

    procedure InitializeProvider(AProviderClass: TLEDStateProviderClass);
    procedure FinalizeProvider;

    procedure RunInMainThread(AExecutor: IRunInMainThread);
    procedure InitializeLEDState; virtual;
    procedure ResetLEDState; virtual;
    procedure LEDStateChanged(ALEDIndex: Integer; AState: TLEDState); virtual;
    procedure Changed; virtual;

    { ILEDStateConsumer }
    function GetFunctionMap: TLEDFunctionMap;
    procedure SetStateByFunction(AFunction: Integer; AState: TLEDState);

    property FunctionMap: TLEDFunctionMap read GetFunctionMap;
    property StateMap: TLEDStateMap read FStateMap;
    property Provider: TLEDStateProvider read FProvider;
    property UpdateCount: Integer read FUpdateCount write FUpdateCount;
  public
    constructor Create;

    procedure BeginUpdate;
    procedure EndUpdate;

    class procedure ClearFunctions(AConsumer: IOmniTaskControl);
    class procedure SetFunction(AConsumer: IOmniTaskControl; ALEDIndex, AFunction: Integer);
    class procedure InitializeStateProvider(AConsumer: IOmniTaskControl; AProviderClass: TLEDStateProviderClass);
    class procedure FinalizeStateProvider(AConsumer: IOmniTaskControl);
    class procedure Finalize(AConsumer: IOmniTaskControl);
  end;



implementation
uses
  SysUtils,
  Windows,
  
  OtlCommon;


const
  G940_LED_COUNT = 8;


{ TLEDStateConsumer }
constructor TLEDStateConsumer.Create;
begin
  inherited;

  FFunctionMap := TLEDFunctionMap.Create;
  FStateMap := TLEDStateMap.Create;

  InitializeLEDState;


end;


procedure TLEDStateConsumer.Cleanup;
begin
  inherited;

  FreeAndNil(FStateMap);
  FreeAndNil(FFunctionMap);
end;


procedure TLEDStateConsumer.BeginUpdate;
begin
  if FUpdateCount = 0 then
    FChanged := False;

  Inc(FUpdateCount);
end;


procedure TLEDStateConsumer.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if (FUpdateCount = 0) and FChanged then
    Changed;
end;


function TLEDStateConsumer.GetFunctionMap: TLEDFunctionMap;
begin
  Result := FFunctionMap;
end;


procedure TLEDStateConsumer.SetStateByFunction(AFunction: Integer; AState: TLEDState);
var
  ledIndex: Integer;

begin
  if FunctionMap.FindFirst(AFunction, ledIndex) then
  repeat
    if StateMap.SetState(ledIndex, AState) then
      LEDStateChanged(ledIndex, AState);
  until not FunctionMap.FindNext(AFunction, ledIndex);
end;



procedure TLEDStateConsumer.MsgClearFunctions(var msg: TOmniMessage);
begin
  FunctionMap.Clear;
end;


procedure TLEDStateConsumer.MsgSetFunction(var msg: TOmniMessage);
var
  values: TOmniValueContainer;

begin
  values := msg.MsgData.AsArray;
  FunctionMap.SetFunction(values[0], values[1]);
end;


procedure TLEDStateConsumer.MsgInitializeProvider(var msg: TOmniMessage);
begin
  InitializeProvider(TLEDStateProviderClass(msg.MsgData.AsPointer));
end;


procedure TLEDStateConsumer.MsgFinalizeProvider(var msg: TOmniMessage);
begin
  FinalizeProvider;
end;


procedure TLEDStateConsumer.MsgProcessMessages(var msg: TOmniMessage);
begin
  BeginUpdate;
  try
    Provider.ProcessMessages;
  finally
    EndUpdate;
  end;
end;


procedure TLEDStateConsumer.MsgFinalize(var msg: TOmniMessage);
begin
  FinalizeProvider;
end;


procedure TLEDStateConsumer.InitializeProvider(AProviderClass: TLEDStateProviderClass);
begin
  FinalizeProvider;

  FProvider := AProviderClass.Create(Self);
  // ToDo exception handling
  Provider.Initialize;

  if Provider.ProcessMessagesInterval > -1 then
  begin
    Task.SetTimer(TIMER_PROCESSMESSAGES, Provider.ProcessMessagesInterval, MSG_PROCESS_MESSAGES);
    FTimerSet := True;
  end;

  InitializeLEDState;
end;


procedure TLEDStateConsumer.FinalizeProvider;
begin
  if Assigned(Provider) then
  begin
    if FTimerSet then
    begin
      Task.ClearTimer(TIMER_PROCESSMESSAGES);
      FTimerSet := False;
    end;

    Provider.Terminate;
    Provider.Finalize;
    FreeAndNil(FProvider);

    StateMap.Clear;
    ResetLEDState;
  end;
end;


procedure TLEDStateConsumer.RunInMainThread(AExecutor: IRunInMainThread);
var
  value: TOmniWaitableValue;

begin
  value := TOmniWaitableValue.Create;
  try
    value.Value.AsInterface := AExecutor;
    Task.Comm.Send(MSG_RUN_IN_MAINTHREAD, value);

    value.WaitFor(INFINITE);
  finally
    FreeAndNil(value);
  end;
end;


procedure TLEDStateConsumer.InitializeLEDState;
var
  ledIndex: Integer;
  state: TLEDState;
  newState: TLEDState;

begin
  BeginUpdate;
  try
    ResetLEDState;

    for ledIndex := 0 to Pred(G940_LED_COUNT) do
    begin
      state := StateMap.GetState(ledIndex, lsGreen);
      newState := state;

      case FunctionMap.GetFunction(ledIndex) of
        FUNCTION_OFF:     newState := lsOff;
        FUNCTION_RED:     newState := lsRed;
        FUNCTION_AMBER:   newState := lsAmber;
        FUNCTION_GREEN:   newState := lsGreen;
      end;

      if state <> newState then
        LEDStateChanged(ledIndex, newState);
    end;
  finally
    EndUpdate;
  end;
end;


procedure TLEDStateConsumer.ResetLEDState;
begin
  if UpdateCount = 0 then
    Changed
  else
    FChanged := True;
end;


procedure TLEDStateConsumer.LEDStateChanged(ALEDIndex: Integer; AState: TLEDState);
begin
  if UpdateCount = 0 then
    Changed
  else
    FChanged := True;
end;


procedure TLEDStateConsumer.Changed;
begin
  FChanged := False;
end;


class procedure TLEDStateConsumer.ClearFunctions(AConsumer: IOmniTaskControl);
begin
  AConsumer.Comm.Send(MSG_CLEAR_FUNCTIONS);
end;


class procedure TLEDStateConsumer.SetFunction(AConsumer: IOmniTaskControl; ALEDIndex, AFunction: Integer);
begin
  AConsumer.Comm.Send(MSG_SET_FUNCTION, [ALEDIndex, AFunction]);
end;


class procedure TLEDStateConsumer.InitializeStateProvider(AConsumer: IOmniTaskControl; AProviderClass: TLEDStateProviderClass);
begin
  AConsumer.Comm.Send(MSG_INITIALIZE_PROVIDER, Pointer(AProviderClass));
end;


class procedure TLEDStateConsumer.FinalizeStateProvider(AConsumer: IOmniTaskControl);
begin
  AConsumer.Comm.Send(MSG_FINALIZE_PROVIDER);
end;


class procedure TLEDStateConsumer.Finalize(AConsumer: IOmniTaskControl);
begin
  AConsumer.Comm.Send(MSG_FINALIZE);
end;

end.
