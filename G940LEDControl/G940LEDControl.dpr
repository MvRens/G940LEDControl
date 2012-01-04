program G940LEDControl;

uses
  Forms,
  MainFrm in 'Forms\MainFrm.pas' {MainForm},
  CustomLEDStateProvider in 'Units\CustomLEDStateProvider.pas',
  FSXLEDStateProvider in 'Units\FSXLEDStateProvider.pas',
  LEDStateConsumer in 'Units\LEDStateConsumer.pas';

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
