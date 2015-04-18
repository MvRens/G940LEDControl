unit FSXAutoLaunch;

interface
type
  TFSXVersion = (fsxStandard, fsxSteamEdition);

  TFSXAutoLaunch = class(TObject)
  protected
    class function GetLaunchFileName(AVersion: TFSXVersion): string;
  public
    class function IsEnabled(AVersion: TFSXVersion): Boolean;
    class function SetEnabled(AVersion: TFSXVersion; AValue: Boolean): Boolean;
  end;


implementation
uses
  System.SysUtils,
  Xml.XMLIntf,

  X2UtApp,

  SimBaseDocumentXMLBinding;


const
  FSXEXELaunchFileName = 'exe.xml';
  AddonName = 'G940LEDControl';



{ TFSXAutoLaunch }
class function TFSXAutoLaunch.GetLaunchFileName(AVersion: TFSXVersion): string;
const
  VersionPath: array[TFSXVersion] of string = ('FSX', 'FSX-SE');

begin
  Result := App.UserPath + 'Microsoft\' + VersionPath[AVersion] + '\' + FSXEXELaunchFileName;
end;


class function TFSXAutoLaunch.IsEnabled(AVersion: TFSXVersion): Boolean;
var
  launch: IXMLSimBaseDocument;
  addon: IXMLLaunchAddon;

begin
  Result := False;
  if not FileExists(GetLaunchFileName(AVersion)) then
    exit;

  try
    launch := LoadSimBaseDocument(GetLaunchFileName(AVersion));

    for addon in launch do
    begin
      if addon.Name = AddonName then
      begin
        Result := True;
        break;
      end;
    end;
  except
    Result := False;
  end;
end;


class function TFSXAutoLaunch.SetEnabled(AVersion: TFSXVersion; AValue: Boolean): Boolean;
var
  launch: IXMLSimBaseDocument;
  findAddon: IXMLLaunchAddon;
  addon: IXMLLaunchAddon;

begin
  if not FileExists(GetLaunchFileName(AVersion)) then
  begin
    launch := NewSimBaseDocument;
    launch.OwnerDocument.Encoding := 'Windows-1252';
    launch.OwnerDocument.Options := launch.OwnerDocument.Options + [doNodeAutoIndent];

    launch._Type := 'Launch';
    launch.version := '1,0';

    launch.Descr := 'Launch';
    launch.Filename := FSXEXELaunchFileName;
    launch.Disabled := SimBaseBoolean_False;
    launch.LaunchManualLoad := SimBaseBoolean_False;
  end else
  begin
    launch := LoadSimBaseDocument(GetLaunchFileName(AVersion));
    launch.OwnerDocument.Options := launch.OwnerDocument.Options + [doNodeAutoIndent];
  end;

  addon := nil;
  for findAddon in launch do
  begin
    if findAddon.Name = AddonName then
    begin
      addon := findAddon;
      break;
    end;
  end;

  if AValue then
  begin
    if not Assigned(addon) then
    begin
      addon := launch.Add;
      addon.Name := AddonName;
    end;

    addon.Disabled := SimBaseBoolean_False;
    addon.ManualLoad := SimBaseBoolean_False;
    addon.Path := App.FileName;
    launch.OwnerDocument.SaveToFile(GetLaunchFileName(AVersion));
  end else
  begin
    if Assigned(addon) then
    begin
      launch.Remove(addon);
      launch.OwnerDocument.SaveToFile(GetLaunchFileName(AVersion));
    end;
  end;

  Result := AValue;
end;

end.
