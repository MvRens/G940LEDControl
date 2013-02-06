unit ButtonSelectFrm;

interface
uses
  Classes,
  Controls,
  Forms,
  StdCtrls,
  SyncObjs,

  DirectInput,
  OtlComm,
  OtlEventMonitor,
  OtlTaskControl;

type
  TDeviceType = (dtGeneric, dtG940Joystick, dtG940Throttle);

  TButtonSelectForm = class(TForm)
    lblDevice: TLabel;
    cmbDevice: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    lblStatus: TLabel;
    lblButton: TLabel;
    edtButton: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbDeviceChange(Sender: TObject);
  private
    FDirectInput: IDirectInput8;
    FDeviceIndex: Integer;
    FDevice: IDirectInputDevice8;
    FDeviceType: TDeviceType;

    FEventMonitor: TOmniEventMonitor;
    FEventTask: IOmniTaskControl;
    FDeviceEvent: TEvent;

    FButtons: array[0..31] of Boolean;
    FLastButtonIndex: Integer;
    FLastButtonText: string;
    function GetDeviceName: string;
  protected
    procedure AcquireDevice;
    procedure DoAcquireDevice;
    procedure ReleaseDevice;
    procedure CheckDeviceState;
    procedure ButtonPressed(AButtonIndex: Integer);

    procedure SetAcquiredStatus(AAcquired: Boolean; const AMessage: string);

    procedure TaskMessage(const ATask: IOmniTaskControl; const AMessage: TOmniMessage);
    procedure TaskTerminated(const ATask: IOmniTaskControl);

    property DirectInput: IDirectInput8 read FDirectInput;
    property DeviceIndex: Integer read FDeviceIndex;
    property Device: IDirectInputDevice8 read FDevice;
    property DeviceType: TDeviceType read FDeviceType;
    property DeviceName: string read GetDeviceName;
  public
    class function Execute(var ADeviceGUID: TGUID; var AButton: Integer; out ADisplayText: string): Boolean;
  end;


implementation
uses
  Graphics,
  SysUtils,
  Windows,

  LogiJoystickDLL;


type
  TDeviceInfo = class(TObject)
  private
    FInstanceGUID: TGUID;
    FProductGUID: TGUID;
  public
    property InstanceGUID: TGUID read FInstanceGUID write FInstanceGUID;
    property ProductGUID: TGUID read FProductGUID write FProductGUID;
  end;


  TEventTask = class(TOmniWorker)
  private
    FEvent: THandle;
  protected
    function Initialize: Boolean; override;

    procedure EventSignaled;
  public
    constructor Create(AEvent: THandle);
  end;


const
  MSG_EVENT_SIGNALED = 1;


{$R *.dfm}


function EnumDevicesProc(var lpddi: TDIDeviceInstanceW; pvRef: Pointer): BOOL; stdcall;
var
  items: TStrings;
  info: TDeviceInfo;

begin
  items := TStrings(pvRef);

  info := TDeviceInfo.Create;
  info.InstanceGUID := lpddi.guidInstance;
  info.ProductGUID := lpddi.guidProduct;

  items.AddObject(string(lpddi.tszProductName), info);
  Result := True;
end;


{ TButtonSelectForm }
class function TButtonSelectForm.Execute(var ADeviceGUID: TGUID; var AButton: Integer;
                                         out ADisplayText: string): Boolean;
begin
  with Self.Create(Application) do
  try
    Result := (ShowModal = mrOk);

    if Result then
    begin
      AButton := FLastButtonIndex;
      ADisplayText := FLastButtonText;
    end;
  finally
    Free;
  end;
end;


procedure TButtonSelectForm.FormCreate(Sender: TObject);
begin
  FEventMonitor := TOmniEventMonitor.Create(Self);
  FEventMonitor.OnTaskMessage := TaskMessage;
  FEventMonitor.OnTaskTerminated := TaskTerminated;

  FDeviceEvent := TEvent.Create(nil, False, False, '');

  lblStatus.Caption := '';

  FDeviceIndex := -1;
