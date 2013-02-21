unit G940LEDStateConsumer;

interface
uses
  Classes,

  DirectInput,
  OtlComm,
  OtlTaskControl,

  LEDStateConsumer;


const
  TM_FINDTHROTTLEDEVICE = 2001;
  TM_TESTTHROTTLEDEVICE = 2002;

  TM_NOTIFY_DEVICESTATE = 2003;


type
  TG940LEDStateConsumer = class(TLEDStateConsumer)
  private
    FDirectInput: IDirectInput8;
    FThrottleDevice: IDirectInputDevice8;
    FTHrottleDeviceGUID: TGUID;
  protected
    procedure TMFindThrottleDevice(var Msg: TOmniMessage); message TM_FINDTHROTTLEDEVICE;
    procedure TMTestThrottleDevice(var Msg: TOmniMessage); message TM_TESTTHROTTLEDEVICE;
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    procedure FindThrottleDevice;
    procedure FoundThrottleDevice(ADeviceGUID: TGUID);

    procedure SetDeviceState(AState: Integer);

    procedure Update; override;

    property DirectInput: IDirectInput8 read FDirectInput;
    property ThrottleDevice: IDirectInputDevice8 read FThrottleDevice;
    property ThrottleDeviceGUID: TGUID read FTHrottleDeviceGUID;
  end;


const
  DEVICESTATE_SEARCHING = 0;
  DEVICESTATE_FOUND = 1;
  DEVICESTATE_NOTFOUND = 2;

  EXIT_ERROR_LOGIJOYSTICKDLL = 9001;
  EXIT_ERROR_DIRECTINPUT = 9002;

  
implementation
uses
  SysUtils,
  Windows,

  OtlCommon,
  OtlTask,

  LEDColorIntf,
  LogiJoystickDLL;


const
  G940_BUTTONCOUNT = 8;


function EnumDevicesProc(var lpddi: TDIDeviceInstanceW; pvRef: Pointer): BOOL; stdcall;
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
  Task.Comm.OtherEndpoint.Send(TM_FINDTHROTTLEDEVICE);
end;


procedure TG940LEDStateConsumer.Cleanup;
begin
  inherited Cleanup;

  if Assigned(ThrottleDevice) then
    SetLEDs(ThrottleDevice, 0, $FF);
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
    Update;
end;


procedure TG940LEDStateConsumer.FoundThrottleDevice(ADeviceGUID: TGUID);
begin
  if DirectInput.CreateDevice(ADeviceGUID, FThrottleDevice, nil) = S_OK then
  begin
    FTHrottleDeviceGUID := ADeviceGUID;
    SetDeviceState(DEVICESTATE_FOUND);
  end;
end;


procedure TG940LEDStateConsumer.SetDeviceState(AState: Integer);
begin
  Task.Comm.Send(TM_NOTIFY_DEVICESTATE, AState);
end;


procedure TG940LEDStateConsumer.Update;

  procedure SetBit(var AMask: Byte; ABit: Integer); inline;
  begin
    AMask := AMask or (1 shl ABit)
  end;


var
  red: Byte;
  green: Byte;
  buttonIndex: Integer;
  buttonColor: TStaticLEDColor;

begin
  if not Assigned(ThrottleDevice) then
    exit;

  red := 0;
  green := 0;

  for buttonIndex := 0 to Pred(G940_BUTTONCOUNT) do
  begin
    if buttonIndex >= ButtonColors.Count then
      buttonColor := lcOff
    else
      buttonColor := (ButtonColors[buttonIndex] as ILEDStateColor).GetCurrentColor;

    case buttonColor of
      lcGreen:
        SetBit(green, buttonIndex);

      lcAmber:
        begin
          SetBit(green, buttonIndex);
          SetBit(red, buttonIndex);
        end;

      lcRed:
        SetBit(red, buttonIndex);
    end;
  end;

  SetLEDs(ThrottleDevice, red, green);
end;


procedure TG940LEDStateConsumer.TMFindThrottleDevice(var Msg: TOmniMessage);
begin
  FindThrottleDevice;
end;


procedure TG940LEDStateConsumer.TMTestThrottleDevice(var Msg: TOmniMessage);
begin
  if Assigned(ThrottleDevice) then
  begin
    if DirectInput.GetDeviceStatus(ThrottleDeviceGUID) = DI_NOTATTACHED then
    begin
      FThrottleDevice := nil;
      SetDeviceState(DEVICESTATE_NOTFOUND);
    end;
  end;
end;

end.
