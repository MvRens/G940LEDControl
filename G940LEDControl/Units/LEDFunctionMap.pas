unit LEDFunctionMap;

interface
uses
  Classes,
  SyncObjs,

  X2UtHashes;

  
type
  TLEDState = (lsOff, lsGreen, lsAmber, lsRed, lsWarning, lsError);

  TLEDFunctionMap = class(TObject)
  private
    FFunctions: TX2IIHash;
  protected
    function Find(AFunction: Integer; out ALEDIndex: Integer): Boolean;
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
  end;


const
  FUNCTION_NONE = 0;


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
  Result := Find(AFunction, ALEDIndex);
end;


function TLEDFunctionMap.FindNext(AFunction: Integer; out ALEDIndex: Integer): Boolean;
begin
  Result := Find(AFunction, ALEDIndex);
end;



function TLEDFunctionMap.Find(AFunction: Integer; out ALEDIndex: Integer): Boolean;
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

end.
