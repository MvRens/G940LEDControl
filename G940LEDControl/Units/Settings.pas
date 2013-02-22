unit Settings;

interface
uses
  X2UtPersistIntf;

type
  TSettings = class(TObject)
  private
    FCheckUpdates: Boolean;
    FHasCheckUpdates: Boolean;

    procedure SetCheckUpdates(const Value: Boolean);
  public
    procedure Load(AReader: IX2PersistReader);
    procedure Save(AWriter: IX2PersistWriter);

    property CheckUpdates: Boolean read FCheckUpdates write SetCheckUpdates;
    property HasCheckUpdates: Boolean read FHasCheckUpdates;
  end;


implementation
const
  SectionSettings = 'Settings';

  KeyCheckUpdates = 'CheckUpdates';


{ TSettings }
procedure TSettings.Load(AReader: IX2PersistReader);
var
  value: Boolean;

begin
  if AReader.BeginSection(SectionSettings) then
  try
    if AReader.ReadBoolean(KeyCheckUpdates, value) then
      CheckUpdates := value;
  finally
    AReader.EndSection;
  end;
end;


procedure TSettings.Save(AWriter: IX2PersistWriter);
begin
  if AWriter.BeginSection(SectionSettings) then
  try
    AWriter.WriteBoolean(KeyCheckUpdates, CheckUpdates);
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
