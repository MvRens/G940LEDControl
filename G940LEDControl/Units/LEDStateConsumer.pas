unit LEDStateConsumer;

interface
uses
  System.Classes,

  OtlComm,
  OtlCommon,
  OtlTaskControl,
  X2Log.Intf,

  LEDColorIntf,
  LEDFunctionIntf,
  LEDFunctionRegistry,
  Profile;


const
  TM_LOADPROFILE = 1001;
  TM_TICK = 1002;

  TIMER_TICK = 101;

  
type
  TLEDStateConsumer = class(TOmniWorker, ILEDFunctionObserver)
  private
    FButtonWorkers: TInterfaceList;
    FButtonColors: TInterfaceList;
    FHasTickTimer: Boolean;
    FLog: IX2Log;
    FFunctionRegistry: TLEDFunctionRegistry;
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    function CreateWorker(AProfileButton: TProfileButton; const APreviousState: string): ILEDFunctionWorker;

    property ButtonWorkers: TInterfaceList read FButtonWorkers;
    property ButtonColors: TInterfaceList read FButtonColors;
    property HasTickTimer: Boolean read FHasTickTimer;
  protected
    { ILEDFunctionObserver }
    procedure ObserveUpdate(Sender: ILEDFunctionWorker);

    procedure Changed; virtual;
    procedure Update; virtual; abstract;

    property Log: IX2Log read FLog;
    property FunctionRegistry: TLEDFunctionRegistry read FFunctionRegistry;
  protected
    procedure TMLoadProfile(var Msg: TOmniMessage); message TM_LOADPROFILE;
    procedure TMTick(var Msg: TOmniMessage); message TM_TICK;
  public
    constructor Create(ALog: IX2Log; AFunctionRegistry: TLEDFunctionRegistry);
  end;


implementation
uses
  Generics.Collections,
  System.SysUtils,
  Winapi.Windows,

  LEDStateIntf;


const
  INTERVAL_TICK = 500;


type
  TProfileButtonWorkerSettings = class(TInterfacedObject, ILEDFunctionWorkerSettings)
  private
    FProfileButton: TProfileButton;
  protected
    { ILEDFunctionWorkerSettings }
    function GetStateColor(const AUID: string; out AColor: TLEDColor): Boolean;

    property ProfileButton: TProfileButton read FProfileButton;
  public
    constructor Create(AProfileButton: TProfileButton);
  end;


{ TLEDStateConsumer }
constructor TLEDStateConsumer.Create(ALog: IX2Log; AFunctionRegistry: TLEDFunctionRegistry);
begin
  inherited Create;

  FLog := ALog;
  FFunctionRegistry := AFunctionRegistry;
end;


function TLEDStateConsumer.Initialize: Boolean;
begin
  Result := inherited Initialize;
  if not Result then
    exit;

  FButtonWorkers := TInterfaceList.Create;
  FButtonColors := TInterfaceList.Create;
end;


procedure TLEDStateConsumer.Cleanup;
begin
  FreeAndNil(FButtonColors);
  FreeAndNil(FButtonWorkers);

  inherited Cleanup;
end;


function TLEDStateConsumer.CreateWorker(AProfileButton: TProfileButton; const APreviousState: string): ILEDFunctionWorker;
var
  provider: ILEDFunctionProvider;
  ledFunction: ILEDFunction;

begin
  Result := nil;

  provider := FunctionRegistry.Find(AProfileButton.ProviderUID);
  if Assigned(provider) then
  begin
    ledFunction := provider.Find(AProfileButton.FunctionUID);
    if Assigned(ledFunction) then
      Result := ledFunction.CreateWorker(TProfileButtonWorkerSettings.Create(AProfileButton), APreviousState);
  end;
end;


procedure TLEDStateConsumer.Changed;
var
  hasDynamicColors: Boolean;
  buttonIndex: Integer;
  state: ILEDStateWorker;
  color: ILEDStateColor;
  dynamicColor: ILEDStateDynamicColor;

begin
  Log.Info('Updating LED states');

  hasDynamicColors := False;
  ButtonColors.Clear;

  for buttonIndex := 0 to Pred(ButtonWorkers.Count) do
  begin
    color := nil;

    if Assigned(ButtonWorkers[buttonIndex]) then
    begin
      state := (ButtonWorkers[buttonIndex] as ILEDFunctionWorker).GetCurrentState;
      if Assigned(state) then
      begin
        color := state.GetColor;
        if Assigned(color) then
        begin
          if (hasDynamicColors = False) and Supports(color, ILEDStateDynamicColor, dynamicColor) then
          begin
            { If the tick timer isn't currently running, there were no
              dynamic colors before. Reset each dynamic colors now. }
            if not HasTickTimer then
              dynamicColor.Reset;

            hasDynamicColors := True;
          end;

          ButtonColors.Add(color as ILEDStateColor);
        end;
      end;
    end;

    if not Assigned(color) then
      ButtonColors.Add(nil);
  end;

  if hasDynamicColors <> HasTickTimer then
  begin
    if hasDynamicColors then
    begin
      Log.Verbose('Starting tick timer');
      Task.SetTimer(TIMER_TICK, INTERVAL_TICK, TM_TICK)
    end else
    begin
      Log.Verbose('Stopping tick timer');
      Task.ClearTimer(TIMER_TICK);
    end;
  end;

  Update;
