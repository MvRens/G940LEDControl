program G940LEDControl;

uses
  Forms,
  MainFrm in 'Forms\MainFrm.pas' {MainForm},
  FSXLEDStateProvider in 'Units\FSXLEDStateProvider.pas',
  LEDStateConsumer in 'Units\LEDStateConsumer.pas',
  LEDStateProvider in 'Units\LEDStateProvider.pas',
  LEDFunctionMap in 'Units\LEDFunctionMap.pas',
  G940LEDStateConsumer in 'Units\G940LEDStateConsumer.pas';

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
