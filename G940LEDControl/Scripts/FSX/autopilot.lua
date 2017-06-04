local strings = require './lib/strings'


RegisterFunction(
  {
    uid = 'autoPilotAirspeed',
    category = strings.Category.FSX.AutoPilot,
    displayName = 'Autopilot airspeed',
    states = {
      on = { displayName = 'On', default = LEDColor.Green },
      off = { displayName = 'Off', default =  LEDColor.Red },
      notAvailable = { displayName = 'Not available', default = LEDColor.Off }
    }
  },
  function(context)
    SetState(context, 'notAvailable')

    OnSimConnect(context,
      {
        autoPilotAvailable = { variable = 'AUTOPILOT AVAILABLE', type = SimConnectDataType.Bool },
        autoPilotAirspeed = { variable = 'AUTOPILOT AIRSPEED HOLD', type = SimConnectDataType.Bool }
      },
      function(context, data)
        if data.autoPilotAvailable then
          if data.autoPilotAirspeed then
            SetState(context, 'on')
          else
            SetState(context, 'off')
          end
        else
          SetState(context, 'notAvailable')
        end
      end)
  end
)