end;


procedure TLEDStateConsumer.ObserveUpdate(Sender: ILEDFunctionWorker);
begin
  Changed;
end;


procedure TLEDStateConsumer.TMLoadProfile(var Msg: TOmniMessage);

  function GetFunctionKey(const AProviderUID, AFunctionUID: string): string; inline;
  begin
    Result := AProviderUID + '|' + AFunctionUID;
  end;


var
  oldWorkers: TInterfaceList;
  oldStates: TDictionary<string, string>;
  oldWorker: IInterface;
  profile: TProfile;
  buttonIndex: Integer;
  worker: ILEDFunctionWorker;
  state: ILEDStateWorker;
  previousState: string;
  button: TProfileButton;
  functionKey: string;

begin
  profile := Msg.MsgData;
  if not Assigned(profile) then
    exit;

  Log.Info('Loading profile');

  oldStates := nil;
  oldWorkers := nil;
  try
    oldStates := TDictionary<string, string>.Create;
    oldWorkers := TInterfaceList.Create;

    { Keep a copy of the old workers until all the new ones are initialized,
      so we don't get unneccessary SimConnect reconnects. }
    for oldWorker in ButtonWorkers do
    begin
      if Assigned(oldWorker) then
      begin
        worker := (oldWorker as ILEDFunctionWorker);
        try
          worker.Detach(Self);
          oldWorkers.Add(worker);

          { Keep the current state as well, to prevent the LEDs from flickering }
          state := worker.GetCurrentState;
          try
            oldStates.AddOrSetValue(GetFunctionKey(worker.GetProviderUID, worker.GetFunctionUID), state.GetUID);
          finally
            state := nil;
          end;
        finally
          worker := nil;
        end;
      end;
    end;

    ButtonWorkers.Clear;

    for buttonIndex := 0 to Pred(profile.ButtonCount) do
    begin
      if profile.HasButton(buttonIndex) then
      begin
        button := profile.Buttons[buttonIndex];

        previousState := '';
        functionKey := GetFunctionKey(button.ProviderUID, button.FunctionUID);
        if oldStates.ContainsKey(functionKey) then
          previousState := oldStates[functionKey];

        worker := CreateWorker(button, previousState) as ILEDFunctionWorker;
        ButtonWorkers.Add(worker);

        if Assigned(worker) then
          worker.Attach(Self);
      end else
        ButtonWorkers.Add(nil);
    end;
  finally
    FreeAndNil(oldWorkers);
    FreeAndNil(oldStates);
  end;

  Changed;
end;


procedure TLEDStateConsumer.TMTick(var Msg: TOmniMessage);
var
  buttonIndex: Integer;
  checkButtonIndex: Integer;
  alreadyTicked: Boolean;
  color: ILEDStateColor;
  dynamicColor: ILEDStateDynamicColor;

begin
  Log.Verbose('Tick');

  // (MvR) 19-2-2013: I could pass a tick count to Tick() so that they can all use modulus to blink synchronously... think about it.

  for buttonIndex := 0 to Pred(ButtonColors.Count) do
  begin
    alreadyTicked := False;
    color := (ButtonColors[buttonIndex] as ILEDStateColor);

    if Supports(color, ILEDStateDynamicColor, dynamicColor) then
    begin
      { Check if this color has already been ticked }
      for checkButtonIndex := Pred(buttonIndex) downto 0 do
        if (ButtonColors[checkButtonIndex] as ILEDStateColor) = color  then
        begin
          alreadyTicked := True;
          break;
        end;

      if not alreadyTicked then
        dynamicColor.Tick;
    end;
  end;

  Update;
end;


{ TProfileButtonWorkerSettings }
constructor TProfileButtonWorkerSettings.Create(AProfileButton: TProfileButton);
begin
  inherited Create;

  FProfileButton := AProfileButton;
end;


function TProfileButtonWorkerSettings.GetStateColor(const AUID: string; out AColor: TLEDColor): Boolean;
begin
  Result := ProfileButton.GetStateColor(AUID, AColor);
end;

end.
