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
  OtlTask,
  pngimage,
  X2UtPersistIntf,

  LEDFunctionMap,
  LEDStateConsumer,
  LEDStateProvider;


const
  CM_ASKAUTOUPDATE = WM_APP + 1;

  MSG_UPDATE = 1;
  MSG_NOUPDATE = 2;

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
    pcFSXOptions: TPageControl;
    tsFSXLEDButtons: TTabSheet;
    tsFSXExtra: TTabSheet;
    GroupBox1: TGroupBox;
    cbFSXToggleZoom: TCheckBox;
    lblFSXToggleZoomButton: TLabel;
    lblFSXZoomDepressed: TLabel;
    lblFSXZoomPressed: TLabel;
    lblFSXToggleZoomButtonName: TLabel;
    btnFSXToggleZoom: TButton;
    cmbFSXZoomDepressed: TComboBox;
    cmbFSXZoomPressed: TComboBox;
    GroupBox2: TGroupBox;
    tsAbout: TTabSheet;
    lblVersionCaption: TLabel;
    lblVersion: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    lblWebsiteLink: TLinkLabel;
    lblEmailLink: TLinkLabel;
    lblWebsite: TLabel;
    lblEmail: TLabel;
    cbCheckUpdates: TCheckBox;
    btnCheckUpdates: TButton;
    lblProxy: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure btnRetryClick(Sender: TObject);
    procedure btnFSXConnectClick(Sender: TObject);
    procedure btnFSXDisconnectClick(Sender: TObject);
    procedure btnFSXToggleZoomClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FunctionComboBoxChange(Sender: TObject);
    procedure lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure btnCheckUpdatesClick(Sender: TObject);
  private
    FEventMonitor: TOmniEventMonitor;
    FStateConsumerTask: IOmniTaskControl;
    FFSXComboBoxes: TComboBoxArray;
    FFSXToggleZoomDeviceGUID: TGUID;
    FFSXToggleZoomButtonIndex: Integer;
  protected
    procedure LoadFunctions(AProviderClass: TLEDStateProviderClass; AComboBoxes: TComboBoxArray);
    procedure SetFunctions(AComboBoxes: TComboBoxArray);

    procedure ReadFunctions(AReader: IX2PersistReader; AComboBoxes: TComboBoxArray);
    procedure ReadFSXExtra(AReader: IX2PersistReader);
    procedure ReadAutoUpdate(AReader: IX2PersistReader);
    procedure WriteFunctions(AWriter: IX2PersistWriter; AComboBoxes: TComboBoxArray);
    procedure WriteFSXExtra(AWriter: IX2PersistWriter);
    procedure WriteAutoUpdate(AWriter: IX2PersistWriter);

    procedure LoadDefaultProfile;
    procedure SaveDefaultProfile;

    procedure SetDeviceState(const AMessage: string; AFound: Boolean);
    procedure SetFSXToggleZoomButton(const ADeviceGUID: TGUID; AButtonIndex: Integer; const ADisplayText: string);

    procedure InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
    procedure FinalizeStateProvider;

    procedure UpdateMapping;

    procedure CheckForUpdatesThread(const ATask: IOmniTask);
    procedure CheckForUpdates(AReportNoUpdates: Boolean);

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure EventMonitorTerminated(const task: IOmniTaskControl);

    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleRunInMainThreadMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleProviderKilled(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleProviderKilledFSX(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    procedure CMAskAutoUpdate(var Msg: TMessage); message CM_ASKAUTOUPDATE;

    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
  end;


implementation
uses
  ComObj,
  Dialogs,
  ShellAPI,
  SysUtils,

  IdException,
  IdHTTP,
  OtlCommon,
  X2UtApp,
  X2UtPersistRegistry,

  ButtonSelectFrm,
  FSXLEDStateProvider,
  G940LEDStateConsumer;


{$R *.dfm}


const
  SPECIAL_CATEGORY = -1;

  TEXT_STATE_SEARCHING = 'Searching...';
  TEXT_STATE_NOTFOUND = 'Not found';
  TEXT_STATE_FOUND = 'Connected';

  KEY_SETTINGS = '\Software\X2Software\G940LEDControl\';
  SECTION_DEFAULTPROFILE = 'DefaultProfile';
  SECTION_FSX = 'FSX';
  SECTION_SETTINGS = 'Settings';


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
  lblVersion.Caption := App.Version.FormatVersion(False);

  pcConnections.ActivePageIndex := 0;
  pcFSXOptions.ActivePageIndex := 0;
  lblFSXToggleZoomButtonName.Caption := '';

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


procedure TMainForm.CMAskAutoUpdate(var Msg: TMessage);
begin
  if MessageBox(Self.Handle, 'I''m sorry to delay your flight, but I will only ask this once.'#13#10 +
                             'Do you want to automatically check for updates?', 'Check for updates', MB_YESNO or MB_ICONQUESTION) = ID_YES then
  begin
    cbCheckUpdates.Checked := True;
    CheckForUpdates(False);
  end;
end;


procedure TMainForm.SetDeviceState(const AMessage: string; AFound: Boolean);
begin
  lblG940ThrottleState.Caption := AMessage;
  lblG940ThrottleState.Update;

  imgStateFound.Visible := AFound;
  imgStateNotFound.Visible := not AFound;
end;


procedure TMainForm.SetFSXToggleZoomButton(const ADeviceGUID: TGUID; AButtonIndex: Integer; const ADisplayText: string);
begin
  FFSXToggleZoomDeviceGUID := ADeviceGUID;
  FFSXToggleZoomButtonIndex := AButtonIndex;
  lblFSXToggleZoomButtonName.Caption := ADisplayText;
end;


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


procedure TMainForm.ReadFSXExtra(AReader: IX2PersistReader);
var
  deviceGUID: string;
  buttonIndex: Integer;
  displayText: string;

begin
  if AReader.BeginSection(SECTION_FSX) then
  try
    if AReader.ReadString('ToggleZoomDeviceGUID', deviceGUID) and
       AReader.ReadInteger('ToggleZoomButtonIndex', buttonIndex) and
       AReader.ReadString('ToggleZoomDisplayText', displayText) then
    begin
      try
        SetFSXToggleZoomButton(StringToGUID(deviceGUID), buttonIndex, displayText);
      except
        on E:EConvertError do;
      end;
    end;
  finally
    AReader.EndSection;
  end;
end;


procedure TMainForm.ReadAutoUpdate(AReader: IX2PersistReader);
var
  checkUpdates: Boolean;
  askAutoUpdate: Boolean;

begin
  askAutoUpdate := True;

  if AReader.BeginSection(SECTION_SETTINGS) then
  try
    if AReader.ReadBoolean('CheckUpdates', checkUpdates) then
    begin
      cbCheckUpdates.Checked := checkUpdates;
      askAutoUpdate := False;
    end;
  finally
    AReader.EndSection;
  end;

  if askAutoUpdate then
    PostMessage(Self.Handle, CM_ASKAUTOUPDATE, 0, 0)
  else if cbCheckUpdates.Checked then
    CheckForUpdates(False);
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


procedure TMainForm.WriteFSXExtra(AWriter: IX2PersistWriter);
begin
  if AWriter.BeginSection(SECTION_FSX) then
  try
    AWriter.WriteString('ToggleZoomDeviceGUID', GUIDToString(FFSXToggleZoomDeviceGUID));
    AWriter.WriteInteger('ToggleZoomButtonIndex', FFSXToggleZoomButtonIndex);
    AWriter.WriteString('ToggleZoomDisplayText', lblFSXToggleZoomButtonName.Caption);
    // ToDo pressed / depressed levels
  finally
    AWriter.EndSection;
  end;
end;


procedure TMainForm.WriteAutoUpdate(AWriter: IX2PersistWriter);
begin
  if AWriter.BeginSection(SECTION_SETTINGS) then
  try
    AWriter.WriteBoolean('CheckUpdates', cbCheckUpdates.Checked);
  finally
    AWriter.EndSection;
  end;
end;


procedure TMainForm.LoadDefaultProfile;
var
  registryReader: TX2UtPersistRegistry;
  reader: IX2PersistReader;

begin
  registryReader := TX2UtPersistRegistry.Create;
  try
    registryReader.RootKey := HKEY_CURRENT_USER;
    registryReader.Key := KEY_SETTINGS;

    reader := registryReader.CreateReader;

    if reader.BeginSection(SECTION_DEFAULTPROFILE) then
    try
      ReadFunctions(reader, FFSXComboBoxes);
      ReadFSXExtra(reader);
    finally
      reader.EndSection;
    end;

    ReadAutoUpdate(reader);
  finally
    FreeAndNil(registryReader);
  end;
end;


procedure TMainForm.SaveDefaultProfile;
var
  registryWriter: TX2UtPersistRegistry;
  writer: IX2PersistWriter;

begin
  registryWriter := TX2UtPersistRegistry.Create;
  try
    registryWriter.RootKey := HKEY_CURRENT_USER;
    registryWriter.Key := KEY_SETTINGS;

    writer := registryWriter.CreateWriter;
    if writer.BeginSection(SECTION_DEFAULTPROFILE) then
    try
      WriteFunctions(writer, FFSXComboBoxes);
      WriteFSXExtra(writer);
    finally
      writer.EndSection;
    end;

    WriteAutoUpdate(writer);
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


function FetchNextNumber(var AValue: string; out ANumber: Integer): Boolean;
var
  dotPos: Integer;
  number: string;

begin
  ANumber := 0;

  dotPos := AnsiPos('.', AValue);
  if dotPos > 0 then
  begin
    number := Copy(AValue, 1, Pred(dotPos));
    Delete(AValue, 1, dotPos);
  end
  else
  begin
    number := AValue;
    AValue := '';
  end;

  Result := TryStrToInt(number, ANumber);
end;


function VersionIsNewer(const AVersion1, AVersion2: string): Boolean;
var
  version1: string;
  version2: string;
  number1: Integer;
  number2: Integer;

begin
  if Length(AVersion1) = 0 then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  version1 := AVersion1;
  version2 := AVersion2;

  while (not Result) and
        FetchNextNumber(version1, number1) and
        FetchNextNumber(version2, number2) do
  begin
    if number2 > number1 then
      Result := True
    else if number2 < number1 then
      Break;
  end;
end;


procedure TMainForm.CheckForUpdatesThread(const ATask: IOmniTask);
var
  httpClient: TIdHTTP;
  msgSent: Boolean;
  latestVersion: string;

begin
  msgSent := False;
  try
    httpClient := TIdHTTP.Create(nil);
    try
      latestVersion := httpClient.Get('http://g940.x2software.net/version');
      if VersionIsNewer(Format('%d.%d.%d', [App.Version.Major, App.Version.Minor, App.Version.Release]), latestVersion) then
        ATask.Comm.Send(MSG_UPDATE)
      else
      begin
        if ATask.Param.ByName('ReportNoUpdates').AsBoolean then
          ATask.Comm.Send(MSG_NOUPDATE, True);
      end;

      msgSent := True;
    finally
      FreeAndNil(httpClient);
    end;
  except
    on E:EIdSilentException do;
    on E:Exception do
    begin
      if not msgSent then
        ATask.Comm.Send(MSG_NOUPDATE, False);
    end;
  end;
end;


procedure TMainForm.CheckForUpdates(AReportNoUpdates: Boolean);
begin
  btnCheckUpdates.Enabled := False;

  CreateTask(CheckForUpdatesThread, 'CheckForUpdatesThread')
    .MonitorWith(EventMonitor)
    .SetParameter('ReportNoUpdates', AReportNoUpdates)
    .Run;
end;


procedure TMainForm.EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
begin
  case msg.MsgID of
    MSG_NOTIFY_DEVICESTATE:   HandleDeviceStateMessage(task, msg);
    MSG_RUN_IN_MAINTHREAD:    HandleRunInMainThreadMessage(task, msg);
    MSG_PROVIDER_KILLED:      HandleProviderKilled(task, msg);

    MSG_UPDATE:
      if MessageBox(Self.Handle, 'An update is available on the G940 LED Control website.'#13#10'Do you want to go there now?',
                                 'Update available', MB_YESNO or MB_ICONINFORMATION) = ID_YES then
        ShellExecute(Self.Handle, 'open', PChar('http://g940.x2software.net/#download'), nil, nil, SW_SHOWNORMAL);

    MSG_NOUPDATE:
      if msg.MsgData.AsBoolean then
        MessageBox(Self.Handle, 'You are using the latest version.', 'No update available', MB_OK or MB_ICONINFORMATION)
      else
        MessageBox(Self.Handle, 'Failed to check for updates. Maybe try again later?', 'Uh-oh', MB_OK or MB_ICONWARNING);
  end;
end;


procedure TMainForm.EventMonitorTerminated(const task: IOmniTaskControl);
begin
  if task = StateConsumerTask then
  begin
    FStateConsumerTask := nil;
    Close;
  end else if task.Name = 'CheckForUpdatesThread' then
    btnCheckUpdates.Enabled := True;
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


procedure TMainForm.btnCheckUpdatesClick(Sender: TObject);
begin
  CheckForUpdates(True);
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


procedure TMainForm.btnFSXToggleZoomClick(Sender: TObject);
var
  deviceGUID: TGUID;
  button: Integer;
  displayText: string;

begin
  FillChar(deviceGUID, SizeOf(deviceGUID), 0);
  button := -1;

  if TButtonSelectForm.Execute(deviceGUID, button, displayText) then
    SetFSXToggleZoomButton(deviceGUID, button, displayText);
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


procedure TMainForm.lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(Self.Handle, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
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
