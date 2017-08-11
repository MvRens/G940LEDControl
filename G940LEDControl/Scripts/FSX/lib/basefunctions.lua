local basefunctions = {}

-- Required keys for info:
--   uid
--   category
--   displayName
--   variable (SimConnect boolean-compatible variable name)
--
-- Optional keys:
--   inverted (Off is Green instead of Red)
basefunctions.RegisterOnOffFunction = function(info)
  if info.inverted then
      onOffStates = {
        on = { displayName = 'On', default = LEDColor.Green, order = 1 },
        off = { displayName = 'Off', default =  LEDColor.Red, order = 2 }
      }
  else
      onOffStates = {
        on = { displayName = 'On', default = LEDColor.Red, order = 1 },
        off = { displayName = 'Off', default =  LEDColor.Green, order = 2 }
      }
  end

  RegisterFunction(
    {
      uid = info.uid,
      category = info.category,
      displayName = info.displayName,
      states = onOffStates
    },
    function(context)
      SetState(context, 'on')

      OnSimConnect(context,
        {
          value = { variable = info.variable, type = SimConnectDataType.Bool }
        },
        function(context, data)
          if data.value then
            SetState(context, 'on')
          else
            SetState(context, 'off')
          end
        end)
    end
  )
end

return basefunctions