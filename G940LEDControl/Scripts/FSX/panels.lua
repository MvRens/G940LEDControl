local strings = require './lib/strings'



-- ATC panel
RegisterFunction(
  {
    uid = 'atcVisiblity',
    category = strings.Category.FSX.Panels,
    displayName = 'ATC panel',
    states = {
      hidden = { displayName = 'Hidden', default = LEDColor.Green, order = 1 },
      visible = { displayName = 'Visible', default =  LEDColor.FlashingAmberNormal, order = 2 },
    }
  },
  function(context)
    SetState(context, 'hidden')

    OnTimer(context, 1000,
      function(context)
        if FSXWindowVisible('ATC Menu') then
          SetState(context, 'visible')
        else
          SetState(context, 'hidden')
        end
      end)
  end
)
