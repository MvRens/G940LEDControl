unit LEDStateConsumer;

interface
uses
  DirectInput,
  OtlComm,
  OtlTaskControl,

  CustomLEDStateProvider;

  
const
  MSG_FINDTHROTTLEDEVICE = 1;
  MSG_NOTIFY_DEVICESTATE = 2;


type
  TG940LEDStateConsumer = class(TOmniWorker)
  private
    FProviderChannel: IOmniCommunicationEndpoint;
    FDirectInput: IDirectInput8;
    FThrottleDevice: IDirectInputDevice8;
    FFunctionMap: TLEDFunctionMap;
  protected
    procedure MsgFindThrottleDevice(var msg: TOmniMessage); message MSG_FINDTHROTTLEDEVICE;
    procedure MsgUpdateFunctionMap(var msg: TOmniMessage); message MSG_UPDATEFUNCTIONMAP;
    procedure MsgSetStateByFunction(var msg: TOmniMessage); message MSG_SETSTATEBYFUNCTION;
  protected
    function Initialize: Boolean; override;

    procedure FindThrottleDevice;
    procedure FoundThrottleDevice(ADeviceGUID: TGUID);

    procedure SetDeviceState(AState: Integer);

    property DirectInput: IDirectInput8 read FDirectInput;
    property ThrottleDevice: IDirectInputDevice8 read FThrottleDevice;
  public
    constructor Create(AProviderChannel: IOmniCommunicationEndpoint);
    destructor Destroy; override;
  end;


const
  EXIT_ERROR_LOGIJOYSTICKDLL = 1;
  EXIT_ERROR_DIRECTINPUT = 2;


  DEVICESTATE_SEARCHING = 0;
  DEVICESTATE_FOUND = 1;
  DEVICESTATE_NOTFOUND = 2;


implementation
uses
  SysUtils,
  Windows,
  
  LogiJoystickDLL;


function EnumDevicesProc(var lpddi: TDIDeviceInstanceA; pvRef: Pointer): BOOL; stdcall;
var
  vendorID: Word;
  productID: Word;

begin
  Result := True;

  vendorID := LOWORD(lpddi.guidProduct.D1);
  productID := HIWORD(lpddi.guidProduct.D1);

  if (vendorID = VENDOR_LOGITECH) and
     (productID = PRODUCT_G940_THROTTLE) then
  begin
    TG940LEDStateConsumer(pvRef).FoundThrottleDevice(lpddi.guidInstance);
    Result := False;
  end;
end;



{ TG940LEDStateConsumer }
constructor TG940LEDStateConsumer.Create(AProviderChannel: IOmniCommunicationEndpoint);
begin
  inherited Create;

  FProviderChannel := AProviderChannel;
  FFunctionMap := TLEDFunctionMap.Create;
end;


destructor TG940LEDStateConsumer.Destroy;
begin
  FreeAndNil(FFunctionMap);

  inherited;
end;


function TG940LEDStateConsumer.Initialize: Boolean;
begin
  Result := False;

  if not LogiJoystickDLLInitialized then
  begin
    Task.SetExitStatus(EXIT_ERROR_LOGIJOYSTICKDLL, 'Could not load LogiJoystickDLL.dll');
    exit;
  end;

//    btnRetry.Visible := False;
//    SetState(STATE_SEARCHING, False);

  if DirectInput8Create(SysInit.HInstance, DIRECTINPUT_VERSION, IDirectInput8, FDirectInput, nil) <> S_OK then
  begin
    Task.SetExitStatus(EXIT_ERROR_DIRECTINPUT, 'Failed to initialize DirectInput');
    exit;
  end;

  Result := True;

  Task.RegisterComm(FProviderChannel);
  FindThrottleDevice;
end;


procedure TG940LEDStateConsumer.FindThrottleDevice;
begin
  SetDeviceState(DEVICESTATE_SEARCHING);
  DirectInput.EnumDevices(DI8DEVCLASS_GAMECTRL,
                          EnumDevicesProc,
                          Pointer(Self),
                          DIEDFL_ATTACHEDONLY);

  if not Assigned(ThrottleDevice) then
    SetDeviceState(DEVICESTATE_NOTFOUND);
end;


procedure TG940LEDStateConsumer.FoundThrottleDevice(ADeviceGUID: TGUID);
begin
  if DirectInput.CreateDevice(ADeviceGUID, FThrottleDevice, nil) = S_OK then
    SetDeviceState(DEVICESTATE_FOUND);
end;


procedure TG940LEDStateConsumer.SetDeviceState(AState: Integer);
begin
  Task.Comm.Send(MSG_NOTIFY_DEVICESTATE, AState);
end;


procedure TG940LEDStateConsumer.MsgFindThrottleDevice(var msg: TOmniMessage);
begin
  FindThrottleDevice;
end;


procedure TG940LEDStateConsumer.MsgUpdateFunctionMap(var msg: TOmniMessage);
var
  provider: TCustomLEDStateProvider;
  functionMap: TLEDFunctionMap;

begin
  provider := (msg.MsgData.AsObject as TCustomLEDStateProvider);
  functionMap := provider.LockFunctionMap;
  try
    FFunctionMap.Assign(functionMap);
  finally
    provider.UnlockFunctionMap;
  end;
end;


procedure TG940LEDStateConsumer.MsgSetStateByFunction(var msg: TOmniMessage);
begin
  //
end;


//procedure TCustomLEDStateProvider.SetStateByFunction(AFunction: Integer; AState: TLEDState);
//var
//  functionMap: TLEDFunctionMap;
//  ledIndex: Integer;
//
//begin
//  functionMap := LockFunctionMap;
//  try
//    for ledIndex := 0 to Pred(functionMap.Count) do
//      if functionMap.GetFunction(ledIndex) = AFunction then
//      begin
//        if AState <> FState[ledIndex] then
//        begin
//          FState[ledIndex] := AState;
//          ConsumerChannel.Send(MSG_STATECHANGED, [ledIndex, Ord(AState)]);
//        end;
//      end;
//  finally
//    UnlockFunctionMap;
//  end;
//end;

end.
