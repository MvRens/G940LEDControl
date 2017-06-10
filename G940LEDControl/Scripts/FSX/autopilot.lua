local strings = require './lib/strings'


local function RegisterAutopilotFunction(functionUid, functionDisplayName, variableName)
  RegisterFunction(
    {
      uid = functionUid,
      category = strings.Category.FSX.AutoPilot,
      displayName = functionDisplayName,
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
          autoPilotState = { variable = variableName, type = SimConnectDataType.Bool }
        },
        function(context, data)
          if data.autoPilotAvailable then
            if data.autoPilotState then
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
end

RegisterAutopilotFunction('autoPilotMaster', 'Autopilot master', 'AUTOPILOT MASTER')
RegisterAutopilotFunction('autoPilotHeading', 'Autopilot heading', 'AUTOPILOT HEADING LOCK')
RegisterAutopilotFunction('autoPilotApproach', 'Autopilot approach', 'AUTOPILOT APPROACH HOLD')
RegisterAutopilotFunction('autoPilotBackcourse', 'Autopilot backcourse', 'AUTOPILOT BACKCOURSE HOLD')
RegisterAutopilotFunction('autoPilotAltitude', 'Autopilot heading', 'AUTOPILOT ALTITUDE LOCK')
RegisterAutopilotFunction('autoPilotNav', 'Autopilot nav', 'AUTOPILOT NAV1 LOCK')
RegisterAutopilotFunction('autoPilotAirspeed', 'Autopilot airspeed', 'AUTOPILOT AIRSPEED HOLD')
