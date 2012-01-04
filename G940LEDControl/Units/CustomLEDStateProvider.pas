unit CustomLEDStateProvider;

interface
uses
  Classes,
  SyncObjs,

  OtlComm,
  OtlTaskControl;

const
  MAX_LEDS = 8;
  FUNCTION_NONE = 0;


  MSG_EXECUTE = 10;
  MSG_UPDATEFUNCTIONMAP = 11;
  MSG_SETSTATEBYFUNCTION = 12;

  
type
  TLEDState = (lsOff, lsGreen, lsAmber, lsRed, lsWarning, lsError);


  // todo implement assign
  TLEDFunctionMap = class(TPersistent)
  private
    FFunctions: array[0..MAX_LEDS - 1] of Integer;
    
    function GetCount: Integer;
  public
    procedure Clear;
    
    procedure SetFunction(ALEDIndex, AFunction: Integer);
    function GetFunction(ALEDIndex: Integer): Integer;

    property Count: Integer read GetCount;
  end;


  TCustomLEDStateProvider = class(TOmniWorker)
  private
    FConsumerChannel: IOmniCommunicationEndpoint;
    FFunctionMap: TLEDFunctionMap;
    FFunctionMapLock: TCriticalSection;
    FState: array[0..MAX_LEDS - 1] of TLEDState;
  protected
    procedure MsgExecute(var msg: TOmniMessage); message MSG_EXECUTE;
  protected
    function Initialize: Boolean; override;
    procedure Execute; virtual; abstract;

    procedure SetStateByFunction(AFunction: Integer; AState: TLEDState);

    property ConsumerChannel: IOmniCommunicationEndpoint read FConsumerChannel;
  public
    constructor Create(AConsumerChannel: IOmniCommunicationEndpoint);
    destructor Destroy; override;

    function LockFunctionMap: TLEDFunctionMap;
    procedure UnlockFunctionMap;
  end;

  TCustomLEDStateProviderClass = class of TCustomLEDStateProvider;
  

implementation
uses
  SysUtils;


{ TCustomLEDStateProvider }
constructor TCustomLEDStateProvider.Create(AConsumerChannel: IOmniCommunicationEndpoint);
var
  ledIndex: Integer;

begin
  inherited Create;

  FConsumerChannel := AConsumerChannel;

  FFunctionMap := TLEDFunctionMap.Create;
  FFunctionMapLock := TCriticalSection.Create;

  for ledIndex := Low(FState) to High(FState) do
    FState[ledIndex] := lsGreen;
end;


destructor TCustomLEDStateProvider.Destroy;
begin
  FreeAndNil(FFunctionMap);
  FreeAndNil(FFunctionMapLock);

  inherited;
end;

function TCustomLEDStateProvider.Initialize: Boolean;
begin
  Result := True;
  Task.Comm.OtherEndpoint.Send(MSG_EXECUTE);
end;

function TCustomLEDStateProvider.LockFunctionMap: TLEDFunctionMap;
begin
  FFunctionMapLock.Acquire;
  Result := FFunctionMap;
end;


procedure TCustomLEDStateProvider.UnlockFunctionMap;
begin
  FFunctionMapLock.Release;
  Task.Comm.Send(MSG_UPDATEFUNCTIONMAP, Self);
end;


procedure TCustomLEDStateProvider.SetStateByFunction(AFunction: Integer; AState: TLEDState);
begin
  ConsumerChannel.Send(MSG_SETSTATEBYFUNCTION, [AFunction, Ord(AState)]);
end;


procedure TCustomLEDStateProvider.MsgExecute(var msg: TOmniMessage);
begin
  Execute;
end;


{ TLEDFunctionMap }
procedure TLEDFunctionMap.Clear;
var
  ledPosition: Integer;
  
begin
  for ledPosition := Low(FFunctions) to High(FFunctions) do
    FFunctions[ledPosition] := FUNCTION_NONE;
end;


procedure TLEDFunctionMap.SetFunction(ALEDIndex, AFunction: Integer);
begin
  FFunctions[ALEDIndex] := AFunction;
end;


function TLEDFunctionMap.GetFunction(ALEDIndex: Integer): Integer;
begin
  Result := FFunctions[ALEDIndex];
end;


function TLEDFunctionMap.GetCount: Integer;
begin
  Result := Length(FFunctions);
end;

end.
