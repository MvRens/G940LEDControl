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
  MSG_NOTIFY_DEVICESTATE = MSG_CONSUMER_OFFSET + 2;

type
  TG940LEDStateConsumer = class(TLEDStateConsumer)
  private
    FDirectInput: IDirectInput8;
    FThrottleDevice: IDirectInputDevice8;

    FRed: Byte;
    FGreen: Byte;
  protected
    procedure MsgFindThrottleDevice(var msg: TOmniMessage); message MSG_FINDTHROTTLEDEVICE;
  protected
    function Initialize: Boolean; override;
    procedure ResetLEDState; override;
    procedure LEDStateChanged(ALEDIndex: Integer; AState: TLEDState); override;
    procedure Changed; override;

    procedure FindThrottleDevice;
    procedure FoundThrottleDevice(ADeviceGUID: TGUID);

    procedure SetDeviceState(AState: Integer);

    property DirectInput: IDirectInput8 read FDirectInput;
    property ThrottleDevice: IDirectInputDevice8 read FThrottleDevice;
  end;


const
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



type
  TRunInMainThreadSetLEDs = class(TInterfacedObject, IRunInMainThread)
  private
    FDevice: IDirectInputDevice8;
    FRed: Byte;
    FGreen: Byte;
  protected
    procedure Execute;
  public
    constructor Create(ADevice: IDirectInputDevice8; ARed, AGreen: Byte);
  end;


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

  if DirectInput8Create(SysInit.HInstance, DIRECTINPUT_VERSION, IDirectInput8, FDirectInput, nil) <> S_OK then
  begin
    Task.SetExitStatus(EXIT_ERROR_DIRECTINPUT, 'Failed to initialize DirectInput');
    exit;
  end;

  Result := True;
  Task.Comm.OtherEndpoint.Send(MSG_FINDTHROTTLEDEVICE);
end;


procedure TG940LEDStateConsumer.ResetLEDState;
begin
  FRed := 0;
  FGreen := $FF;

  inherited;
end;


procedure TG940LEDStateConsumer.LEDStateChanged(ALEDIndex: Integer; AState: TLEDState);

  procedure SetBit(var AMask: Byte; ABit: Integer; ASet: Boolean); inline;
  begin
    if ASet then
      AMask := AMask or (1 shl ABit)
    else
      AMask := AMask and not (1 shl ABit);
  end;

var
  red: Boolean;
  green: Boolean;

begin
  red := False;
  green := False;

  case AState of
    lsGreen:
      green := True;

    lsAmber:
      begin
        red := True;
        green := True;
      end;

    lsRed:
      red := True;

    // ToDo timers voor warning / error
    lsWarning:
      red := True;

    lsError:
      red := True;
  end;

  SetBit(FRed, ALEDIndex, red);
  SetBit(FGreen, ALEDIndex, green);

  inherited;
end;


procedure TG940LEDStateConsumer.Changed;
begin
  inherited;

  if Assigned(ThrottleDevice) then
    { Logitech SDK will not change the color outside of the main thread }
    RunInMainThread(TRunInMainThreadSetLEDs.Create(ThrottleDevice, FRed, FGreen));
end;


procedure TG940LEDStateConsumer.FindThrottleDevice;
begin
  SetDeviceState(DEVICESTATE_SEARCHING);
  DirectInput.EnumDevices(DI8DEVCLASS_GAMECTRL,
                          EnumDevicesProc,
                          Pointer(Self),
                          DIEDFL_ATTACHEDONLY);

  if not Assigned(ThrottleDevice) then
    SetDeviceState(DEVICESTATE_NOTFOUND)
  else
    Changed;
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


{ TRunInMainThreadSetLEDs }
constructor TRunInMainThreadSetLEDs.Create(ADevice: IDirectInputDevice8; ARed, AGreen: Byte);
begin
  inherited Create;

  FDevice := ADevice;
  FRed := ARed;
  FGreen := AGreen;
end;


procedure TRunInMainThreadSetLEDs.Execute;
begin
  SetLEDs(FDevice, FRed, FGreen);
end;

end.
