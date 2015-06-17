program G940LEDControl;

uses
  Forms,
  SysUtils,
  X2UtSingleInstance,
  MainFrm in 'Forms\MainFrm.pas' {MainForm},
  LogiJoystickDLL in '..\Shared\LogiJoystickDLL.pas',
  SimConnect in '..\Shared\SimConnect.pas',
  G940LEDStateConsumer in 'Units\G940LEDStateConsumer.pas',
  LEDStateConsumer in 'Units\LEDStateConsumer.pas',
  LEDColorIntf in 'Units\LEDColorIntf.pas',
  LEDColor in 'Units\LEDColor.pas',
  LEDFunctionIntf in 'Units\LEDFunctionIntf.pas',
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
  LEDResources in 'Units\LEDResources.pas',
  Settings in 'Units\Settings.pas',
  FSXLEDFunctionWorker in 'Units\FSXLEDFunctionWorker.pas',
  FSXSimConnectStateMonitor in 'Units\FSXSimConnectStateMonitor.pas',
  ProfileManager in 'Units\ProfileManager.pas',
  FSXLEDFunctionProviderIntf in 'Units\FSXLEDFunctionProviderIntf.pas',
  SimBaseDocumentXMLBinding in 'Units\SimBaseDocumentXMLBinding.pas',
  FSXAutoLaunch in 'Units\FSXAutoLaunch.pas',
  ControlIntf in 'Units\ControlIntf.pas';

{$R *.res}


var
  MainForm: TMainForm;
  isRestarting: Boolean;

begin
  isRestarting := FindCmdLineSwitch('restart');

  while not SingleInstance('{67D1802F-2AB8-40B9-ADD7-14C9D36903C8}', False, False) do
  begin
    Instance.Close;

    if not isRestarting then
      exit;

    Sleep(1000);
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'G940 LED Control';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
