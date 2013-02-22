unit MainFrm;

interface
uses
  System.Classes,
  System.Contnrs,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.Messages,
  Winapi.Windows,

  OtlComm,
  OtlEventMonitor,
  OtlTaskControl,
  OtlTask,
  pngimage,
  X2UtPersistIntf,

  LEDStateConsumer,
  Profile,
  Settings;


const
  CM_ASKAUTOUPDATE = WM_APP + 1;

  MSG_UPDATE = 1;
  MSG_NOUPDATE = 2;

  LED_COUNT = 8;

  DBT_DEVICEARRIVAL = $8000;
  DBT_DEVICEREMOVECOMPLETE = $8004;
  DBT_DEVTYP_DEVICEINTERFACE = $0005;
  DEVICE_NOTIFY_ALL_INTERFACE_CLASSES = $0004;


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
    procedure lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure btnCheckUpdatesClick(Sender: TObject);
    procedure LEDButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbProfilesClick(Sender: TObject);
    procedure cbCheckUpdatesClick(Sender: TObject);
  private
    FLEDControls: array[0..LED_COUNT - 1] of TLEDControls;
    FEventMonitor: TOmniEventMonitor;

    FProfilesFilename: string;
    FProfiles: TProfileList;
    FActiveProfile: TProfile;
    FLoadingProfiles: Boolean;
    FStateConsumerTask: IOmniTaskControl;

    FDeviceNotification: Pointer;
    FG940Found: Boolean;

    FSettingsFileName: string;
    FSettings: TSettings;
  protected
    procedure RegisterDeviceArrival;
    procedure UnregisterDeviceArrival;

    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
  protected
    procedure FindLEDControls;
    procedure LoadProfiles;
    procedure SaveProfiles;

    procedure LoadSettings;
    procedure SaveSettings;

    function CreateDefaultProfile: TProfile;
    procedure LoadActiveProfile;
    procedure UpdateButton(AProfile: TProfile; AButtonIndex: Integer);

    procedure SetDeviceState(const AMessage: string; AFound: Boolean);
//    procedure SetFSXToggleZoomButton(const ADeviceGUID: TGUID; AButtonIndex: Integer; const ADisplayText: string);

    procedure CheckForUpdatesThread(const ATask: IOmniTask);
    procedure CheckForUpdates(AReportNoUpdates: Boolean);

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure EventMonitorTerminated(const task: IOmniTaskControl);

    procedure HandleDeviceStateMessage(ATask: IOmniTaskControl; AMessage: TOmniMessage);

    procedure CMAskAutoUpdate(var Msg: TMessage); message CM_ASKAUTOUPDATE;

    property ActiveProfile: TProfile read FActiveProfile;
    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property Profiles: TProfileList read FProfiles;
    property Settings: TSettings read FSettings;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
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
  G940LEDStateConsumer,
  LEDColorIntf,
  LEDFunctionIntf,
  LEDFunctionRegistry,
  StaticResources;


{$R *.dfm}


const
  DefaultProfileName = 'Default';

  FILENAME_PROFILES = 'G940LEDControl\Profiles.xml';
  FILENAME_SETTINGS = 'G940LEDControl\Settings.xml';

  SPECIAL_CATEGORY = -1;

  TEXT_STATE_SEARCHING = 'Searching...';
  TEXT_STATE_NOTFOUND = 'Not found';
  TEXT_STATE_FOUND = 'Connected';




