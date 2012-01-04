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

  CustomLEDStateProvider;


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
    FProviderConsumerChannel: IOmniTwoWayChannel;
    FStateConsumerTask: IOmniTaskControl;
    FStateProviderWorker: IOmniWorker;
    FStateProviderTask: IOmniTaskControl;

//    FInitCounter: Integer;
//    FInitRedState: Byte;
//    FInitGreenState: Byte;
  protected
    procedure SetDeviceState(const AMessage: string; AFound: Boolean);

    procedure InitializeStateProvider(AProviderClass: TCustomLEDStateProviderClass);
    procedure FinalizeStateProvider;

    procedure UpdateMapping;
    procedure UpdateMappingFSX(AFunctionMap: TLEDFunctionMap);

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property ProviderConsumerChannel: IOmniTwoWayChannel read FProviderConsumerChannel;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
    property StateProviderWorker: IOmniWorker read FStateProviderWorker;
    property StateProviderTask: IOmniTaskControl read FStateProviderTask;
  end;


implementation
uses
  ComObj,
  SysUtils,
  Windows,

  OtlTask,

  FSXLEDStateProvider,
  LEDStateConsumer;


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
  FProviderConsumerChannel := CreateTwoWayChannel(1024);

  consumer := TG940LEDStateConsumer.Create(ProviderConsumerChannel.Endpoint1);
  FStateConsumerTask := FEventMonitor.Monitor(CreateTask(consumer));

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


procedure TMainForm.InitializeStateProvider(AProviderClass: TCustomLEDStateProviderClass);
begin
  if Assigned(StateProviderTask) then
    FinalizeStateProvider;

  FStateProviderWorker := AProviderClass.Create(ProviderConsumerChannel.Endpoint2);
  FStateProviderTask := CreateTask(StateProviderWorker);

  StateProviderTask.Run;
  StateProviderTask.WaitForInit;

  UpdateMapping;
end;


procedure TMainForm.FinalizeStateProvider;
begin
  FStateProviderWorker := nil;

  if Assigned(StateProviderTask) then
    StateProviderTask.Terminate;
    
  FStateProviderTask := nil;
end;


procedure TMainForm.UpdateMapping;
var
  provider: TCustomLEDStateProvider;
  functionMap: TLEDFunctionMap;

begin
  if not Assigned(StateProviderWorker) then
    Exit;

  provider := (StateProviderWorker.Implementor as TCustomLEDStateProvider);
  functionMap := provider.LockFunctionMap;
  try
    UpdateMappingFSX(functionMap);
  finally
    provider.UnlockFunctionMap;
  end;
end;


procedure TMainForm.UpdateMappingFSX(AFunctionMap: TLEDFunctionMap);
begin
  AFunctionMap.Clear;
  AFunctionMap.SetFunction(4, FUNCTION_FSX_GEAR);
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


(*
procedure TMainForm.DoStateChange(Sender: TObject; ALEDPosition: Integer; AState: TLEDState);
begin
  if not Assigned(ThrottleDevice) then
    exit;
    
  // (MvR) 2-1-2012: dit moet slimmer zodra we lsWarning/lsError willen ondersteunen

  case AState of
    lsOff:    SetButtonColor(ThrottleDevice, TLogiPanelButton(Pred(ALEDPosition)), LOGI_OFF);
    lsGreen:  SetButtonColor(ThrottleDevice, TLogiPanelButton(Pred(ALEDPosition)), LOGI_GREEN);
    lsAmber:  SetButtonColor(ThrottleDevice, TLogiPanelButton(Pred(ALEDPosition)), LOGI_AMBER);
    lsRed:    SetButtonColor(ThrottleDevice, TLogiPanelButton(Pred(ALEDPosition)), LOGI_RED);
  end;
end;
*)


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
