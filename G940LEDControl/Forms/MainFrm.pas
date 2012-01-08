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

    procedure FormCreate(Sender: TObject);
    procedure btnRetryClick(Sender: TObject);
    procedure btnFSXConnectClick(Sender: TObject);
    procedure btnFSXDisconnectClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FEventMonitor: TOmniEventMonitor;
    FStateConsumerTask: IOmniTaskControl;
  protected
    procedure SetDeviceState(const AMessage: string; AFound: Boolean);

    procedure InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
    procedure FinalizeStateProvider;

    procedure UpdateMapping;
    procedure UpdateMappingFSX;

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure EventMonitorTerminated(const task: IOmniTaskControl);

    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleRunInMainThreadMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
  end;


implementation
uses
  ComObj,
  SysUtils,
  Windows,

  OtlCommon,
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
  EventMonitor.OnTaskTerminated := EventMonitorTerminated;
  StateConsumerTask.Run;
end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(StateConsumerTask) then
  begin
    StateConsumerTask.Terminate;
    CanClose := False;
  end;
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
  TLEDStateConsumer.SetFunction(StateConsumerTask, 1, FUNCTION_FSX_PARKINGBRAKE);
  TLEDStateConsumer.SetFunction(StateConsumerTask, 2, FUNCTION_FSX_LANDINGLIGHTS);
  TLEDStateConsumer.SetFunction(StateConsumerTask, 3, FUNCTION_FSX_GEAR);
  TLEDStateConsumer.SetFunction(StateConsumerTask, 6, FUNCTION_FSX_INSTRUMENTLIGHTS);

  TLEDStateConsumer.SetFunction(StateConsumerTask, 7, FUNCTION_OFF);
end;


procedure TMainForm.EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
begin
  case msg.MsgID of
    MSG_NOTIFY_DEVICESTATE:   HandleDeviceStateMessage(task, msg);
    MSG_RUN_IN_MAINTHREAD:    HandleRunInMainThreadMessage(task, msg);
  end;
end;


procedure TMainForm.EventMonitorTerminated(const task: IOmniTaskControl);
begin
  if task = StateConsumerTask then
  begin
    FStateConsumerTask := nil;
    Close;
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


procedure TMainForm.HandleRunInMainThreadMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
var
  waitableObject: TObject;
  waitableValue: TOmniWaitableValue;

begin
  waitableObject := ATask.Param[0].AsObject;
  waitableValue := (waitableObject as TOmniWaitableValue);

//  (waitableValue.Value.AsInterface as IRunInMainThread).Execute;
//  waitableValue.Signal;
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
