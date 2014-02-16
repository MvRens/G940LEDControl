unit ProfileManager;

interface
uses
  System.Classes,

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


  ILockedProfileList = interface
    ['{4F647762-AA70-4315-BB1C-E85E320F4E82}']
    function GetEnumerator: TProfileList.TEnumerator;
  end;



  TProfileManager = class(TObject)
  private
    FObservers: TInterfaceList;
    FProfileList: TProfileList;
    FActiveProfile: TProfile;

    function GetCount: Integer;
    function GetItem(Index: Integer): TProfile;
    procedure SetActiveProfile(const Value: TProfile);
    procedure SetItem(Index: Integer; const Value: TProfile);
  protected
    property Observers: TInterfaceList read FObservers;
    property ProfileList: TProfileList read FProfileList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AProfile: TProfile; ASetActive: Boolean = False);
    function FindByName(const AName: string): TProfile;
    function FindByUID(const AName: string): TProfile;
    function Remove(const AProfile: TProfile): Integer;

    procedure Load(AReader: IX2PersistReader);
    procedure Save(AWriter: IX2PersistWriter);

    procedure Attach(AObserver: IProfileObserver);
    procedure Detach(AObserver: IProfileObserver);

    function LockList: ILockedProfileList;
    procedure UnlockList;

    property ActiveProfile: TProfile read FActiveProfile write SetActiveProfile;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TProfile read GetItem write SetItem; default;
  end;


  { Singleton }
  function Profiles: TProfileManager;



implementation
uses
  System.SysUtils;


var
  ProfileManagerInstance: TProfileManager;



type
  TLockedProfileList = class(TInterfacedObject, ILockedProfileList)
  private
    FList: TProfileList;
  public
    constructor Create(AList: TProfileList);

    function GetEnumerator: TProfileList.TEnumerator;
  end;



function Profiles: TProfileManager;
begin
  if not Assigned(ProfileManagerInstance) then
    ProfileManagerInstance := TProfileManager.Create;

  Result := ProfileManagerInstance;
end;


{ TProfileManager }
constructor TProfileManager.Create;
begin
  inherited Create;

  FObservers := TInterfaceList.Create;
  FProfileList := TProfileList.Create(True);
end;


destructor TProfileManager.Destroy;
begin
  FreeAndNil(FProfileList);
  FreeAndNil(FObservers);

  inherited;
end;


procedure TProfileManager.Add(AProfile: TProfile; ASetActive: Boolean);
var
  observer: IInterface;

begin
  TMonitor.Enter(ProfileList);
  try
    ProfileList.Add(AProfile);
  finally
    TMonitor.Exit(ProfileList);
  end;

  for observer in Observers do
    (observer as IProfileObserver).ObserveAdd(AProfile);

  if ASetActive then
    SetActiveProfile(AProfile);
end;


function TProfileManager.FindByName(const AName: string): TProfile;
begin
//  Result := Instance.ProfileList.Find(AName);
end;


function TProfileManager.FindByUID(const AName: string): TProfile;
begin
  //
end;


function TProfileManager.Remove(const AProfile: TProfile): Integer;
var
  observer: IInterface;

begin
  TMonitor.Enter(ProfileList);
  try
    Result := ProfileList.Remove(AProfile);
  finally
    TMonitor.Exit(ProfileList);
  end;

  for observer in Observers do
    (observer as IProfileObserver).ObserveRemove(AProfile);
end;


procedure TProfileManager.Load(AReader: IX2PersistReader);
begin
  TMonitor.Enter(ProfileList);
  try
    ProfileList.Load(AReader);
  finally
    TMonitor.Exit(ProfileList);
  end;
end;


procedure TProfileManager.Save(AWriter: IX2PersistWriter);
begin
  TMonitor.Enter(ProfileList);
  try
    ProfileList.Save(AWriter);
  finally
    TMonitor.Exit(ProfileList);
  end;
end;


procedure TProfileManager.Attach(AObserver: IProfileObserver);
begin
  Observers.Add(AObserver as IProfileObserver);
end;


procedure TProfileManager.Detach(AObserver: IProfileObserver);
begin
  Observers.Remove(AObserver as IProfileObserver);
end;


function TProfileManager.LockList: ILockedProfileList;
begin
  TMonitor.Enter(ProfileList);
  Result := TLockedProfileList.Create(ProfileList);
end;


procedure TProfileManager.UnlockList;
begin
  TMonitor.Exit(ProfileList);
end;


function TProfileManager.GetCount: Integer;
begin
  Result := ProfileList.Count;
end;


function TProfileManager.GetItem(Index: Integer): TProfile;
begin
  Result := ProfileList[Index];
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
  ProfileList[Index] := Value;
end;


{ TLockedProfileList }
constructor TLockedProfileList.Create(AList: TProfileList);
begin
  inherited Create;

  FList := AList;
end;


function TLockedProfileList.GetEnumerator: TProfileList.TEnumerator;
begin
  Result := FList.GetEnumerator;
end;


initialization
finalization
  FreeAndNil(ProfileManagerInstance);

end.
