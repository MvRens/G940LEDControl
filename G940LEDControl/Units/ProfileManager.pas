unit ProfileManager;

interface
uses
  System.Classes,
  System.SyncObjs,

  Profile,
  X2UtPersistIntf;


type
  IProfileObserver = interface
    ['{DF41398E-015B-4BF4-A6EE-D3E8679E16A9}']
    procedure ObserveAdd(AProfile: TProfile);
    procedure ObserveRemove(AProfile: TProfile);
    procedure ObserveActiveChanged(AProfile: TProfile);
  end;


  TProfileManager = class;


  TProfileManagerEnumerator = class(TProfileList.TEnumerator)
  private
    FManager: TProfileManager;
  public
    constructor Create(AManager: TProfileManager);
    destructor Destroy; override;
  end;


  TProfileManager = class(TObject)
  private
    FLock: TCriticalSection;
    FProfiles: TProfileList;
    FObservers: TInterfaceList;
    FActiveProfile: TProfile;

    function GetActiveProfile: TProfile;
    function GetCount: Integer;
    function GetItem(Index: Integer): TProfile;
    procedure SetActiveProfile(const Value: TProfile);
    procedure SetItem(Index: Integer; const Value: TProfile);
  protected
    property Observers: TInterfaceList read FObservers;
    property Profiles: TProfileList read FProfiles;
  public
    class function Instance(): TProfileManager;

    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    class procedure Add(AProfile: TProfile; ASetActive: Boolean = False);
    class function Find(const AName: string): TProfile;
    class function Remove(const AProfile: TProfile): Integer;

    class procedure Load(AReader: IX2PersistReader);
    class procedure Save(AWriter: IX2PersistWriter);

    class procedure Attach(AObserver: IProfileObserver);
    class procedure Detach(AObserver: IProfileObserver);

    function GetEnumerator: TProfileManagerEnumerator;

    property ActiveProfile: TProfile read GetActiveProfile write SetActiveProfile;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TProfile read GetItem write SetItem; default;
  end;




implementation
uses
  System.SysUtils;


var
  ProfileManagerInstance: TProfileManager;


{ TProfileManager }
class function TProfileManager.Instance: TProfileManager;
begin
  if not Assigned(ProfileManagerInstance) then
    ProfileManagerInstance := TProfileManager.Create;

  Result := ProfileManagerInstance;
end;


constructor TProfileManager.Create;
begin
  inherited Create;

  FObservers := TInterfaceList.Create;
  FProfiles := TProfileList.Create(True);
  FLock := TCriticalSection.Create;
end;


destructor TProfileManager.Destroy;
begin
  FreeAndNil(FLock);
  FreeAndNil(FProfiles);
  FreeAndNil(FObservers);

  inherited;
end;


procedure TProfileManager.Lock;
begin

end;


procedure TProfileManager.Unlock;
begin

end;


class procedure TProfileManager.Add(AProfile: TProfile; ASetActive: Boolean);
var
  observer: IInterface;

begin
  Instance.Lock;
  try
    Instance.Profiles.Add(AProfile);
  finally
    Instance.Unlock;
  end;

  for observer in Instance.Observers do
    (observer as IProfileObserver).ObserveAdd(AProfile);

  if ASetActive then
    Instance.SetActiveProfile(AProfile);
end;


class function TProfileManager.Find(const AName: string): TProfile;
begin
  Result := Instance.Profiles.Find(AName);
end;


class function TProfileManager.Remove(const AProfile: TProfile): Integer;
var
  observer: IInterface;

begin
  Instance.Lock;
  try
    Result := Instance.Profiles.Remove(AProfile);
  finally
    Instance.Unlock;
  end;

  for observer in Instance.Observers do
    (observer as IProfileObserver).ObserveRemove(AProfile);
end;


class procedure TProfileManager.Load(AReader: IX2PersistReader);
begin
  Instance.Lock;
  try
    Instance.Profiles.Load(AReader);
  finally
    Instance.Unlock;
  end;
end;


class procedure TProfileManager.Save(AWriter: IX2PersistWriter);
begin
  Instance.Lock;
  try
    Instance.Profiles.Save(AWriter);
  finally
    Instance.Unlock;
  end;
end;


class procedure TProfileManager.Attach(AObserver: IProfileObserver);
begin
  Instance.Observers.Add(AObserver as IProfileObserver);
end;


class procedure TProfileManager.Detach(AObserver: IProfileObserver);
begin
  Instance.Observers.Remove(AObserver as IProfileObserver);
end;


function TProfileManager.GetActiveProfile: TProfile;
begin
  Result := Instance.FActiveProfile;
end;


function TProfileManager.GetCount: Integer;
begin
  Result := Instance.Profiles.Count;
end;


function TProfileManager.GetEnumerator: TProfileManagerEnumerator;
begin
  Result := TProfileManagerEnumerator.Create(Self);
end;


function TProfileManager.GetItem(Index: Integer): TProfile;
begin
  Result := Profiles[Index];
end;


procedure TProfileManager.SetActiveProfile(const Value: TProfile);
var
  observer: IInterface;
begin
  if Value <> FActiveProfile then
  begin
    FActiveProfile := Value;

    for observer in Observers do
      (observer as IProfileObserver).ObserveActiveChanged(Value);
  end;
end;


procedure TProfileManager.SetItem(Index: Integer; const Value: TProfile);
begin
  Profiles[Index] := Value;
end;


{ TProfileManagerEnumerator }
constructor TProfileManagerEnumerator.Create(AManager: TProfileManager);
begin
  inherited Create(AManager.Profiles);

  FManager := AManager;
  FManager.Lock;
end;


destructor TProfileManagerEnumerator.Destroy;
begin
  FManager.Unlock;

  inherited;
end;

initialization
finalization
  FreeAndNil(ProfileManagerInstance);

end.
