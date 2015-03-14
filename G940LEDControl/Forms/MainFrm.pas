unit MainFrm;

// #ToDo1 -oMvR: 3-3-2013: trigger profile update when Save As only changes the name

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

  FSXSimConnectIntf,
  LEDStateConsumer,
  Profile,
  ProfileManager,
  Settings;


const
  CM_ASKAUTOUPDATE = WM_APP + 1;
  CM_PROFILECHANGED = WM_APP + 2;

  TM_UPDATE = 1;
  TM_NOUPDATE = 2;
  TM_FSXSTATE = 3;

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


  TMainForm = class(TForm, IProfileObserver)
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
    tsButtons: TTabSheet;
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
    pnlFSX: TPanel;
    imgFSXStateNotConnected: TImage;
    imgFSXStateConnected: TImage;
    lblFSX: TLabel;
    lblFSXState: TLabel;
    pnlState: TPanel;
    tsConfiguration: TTabSheet;
    cbProfileMenu: TCheckBox;
    cbProfileMenuCascaded: TCheckBox;
    lblProfileSwitching: TLabel;
    bvlProfileSwitching: TBevel;

    procedure FormCreate(Sender: TObject);
    procedure lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure btnCheckUpdatesClick(Sender: TObject);
    procedure LEDButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbProfilesClick(Sender: TObject);
    procedure cbCheckUpdatesClick(Sender: TObject);
    procedure btnSaveProfileClick(Sender: TObject);
    procedure btnDeleteProfileClick(Sender: TObject);
    procedure cbProfileMenuClick(Sender: TObject);
    procedure cbProfileMenuCascadedClick(Sender: TObject);
  private
    FLEDControls: array[0..LED_COUNT - 1] of TLEDControls;
    FEventMonitor: TOmniEventMonitor;

    FProfilesFilename: string;
    FLockChangeProfile: Boolean;
    FStateConsumerTask: IOmniTaskControl;

    FDeviceNotification: Pointer;
    FG940Found: Boolean;

    FSettingsFileName: string;
    FSettings: TSettings;
  protected
    procedure RegisterDeviceArrival;
    procedure UnregisterDeviceArrival;

    { IProfileObserver }
    procedure ObserveAdd(AProfile: TProfile);
    procedure ObserveRemove(AProfile: TProfile);
    procedure ObserveActiveChanged(AProfile: TProfile);

    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure CMProfileChanged(var Msg: TMessage); message CM_PROFILECHANGED;
  protected
    procedure FindLEDControls;
    procedure LoadProfiles;
    procedure SaveProfiles;

    procedure LoadSettings;
    procedure SaveSettings;

    function CreateDefaultProfile: TProfile;
    procedure LoadActiveProfile;
    procedure UpdateButton(AProfile: TProfile; AButtonIndex: Integer);

    procedure AddProfile(AProfile: TProfile);
    procedure UpdateProfile(AProfile: TProfile);
    procedure DeleteProfile(AProfile: TProfile; ASetActiveProfile: Boolean);

    procedure ApplyProfileMenuSettings;
    procedure FinalizeProfileMenu;

    procedure SetDeviceState(const AMessage: string; AFound: Boolean);
    procedure SetFSXState(const AMessage: string; AConnected: Boolean);
//    procedure SetFSXToggleZoomButton(const ADeviceGUID: TGUID; AButtonIndex: Integer; const ADisplayText: string);

    procedure CheckForUpdatesThread(const ATask: IOmniTask);
    procedure CheckForUpdates(AReportNoUpdates: Boolean);

    procedure EventMonitorMessage(const task: IOmniTaskControl; const msg: TOmniMessage);
    procedure EventMonitorTerminated(const task: IOmniTaskControl);

    procedure HandleDeviceStateMessage(AMessage: TOmniMessage);
    procedure HandleFSXStateMessage(AMessage: TOmniMessage);

    procedure CMAskAutoUpdate(var Msg: TMessage); message CM_ASKAUTOUPDATE;

    property EventMonitor: TOmniEventMonitor read FEventMonitor;
    property Settings: TSettings read FSettings;
    property StateConsumerTask: IOmniTaskControl read FStateConsumerTask;
  end;


