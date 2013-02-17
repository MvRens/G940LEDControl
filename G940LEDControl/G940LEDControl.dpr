program G940LEDControl;

uses
  Forms,
  MainFrm in 'Forms\MainFrm.pas' {MainForm},
  LogiJoystickDLL in '..\Shared\LogiJoystickDLL.pas',
  SimConnect in '..\Shared\SimConnect.pas',
  FSXLEDStateProvider in 'Units\FSXLEDStateProvider.pas',
  G940LEDStateConsumer in 'Units\G940LEDStateConsumer.pas',
  LEDFunctionMap in 'Units\LEDFunctionMap.pas',
  LEDStateConsumer in 'Units\LEDStateConsumer.pas',
  LEDStateProvider in 'Units\LEDStateProvider.pas',
  LEDColorIntf in 'Units\LEDColorIntf.pas',
  LEDColor in 'Units\LEDColor.pas',
  LEDFunctionIntf in 'Units\LEDFunctionIntf.pas',
  ObserverIntf in 'Units\ObserverIntf.pas',
  LEDFunction in 'Units\LEDFunction.pas',
  StaticLEDFunction in 'Units\StaticLEDFunction.pas',
  ConfigConversion in 'Units\ConfigConversion.pas',
  LEDFunctionRegistry in 'Units\LEDFunctionRegistry.pas',
  StaticLEDColor in 'Units\StaticLEDColor.pas',
  DynamicLEDColor in 'Units\DynamicLEDColor.pas',
  LEDStateIntf in 'Units\LEDStateIntf.pas',
  LEDState in 'Units\LEDState.pas',
  Profile in 'Units\Profile.pas',
  LEDColorPool in 'Units\LEDColorPool.pas',
  ButtonFunctionFrm in 'Forms\ButtonFunctionFrm.pas' {ButtonFunctionForm},
  FSXLEDFunctionProvider in 'Units\FSXLEDFunctionProvider.pas',
  StaticResources in 'Units\StaticResources.pas',
  FSXResources in 'Units\FSXResources.pas',
  FSXSimConnectClient in 'Units\FSXSimConnectClient.pas',
  FSXSimConnectIntf in 'Units\FSXSimConnectIntf.pas',
  FSXLEDFunction in 'Units\FSXLEDFunction.pas',
  LEDResources in 'Units\LEDResources.pas';

{$R *.res}


var
  MainForm: TMainForm;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'G940 LED Control';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
