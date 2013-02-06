program G940LEDControl;

uses
  Forms,
  MainFrm in 'Forms\MainFrm.pas' {MainForm},
  LogiJoystickDLL in '..\Shared\LogiJoystickDLL.pas',
  SimConnect in '..\Shared\SimConnect.pas',
  ButtonSelectFrm in 'Forms\ButtonSelectFrm.pas' {ButtonSelectForm},
  FSXLEDStateProvider in 'Units\FSXLEDStateProvider.pas',
  G940LEDStateConsumer in 'Units\G940LEDStateConsumer.pas',
  LEDFunctionMap in 'Units\LEDFunctionMap.pas',
  LEDStateConsumer in 'Units\LEDStateConsumer.pas',
  LEDStateProvider in 'Units\LEDStateProvider.pas',
  LEDStateIntf in 'Units\LEDStateIntf.pas',
  LEDState in 'Units\LEDState.pas',
  LEDFunctionIntf in 'Units\LEDFunctionIntf.pas',
  ObserverIntf in 'Units\ObserverIntf.pas',
  LEDFunction in 'Units\LEDFunction.pas',
  StaticLEDFunction in 'Units\StaticLEDFunction.pas',
  ConfigConversion in 'Units\ConfigConversion.pas',
  LEDFunctionRegistry in 'Units\LEDFunctionRegistry.pas';

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