implementation
uses
  System.SysUtils,
  System.Win.ComObj,
  Vcl.Dialogs,
  Vcl.Graphics,
  Winapi.ShellAPI,

  IdException,
  IdHTTP,
  OtlCommon,
  X2UtApp,
  X2UtPersistXML,

  ButtonFunctionFrm,
  ConfigConversion,
  DebugLog,
  FSXLEDFunctionProviderIntf,
  FSXResources,
  FSXSimConnectStateMonitor,
  G940LEDStateConsumer,
  LEDColorIntf,
  LEDFunctionIntf,
  LEDFunctionRegistry,
  StaticResources;


{$R *.dfm}


const
  DefaultProfileName = 'Default';
  ProfilePostfixModified = ' (modified)';

  FilenameProfiles = 'G940LEDControl\Profiles.xml';
  FilenameSettings = 'G940LEDControl\Settings.xml';

  TextStateSearching = 'Searching...';
  TextStateNotFound = 'Not found';
  TextStateFound = 'Connected';

  TextFSXConnected = 'Connected';
  TextFSXDisconnected = 'Not connected';
  TextFSXFailed = 'Failed to connect';




type
  TFSXStateMonitorWorker = class(TOmniWorker, IFSXSimConnectStateObserver)
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    { IFSXSimConnectStateObserver }
    procedure ObserverStateUpdate(ANewState: TFSXSimConnectState);
  end;




{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);

  procedure AlignBevel(ABevel: TBevel; ACaption: TLabel);
  var
    bounds: TRect;

  begin
    bounds := ABevel.BoundsRect;
    bounds.Left := ACaption.BoundsRect.Right + 8;
    ABevel.BoundsRect := bounds;
  end;

var
  worker: IOmniWorker;

begin
  lblVersion.Caption := App.Version.FormatVersion(False);

  PageControl.ActivePageIndex := 0;
  AlignBevel(bvlProfileSwitching, lblProfileSwitching);

  FEventMonitor := TOmniEventMonitor.Create(Self);

  Debug.Log('UI: Starting G940 LED state consumer thread');
  worker := TG940LEDStateConsumer.Create;
  FStateConsumerTask := EventMonitor.Monitor(CreateTask(worker));

  EventMonitor.OnTaskMessage := EventMonitorMessage;
  EventMonitor.OnTaskTerminated := EventMonitorTerminated;

  StateConsumerTask.Run;


  Debug.Log('UI: Starting FSX state monitor thread');
  worker := TFSXStateMonitorWorker.Create;
  EventMonitor.Monitor(CreateTask(worker)).Run;

  TProfileManager.Attach(Self);

  FindLEDControls;

  FProfilesFilename := App.UserPath + FilenameProfiles;
  LoadProfiles;

  FSettingsFileName := App.UserPath + FilenameSettings;
  LoadSettings;

  RegisterDeviceArrival;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeProfileMenu;

  UnregisterDeviceArrival;
  TProfileManager.Detach(Self);
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
  Debug.Log('UI: Registering for device notifications');

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
    Debug.Log('UI: Unregistering for device notifications');

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
      begin
        Debug.Log('UI: Device arrived');

        if (not FG940Found) then
          StateConsumerTask.Comm.Send(TM_FINDTHROTTLEDEVICE);
      end;

    DBT_DEVICEREMOVECOMPLETE:
      begin
        Debug.Log('UI: Device removed');

        if FG940Found then
          StateConsumerTask.Comm.Send(TM_TESTTHROTTLEDEVICE);
      end;
  end;
end;


procedure TMainForm.CMProfileChanged(var Msg: TMessage);
var
  profile: TProfile;

