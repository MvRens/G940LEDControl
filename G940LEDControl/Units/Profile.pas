unit Profile;

interface
uses
  Generics.Collections,
  System.Classes,

  X2UtPersistIntf,

  LEDColorIntf;


type
  TProfileButtonStateColors = TDictionary<string,TLEDColor>;

  TProfileButton = class(TPersistent)
  private
    FProviderUID: string;
    FFunctionUID: string;

    FStateColors: TProfileButtonStateColors;
  protected
    function Load(AReader: IX2PersistReader): Boolean;
    procedure Save(AWriter: IX2PersistWriter);

    property StateColors: TProfileButtonStateColors read FStateColors;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure ClearStateColors;
    function GetStateColor(const AStateUID: string; out AValue: TLEDColor): Boolean;
    procedure SetStateColor(const AStateUID: string; const AValue: TLEDColor);

    property ProviderUID: string read FProviderUID write FProviderUID;
    property FunctionUID: string read FFunctionUID write FFunctionUID;
  end;


  TProfileButtonList = class(TObjectList<TProfileButton>);


  TProfile = class(TPersistent)
  private
    FUID: string;
    FName: string;
    FButtons: TProfileButtonList;

    function GetButton(Index: Integer): TProfileButton;
    function GetButtonCount: Integer;
  protected
    procedure Load(AReader: IX2PersistReader);
    procedure Save(AWriter: IX2PersistWriter);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function HasButton(AIndex: Integer): Boolean;

    property UID: string read FUID write FUID;
    property Name: string read FName write FName;

    property ButtonCount: Integer read GetButtonCount;
    property Buttons[Index: Integer]: TProfileButton read GetButton;
  end;


  TProfileList = class(TObjectList<TProfile>)
  public
//    function Find(const AName: string): TProfile;

    procedure Load(AReader: IX2PersistReader);
    procedure Save(AWriter: IX2PersistWriter);
  end;


implementation
uses
  System.SysUtils,

  LEDResources;


const
  SectionProfiles = 'Profiles';
  SectionButton = 'Button';
  SectionStates = 'States';

  KeyProviderUID = 'ProviderUID';
  KeyFunctionUID = 'FunctionUID';


{ TProfileButton }
constructor TProfileButton.Create;
begin
  inherited Create;

  FStateColors := TProfileButtonStateColors.Create;
end;


destructor TProfileButton.Destroy;
begin
  FreeAndNil(FStateColors);

  inherited Destroy;
end;


procedure TProfileButton.Assign(Source: TPersistent);
var
  sourceButton: TProfileButton;
  stateUID: string;

begin
  if Source is TProfileButton then
  begin
    sourceButton := TProfileButton(Source);

    FProviderUID := sourceButton.ProviderUID;
    FFunctionUID := sourceButton.FunctionUID;

    FStateColors.Clear;
    for stateUID in sourceButton.StateColors.Keys do
      SetStateColor(stateUID, sourceButton.StateColors[stateUID]);
  end else
    inherited Assign(Source);
end;


procedure TProfileButton.ClearStateColors;
begin
  FStateColors.Clear;
end;


function TProfileButton.GetStateColor(const AStateUID: string; out AValue: TLEDColor): Boolean;
begin
  Result := StateColors.TryGetValue(AStateUID, AValue);
end;


procedure TProfileButton.SetStateColor(const AStateUID: string; const AValue: TLEDColor);
begin
  StateColors.AddOrSetValue(AStateUID, AValue);
end;


function TProfileButton.Load(AReader: IX2PersistReader): Boolean;
var
  stateUIDs: TStringList;
  stateUID: string;
  colorUID: string;
  color: TLEDColor;

begin
  Result := AReader.ReadString(KeyProviderUID, FProviderUID) and
            AReader.ReadString(KeyFunctionUID, FFunctionUID);

  if Result and AReader.BeginSection(SectionStates) then
  try
    StateColors.Clear;

    stateUIDs := TStringList.Create;
    try
      AReader.GetKeys(stateUIDs);

      for stateUID in stateUIDs do
      begin
        if AReader.ReadString(stateUID, colorUID) and
           StringToLEDColor(colorUID, color) then
        begin
          StateColors.Add(stateUID, color);
        end;
      end;
    finally
      FreeAndNil(stateUIDs);
    end;
  finally
    AReader.EndSection;
  end;
end;


procedure TProfileButton.Save(AWriter: IX2PersistWriter);
var
  stateUID: string;

