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

  MSG_CONSUMER_OFFSET = MSG_PROCESS_MESSAGES;

  TIMER_PROCESSMESSAGES = 1;

  
type
  TLEDStateConsumer = class(TOmniWorker, ILEDStateConsumer)
  private
    FFunctionMap: TLEDFunctionMap;
    FStateMap: TLEDStateMap;
    FProvider: TLEDStateProvider;
    FTimerSet: Boolean;
  protected
    procedure MsgClearFunctions(var msg: TOmniMessage); message MSG_CLEAR_FUNCTIONS;
    procedure MsgSetFunction(var msg: TOmniMessage); message MSG_SET_FUNCTION;
    procedure MsgInitializeProvider(var msg: TOmniMessage); message MSG_INITIALIZE_PROVIDER;
    procedure MsgFinalizeProvider(var msg: TOmniMessage); message MSG_FINALIZE_PROVIDER;
    procedure MsgProcessMessages(var msg: TOmniMessage); message MSG_PROCESS_MESSAGES;

    procedure InitializeProvider(AProviderClass: TLEDStateProviderClass);
    procedure FinalizeProvider;

    procedure LEDStateChanged(ALEDIndex: Integer; AState: TLEDState); virtual;

    { ILEDStateConsumer }
    function GetFunctionMap: TLEDFunctionMap;
    procedure SetStateByFunction(AFunction: Integer; AState: TLEDState);

    property FunctionMap: TLEDFunctionMap read GetFunctionMap;
    property StateMap: TLEDStateMap read FStateMap;
    property Provider: TLEDStateProvider read FProvider;
  public
    constructor Create;
    destructor Destroy; override;

    class procedure ClearFunctions(AConsumer: IOmniTaskControl);
    class procedure SetFunction(AConsumer: IOmniTaskControl; ALEDIndex, AFunction: Integer);
    class procedure InitializeStateProvider(AConsumer: IOmniTaskControl; AProviderClass: TLEDStateProviderClass);
    class procedure FinalizeStateProvider(AConsumer: IOmniTaskControl);
  end;



implementation
uses
  SysUtils,
  
  OtlCommon;


{ TLEDStateConsumer }
constructor TLEDStateConsumer.Create;
begin
  inherited;

  FFunctionMap := TLEDFunctionMap.Create;
  FStateMap := TLEDStateMap.Create;
end;


destructor TLEDStateConsumer.Destroy;
begin
  FinalizeProvider;
  
  FreeAndNil(FStateMap);
  FreeAndNil(FFunctionMap);

  inherited;
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
  Provider.ProcessMessages;
end;


procedure TLEDStateConsumer.InitializeProvider(AProviderClass: TLEDStateProviderClass);
begin
  FinalizeProvider;

  FProvider := AProviderClass.Create(Self);
  // ToDo exception handlign
  Provider.Initialize;

  if Provider.ProcessMessagesInterval > -1 then
  begin
    Task.SetTimer(TIMER_PROCESSMESSAGES, Provider.ProcessMessagesInterval, MSG_PROCESS_MESSAGES);
    FTimerSet := True;
  end;
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
  end;
end;


procedure TLEDStateConsumer.LEDStateChanged(ALEDIndex: Integer; AState: TLEDState);
begin
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

end.
