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
  TM_NOTIFY_DEVICESTATE = 2002;


type
  TG940LEDStateConsumer = class(TLEDStateConsumer)
  private
    FDirectInput: IDirectInput8;
    FThrottleDevice: IDirectInputDevice8;
  protected
    procedure MsgFindThrottleDevice(var msg: TOmniMessage); message TM_FINDTHROTTLEDEVICE;
  protected
    function Initialize: Boolean; override;

    procedure FindThrottleDevice;
    procedure FoundThrottleDevice(ADeviceGUID: TGUID);

    procedure SetDeviceState(AState: Integer);

    procedure Update; override;

    property DirectInput: IDirectInput8 read FDirectInput;
    property ThrottleDevice: IDirectInputDevice8 read FThrottleDevice;
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



(*
type
  TRunInMainThreadSetLEDs = class(TOmniWaitableValue, IRunInMainThread)
  private
    FDevice: IDirectInputDevice8;
    FRed: Byte;
    FGreen: Byte;
  protected
    { IRunInMainThread }
    procedure Execute;
  public
    constructor Create(ADevice: IDirectInputDevice8; ARed, AGreen: Byte);
  end;
*)


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


{
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

    lsWarning:
      begin
        red := True;
        green := True;

        StartBlinkTimer;
      end;

    lsError:
      begin
        red := True;

        StartBlinkTimer;
      end;
  end;

  SetBit(FRed, ALEDIndex, red);
  SetBit(FGreen, ALEDIndex, green);

  inherited;
end;

}

{
procedure TG940LEDStateConsumer.Changed;
begin
  inherited;

  if Assigned(ThrottleDevice) then
    { Logitech SDK will not change the color outside of the main thread
    RunInMainThread(TRunInMainThreadSetLEDs.Create(ThrottleDevice, FRed, FGreen), Destroying);
end;
}


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
    SetDeviceState(DEVICESTATE_FOUND);
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


procedure TG940LEDStateConsumer.MsgFindThrottleDevice(var msg: TOmniMessage);
begin
  FindThrottleDevice;
end;


{ TRunInMainThreadSetLEDs }
(*
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
*)

end.
