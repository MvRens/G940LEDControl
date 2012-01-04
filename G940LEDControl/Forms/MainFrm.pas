unit MainFrm;

interface
uses
  Classes,
  Controls,
  ComCtrls,
  ExtCtrls,
  Forms,
  Messages,
  StdCtrls,

  OtlComm,
  OtlEventMonitor,
  OtlTaskControl,
  pngimage,

  LEDFunctionMap,
  LEDStateConsumer,
  LEDStateProvider;


type
  TMainForm = class(TForm)
    imgStateNotFound: TImage;
    lblG940Throttle: TLabel;
    imgStateFound: TImage;
    lblG940ThrottleState: TLabel;
    btnRetry: TButton;
    pcConnections: TPageControl;
    pnlG940: TPanel;
    tsFSX: TTabSheet;
    gbFSXButtons: TGroupBox;
    lblFSXP1: TLabel;
    cmbFSXP1: TComboBox;
    cmbFSXP2: TComboBox;
    lblFSXP2: TLabel;
    cmbFSXP3: TComboBox;
    lblFSXP3: TLabel;
    cmbFSXP4: TComboBox;
    lblFSXP4: TLabel;
    cmbFSXP5: TComboBox;
    lblFSXP5: TLabel;
    cmbFSXP6: TComboBox;
    lblFSXP6: TLabel;
    cmbFSXP7: TComboBox;
    lblFSXP7: TLabel;
    cmbFSXP8: TComboBox;
    lblFSXP8: TLabel;
    gbFSXConnection: TGroupBox;
    btnFSXConnect: TButton;
    btnFSXDisconnect: TButton;
    lblFSXLocal: TLabel;
    tmrG940Init: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRetryClick(Sender: TObject);
    procedure btnFSXConnectClick(Sender: TObject);
    procedure btnFSXDisconnectClick(Sender: TObject);
//    procedure tmrG940InitTimer(Sender: TObject);
  private
    FEventMonitor: TOmniEventMonitor;
    FStateConsumerTask: IOmniTaskControl;

//    FInitCounter: Integer;
//    FInitRedState: Byte;
//    FInitGreenState: Byte;
  protected
    procedure SetDeviceState(const AMessage: string; AFound: Boolean);

    procedure InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
    procedure FinalizeStateProvider;

    procedure UpdateMapping;
    procedure UpdateMappingFSX;

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
  end;


implementation
uses
  ComObj,
  SysUtils,
  Windows,

  OtlTask,

  FSXLEDStateProvider,
  G940LEDStateConsumer;


{$R *.dfm}


const
  TEXT_STATE_SEARCHING = 'Searching...';
  TEXT_STATE_NOTFOUND = 'Not found';
  TEXT_STATE_FOUND = 'Connected';



procedure RunStateProvider(const task: IOmniTask);
begin

end;


{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
var
  consumer: IOmniWorker;
  
begin
  FEventMonitor := TOmniEventMonitor.Create(Self);

  consumer := TG940LEDStateConsumer.Create;
  FStateConsumerTask := FEventMonitor.Monitor(CreateTask(consumer)).MsgWait;

  // ToDo handle OnTerminate, check exit code for initialization errors
  EventMonitor.OnTaskMessage := EventMonitorMessage;
  StateConsumerTask.Run;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeStateProvider;

  StateConsumerTask.Terminate;
  FStateConsumerTask := nil;
end;


procedure TMainForm.SetDeviceState(const AMessage: string; AFound: Boolean);
begin
  lblG940ThrottleState.Caption := AMessage;
  lblG940ThrottleState.Update;

  imgStateFound.Visible := AFound;
  imgStateNotFound.Visible := not AFound;
end;


(*
procedure TMainForm.tmrG940InitTimer(Sender: TObject);

  procedure TurnOn(ALEDPosition: Integer);
  begin
    FInitGreenState := FInitGreenState or (1 shl Pred(ALEDPosition));
  end;

  procedure TurnOff(ALEDPosition: Integer);
  begin
    FInitGreenState := FInitGreenState and not (1 shl Pred(ALEDPosition));
    FInitRedState := FInitRedState and not (1 shl Pred(ALEDPosition));
  end;

begin
  if not Assigned(ThrottleDevice) then
  begin
    tmrG940Init.Enabled := False;
    exit;
  end; 

  if FInitCounter = 0 then
    GetLEDs(ThrottleDevice, FInitRedState, FInitGreenState);

  Inc(FInitCounter);
  if FInitCounter > 8 then
  begin
    tmrG940Init.Enabled := False;
    exit;
  end;

  { Clear all the LEDs in a right-to-left pattern for the top row and a
    left-to-right pattern for the bottom row. Then light only the green LEDs
    in the same pattern. }
  if FInitCounter in [1..4] then
  begin
    TurnOff(5 - FInitCounter);
    TurnOff(4 + FInitCounter);
  end else
  begin
    TurnOn(5 - (FInitCounter - 4));
    TurnOn(4 + (FInitCounter - 4));
  end;

  SetLEDs(ThrottleDevice, FInitRedState, FInitGreenState);
end;
*)


procedure TMainForm.InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
begin  
  UpdateMapping;
  TLEDStateConsumer.InitializeStateProvider(StateConsumerTask, AProviderClass);
end;


procedure TMainForm.FinalizeStateProvider;
begin
  TLEDStateConsumer.FinalizeStateProvider(StateConsumerTask);
end;


procedure TMainForm.UpdateMapping;
begin
  if not Assigned(StateConsumerTask) then
    Exit;

  TLEDStateConsumer.ClearFunctions(StateConsumerTask);
  UpdateMappingFSX;
end;


procedure TMainForm.UpdateMappingFSX;
begin
  TLEDStateConsumer.SetFunction(StateConsumerTask, 3, FUNCTION_FSX_GEAR);
end;


procedure TMainForm.EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
begin
  case msg.MsgID of
    MSG_NOTIFY_DEVICESTATE:    HandleDeviceStateMessage(task, msg);  
  end;
end;


procedure TMainForm.HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
begin
  case AMessage.MsgData.AsInteger of
    DEVICESTATE_SEARCHING:
      SetDeviceState(TEXT_STATE_SEARCHING, False);

    DEVICESTATE_FOUND:
      SetDeviceState(TEXT_STATE_FOUND, True);

    DEVICESTATE_NOTFOUND:
      begin
        SetDeviceState(TEXT_STATE_NOTFOUND, False);
        btnRetry.Visible := True;
      end;
  end;
end;


procedure TMainForm.btnFSXConnectClick(Sender: TObject);
begin
  InitializeStateProvider(TFSXLEDStateProvider);

  btnFSXDisconnect.Enabled := True;
  btnFSXConnect.Enabled := False;
end;


procedure TMainForm.btnFSXDisconnectClick(Sender: TObject);
begin
  FinalizeStateProvider;
  btnFSXDisconnect.Enabled := False;
  btnFSXConnect.Enabled := True;
end;


procedure TMainForm.btnRetryClick(Sender: TObject);
begin
  btnRetry.Visible := False;
  StateConsumerTask.Comm.Send(MSG_FINDTHROTTLEDEVICE);
end;

end.
