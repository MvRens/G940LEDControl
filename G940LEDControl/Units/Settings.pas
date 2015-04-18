unit Settings;

interface
uses
  X2UtPersistIntf;

type
  TSettings = class(TObject)
  private
    FCheckUpdates: Boolean;
    FHasCheckUpdates: Boolean;
    FActiveProfile: string;
    FProfileMenu: Boolean;
    FProfileMenuCascaded: Boolean;
    FTrayIcon: Boolean;
    FMinimizeToTray: Boolean;
    FLaunchMinimized: Boolean;

    procedure SetCheckUpdates(const Value: Boolean);
  public
    procedure Load(AReader: IX2PersistReader);
    procedure Save(AWriter: IX2PersistWriter);

    property CheckUpdates: Boolean read FCheckUpdates write SetCheckUpdates;
    property HasCheckUpdates: Boolean read FHasCheckUpdates;

    property ActiveProfile: string read FActiveProfile write FActiveProfile;

    property ProfileMenu: Boolean read FProfileMenu write FProfileMenu;
    property ProfileMenuCascaded: Boolean read FProfileMenuCascaded write FProfileMenuCascaded;

    property TrayIcon: Boolean read FTrayIcon write FTrayIcon;
    property MinimizeToTray: Boolean read FMinimizeToTray write FMinimizeToTray;
    property LaunchMinimized: Boolean read FLaunchMinimized write FLaunchMinimized;
  end;


implementation
const
  SectionSettings = 'Settings';

  KeyCheckUpdates = 'CheckUpdates';
  KeyActiveProfile = 'ActiveProfile';

  KeyProfileMenu = 'ProfileMenu';
  KeyProfileMenuCascaded = 'ProfileMenuCascaded';

  KeyTrayIcon = 'TrayIcon';
  KeyMinimizeToTray = 'MinimizeToTray';
  KeyLaunchMinimized = 'LaunchMinimized';


{ TSettings }
procedure TSettings.Load(AReader: IX2PersistReader);
var
  value: Boolean;

begin
  if AReader.BeginSection(SectionSettings) then
  try
    if AReader.ReadBoolean(KeyCheckUpdates, value) then
      CheckUpdates := value;

    if not AReader.ReadString(KeyActiveProfile, FActiveProfile) then
      FActiveProfile := '';

    if not AReader.ReadBoolean(KeyProfileMenu, FProfileMenu) then
      FProfileMenu := False;

    if not AReader.ReadBoolean(KeyProfileMenuCascaded, FProfileMenuCascaded) then
      FProfileMenuCascaded := False;

    if not AReader.ReadBoolean(KeyTrayIcon, FTrayIcon) then
      FTrayIcon := False;

    if not AReader.ReadBoolean(KeyMinimizeToTray, FMinimizeToTray) then
      FMinimizeToTray := False;

    if not AReader.ReadBoolean(KeyLaunchMinimized, FLaunchMinimized) then
      FLaunchMinimized := False;
  finally
    AReader.EndSection;
  end;
end;


procedure TSettings.Save(AWriter: IX2PersistWriter);
begin
  if AWriter.BeginSection(SectionSettings) then
  try
    AWriter.WriteBoolean(KeyCheckUpdates, CheckUpdates);
    AWriter.WriteString(KeyActiveProfile, ActiveProfile);
    AWriter.WriteBoolean(KeyProfileMenu, ProfileMenu);
    AWriter.WriteBoolean(KeyProfileMenuCascaded, ProfileMenuCascaded);
    AWriter.WriteBoolean(KeyTrayIcon, TrayIcon);
    AWriter.WriteBoolean(KeyMinimizeToTray, MinimizeToTray);
    AWriter.WriteBoolean(KeyLaunchMinimized, LaunchMinimized);
  finally
    AWriter.EndSection;
  end;
end;


procedure TSettings.SetCheckUpdates(const Value: Boolean);
begin
  FCheckUpdates := Value;
  FHasCheckUpdates := True;
end;

end.