end;


procedure TButtonSelectForm.FormDestroy(Sender: TObject);
var
  itemIndex: Integer;

begin
  ReleaseDevice;

  for itemIndex := Pred(cmbDevice.Items.Count) downto 0 do
    TDeviceInfo(cmbDevice.Items.Objects[itemIndex]).Free;

  FreeAndNil(FDeviceEvent);
end;


procedure TButtonSelectForm.FormShow(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    Self.Show;
    Self.Update;

    if DirectInput8Create(SysInit.HInstance, DIRECTINPUT_VERSION, IDirectInput8, FDirectInput, nil) <> S_OK then
      raise Exception.Create('Failed to initialize DirectInput');

    cmbDevice.Items.BeginUpdate;
    try
      cmbDevice.Items.Clear;
      DirectInput.EnumDevices(DI8DEVCLASS_GAMECTRL,
                              EnumDevicesProc,
                              Pointer(cmbDevice.Items),
                              DIEDFL_ATTACHEDONLY);

      // todo set ItemIndex to previous productGUID

      cmbDevice.ItemIndex := 0;
    finally
      cmbDevice.Items.EndUpdate;
    end;

    if cmbDevice.ItemIndex > -1 then
      AcquireDevice;
  finally
    Screen.Cursor := crDefault;
  end;
end;


procedure TButtonSelectForm.cmbDeviceChange(Sender: TObject);
begin
  AcquireDevice;
end;


procedure TButtonSelectForm.AcquireDevice;
var
  info: TDeviceInfo;
  vendorID: Word;
  productID: Word;

begin
  if cmbDevice.ItemIndex <> DeviceIndex then
  begin
    ReleaseDevice;

    if cmbDevice.ItemIndex > -1 then
    begin
      info := TDeviceInfo(cmbDevice.Items.Objects[cmbDevice.ItemIndex]);

      FDeviceType := dtGeneric;
      vendorID := LOWORD(info.ProductGUID.D1);
      productID := HIWORD(info.ProductGUID.D1);

      if vendorID = VENDOR_LOGITECH then
      begin
        case productID of
          PRODUCT_G940_JOYSTICK:  FDeviceType := dtG940Joystick;
          PRODUCT_G940_THROTTLE:  FDeviceType := dtG940Throttle;
        end;
      end;


      if DirectInput.CreateDevice(info.InstanceGUID, FDevice, nil) = S_OK then
      begin
        Device.SetCooperativeLevel(0, DISCL_NONEXCLUSIVE or DISCL_BACKGROUND);
        Device.SetDataFormat(c_dfDIJoystick);

        DoAcquireDevice;
      end else
      begin
        ReleaseDevice;
        SetAcquiredStatus(False, 'Could not connect to device (CreateDevice failed)');
      end;
    end;
  end;
end;


procedure TButtonSelectForm.DoAcquireDevice;
begin
  FDeviceEvent.ResetEvent;
  Device.SetEventNotification(FDeviceEvent.Handle);

  if Device.Acquire = DI_OK then
  begin
    FDeviceIndex := cmbDevice.ItemIndex;
    SetAcquiredStatus(True, 'Press a button on the joystick to select it');

    FEventTask := FEventMonitor.Monitor(CreateTask(TEventTask.Create(FDeviceEvent.Handle))).Run;
  end else
  begin
    ReleaseDevice;
    SetAcquiredStatus(False, 'Could not connect to device (acquire failed)');
  end;
end;


procedure TButtonSelectForm.ReleaseDevice;
begin
  if Assigned(Device) then
  begin
    Device.SetEventNotification(0);
    FDevice := nil;
  end;

  FDeviceIndex := -1;
  FDeviceType := dtGeneric;

  if Assigned(FEventTask) then
  begin
    FEventTask.Terminate;
    FEventTask := nil;
  end;

  FillChar(FButtons, SizeOf(FButtons), 0);

  edtButton.Text := '';

  FLastButtonIndex := -1;
  FLastButtonText := '';
end;


procedure TButtonSelectForm.CheckDeviceState;
var
  state: DIJOYSTATE;
  status: Integer;
  buttonIndex: Integer;
  down: Boolean;

begin
  FillChar(state, SizeOf(state), 0);
  status := Device.GetDeviceState(SizeOf(state), @state);

  case status of
    DI_OK:
      begin
        for buttonIndex := Low(state.rgbButtons) to High(state.rgbButtons) do
        begin
          down := ((state.rgbButtons[buttonIndex] and $80) <> 0);

          if down and (not FButtons[buttonIndex]) then
            ButtonPressed(buttonIndex);

          FButtons[buttonIndex] := down;
        end;
      end;

    DIERR_INPUTLOST,
    DIERR_NOTACQUIRED:
      DoAcquireDevice;
  end;
end;


procedure TButtonSelectForm.ButtonPressed(AButtonIndex: Integer);
const
  G940_JOYSTICK_BUTTONS: array[0..8] of string =
                         (
                           'Trigger',
                           'Fire',
                           'S1',
                           'S2',
                           'S3',
                           'S4',
                           'S5',
                           'Mini Button',
                           'Trigger Button'
                         );

  G940_THROTTLE_BUTTONS: array[0..11] of string =
                         (
                           'T1',
                           'T2',
                           'T3',
                           'T4',
                           'P1',
                           'P2',
                           'P3',
                           'P4',
                           'P5',
                           'P6',
                           'P7',
                           'P8'
                         );

var
  buttonText: string;

begin
  buttonText := Format('Button #%d', [Succ(AButtonIndex)]);

  case DeviceType of
    dtG940Joystick:
      if AButtonIndex in [Low(G940_JOYSTICK_BUTTONS)..High(G940_JOYSTICK_BUTTONS)] then
        buttonText := G940_JOYSTICK_BUTTONS[AButtonIndex];

    dtG940Throttle:
      if AButtonIndex in [Low(G940_THROTTLE_BUTTONS)..High(G940_THROTTLE_BUTTONS)] then
        buttonText := G940_THROTTLE_BUTTONS[AButtonIndex];
  end;

  edtButton.Text := buttonText;

  FLastButtonIndex := AButtonIndex;
  FLastButtonText := Format('%s on %s', [buttonText, GetDeviceName]);
end;


procedure TButtonSelectForm.SetAcquiredStatus(AAcquired: Boolean; const AMessage: string);
begin
  if AAcquired then
    lblStatus.Font.Color := clGreen
  else
    lblStatus.Font.Color := clMaroon;

  lblStatus.Caption := AMessage;
end;


procedure TButtonSelectForm.TaskMessage(const ATask: IOmniTaskControl; const AMessage: TOmniMessage);
begin
  if AMessage.MsgID = MSG_EVENT_SIGNALED then
    CheckDeviceState;
end;


procedure TButtonSelectForm.TaskTerminated(const ATask: IOmniTaskControl);
begin
  if ATask = FEventTask then
    FEventTask := nil;
end;


function TButtonSelectForm.GetDeviceName: string;
begin
  Result := '';

  if cmbDevice.ItemIndex > -1 then
    Result := cmbDevice.Items[cmbDevice.ItemIndex];
end;


{ TEventTask }
constructor TEventTask.Create(AEvent: THandle);
begin
  inherited Create;

  FEvent := AEvent;
end;


function TEventTask.Initialize: Boolean;
begin
  Result := inherited Initialize;

  Task.RegisterWaitObject(FEvent, EventSignaled);
end;


procedure TEventTask.EventSignaled;
begin
  Task.Comm.Send(MSG_EVENT_SIGNALED);
end;

end.
