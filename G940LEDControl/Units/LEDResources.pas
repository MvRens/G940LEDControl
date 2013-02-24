unit LEDResources;

interface
uses
  LEDColorIntf;


const
  LEDColorUID: array[TLEDColor] of string =
               (
                 'off',
                 'green',
                 'amber',
                 'red',
                 'green.flashing.fast',
                 'green.flashing',
                 'amber.flashing.fast',
                 'amber.flashing',
                 'red.flashing.fast',
                 'red.flashing'
               );

  LEDColorDisplayName: array[TLEDColor] of string =
                       (
                         'Off',
                         'Green',
                         'Amber',
                         'Red',
                         'Flashing green (fast)',
                         'Flashing green (normal)',
                         'Flashing amber (fast)',
                         'Flashing amber (normal)',
                         'Flashing red (fast)',
                         'Flashing red (normal)'
                       );


  function StringToLEDColor(const AValue: string; out AColor: TLEDColor): Boolean;

implementation


function StringToLEDColor(const AValue: string; out AColor: TLEDColor): Boolean;
var
  color: TLEDColor;

begin
  Result := False;

  for color := Low(TLEDColor) to High(TLEDColor) do
  begin
    if LEDColorUID[color] = AValue then
    begin
      Result := True;
      AColor := color;
      break;
    end;
  end;
end;

end.
