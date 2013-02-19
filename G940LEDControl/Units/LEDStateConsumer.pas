unit LEDStateConsumer;

interface
uses
  System.Classes,

  OtlComm,
  OtlCommon,
  OtlTaskControl,

  LEDColorIntf,
  LEDFunctionIntf,
  Profile;


const
  TM_LOADPROFILE = 1001;
  TM_TICK = 1002;

  TIMER_TICK = 101;

  
type
  IRunInMainThread = interface(IOmniWaitableValue)
    ['{68B8F2F7-ED40-4078-9D99-503D7AFA068B}']
    procedure Execute;
  end;


  TLEDStateConsumer = class(TOmniWorker)
  private
    FButtonWorkers: TInterfaceList;
    FButtonColors: TInterfaceList;
    FHasTickTimer: Boolean;
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    function CreateWorker(AProfileButton: TProfileButton): ILEDFunctionWorker;

    property ButtonWorkers: TInterfaceList read FButtonWorkers;
    property ButtonColors: TInterfaceList read FButtonColors;
    property HasTickTimer: Boolean read FHasTickTimer;
  protected
    procedure Changed; virtual;
    procedure Update; virtual; abstract;
  protected
    procedure TMLoadProfile(var Msg: TOmniMessage); message TM_LOADPROFILE;
    procedure TMTick(var Msg: TOmniMessage); message TM_TICK;
  end;


implementation
uses
  System.SysUtils,
  Winapi.Windows,

  LEDFunctionRegistry,
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


function TLEDStateConsumer.CreateWorker(AProfileButton: TProfileButton): ILEDFunctionWorker;
var
  provider: ILEDFunctionProvider;
  ledFunction: ILEDFunction;

begin
  Result := nil;

  provider := TLEDFunctionRegistry.Find(AProfileButton.ProviderUID);
  if Assigned(provider) then
  begin
    ledFunction := provider.Find(AProfileButton.FunctionUID);
    if Assigned(ledFunction) then
      Result := ledFunction.CreateWorker(TProfileButtonWorkerSettings.Create(AProfileButton));
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
      Task.SetTimer(TIMER_TICK, INTERVAL_TICK, TM_TICK)
    else
      Task.ClearTimer(TIMER_TICK);
  end;

  Update;
end;


procedure TLEDStateConsumer.TMLoadProfile(var Msg: TOmniMessage);
var
  profile: TProfile;
  buttonIndex: Integer;

begin
  profile := Msg.MsgData;
  ButtonWorkers.Clear;

  for buttonIndex := 0 to Pred(profile.ButtonCount) do
  begin
    if profile.HasButton(buttonIndex) then
      ButtonWorkers.Add(CreateWorker(profile.Buttons[buttonIndex]) as ILEDFunctionWorker)
    else
      ButtonWorkers.Add(nil);
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
