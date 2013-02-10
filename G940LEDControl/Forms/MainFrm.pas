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
  LEDStateProvider,
  Profile;


const
  CM_ASKAUTOUPDATE = WM_APP + 1;

  MSG_UPDATE = 1;
  MSG_NOUPDATE = 2;

  LED_COUNT = 8;

type
  TLEDControls = record
    ConfigureButton: TButton;
    CategoryLabel: TLabel;
    FunctionLabel: TLabel;
  end;


  TMainForm = class(TForm)
    imgStateNotFound: TImage;
    lblG940Throttle: TLabel;
    imgStateFound: TImage;
    lblG940ThrottleState: TLabel;
    btnRetry: TButton;
    PageControl: TPageControl;
    pnlG940: TPanel;
    tsAbout: TTabSheet;
    lblVersionCaption: TLabel;
    lblVersion: TLabel;
    lblProductName: TLabel;
    lblCopyright: TLabel;
    lblWebsiteLink: TLinkLabel;
    lblEmailLink: TLinkLabel;
    lblWebsite: TLabel;
    lblEmail: TLabel;
    cbCheckUpdates: TCheckBox;
    btnCheckUpdates: TButton;
    lblProxy: TLabel;
    tsFSX: TTabSheet;
    btnP1: TButton;
    lblP1Function: TLabel;
    lblP1Category: TLabel;
    btnP2: TButton;
    lblP2Function: TLabel;
    lblP2Category: TLabel;
    btnP3: TButton;
    lblP3Function: TLabel;
    lblP3Category: TLabel;
    btnP4: TButton;
    lblP4Function: TLabel;
    lblP4Category: TLabel;
    btnP5: TButton;
    lblP5Function: TLabel;
    lblP5Category: TLabel;
    btnP6: TButton;
    lblP6Function: TLabel;
    lblP6Category: TLabel;
    btnP7: TButton;
    lblP7Function: TLabel;
    lblP7Category: TLabel;
    btnP8: TButton;
    lblP8Function: TLabel;
    lblP8Category: TLabel;
    lblProfile: TLabel;
    cmbProfiles: TComboBox;
    btnSaveProfile: TButton;
    btnDeleteProfile: TButton;
    bvlProfiles: TBevel;

    procedure FormCreate(Sender: TObject);
    procedure btnRetryClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FunctionComboBoxChange(Sender: TObject);
    procedure lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure btnCheckUpdatesClick(Sender: TObject);
    procedure LEDButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbProfilesClick(Sender: TObject);
  private
    FLEDControls: array[0..LED_COUNT - 1] of TLEDControls;
    FEventMonitor: TOmniEventMonitor;

    FProfilesFilename: string;
    FProfiles: TProfileList;
    FActiveProfile: TProfile;
    FLoadingProfiles: Boolean;
//    FStateConsumerTask: IOmniTaskControl;
  protected
//    procedure ReadFunctions(AReader: IX2PersistReader; AComboBoxes: TComboBoxArray);
//    procedure ReadFSXExtra(AReader: IX2PersistReader);
//    procedure ReadAutoUpdate(AReader: IX2PersistReader);
//    procedure WriteFunctions(AWriter: IX2PersistWriter; AComboBoxes: TComboBoxArray);
//    procedure WriteFSXExtra(AWriter: IX2PersistWriter);
//    procedure WriteAutoUpdate(AWriter: IX2PersistWriter);

    procedure FindLEDControls;
    procedure LoadProfiles;
    procedure SaveProfiles;

    function CreateDefaultProfile: TProfile;
    procedure LoadActiveProfile;
    procedure UpdateButton(AProfile: TProfile; AButtonIndex: Integer);

    procedure SetDeviceState(const AMessage: string; AFound: Boolean);
//    procedure SetFSXToggleZoomButton(const ADeviceGUID: TGUID; AButtonIndex: Integer; const ADisplayText: string);

//    procedure InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
//    procedure FinalizeStateProvider;

