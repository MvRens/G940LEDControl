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

    procedure SetCheckUpdates(const Value: Boolean);
  public
    procedure Load(AReader: IX2PersistReader);
    procedure Save(AWriter: IX2PersistWriter);

    property CheckUpdates: Boolean read FCheckUpdates write SetCheckUpdates;
    property HasCheckUpdates: Boolean read FHasCheckUpdates;

    property ActiveProfile: string read FActiveProfile write FActiveProfile;
  end;


implementation
const
  SectionSettings = 'Settings';

  KeyCheckUpdates = 'CheckUpdates';
  KeyActiveProfile = 'ActiveProfile';


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
