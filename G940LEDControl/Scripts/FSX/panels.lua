local strings = require './lib/strings'


RegisterFunction(
  {
    uid = 'atcVisiblity',
    category = strings.Category.FSX.Panels,
    displayName = 'ATC Visibility',
    states = {
      hidden = { displayName = 'Hidden', default = LEDColor.Green },
      visible = { displayName = 'Visible', default =  LEDColor.FlashingAmberNormal },
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
