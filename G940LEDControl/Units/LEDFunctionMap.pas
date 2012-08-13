unit LEDFunctionMap;

interface
uses
  Classes,
  SyncObjs,

  X2UtHashes;

  
type
  TLEDState = (lsOff, lsGreen, lsAmber, lsRed, lsWarning, lsError);
  TLEDStateSet = set of TLEDState;


  TLEDFunctionMap = class(TObject)
  private
    FFunctions: TX2IIHash;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure SetFunction(ALEDIndex, AFunction: Integer);
    function GetFunction(ALEDIndex: Integer): Integer;

    function HasFunction(AFunction: Integer): Boolean;

    function FindFirst(AFunction: Integer; out ALEDIndex: Integer): Boolean;
    function FindNext(AFunction: Integer; out ALEDIndex: Integer): Boolean;
  end;


  TLEDStateMap = class(TObject)
  private
    FStates: TX2IIHash;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    function GetState(ALEDIndex: Integer; ADefault: TLEDState = lsGreen): TLEDState;
    function SetState(ALEDIndex: Integer; AState: TLEDState): Boolean;

    function HasStates(AStates: TLEDStateSet): Boolean;
    function FindFirst(AStates: TLEDStateSet; out ALEDIndex: Integer; out AState: TLEDState): Boolean;
    function FindNext(AStates: TLEDStateSet; out ALEDIndex: Integer; out AState: TLEDState): Boolean;
  end;


const
  FUNCTION_NONE = 0;
  FUNCTION_OFF = 1;
  FUNCTION_RED = 2;
  FUNCTION_AMBER = 3;
  FUNCTION_GREEN = 4;

  { Note: if this offset ever changes, make sure to write a conversion for
    existing configurations. And probably reserve a bit more. }
  FUNCTION_PROVIDER_OFFSET = FUNCTION_GREEN;


implementation
uses
  SysUtils;
  

{ TLEDFunctionMap }
constructor TLEDFunctionMap.Create;
begin
  inherited;

  FFunctions := TX2IIHash.Create;
end;


destructor TLEDFunctionMap.Destroy;
begin
  FreeAndNil(FFunctions);

  inherited;
end;


procedure TLEDFunctionMap.Clear;
begin
  FFunctions.Clear;
end;


procedure TLEDFunctionMap.SetFunction(ALEDIndex, AFunction: Integer);
begin
  FFunctions[ALEDIndex] := AFunction;
end;


function TLEDFunctionMap.GetFunction(ALEDIndex: Integer): Integer;
begin
  Result := FFunctions[ALEDIndex];
end;


function TLEDFunctionMap.HasFunction(AFunction: Integer): Boolean;
var
  ledIndex: Integer;

begin
  Result := FindFirst(AFunction, ledIndex);
end;


function TLEDFunctionMap.FindFirst(AFunction: Integer; out ALEDIndex: Integer): Boolean;
begin
  FFunctions.First;
  Result := FindNext(AFunction, ALEDIndex);
end;


function TLEDFunctionMap.FindNext(AFunction: Integer; out ALEDIndex: Integer): Boolean;
begin
  Result := False;

  while FFunctions.Next do
  begin
    if FFunctions.CurrentValue = AFunction then
    begin
      ALEDIndex := FFunctions.CurrentKey;
      Result := True;
      break;
    end;
  end;
end;


{ TLEDStateMap }
constructor TLEDStateMap.Create;
begin
  inherited;

  FStates := TX2IIHash.Create;
end;


destructor TLEDStateMap.Destroy;
begin
  FreeAndNil(FStates);

  inherited;
end;


procedure TLEDStateMap.Clear;
begin
  FStates.Clear;
end;


function TLEDStateMap.GetState(ALEDIndex: Integer; ADefault: TLEDState): TLEDState;
begin
  Result := ADefault;
  if FStates.Exists(ALEDIndex) then
    Result := TLEDState(FStates[ALEDIndex]);
end;


function TLEDStateMap.SetState(ALEDIndex: Integer; AState: TLEDState): Boolean;
begin
  if FStates.Exists(ALEDIndex) then
    Result := (FStates[ALEDIndex] <> Ord(AState))
  else
    Result := True;

  if Result then
    FStates[ALEDIndex] := Ord(AState);
end;


function TLEDStateMap.HasStates(AStates: TLEDStateSet): Boolean;
var
  ledIndex: Integer;
  state: TLEDState;

begin
  Result := FindFirst(AStates, ledIndex, state);
end;



function TLEDStateMap.FindFirst(AStates: TLEDStateSet; out ALEDIndex: Integer; out AState: TLEDState): Boolean;
begin
  FStates.First;
  Result := FindNext(AStates, ALEDIndex, AState);
end;


function TLEDStateMap.FindNext(AStates: TLEDStateSet; out ALEDIndex: Integer; out AState: TLEDState): Boolean;
begin
  Result := False;

  while FStates.Next do
    if TLEDState(FStates.CurrentValue) in AStates then
    begin
      ALEDIndex := FStates.CurrentKey;
      AState := TLEDState(FStates.CurrentValue);
      Result := True;
      break;
    end;
end;

end.
