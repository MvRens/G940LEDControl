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


  IFunctionConsumer = interface
    ['{97B47A29-BA7F-4C48-934D-EB66D2741647}']
    procedure SetCategory(const ACategory: string);
    procedure AddFunction(AFunction: Integer; const ADescription: string);
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
    class procedure EnumFunctions(AConsumer: IFunctionConsumer); virtual;

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
const
  CATEGORY_STATIC = 'Static';

  FUNCTION_DESC_OFF = 'Light off';
  FUNCTION_DESC_GREEN = 'Green';
  FUNCTION_DESC_AMBER = 'Amber';
  FUNCTION_DESC_RED = 'Red';


{ TCustomLEDStateProvider }
class procedure TLEDStateProvider.EnumFunctions(AConsumer: IFunctionConsumer);
begin
  AConsumer.SetCategory(CATEGORY_STATIC);
  AConsumer.AddFunction(FUNCTION_OFF, FUNCTION_DESC_OFF);
  AConsumer.AddFunction(FUNCTION_GREEN, FUNCTION_DESC_GREEN);
  AConsumer.AddFunction(FUNCTION_AMBER, FUNCTION_DESC_AMBER);
  AConsumer.AddFunction(FUNCTION_RED, FUNCTION_DESC_RED);
end;


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