begin
  profile := TProfileManager.Instance.ActiveProfile;

  if Settings.ActiveProfile <> profile.Name then
  begin
    Settings.ActiveProfile := profile.Name;
    SaveSettings;
  end;

  FLockChangeProfile := True;
  try
    cmbProfiles.ItemIndex := cmbProfiles.Items.IndexOfObject(profile);
  finally
    FLockChangeProfile := False;
  end;

  LoadActiveProfile;
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
  Debug.LogFmt('UI: Loading profiles (%s)', [FProfilesFilename]);
  Debug.Indent;
  try
    if not FileExists(FProfilesFilename) then
    begin
      Debug.Log('UI: Profiles not found, attempting conversion from 0.x profile');

      { Check if version 0.x settings are in the registry }
      defaultProfile := ConfigConversion.ConvertProfile0To1;

      if not Assigned(defaultProfile) then
      begin
        Debug.Log('UI: 0.x profile not found, creating default profile');
        defaultProfile := CreateDefaultProfile
      end else
      begin
        Debug.Log('UI: Succesfully converted 0.x profile');
        defaultProfile.Name := DefaultProfileName;
        defaultProfile.IsTemporary := True;
      end;

      if Assigned(defaultProfile) then
        TProfileManager.Add(defaultProfile);
    end else
    begin
      persistXML := TX2UtPersistXML.Create;
      try
        persistXML.FileName := FProfilesFilename;
        TProfileManager.Load(persistXML.CreateReader);
      finally
        FreeAndNil(persistXML);
      end;
    end;

    { Make sure we always have a profile }
    if TProfileManager.Instance.Count = 0 then
    begin
      Debug.Log('UI: No profiles found, creating default profile');
      TProfileManager.Add(CreateDefaultProfile);
    end;

    FLockChangeProfile := True;
    try
      cmbProfiles.Items.BeginUpdate;
      try
        cmbProfiles.Items.Clear;

        for profile in TProfileManager.Instance do
          cmbProfiles.Items.AddObject(profile.Name, profile);
      finally
        cmbProfiles.Items.EndUpdate;
      end;
    finally
      FLockChangeProfile := False;
    end;
  finally
    Debug.UnIndent;
  end;
end;


procedure TMainForm.SaveProfiles;
var
  persistXML: TX2UtPersistXML;

begin
  Debug.LogFmt('UI: Saving profiles (%s)', [FProfilesFilename]);

  persistXML := TX2UtPersistXML.Create;
  try
    persistXML.FileName := FProfilesFilename;
    TProfileManager.Instance.Save(persistXML.CreateWriter);
  finally
    FreeAndNil(persistXML);
  end;
end;


procedure TMainForm.LoadSettings;
var
  persistXML: TX2UtPersistXML;
  profile: TProfile;

