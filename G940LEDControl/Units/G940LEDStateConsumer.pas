unit G940LEDStateConsumer;

interface
uses
  Classes,

  DirectInput,
  OtlComm,
  OtlTaskControl,

  LEDFunctionMap,
  LEDStateConsumer,
  LEDStateProvider;


const
  MSG_FINDTHROTTLEDEVICE = MSG_CONSUMER_OFFSET + 1;
  MSG_NOTIFY_DEVICESTATE = MSG_CONSUMER_OFFSET + 2;
  MSG_TIMER_BLINK = MSG_CONSUMER_OFFSET + 3;

  TIMER_BLINK = TIMER_CONSUMER_OFFSET + 1;

type
  TG940LEDStateConsumer = class(TLEDStateConsumer)
  private
    FDirectInput: IDirectInput8;
    FThrottleDevice: IDirectInputDevice8;

    FRed: Byte;
    FGreen: Byte;

    FBlinkTimerStarted: Boolean;
    FBlinkCounter: Integer;
  protected
    procedure MsgFindThrottleDevice(var msg: TOmniMessage); message MSG_FINDTHROTTLEDEVICE;
    procedure MsgTimerBlink(var msg: TOmniMessage); message MSG_TIMER_BLINK;
  protected
    function Initialize: Boolean; override;
    procedure ResetLEDState; override;
    procedure LEDStateChanged(ALEDIndex: Integer; AState: TLEDState); override;
    procedure Changed; override;

    procedure StartBlinkTimer;
    procedure StopBlinkTimer;

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

  EXIT_ERROR_LOGIJOYSTICKDLL = EXIT_CONSUMER_OFFSET + 1;
  EXIT_ERROR_DIRECTINPUT = EXIT_CONSUMER_OFFSET + 2;

  
implementation
uses
  SysUtils,
  Windows,

  OtlCommon,

  LogiJoystickDLL;



const
  BLINK_INTERVAL = 500;


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


procedure TG940LEDStateConsumer.Changed;
begin
  inherited;

  if Assigned(ThrottleDevice) then
    { Logitech SDK will not change the color outside of the main thread }
    RunInMainThread(TRunInMainThreadSetLEDs.Create(ThrottleDevice, FRed, FGreen), Destroying);
end;


procedure TG940LEDStateConsumer.StartBlinkTimer;
begin
  if FBlinkTimerStarted then
    exit;

  FBlinkCounter := 0;
  Task.SetTimer(TIMER_BLINK, BLINK_INTERVAL, MSG_TIMER_BLINK);
  FBlinkTimerStarted := True;
end;


procedure TG940LEDStateConsumer.StopBlinkTimer;
begin
  if not FBlinkTimerStarted then
    exit;

  Task.ClearTimer(TIMER_BLINK);
  FBlinkTimerStarted := False;
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


procedure TG940LEDStateConsumer.MsgTimerBlink(var msg: TOmniMessage);
var
  warningState: TLEDState;
  errorState: TLEDState;
  ledIndex: Integer;
  state: TLEDState;

begin
  Inc(FBlinkCounter);
  if FBlinkCounter > 3 then
    FBlinkCounter := 0;

  warningState := lsOff;
  errorState := lsOff;

  { Error lights blink twice as fast }
  if (FBlinkCounter in [0, 1]) then
    warningState := lsAmber;

  if (FBlinkCounter in [0, 2]) then
    errorState := lsRed;

  if StateMap.FindFirst([lsWarning, lsError], ledIndex, state) then
  begin
    BeginUpdate;
    try
      repeat
        case state of
          lsWarning:
            if StateMap.GetState(ledIndex) <> warningState then
              LEDStateChanged(ledIndex, warningState);

          lsError:
            if StateMap.GetState(ledIndex) <> errorState then
              LEDStateChanged(ledIndex, errorState);
        end;
      until not StateMap.FindNext([lsWarning, lsError], ledIndex, state);
    finally
      EndUpdate;
    end;
  end else
    StopBlinkTimer;
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
