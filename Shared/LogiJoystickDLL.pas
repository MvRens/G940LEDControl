unit LogiJoystickDLL;

interface
uses
  Windows,
  
  DirectInput;

type
  TLogiPanelButton = (LOGI_NONE = -1,
                      LOGI_P1 = 0,
                      LOGI_P2 = 1,
                      LOGI_P3 = 2,
                      LOGI_P4 = 3,
                      LOGI_P5 = 4,
                      LOGI_P6 = 5,
                      LOGI_P7 = 6,
                      LOGI_P8 = 7);

  TLogiColor = (LOGI_OFF = 0,
                LOGI_GREEN = 1,
                LOGI_AMBER = 2,
                LOGI_RED = 3);


  TSetButtonColor = function(device: IDirectInputDevice8; button: TLogiPanelButton; color: TLogiColor): DWORD; cdecl;
  TSetAllButtonsColor = function(device: IDirectInputDevice8; color: TLogiColor): DWORD; cdecl;
  TIsButtonColor = function(device: IDirectInputDevice8; button: TLogiPanelButton; color: TLogiColor): BOOL; cdecl;
  TSetLEDs = function(device: IDirectInputDevice8; redLEDs, greenLEDs: Byte): DWORD; cdecl;
  TGetLEDs = function(device: IDirectInputDevice8; out redLEDs, greenLEDs: Byte): DWORD; cdecl;


  function LogiJoystickDLLInitialized: Boolean;

const
  VENDOR_LOGITECH = $046D;
  
  PRODUCT_G940_JOYSTICK = $C2A8;
  PRODUCT_G940_THROTTLE = $C2A9;
  PRODUCT_G940_PEDALS = $C2AA;


var
  SetButtonColor: TSetButtonColor;
  SetAllButtonsColor: TSetAllButtonsColor;
  IsButtonColor: TIsButtonColor;
  SetLEDs: TSetLEDs;
  GetLEDs: TGetLEDs;


implementation
const
  LogiJoystickDLLFileName = 'LogiJoystickDLL.dll';

var
  LogiJoystickDLLHandle: THandle;


function LogiJoystickDLLInitialized: Boolean;
begin
  Result := (LogiJoystickDLLHandle <> 0);
end;

procedure LoadLogiJoystickDLL;
begin
  LogiJoystickDLLHandle := LoadLibrary(LogiJoystickDLLFileName);
  if LogiJoystickDLLHandle <> 0 then
  begin
    @SetButtonColor := GetProcAddress(LogiJoystickDLLHandle, 'SetButtonColor');
    @SetAllButtonsColor := GetProcAddress(LogiJoystickDLLHandle, 'SetAllButtonsColor');
    @IsButtonColor := GetProcAddress(LogiJoystickDLLHandle, 'IsButtonColor');
    @SetLEDs := GetProcAddress(LogiJoystickDLLHandle, 'SetLEDs');
    @GetLEDs := GetProcAddress(LogiJoystickDLLHandle, 'GetLEDs');
  end;
end;


procedure UnloadLogiJoystickDLL;
begin
  if LogiJoystickDLLHandle <> 0 then
  begin
    FreeLibrary(LogiJoystickDLLHandle);
    LogiJoystickDLLHandle := 0;
  end;
end;


initialization
  LoadLogiJoystickDLL;

finalization
  UnloadLogiJoystickDLL;

end.
