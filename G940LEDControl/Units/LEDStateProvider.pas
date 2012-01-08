unit LEDStateProvider;

interface
uses
  Classes,
  SyncObjs,
  SysUtils,

  LEDFunctionMap;

type
  EInitializeError = class(Exception);

  ILEDStateConsumer = interface
    ['{6E630C92-7C5C-4D16-8BED-AE27559FA584}']
    function GetFunctionMap: TLEDFunctionMap;
    procedure SetStateByFunction(AFunction: Integer; AState: TLEDState);

    property FunctionMap: TLEDFunctionMap read GetFunctionMap;
  end;


  TLEDStateProvider = class(TObject)
  private
    FConsumer: ILEDStateConsumer;
    FTerminated: Boolean;
  protected
    procedure Execute; virtual; abstract;

    function GetProcessMessagesInterval: Integer; virtual;

    property Consumer: ILEDStateConsumer read FConsumer;
  public
    constructor Create(AConsumer: ILEDStateConsumer); virtual;
    destructor Destroy; override;

    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure ProcessMessages; virtual;

    procedure Terminate; virtual;

    property ProcessMessagesInterval: Integer read GetProcessMessagesInterval;
    property Terminated: Boolean read FTerminated;
  end;

  TLEDStateProviderClass = class of TLEDStateProvider;


const
  EXIT_SUCCESS = 0;
  EXIT_ERROR = 1;

  EXIT_CONSUMER_OFFSET = 100;
  EXIT_PROVIDER_OFFSET = 200;

implementation


{ TCustomLEDStateProvider }
constructor TLEDStateProvider.Create(AConsumer: ILEDStateConsumer);
begin
  inherited Create;

  FConsumer := AConsumer;
end;


destructor TLEDStateProvider.Destroy;
begin
  inherited;
end;


procedure TLEDStateProvider.Initialize;
begin
end;


procedure TLEDStateProvider.Finalize;
begin
end;


procedure TLEDStateProvider.ProcessMessages;
begin
end;


procedure TLEDStateProvider.Terminate;
begin
  FTerminated := True;
end;


function TLEDStateProvider.GetProcessMessagesInterval: Integer;
begin
  Result := -1;
end;

end.