begin
  Debug.LogFmt('UI: Loading profiles (%s)', [FSettingsFilename]);
  Debug.Indent;
  try
    if not FileExists(FSettingsFileName) then
    begin
      Debug.Log('UI: Settings not found, attempting conversion from 0.x settings');

      { Check if version 0.x settings are in the registry }
      FSettings := ConfigConversion.ConvertSettings0To1;

      if not Assigned(FSettings) then
      begin
        Debug.Log('UI: 0.x profile not found, creating default settings');
        FSettings := TSettings.Create;
      end else
        Debug.Log('UI: Succesfully converted 0.x settings');
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

    { Default profile }
    profile := nil;
    if Length(Settings.ActiveProfile) > 0 then
      profile := TProfileManager.Instance.Find(Settings.ActiveProfile);

    { LoadProfiles ensures there's always at least 1 profile }
    if (not Assigned(profile)) and (TProfileManager.Instance.Count > 0) then
      profile := TProfileManager.Instance[0];

    TProfileManager.Instance.ActiveProfile := profile;

    { Auto-update }
    cbCheckUpdates.Checked := Settings.CheckUpdates;

    if not Settings.HasCheckUpdates then
      PostMessage(Self.Handle, CM_ASKAUTOUPDATE, 0, 0)
    else if Settings.CheckUpdates then
      CheckForUpdates(False);


    cbProfileMenu.Checked := Settings.ProfileMenu;
    cbProfileMenuCascaded.Checked := Settings.ProfileMenuCascaded;

    ApplyProfileMenuSettings;
  finally
    Debug.UnIndent;
  end;
end;


procedure TMainForm.SaveSettings;
var
  persistXML: TX2UtPersistXML;

begin
  Debug.LogFmt('UI: Saving settings (%s)', [FSettingsFilename]);

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
  Result.Name := DefaultProfileName;
  Result.IsTemporary := True;
end;


procedure TMainForm.LoadActiveProfile;
var
  activeProfile: TProfile;
  buttonIndex: Integer;

begin
  activeProfile := TProfileManager.Instance.ActiveProfile;
  if not Assigned(activeProfile) then
    exit;

  Debug.LogFmt('UI: Loading active profile (%s)', [activeProfile.Name]);

  for buttonIndex := 0 to Pred(LED_COUNT) do
    UpdateButton(activeProfile, buttonIndex);

  if Assigned(StateConsumerTask) then
    StateConsumerTask.Comm.Send(TM_LOADPROFILE, activeProfile);
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


procedure TMainForm.AddProfile(AProfile: TProfile);
begin
  cmbProfiles.Items.AddObject(AProfile.Name, AProfile);
  TProfileManager.Instance.Add(AProfile, True);
end;


procedure TMainForm.UpdateProfile(AProfile: TProfile);
var
  itemIndex: Integer;
  oldItemIndex: Integer;

begin
  itemIndex := cmbProfiles.Items.IndexOfObject(AProfile);
  if itemIndex > -1 then
  begin
    oldItemIndex := cmbProfiles.ItemIndex;
    FLockChangeProfile := True;
    try
      cmbProfiles.Items[itemIndex] := AProfile.Name;
      cmbProfiles.ItemIndex := oldItemIndex;
    finally
      FLockChangeProfile := False;
    end;
  end;
end;


procedure TMainForm.DeleteProfile(AProfile: TProfile; ASetActiveProfile: Boolean);
var
  itemIndex: Integer;

begin
  itemIndex := cmbProfiles.Items.IndexOfObject(AProfile);
  if itemIndex > -1 then
  begin
    TProfileManager.Remove(AProfile);
    cmbProfiles.Items.Delete(itemIndex);

    if TProfileManager.Instance.Count = 0 then
      AddProfile(CreateDefaultProfile);

    if ASetActiveProfile then
    begin
      if itemIndex >= TProfileManager.Instance.Count then
        itemIndex := Pred(TProfileManager.Instance.Count);

      FLockChangeProfile := True;
      try
        cmbProfiles.ItemIndex := itemIndex;
        TProfileManager.Instance.ActiveProfile := TProfile(cmbProfiles.Items.Objects[itemIndex]);
      finally
        FLockChangeProfile := False;
      end;
    end;
  end;
end;


procedure TMainForm.cmbProfilesClick(Sender: TObject);
begin
  if not FLockChangeProfile then
  begin
    if cmbProfiles.ItemIndex > -1 then
      TProfileManager.Instance.ActiveProfile := TProfile(cmbProfiles.Items.Objects[cmbProfiles.ItemIndex]);
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


procedure TMainForm.ObserveActiveChanged(AProfile: TProfile);
begin
  { This callback is not thread-safe }
  PostMessage(Self.Handle, CM_PROFILECHANGED, 0, 0);
end;


procedure TMainForm.ObserveAdd(AProfile: TProfile);
begin
  { For now we'll assume we're the only one changing the profiles }
end;


procedure TMainForm.ObserveRemove(AProfile: TProfile);
begin
end;


procedure TMainForm.SetDeviceState(const AMessage: string; AFound: Boolean);
begin
  Debug.LogFmt('UI: G940 Throttle state changed (found = %s, status = %s)', [BoolToStr(AFound, True), AMessage]);

  lblG940ThrottleState.Caption := AMessage;
  lblG940ThrottleState.Update;

  imgStateFound.Visible := AFound;
  imgStateNotFound.Visible := not AFound;

  FG940Found := AFound;
end;


procedure TMainForm.SetFSXState(const AMessage: string; AConnected: Boolean);
begin
  Debug.LogFmt('UI: FSX SimConnect state changed (connected = %s, status = %s)', [BoolToStr(AConnected, True), AMessage]);

  lblFSXState.Caption := AMessage;
  lblFSXState.Update;

  imgFSXStateConnected.Visible := AConnected;
  imgFSXStateNotConnected.Visible := not AConnected;
end;


procedure TMainForm.LEDButtonClick(Sender: TObject);

  function GetUniqueProfileName(const AName: string): string;
  var
    counter: Integer;

  begin
    Result := AName;
    counter := 0;

    while Assigned(TProfileManager.Find(Result)) do
    begin
      Inc(counter);
      Result := Format('%s (%d)', [AName, counter]);
    end;
  end;


var
  activeProfile: TProfile;
  buttonIndex: NativeInt;
  profile: TProfile;
  newProfile: Boolean;

begin
  activeProfile := TProfileManager.Instance.ActiveProfile;
  if not Assigned(activeProfile) then
    exit;

  { Behaviour similar to the Windows System Sounds control panel;
    when a change occurs, create a temporary profile "(modified)"
    so the original profile can still be selected }
  if not activeProfile.IsTemporary then
  begin
    profile := TProfile.Create;
    profile.Assign(activeProfile);
    profile.Name := GetUniqueProfileName(profile.Name + ProfilePostfixModified);
    profile.IsTemporary := True;
    newProfile := True;
  end else
  begin
    profile := activeProfile;
    newProfile := False;
  end;

  buttonIndex := (Sender as TComponent).Tag;
  if TButtonFunctionForm.Execute(profile, buttonIndex) then
  begin
    if newProfile then
      AddProfile(profile);

    SaveProfiles;
    UpdateButton(profile, buttonIndex);

    if Assigned(StateConsumerTask) then
      StateConsumerTask.Comm.Send(TM_LOADPROFILE, profile);
  end else
  begin
    if newProfile then
      FreeAndNil(profile);
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
const
  UPDATE_URL = 'http://g940.x2software.net/version';

var
  httpClient: TIdHTTP;
  msgSent: Boolean;
  latestVersion: string;

begin
  msgSent := False;
  try
    Debug.LogFmt('AutoUpdate: Checking for updates (%s)', [UPDATE_URL]);

    httpClient := TIdHTTP.Create(nil);
    try
      latestVersion := httpClient.Get(UPDATE_URL);
      Debug.LogFmt('AutoUpdate: Received version "%s"', [latestVersion]);

      if VersionIsNewer(Format('%d.%d.%d', [App.Version.Major, App.Version.Minor, App.Version.Release]), latestVersion) then
        ATask.Comm.Send(TM_UPDATE, latestVersion)
      else
      begin
        if ATask.Param.ByName('ReportNoUpdates').AsBoolean then
          ATask.Comm.Send(TM_NOUPDATE, True);
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
        ATask.Comm.Send(TM_NOUPDATE, False);
    end;
  end;
end;


procedure TMainForm.btnSaveProfileClick(Sender: TObject);
var
  name: string;
  profile: TProfile;
  existingProfile: TProfile;
  newProfile: TProfile;

begin
  name := '';
  profile := TProfileManager.Instance.ActiveProfile;
  existingProfile := nil;

  repeat
    if InputQuery('Save profile as', 'Save this profile as:', name) then
    begin
      existingProfile := TProfileManager.Find(name);
      if existingProfile = profile then
        existingProfile := nil;

      if Assigned(existingProfile) then
      begin
        case MessageBox(Self.Handle, PChar(Format('A profile named "%s" exists, do you want to overwrite it?', [name])),
                        'Save profile as', MB_ICONQUESTION or MB_YESNOCANCEL) of
          ID_YES:
            break;

          ID_CANCEL:
            exit;
        end;
      end else
        break;
    end else
      exit;
  until False;

  if Assigned(existingProfile) then
  begin
    existingProfile.Assign(profile);
    existingProfile.Name := name;
    UpdateProfile(existingProfile);
    TProfileManager.Instance.ActiveProfile := existingProfile;

    if profile.IsTemporary then
      DeleteProfile(profile, False);
  end else
  begin
    if profile.IsTemporary then
    begin
      profile.Name := name;
      profile.IsTemporary := False;
      UpdateProfile(profile);
    end else
    begin
      newProfile := TProfile.Create;
      newProfile.Assign(profile);
      newProfile.Name := name;
      AddProfile(newProfile);
    end;
  end;

  SaveProfiles;
end;


procedure TMainForm.btnDeleteProfileClick(Sender: TObject);
var
  activeProfile: TProfile;

begin
  activeProfile := TProfileManager.Instance.ActiveProfile;
  if Assigned(activeProfile) then
  begin
    if MessageBox(Self.Handle, PChar(Format('Do you want to remove the profile named "%s"?', [activeProfile.Name])),
                  'Remove profile', MB_ICONQUESTION or MB_YESNO) = ID_YES then
    begin
      DeleteProfile(activeProfile, True);
      SaveProfiles;
    end;
  end;
end;


procedure TMainForm.cbCheckUpdatesClick(Sender: TObject);
begin
  Settings.CheckUpdates := cbCheckUpdates.Checked;
  SaveSettings;
end;


procedure TMainForm.cbProfileMenuClick(Sender: TObject);
begin
  Settings.ProfileMenu := cbProfileMenu.Checked;
  SaveSettings;
  ApplyProfileMenuSettings;
end;


procedure TMainForm.cbProfileMenuCascadedClick(Sender: TObject);
begin
  Settings.ProfileMenuCascaded := cbProfileMenuCascaded.Checked;
  SaveSettings;
  ApplyProfileMenuSettings;
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
      HandleDeviceStateMessage(msg);

    TM_FSXSTATE:
      HandleFSXStateMessage(msg);

    TM_UPDATE:
      if MessageBox(Self.Handle, PChar('Version ' + msg.MsgData + ' is available on the G940 LED Control website.'#13#10 +
                                       'Do you want to open the website now?'), 'Update available',
                                       MB_YESNO or MB_ICONINFORMATION) = ID_YES then
        ShellExecute(Self.Handle, 'open', PChar('http://g940.x2software.net/category/releases/'), nil, nil, SW_SHOWNORMAL);

    TM_NOUPDATE:
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


procedure TMainForm.HandleDeviceStateMessage(AMessage: TOmniMessage);
begin
  case AMessage.MsgData.AsInteger of
    DEVICESTATE_SEARCHING:
      SetDeviceState(TextStateSearching, False);

    DEVICESTATE_FOUND:
      SetDeviceState(TextStateFound, True);

    DEVICESTATE_NOTFOUND:
      SetDeviceState(TextStateNotFound, False);
  end;
end;


procedure TMainForm.HandleFSXStateMessage(AMessage: TOmniMessage);
var
  state: TFSXSimConnectState;

begin
  state := TFSXSimConnectState(AMessage.MsgData.AsInteger);

  case state of
    scsDisconnected:
      SetFSXState(TextFSXDisconnected, False);

    scsConnected:
      SetFSXState(TextFSXConnected, True);

    scsFailed:
      SetFSXState(TextFSXFailed, False);
  end;
end;


procedure TMainForm.ApplyProfileMenuSettings;
var
  fsxProvider: IFSXLEDFunctionProvider;

begin
  if Supports(TLEDFunctionRegistry.Find(FSXProviderUID), IFSXLEDFunctionProvider, fsxProvider) then
    fsxProvider.SetProfileMenu(Settings.ProfileMenu, Settings.ProfileMenuCascaded);
end;


procedure TMainForm.FinalizeProfileMenu;
var
  fsxProvider: IFSXLEDFunctionProvider;

begin
  if Supports(TLEDFunctionRegistry.Find(FSXProviderUID), IFSXLEDFunctionProvider, fsxProvider) then
    fsxProvider.SetProfileMenu(False, False);
end;


procedure TMainForm.btnCheckUpdatesClick(Sender: TObject);
begin
  CheckForUpdates(True);
end;


procedure TMainForm.lblLinkLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(Self.Handle, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;


{ TFSXStateMonitorWorker }
function TFSXStateMonitorWorker.Initialize: Boolean;
begin
  Result := inherited Initialize;

  if Result then
    TFSXSimConnectStateMonitor.Instance.Attach(Self);
end;


procedure TFSXStateMonitorWorker.Cleanup;
begin
  TFSXSimConnectStateMonitor.Instance.Detach(Self);

  inherited Cleanup;
end;

procedure TFSXStateMonitorWorker.ObserverStateUpdate(ANewState: TFSXSimConnectState);
begin
  Task.Comm.Send(TM_FSXSTATE, Integer(ANewState));
end;

end.