{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
var
  consumer: IOmniWorker;

begin
  lblVersion.Caption := App.Version.FormatVersion(False);

  PageControl.ActivePageIndex := 0;

  FEventMonitor := TOmniEventMonitor.Create(Self);

  consumer := TG940LEDStateConsumer.Create;
  FStateConsumerTask := FEventMonitor.Monitor(CreateTask(consumer)).MsgWait;

  EventMonitor.OnTaskMessage := EventMonitorMessage;
  EventMonitor.OnTaskTerminated := EventMonitorTerminated;
  StateConsumerTask.Run;

  FindLEDControls;

  FProfilesFilename := App.UserPath + FILENAME_PROFILES;
  FProfiles := TProfileList.Create(True);
  LoadProfiles;

  FSettingsFileName := App.UserPath + FILENAME_SETTINGS;
  LoadSettings;

  // #ToDo1 -oMvR: 22-2-2013: implement profile changing properly
  FStateConsumerTask.Comm.Send(TM_LOADPROFILE, ActiveProfile);

  RegisterDeviceArrival;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterDeviceArrival;

  FreeAndNil(FProfiles);
end;


procedure TMainForm.RegisterDeviceArrival;
type
  TDevBroadcastDeviceInterface = packed record
    dbcc_size: DWORD;
    dbcc_devicetype: DWORD;
    dbcc_reserved: DWORD;
    dbcc_classguid: TGUID;
    dbcc_name: PChar;
  end;

var
  request: TDevBroadcastDeviceInterface;

begin
  ZeroMemory(@request, SizeOf(request));
  request.dbcc_size := SizeOf(request);
  request.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;

  FDeviceNotification := RegisterDeviceNotification(Self.Handle, @request,
                                                    DEVICE_NOTIFY_WINDOW_HANDLE or
                                                    DEVICE_NOTIFY_ALL_INTERFACE_CLASSES);
end;


procedure TMainForm.UnregisterDeviceArrival;
begin
  if Assigned(FDeviceNotification) then
  begin
    UnregisterDeviceNotification(FDeviceNotification);
    FDeviceNotification := nil;
  end;
end;


procedure TMainForm.WMDeviceChange(var Msg: TMessage);
begin
  if not Assigned(StateConsumerTask) then
    exit;

  case Msg.WParam of
    DBT_DEVICEARRIVAL:
      if (not FG940Found) then
        StateConsumerTask.Comm.Send(TM_FINDTHROTTLEDEVICE);

    DBT_DEVICEREMOVECOMPLETE:
      if FG940Found then
        StateConsumerTask.Comm.Send(TM_TESTTHROTTLEDEVICE);
  end;
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
    defaultProfile := ConfigConversion.ConvertProfile0To1;

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


procedure TMainForm.LoadSettings;
var
  persistXML: TX2UtPersistXML;

begin
  if not FileExists(FSettingsFileName) then
  begin
    { Check if version 0.x settings are in the registry }
    FSettings := ConfigConversion.ConvertSettings0To1;

    if not Assigned(FSettings) then
      FSettings := TSettings.Create;
  end else
  begin
    FSettings := TSettings.Create;

    persistXML := TX2UtPersistXML.Create;
    try
      persistXML.FileName := FSettingsFileName;
      Settings.Load(persistXML.CreateReader);
    finally
      FreeAndNil(persistXML);
    end;
  end;

  cbCheckUpdates.Checked := Settings.CheckUpdates;

  if not Settings.HasCheckUpdates then
    PostMessage(Self.Handle, CM_ASKAUTOUPDATE, 0, 0)
  else if Settings.CheckUpdates then
    CheckForUpdates(False);
end;


procedure TMainForm.SaveSettings;
var
  persistXML: TX2UtPersistXML;

begin
  persistXML := TX2UtPersistXML.Create;
  try
    persistXML.FileName := FSettingsFileName;
    Settings.Save(persistXML.CreateWriter);
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
    Settings.CheckUpdates := True;

    CheckForUpdates(False);
  end;

  SaveSettings;
end;


procedure TMainForm.SetDeviceState(const AMessage: string; AFound: Boolean);
begin
  lblG940ThrottleState.Caption := AMessage;
  lblG940ThrottleState.Update;

  imgStateFound.Visible := AFound;
  imgStateNotFound.Visible := not AFound;

  FG940Found := AFound;
end;


procedure TMainForm.LEDButtonClick(Sender: TObject);
var
  buttonIndex: NativeInt;

begin
  if not Assigned(ActiveProfile) then
    exit;

  buttonIndex := (Sender as TComponent).Tag;
  if TButtonFunctionForm.Execute(ActiveProfile, buttonIndex) then
  begin
    UpdateButton(ActiveProfile, buttonIndex);
    FStateConsumerTask.Comm.Send(TM_LOADPROFILE, ActiveProfile);
    SaveProfiles;
  end;
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
        ATask.Comm.Send(MSG_UPDATE, latestVersion)
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


procedure TMainForm.cbCheckUpdatesClick(Sender: TObject);
begin
  Settings.CheckUpdates := cbCheckUpdates.Checked;
  SaveSettings;
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
    TM_NOTIFY_DEVICESTATE:
      HandleDeviceStateMessage(task, msg);

    MSG_UPDATE:
      if MessageBox(Self.Handle, PChar('Version ' + msg.MsgData + ' is available on the G940 LED Control website.'#13#10 +
                                       'Do you want to open the website now?'), 'Update available',
                                       MB_YESNO or MB_ICONINFORMATION) = ID_YES then
        ShellExecute(Self.Handle, 'open', PChar('http://g940.x2software.net/category/releases/'), nil, nil, SW_SHOWNORMAL);

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
      SetDeviceState(TEXT_STATE_NOTFOUND, False);
  end;
end;


procedure TMainForm.btnCheckUpdatesClick(Sender: TObject);
begin
  CheckForUpdates(True);
end;


procedure TMainForm.lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(Self.Handle, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

end.