begin
  AWriter.WriteString(KeyProviderUID, FProviderUID);
  AWriter.WriteString(KeyFunctionUID, FFunctionUID);

  if AWriter.BeginSection(SectionStates) then
  try
    for stateUID in StateColors.Keys do
      AWriter.WriteString(stateUID, LEDColorUID[StateColors[stateUID]]);
  finally
    AWriter.EndSection;
  end;
end;


{ TProfile }
constructor TProfile.Create;
begin
  inherited Create;

  FButtons := TProfileButtonList.Create(True);
end;


destructor TProfile.Destroy;
begin
  FreeAndNil(FButtons);

  inherited Destroy;
end;


procedure TProfile.Assign(Source: TPersistent);
var
  sourceProfile: TProfile;
  buttonIndex: Integer;

begin
  if Source is TProfile then
  begin
    sourceProfile := TProfile(Source);

    FUID := sourceProfile.UID;
    FName := sourceProfile.Name;

    FButtons.Clear;
    for buttonIndex := 0 to Pred(sourceProfile.ButtonCount) do
      Buttons[buttonIndex].Assign(sourceProfile.Buttons[buttonIndex]);
  end else
    inherited Assign(Source);
end;


procedure TProfile.Load(AReader: IX2PersistReader);
var
  buttonIndex: Integer;
  button: TProfileButton;

begin
  buttonIndex := 0;

//  if not AReader.ReadBoolean(KeyIsTemporary, FIsTemporary) then
//    FIsTemporary := False;

  while AReader.BeginSection(SectionButton + IntToStr(buttonIndex)) do
  try
    button := TProfileButton.Create;
    if button.Load(AReader) then
    begin
      FButtons.Add(button);
    end else
    begin
      FButtons.Add(nil);
      FreeAndNil(button);
    end;
  finally
    AReader.EndSection;
    Inc(buttonIndex);
  end;
end;


procedure TProfile.Save(AWriter: IX2PersistWriter);
var
  buttonIndex: Integer;

begin
//  AWriter.WriteBoolean(KeyIsTemporary, IsTemporary);

  for buttonIndex := 0 to Pred(FButtons.Count) do
  begin
    if AWriter.BeginSection(SectionButton + IntToStr(buttonIndex)) then
    try
      if Assigned(FButtons[buttonIndex]) then
        FButtons[buttonIndex].Save(AWriter);
    finally
      AWriter.EndSection;
    end;
  end;
end;


function TProfile.HasButton(AIndex: Integer): Boolean;
begin
  Result := (FButtons.Count > AIndex) and
            Assigned(FButtons[AIndex]);
end;


function TProfile.GetButtonCount: Integer;
begin
  Result := FButtons.Count;
end;


function TProfile.GetButton(Index: Integer): TProfileButton;
var
  oldCount: Integer;
  buttonIndex: Integer;

begin
  oldCount := FButtons.Count;
  if Index >= oldCount then
  begin
    FButtons.Count := Succ(Index);

    for buttonIndex := oldCount to Pred(FButtons.Count) do
      FButtons[buttonIndex] := nil;
  end;

  Result := FButtons[Index];
  if not Assigned(Result) then
  begin
    Result := TProfileButton.Create;
    FButtons[Index] := Result;
  end;
end;


{ TProfileList }
{
function TProfileList.Find(const AName: string): TProfile;
var
  profile: TProfile;

begin
  Result := nil;

  for profile in Self do
    if SameText(profile.Name, AName) then
    begin
      Result := profile;
      break;
    end;
end;
}


procedure TProfileList.Load(AReader: IX2PersistReader);
var
  profiles: TStringList;
  profileName: string;
  profile: TProfile;

begin
  if AReader.BeginSection(SectionProfiles) then
  try
    profiles := TStringList.Create;
    try
      AReader.GetSections(profiles);

      for profileName in profiles do
      begin
        if AReader.BeginSection(profileName) then
        try
          profile := TProfile.Create;
          profile.Name := profileName;
          profile.Load(AReader);

          Add(profile);
        finally
          AReader.EndSection;
        end;
      end;
    finally
      FreeAndNil(profiles);
    end;
  finally
    AReader.EndSection;
  end;
end;


procedure TProfileList.Save(AWriter: IX2PersistWriter);
var
  profile: TProfile;

begin
  if AWriter.BeginSection(SectionProfiles) then
  try
    for profile in Self do
    begin
      if AWriter.BeginSection(profile.Name) then
      try
        profile.Save(AWriter);
      finally
        AWriter.EndSection;
      end;
    end;
  finally
    AWriter.EndSection;
  end;
end;

end.
