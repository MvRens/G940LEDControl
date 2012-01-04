unit MainFrm;

interface
uses
  Forms, Classes, Controls, StdCtrls, SysUtils,

  DirectInput, ExtCtrls;


type
  TMainForm = class(TForm)
    btn1Red: TButton;
    btn1Green: TButton;
    btnInitialize: TButton;
    cmbDevice: TComboBox;
    btnConnect: TButton;
    btnSimConnect: TButton;
    mmoLog: TMemo;
    btnStartDispatch: TButton;
    btnStopDispatch: TButton;
    tmrDispatch: TTimer;
    
    procedure btnInitializeClick(Sender: TObject);
    procedure btn1RedClick(Sender: TObject);
    procedure btn1GreenClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSimConnectClick(Sender: TObject);
    procedure btnStartDispatchClick(Sender: TObject);
    procedure btnStopDispatchClick(Sender: TObject);
    procedure tmrDispatchTimer(Sender: TObject);
  private
    FDirectInput: IDirectInput8;
    FDevice: IDirectInputDevice8;
    FSimConnect: THandle;

    procedure ClearDevices;
  end;

implementation
uses
  Windows, ComObj,

  LogiJoystickDLL, SimConnect;


type
  TJoystickInfo = class(TObject)
  public
    GUID: TGUID;
  end;


const
  SIMCONNECT_OPEN_CONFIGINDEX_LOCAL = Cardinal(-1);


const
  VENDOR_LOGITECH = $046d;
  PRODUCT_G940_JOYSTICK = $C2A8;
  PRODUCT_G940_THROTTLE = $C2A9;
  PRODUCT_G940_PEDALS = $C2AA;


  DEFINITION_GEAR = 1;
  REQUEST_GEAR = 1;


type
  TGearDefinition = record
    gearPercent: Double;
  end;

  PGearDefinition = ^TGearDefinition;


{$R *.dfm}


function EnumDevicesProc(var lpddi: TDIDeviceInstanceA; pvRef: Pointer): BOOL; stdcall;
var
  info: TJoystickInfo;
  items: TStrings;
  vendorID: Word;
  productID: Word;
  itemIndex: Integer;

begin
  info := TJoystickInfo.Create;
  info.GUID := lpddi.guidInstance;

  items := TComboBox(pvRef).Items;
  itemIndex := items.AddObject(lpddi.tszProductName, info);

  vendorID := LOWORD(lpddi.guidProduct.D1);
  productID := HIWORD(lpddi.guidProduct.D1);

  if (vendorID = VENDOR_LOGITECH) and
     (productID = PRODUCT_G940_THROTTLE) then
    TComboBox(pvRef).ItemIndex := itemIndex;

  Result := True;
end;


{ TMainForm }
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ClearDevices;

  if FSimConnect <> 0 then
    SimConnect_Close(FSimConnect);
end;


procedure TMainForm.btnInitializeClick(Sender: TObject);
begin
  if DirectInput8Create(SysInit.HInstance, DIRECTINPUT_VERSION, IDirectInput8, FDirectInput, nil) <> S_OK then
    raise Exception.Create('Failed to initialize DirectInput');

  ClearDevices;
  if FDirectInput.EnumDevices(DI8DEVCLASS_GAMECTRL, EnumDevicesProc, Pointer(cmbDevice), DIEDFL_ATTACHEDONLY) <> S_OK then
    raise Exception.Create('Failed to enumerate devices');
end;


procedure TMainForm.ClearDevices;
var
  itemIndex: Integer;

begin
  for itemIndex := 0 to Pred(cmbDevice.Items.Count) do
    cmbDevice.Items.Objects[itemIndex].Free;

  cmbDevice.Items.Clear;
end;

procedure TMainForm.btnConnectClick(Sender: TObject);
var
  guid: TGUID;

begin
  guid := TJoystickInfo(cmbDevice.Items.Objects[cmbDevice.ItemIndex]).GUID;

  if FDirectInput.CreateDevice(guid, FDevice, nil) <> S_OK then
    raise Exception.Create('Failed to create device');
end;


procedure TMainForm.btn1RedClick(Sender: TObject);
begin
  SetButtonColor(FDevice, LOGI_P1, LOGI_RED);
end;


procedure TMainForm.btn1GreenClick(Sender: TObject);
begin
  SetButtonColor(FDevice, LOGI_P1, LOGI_GREEN);
end;


procedure TMainForm.btnSimConnectClick(Sender: TObject);
begin
  if not InitSimConnect then
    raise Exception.Create('Failed to initialize SimConnect');

  if FSimConnect <> 0 then
    SimConnect_Close(FSimConnect);

  FSimConnect := 0;
  if SimConnect_Open(FSimConnect, 'G940Test', 0, 0, 0, 0) <> S_OK then
    raise Exception.Create('Failed to open SimConnect');
end;


procedure TMainForm.btnStartDispatchClick(Sender: TObject);
begin
  tmrDispatch.Enabled := True;

  OleCheck(SimConnect_AddToDataDefinition(FSimConnect, DEFINITION_GEAR,
                                          'GEAR TOTAL PCT EXTENDED',
                                          'percent'));
  OleCheck(SimConnect_RequestDataOnSimObject(FSimConnect, REQUEST_GEAR,
                                             DEFINITION_GEAR,
                                             SIMCONNECT_OBJECT_ID_USER,
                                             SIMCONNECT_PERIOD_SIM_FRAME,
                                             SIMCONNECT_DATA_REQUEST_FLAG_CHANGED));
end;


procedure TMainForm.btnStopDispatchClick(Sender: TObject);
begin
  OleCheck(SimConnect_ClearClientDataDefinition(FSimConnect, 1));
  tmrDispatch.Enabled := False;
end;


procedure TMainForm.tmrDispatchTimer(Sender: TObject);
var
  data: PSimConnectRecv;
  dataSize: Cardinal;
  simObjectData: PSimConnectRecvSimObjectData;
  gear: TGearDefinition;

begin
  while SimConnect_GetNextDispatch(FSimConnect, data, dataSize) = S_OK do
  begin
    case SIMCONNECT_RECV_ID(data^.dwID) of
      SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
        begin
          simObjectData := PSimConnectRecvSimObjectData(data);

          if simObjectData^.dwRequestID = REQUEST_GEAR then
          begin
            gear := PGearDefinition(@simObjectData^.dwData)^;
            mmoLog.Lines.Add('Gear: ' + FormatFloat('0.00', gear.gearPercent) + '%');
          end;
        end;
    end;
  end;
end;

end.