//    procedure UpdateMapping;

    procedure CheckForUpdatesThread(const ATask: IOmniTask);
    procedure CheckForUpdates(AReportNoUpdates: Boolean);

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure EventMonitorTerminated(const task: IOmniTaskControl);

    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleRunInMainThreadMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleProviderKilled(ATask: IOmniTaskControl; AMessage: TOmniMessage);
    procedure HandleProviderKilledFSX(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    procedure CMAskAutoUpdate(var Msg: TMessage); message CM_ASKAUTOUPDATE;

    property ActiveProfile: TProfile read FActiveProfile;
    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property Profiles: TProfileList read FProfiles;
//    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
  end;


implementation
uses
  ComObj,
  Dialogs,
  Graphics,
  ShellAPI,
  SysUtils,

  IdException,
  IdHTTP,
  OtlCommon,
  X2UtApp,
  X2UtPersistXML,

  ButtonFunctionFrm,
  ConfigConversion,
  FSXLEDStateProvider,
  G940LEDStateConsumer,
  LEDColorIntf,
  LEDFunctionIntf,
  LEDFunctionRegistry,
  StaticLEDFunction;


{$R *.dfm}


const
  DefaultProfileName = 'Default';

  FILENAME_PROFILES = 'G940LEDControl\Profiles.xml';

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
//var
//  consumer: IOmniWorker;
//
begin
  lblVersion.Caption := App.Version.FormatVersion(False);

  PageControl.ActivePageIndex := 0;

  FEventMonitor := TOmniEventMonitor.Create(Self);

//  consumer := TG940LEDStateConsumer.Create;
//  FStateConsumerTask := FEventMonitor.Monitor(CreateTask(consumer)).MsgWait;

  EventMonitor.OnTaskMessage := EventMonitorMessage;
  EventMonitor.OnTaskTerminated := EventMonitorTerminated;
//  StateConsumerTask.Run;

  FindLEDControls;

  FProfilesFilename := App.UserPath + FILENAME_PROFILES;
  FProfiles := TProfileList.Create(True);
  LoadProfiles;

//  LoadFunctions(TFSXLEDStateProvider, FFSXComboBoxes);
//  LoadDefaultProfile;
end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SaveProfiles;
//  if Assigned(StateConsumerTask) then
//  begin
//    SaveDefaultProfile;
//
//    LEDStateConsumer.Finalize(StateConsumerTask);
//    CanClose := False;
//  end;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FProfiles);
end;


procedure TMainForm.FindLEDControls;

  function ComponentByName(const AName: string; ATag: NativeInt): TComponent;
  begin
    Result := FindComponent(AName);
    if not Assigned(Result) then
      raise EArgumentException.CreateFmt('"%s" is not a valid component', [AName]);

    Result.Tag := ATag;
  end;

var
  ledIndex: Integer;
  ledNumber: string;

begin
  for ledIndex := 0 to Pred(LED_COUNT) do
  begin
    ledNumber := IntToStr(Succ(ledIndex));

    FLEDControls[ledIndex].ConfigureButton := (ComponentByName('btnP' + ledNumber, ledIndex) as TButton);
    FLEDControls[ledIndex].CategoryLabel := (ComponentByName('lblP' + ledNumber + 'Category', ledIndex) as TLabel);
    FLEDControls[ledIndex].FunctionLabel := (ComponentByName('lblP' + ledNumber + 'Function', ledIndex) as TLabel);

    FLEDControls[ledIndex].ConfigureButton.OnClick := LEDButtonClick;
    FLEDControls[ledIndex].CategoryLabel.Caption := '';
    FLEDControls[ledIndex].CategoryLabel.Font.Color := clGrayText;
    FLEDControls[ledIndex].FunctionLabel.Caption := '';
  end;
end;


procedure TMainForm.LoadProfiles;
var
  defaultProfile: TProfile;
  persistXML: TX2UtPersistXML;
  profile: TProfile;

begin
  if not FileExists(FProfilesFilename) then
  begin
    { Check if version 0.x settings are in the registry }
    defaultProfile := ConfigConversion.Convert0To1;

    if not Assigned(defaultProfile) then
      defaultProfile := CreateDefaultProfile;

    if Assigned(defaultProfile) then
    begin
      defaultProfile.Name := DefaultProfileName;
      Profiles.Add(defaultProfile);
    end;
  end else
  begin
    persistXML := TX2UtPersistXML.Create;
    try
      persistXML.FileName := FProfilesFilename;
      Profiles.Load(persistXML.CreateReader);
    finally
      FreeAndNil(persistXML);
    end;
  end;

  FLoadingProfiles := True;
  try
    cmbProfiles.Items.BeginUpdate;
    try
      cmbProfiles.Items.Clear;

      for profile in Profiles do
        cmbProfiles.Items.AddObject(profile.Name, profile);
    finally
      cmbProfiles.Items.EndUpdate;

      if cmbProfiles.Items.Count > 0 then
      begin
        cmbProfiles.ItemIndex := 0;

        FActiveProfile := TProfile(cmbProfiles.Items.Objects[0]);
        LoadActiveProfile;
      end;
    end;
  finally
    FLoadingProfiles := False;
  end;
end;


procedure TMainForm.SaveProfiles;
var
  persistXML: TX2UtPersistXML;

begin
  persistXML := TX2UtPersistXML.Create;
  try
    persistXML.FileName := FProfilesFilename;
    Profiles.Save(persistXML.CreateWriter);
  finally
    FreeAndNil(persistXML);
  end;
end;


function TMainForm.CreateDefaultProfile: TProfile;
begin
  { Default button functions are assigned during UpdateButton }
  Result := TProfile.Create;
end;


procedure TMainForm.LoadActiveProfile;
var
  buttonIndex: Integer;

begin
  if not Assigned(ActiveProfile) then
    exit;

  for buttonIndex := 0 to Pred(LED_COUNT) do
    UpdateButton(ActiveProfile, buttonIndex);
end;


procedure TMainForm.UpdateButton(AProfile: TProfile; AButtonIndex: Integer);
var
  button: TProfileButton;
  providerUID: string;
  functionUID: string;
  provider: ILEDFunctionProvider;
  buttonFunction: ILEDFunction;

begin
  if AProfile.HasButton(AButtonIndex) then
  begin
    button := AProfile.Buttons[AButtonIndex];
    providerUID := button.ProviderUID;
    functionUID := button.FunctionUID;
  end else
  begin
    providerUID := StaticProviderUID;
    functionUID := StaticFunctionUID[lcGreen];
  end;

  buttonFunction := nil;
  provider := TLEDFunctionRegistry.Find(providerUID);
  if Assigned(provider) then
    buttonFunction := provider.Find(functionUID);

  if Assigned(buttonFunction) then
  begin
    FLEDControls[AButtonIndex].CategoryLabel.Caption := buttonFunction.GetCategoryName;
    FLEDControls[AButtonIndex].FunctionLabel.Caption := buttonFunction.GetDisplayName;
  end;
end;


procedure TMainForm.cmbProfilesClick(Sender: TObject);
begin
  if not FLoadingProfiles then
  begin
    if cmbProfiles.ItemIndex > -1 then
      FActiveProfile := TProfile(cmbProfiles.Items.Objects[cmbProfiles.ItemIndex])
    else
      FActiveProfile := nil;

    LoadActiveProfile;
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


//procedure TMainForm.ReadFunctions(AReader: IX2PersistReader; AComboBoxes: TComboBoxArray);
//var
//  comboBox: TComboBoxEx;
//  value: Integer;
//  itemIndex: Integer;
//
//begin
//  if AReader.BeginSection(SECTION_FSX) then
//  try
//    for comboBox in AComboBoxes do
//    begin
//      if AReader.ReadInteger('Function' + IntToStr(comboBox.Tag), value) then
//      begin
//        for itemIndex := 0 to Pred(comboBox.ItemsEx.Count) do
//          if Integer(comboBox.ItemsEx[itemIndex].Data) = value then
//          begin
//            comboBox.ItemIndex := itemIndex;
//            break;
//          end;
//      end;
//    end;
//  finally
//    AReader.EndSection;
//  end;
//end;


//procedure TMainForm.ReadAutoUpdate(AReader: IX2PersistReader);
//var
//  checkUpdates: Boolean;
//  askAutoUpdate: Boolean;
//
//begin
//  askAutoUpdate := True;
//
//  if AReader.BeginSection(SECTION_SETTINGS) then
//  try
//    if AReader.ReadBoolean('CheckUpdates', checkUpdates) then
//    begin
//      cbCheckUpdates.Checked := checkUpdates;
//      askAutoUpdate := False;
//    end;
//  finally
//    AReader.EndSection;
//  end;
//
//  if askAutoUpdate then
//    PostMessage(Self.Handle, CM_ASKAUTOUPDATE, 0, 0)
//  else if cbCheckUpdates.Checked then
//    CheckForUpdates(False);
//end;


//procedure TMainForm.WriteAutoUpdate(AWriter: IX2PersistWriter);
//begin
//  if AWriter.BeginSection(SECTION_SETTINGS) then
//  try
//    AWriter.WriteBoolean('CheckUpdates', cbCheckUpdates.Checked);
//  finally
//    AWriter.EndSection;
//  end;
//end;


//procedure TMainForm.LoadDefaultProfile;
//var
//  registryReader: TX2UtPersistRegistry;
//  reader: IX2PersistReader;
//
//begin
//  registryReader := TX2UtPersistRegistry.Create;
//  try
//    registryReader.RootKey := HKEY_CURRENT_USER;
//    registryReader.Key := KEY_SETTINGS;
//
//    reader := registryReader.CreateReader;
//
//    if reader.BeginSection(SECTION_DEFAULTPROFILE) then
//    try
//      ReadFunctions(reader, FFSXComboBoxes);
//      ReadFSXExtra(reader);
//    finally
//      reader.EndSection;
//    end;
//
//    ReadAutoUpdate(reader);
//  finally
//    FreeAndNil(registryReader);
//  end;
//end;
//
//
//procedure TMainForm.SaveDefaultProfile;
//var
//  registryWriter: TX2UtPersistRegistry;
//  writer: IX2PersistWriter;
//
//begin
//  registryWriter := TX2UtPersistRegistry.Create;
//  try
//    registryWriter.RootKey := HKEY_CURRENT_USER;
//    registryWriter.Key := KEY_SETTINGS;
//
//    writer := registryWriter.CreateWriter;
//    if writer.BeginSection(SECTION_DEFAULTPROFILE) then
//    try
//      WriteFunctions(writer, FFSXComboBoxes);
//      WriteFSXExtra(writer);
//    finally
//      writer.EndSection;
//    end;
//
//    WriteAutoUpdate(writer);
//  finally
//    FreeAndNil(registryWriter);
//  end;
//end;


//procedure TMainForm.InitializeStateProvider(AProviderClass: TLEDStateProviderClass);
//begin
//  UpdateMapping;
//  LEDStateConsumer.InitializeStateProvider(StateConsumerTask, AProviderClass);
//end;
//
//
//procedure TMainForm.FinalizeStateProvider;
//begin
//  LEDStateConsumer.FinalizeStateProvider(StateConsumerTask);
//end;


//procedure TMainForm.UpdateMapping;
//begin
//  if not Assigned(StateConsumerTask) then
//    Exit;
//
//  LEDStateConsumer.ClearFunctions(StateConsumerTask);
//  SetFunctions(FFSXComboBoxes);
//end;


procedure TMainForm.LEDButtonClick(Sender: TObject);
var
  buttonIndex: NativeInt;

begin
  if not Assigned(ActiveProfile) then
    exit;

  buttonIndex := (Sender as TComponent).Tag;
  if TButtonFunctionForm.Execute(ActiveProfile, buttonIndex) then
    UpdateButton(ActiveProfile, buttonIndex);
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
//  if task = StateConsumerTask then
//  begin
//    FStateConsumerTask := nil;
//    Close;
//  end else if task.Name = 'CheckForUpdatesThread' then
//    btnCheckUpdates.Enabled := True;
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
//  btnFSXDisconnect.Enabled := False;
//  btnFSXConnect.Enabled := True;

  msg := AMessage.MsgData;
  if Length(msg) > 0 then
    ShowMessage(msg);
end;


procedure TMainForm.btnCheckUpdatesClick(Sender: TObject);
begin
  CheckForUpdates(True);
end;


procedure TMainForm.btnRetryClick(Sender: TObject);
begin
  btnRetry.Visible := False;
//  StateConsumerTask.Comm.Send(MSG_FINDTHROTTLEDEVICE);
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
