unit G940LEDStateConsumer;

interface
uses
  Classes,

  DirectInput,
  OtlComm,
  OtlTaskControl,

  LEDFunctionMap,
  LEDStateConsumer;


const
  MSG_FINDTHROTTLEDEVICE = MSG_CONSUMER_OFFSET + 1;

  
type
  TG940LEDStateConsumer = class(TLEDStateConsumer)
  private
    FDirectInput: IDirectInput8;
    FThrottleDevice: IDirectInputDevice8;
  protected
    procedure MsgFindThrottleDevice(var msg: TOmniMessage); message MSG_FINDTHROTTLEDEVICE;
  protected
    function Initialize: Boolean; override;
    procedure LEDStateChanged(ALEDIndex: Integer; AState: TLEDState); override;

    procedure FindThrottleDevice;
    procedure FoundThrottleDevice(ADeviceGUID: TGUID);

    procedure SetDeviceState(AState: Integer);

    property DirectInput: IDirectInput8 read FDirectInput;
    property ThrottleDevice: IDirectInputDevice8 read FThrottleDevice;
  end;


const
  MSG_NOTIFY_DEVICESTATE = 1;

  DEVICESTATE_SEARCHING = 0;
  DEVICESTATE_FOUND = 1;
  DEVICESTATE_NOTFOUND = 2;

  EXIT_ERROR_LOGIJOYSTICKDLL = 1;
  EXIT_ERROR_DIRECTINPUT = 2;

  
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
function TG940LEDStateConsumer.Initialize: Boolean;
begin
  Result := inherited Initialize;
  if not Result then
    exit;

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
  Task.Comm.OtherEndpoint.Send(MSG_FINDTHROTTLEDEVICE);
end;


procedure TG940LEDStateConsumer.LEDStateChanged(ALEDIndex: Integer; AState: TLEDState);
var
  color: TLogiColor;

begin
  // ToDo SetLEDs gebruiken (vereist override van SetStateByFunction om te groeperen)
  if Assigned(ThrottleDevice) then
  begin
    color := LOGI_GREEN;

    case AState of
      lsOff:      color := LOGI_OFF;
      lsGreen:    color := LOGI_GREEN;
      lsAmber:    color := LOGI_AMBER;
      lsRed:      color := LOGI_RED;

      // ToDo timers voor warning / error
      lsWarning:  color := LOGI_RED;
      lsError:    color := LOGI_RED;
    end;

    SetButtonColor(ThrottleDevice, TLogiPanelButton(ALEDIndex), color);
    ProcessMessages;
  end;
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
