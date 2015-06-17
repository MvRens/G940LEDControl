unit ControlIntf;

interface
type
  IControlHandler = interface
    ['{209A2DC9-D79C-4DC5-B515-AD4D14C44E37}']
    procedure Restart;
  end;


  procedure SetControlHandler(AControlHandler: IControlHandler);
  function GetControlHandler: IControlHandler;


implementation
var
  ControlHandler: IControlHandler;


type
  TNullControlHandler = class(TInterfacedObject, IControlHandler)
  public
    { IControlHandler }
    procedure Restart;
  end;


procedure SetControlHandler(AControlHandler: IControlHandler);
begin
  ControlHandler := AControlHandler;
end;


function GetControlHandler: IControlHandler;
begin
  if Assigned(ControlHandler) then
    Result := ControlHandler
  else
    Result := TNullControlHandler.Create;
end;


{ TNullControlHandler }
procedure TNullControlHandler.Restart;
begin
end;

end.
