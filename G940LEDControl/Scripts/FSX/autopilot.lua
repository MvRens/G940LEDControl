local strings = require './lib/strings'

-- Autopilot master
-- Autopilot altitude
-- Autopilot approach
-- Autopilot backcourse
-- Autopilot heading
-- Autopilot nav


-- Autopilot airspeed
RegisterFunction(
  {
    uid = 'autoPilotAirspeed',
    category = strings.Category.FSX.AutoPilot,
    displayName = 'Autopilot airspeed',
    states = {
      notAvailable = { displayName = 'Not available', default = LEDColor.Off, order = 1 },
      on = { displayName = 'On', default = LEDColor.Green, order = 2 },
      off = { displayName = 'Off', default =  LEDColor.Red, order = 3 }
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
