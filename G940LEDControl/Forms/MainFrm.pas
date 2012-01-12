unit MainFrm;

interface
uses
  Classes,
  Contnrs,
  Controls,
  ComCtrls,
  ExtCtrls,
  Forms,
  Messages,
  StdCtrls,
  Windows,

  OtlComm,
  OtlEventMonitor,
  OtlTaskControl,
  pngimage,
  X2UtPersistIntf,

  LEDFunctionMap,
  LEDStateConsumer,
  LEDStateProvider;


type
  TComboBoxArray = array[0..7] of TComboBoxEx;


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
    cmbFSXP1: TComboBoxEx;
    cmbFSXP2: TComboBoxEx;
    lblFSXP2: TLabel;
    cmbFSXP3: TComboBoxEx;
    lblFSXP3: TLabel;
    cmbFSXP4: TComboBoxEx;
    lblFSXP4: TLabel;
    cmbFSXP5: TComboBoxEx;
    lblFSXP5: TLabel;
    cmbFSXP6: TComboBoxEx;
    lblFSXP6: TLabel;
    cmbFSXP7: TComboBoxEx;
    lblFSXP7: TLabel;
    cmbFSXP8: TComboBoxEx;
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
    procedure FunctionComboBoxChange(Sender: TObject);
  private
    FEventMonitor: TOmniEventMonitor;
    FStateConsumerTask: IOmniTaskControl;
    FFSXComboBoxes: TComboBoxArray;
  protected
    procedure LoadFunctions(AProviderClass: TLEDStateProviderClass; AComboBoxes: TComboBoxArray);
    procedure SetFunctions(AComboBoxes: TComboBoxArray);

    procedure ReadFunctions(AReader: IX2PersistReader; AComboBoxes: TComboBoxArray);
    procedure WriteFunctions(AWriter: IX2PersistWriter; AComboBoxes: TComboBoxArray);

    procedure LoadDefaultProfile;
    procedure SaveDefaultProfile;

    procedure SetDeviceState(const AMessage: string; AFound: Boolean);

    procedure InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
    procedure FinalizeStateProvider;

    procedure UpdateMapping;

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure EventMonitorTerminated(const task: IOmniTaskControl);

    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleRunInMainThreadMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleProviderKilled(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleProviderKilledFSX(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
  end;


implementation
uses
  ComObj,
  Dialogs,
  SysUtils,

  OtlCommon,
  OtlTask,
  X2UtPersistRegistry,

  FSXLEDStateProvider,
  G940LEDStateConsumer;


{$R *.dfm}


const
  SPECIAL_CATEGORY = -1;

  TEXT_STATE_SEARCHING = 'Searching...';
  TEXT_STATE_NOTFOUND = 'Not found';
  TEXT_STATE_FOUND = 'Connected';

  KEY_DEFAULTPROFILE = '\Software\X2Software\G940LEDControl\DefaultProfile\';
  SECTION_FSX = 'FSX';


type
  TComboBoxFunctionConsumer = class(TInterfacedObject, IFunctionConsumer)
  private
    FComboBox: TComboBoxEx;
  protected
    { IFunctionConsumer }
    procedure SetCategory(const ACategory: string);
    procedure AddFunction(AFunction: Integer; const ADescription: string);

    property ComboBox: TComboBoxEx read FComboBox;
  public
    constructor Create(AComboBox: TComboBoxEx);
  end;




{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
var
  consumer: IOmniWorker;
  
begin
  FEventMonitor := TOmniEventMonitor.Create(Self);

  consumer := TG940LEDStateConsumer.Create;
  FStateConsumerTask := FEventMonitor.Monitor(CreateTask(consumer)).MsgWait;

  EventMonitor.OnTaskMessage := EventMonitorMessage;
  EventMonitor.OnTaskTerminated := EventMonitorTerminated;
  StateConsumerTask.Run;

  FFSXComboBoxes[0] := cmbFSXP1;
  FFSXComboBoxes[1] := cmbFSXP2;
  FFSXComboBoxes[2] := cmbFSXP3;
  FFSXComboBoxes[3] := cmbFSXP4;
  FFSXComboBoxes[4] := cmbFSXP5;
  FFSXComboBoxes[5] := cmbFSXP6;
  FFSXComboBoxes[6] := cmbFSXP7;
  FFSXComboBoxes[7] := cmbFSXP8;
  LoadFunctions(TFSXLEDStateProvider, FFSXComboBoxes);
  LoadDefaultProfile;
end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(StateConsumerTask) then
  begin
    SaveDefaultProfile;

    LEDStateConsumer.Finalize(StateConsumerTask);
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


procedure TMainForm.LoadFunctions(AProviderClass: TLEDStateProviderClass; AComboBoxes: TComboBoxArray);
var
  comboBox: TComboBoxEx;

begin
  for comboBox in AComboBoxes do
  begin
    comboBox.Items.BeginUpdate;
    try
      comboBox.Items.Clear;
      AProviderClass.EnumFunctions(TComboBoxFunctionConsumer.Create(comboBox));

      comboBox.ItemIndex := 0;
      if Assigned(comboBox.OnChange) then
        comboBox.OnChange(comboBox);
    finally
      comboBox.Items.EndUpdate;
    end;
  end;
end;


procedure TMainForm.SetFunctions(AComboBoxes: TComboBoxArray);
var
  comboBox: TComboBoxEx;

begin
  for comboBox in AComboBoxes do
  begin
    if comboBox.ItemIndex > -1 then
      LEDStateConsumer.SetFunction(StateConsumerTask, comboBox.Tag, Integer(comboBox.ItemsEx[comboBox.ItemIndex].Data));
  end;
end;


procedure TMainForm.ReadFunctions(AReader: IX2PersistReader; AComboBoxes: TComboBoxArray);
var
  comboBox: TComboBoxEx;
  value: Integer;
  itemIndex: Integer;

begin
  if AReader.BeginSection(SECTION_FSX) then
  try
    for comboBox in AComboBoxes do
    begin
      if AReader.ReadInteger('Function' + IntToStr(comboBox.Tag), value) then
      begin
        for itemIndex := 0 to Pred(comboBox.ItemsEx.Count) do
          if Integer(comboBox.ItemsEx[itemIndex].Data) = value then
          begin
            comboBox.ItemIndex := itemIndex;
            break;
          end;
      end;
    end;
  finally
    AReader.EndSection;
  end;
end;


procedure TMainForm.WriteFunctions(AWriter: IX2PersistWriter; AComboBoxes: TComboBoxArray);
var
  comboBox: TComboBoxEx;
  value: Integer;

begin
  if AWriter.BeginSection(SECTION_FSX) then
  try
    for comboBox in AComboBoxes do
    begin
      value := -1;
      if comboBox.ItemIndex > -1 then
        value := Integer(comboBox.ItemsEx[comboBox.ItemIndex].Data);

      AWriter.WriteInteger('Function' + IntToStr(comboBox.Tag), value);
    end;
  finally
    AWriter.EndSection;
  end;
end;


procedure TMainForm.LoadDefaultProfile;
var
  registryReader: TX2UtPersistRegistry;

begin
  registryReader := TX2UtPersistRegistry.Create;
  try
    registryReader.RootKey := HKEY_CURRENT_USER;
    registryReader.Key := KEY_DEFAULTPROFILE;

    ReadFunctions(registryReader.CreateReader, FFSXComboBoxes);
  finally
    FreeAndNil(registryReader);
  end;
end;


procedure TMainForm.SaveDefaultProfile;
var
  registryWriter: TX2UtPersistRegistry;

begin
  registryWriter := TX2UtPersistRegistry.Create;
  try
    registryWriter.RootKey := HKEY_CURRENT_USER;
    registryWriter.Key := KEY_DEFAULTPROFILE;

    WriteFunctions(registryWriter.CreateWriter, FFSXComboBoxes);
  finally
    FreeAndNil(registryWriter);
  end;
end;


procedure TMainForm.InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
begin
  UpdateMapping;
  LEDStateConsumer.InitializeStateProvider(StateConsumerTask, AProviderClass);
end;


procedure TMainForm.FinalizeStateProvider;
begin
  LEDStateConsumer.FinalizeStateProvider(StateConsumerTask);
end;


procedure TMainForm.UpdateMapping;
begin
  if not Assigned(StateConsumerTask) then
    Exit;

  LEDStateConsumer.ClearFunctions(StateConsumerTask);
  SetFunctions(FFSXComboBoxes);
end;


procedure TMainForm.EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
begin
  case msg.MsgID of
    MSG_NOTIFY_DEVICESTATE:   HandleDeviceStateMessage(task, msg);
    MSG_RUN_IN_MAINTHREAD:    HandleRunInMainThreadMessage(task, msg);
    MSG_PROVIDER_KILLED:      HandleProviderKilled(task, msg);
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
  executor: IRunInMainThread;

begin
  executor := (AMessage.MsgData.AsInterface as IRunInMainThread);
  executor.Execute;
  executor.Signal;
end;


procedure TMainForm.HandleProviderKilled(ATask: IOmniTaskControl; AMessage: TOmniMessage);
begin
  HandleProviderKilledFSX(ATask, AMessage);
end;


procedure TMainForm.HandleProviderKilledFSX(ATask: IOmniTaskControl; AMessage: TOmniMessage);
var
  msg: string;

begin
  btnFSXDisconnect.Enabled := False;
  btnFSXConnect.Enabled := True;

  msg := AMessage.MsgData;
  if Length(msg) > 0 then
    ShowMessage(msg);
end;


procedure TMainForm.btnFSXConnectClick(Sender: TObject);
begin
  SaveDefaultProfile;
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


procedure TMainForm.FunctionComboBoxChange(Sender: TObject);
var
  comboBox: TComboBoxEx;

begin
  comboBox := TComboBoxEx(Sender);
  if comboBox.ItemIndex > -1 then
  begin
    if not Assigned(comboBox.ItemsEx[comboBox.ItemIndex].Data) then
      comboBox.ItemIndex := Succ(comboBox.ItemIndex);
  end;
end;

{ TComboBoxFunctionConsumer }
constructor TComboBoxFunctionConsumer.Create(AComboBox: TComboBoxEx);
begin
  inherited Create;

  FComboBox := AComboBox;
end;


procedure TComboBoxFunctionConsumer.SetCategory(const ACategory: string);
begin
  with ComboBox.ItemsEx.Add do
  begin
    Caption := ACategory;
    Data := nil;
  end;
end;


procedure TComboBoxFunctionConsumer.AddFunction(AFunction: Integer; const ADescription: string);
begin
  with ComboBox.ItemsEx.Add do
  begin
    Caption := ADescription;
    Indent := 1;
    Data := Pointer(AFunction);
  end;
end;

end.
