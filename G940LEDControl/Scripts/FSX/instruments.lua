local basefunctions = require './lib/basefunctions'
local strings = require './lib/strings'


-- Pitot heat (on / off only)
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Instruments,
  uid = 'pitotOnOff',
  displayName = 'Pitot heat (on / off only)',
  variable = 'PITOT HEAT'
})


-- Pitot heat (including warnings)
RegisterFunction(
  {
    uid = 'pitotWarning',
    category = strings.Category.FSX.Instruments,
    displayName = 'Pitot heat (including warnings)',
    states = {
      ['off0'] = { displayName = 'Heat off - No ice', default = LEDColor.Red, order = 1 },
      ['off25To50'] = { displayName = 'Heat off - > 25% iced', default = LEDColor.FlashingAmberNormal, order = 2 },
      ['off50To75'] = { displayName = 'Heat off - > 50% iced', default = LEDColor.FlashingAmberFast, order = 3 },
      ['off75To100'] = { displayName = 'Heat off - > 75% iced', default = LEDColor.FlashingAmberFast, order = 4 },
      ['off100'] = { displayName = 'Heat off - Fully iced', default = LEDColor.FlashingRedFast, order = 5 },
      ['on0'] = { displayName = 'Heat on - No ice', default = LEDColor.FlashingRedNormal, order = 6 },
      ['on25To50'] = { displayName = 'Heat on - > 25% iced', default = LEDColor.Amber, order = 7 },
      ['on50To75'] = { displayName = 'Heat on - > 50% iced', default = LEDColor.Amber, order = 8 },
      ['on75To100'] = { displayName = 'Heat on - > 75% iced', default = LEDColor.Amber, order = 9 },
      ['on100'] = { displayName = 'Heat on - Fully iced', default = LEDColor.Green, order = 10 }
    }
  },
  function(context)
    SetState(context, 'off0')

    OnSimConnect(context,
      {
        heat = { variable = 'PITOT HEAT', type = SimConnectDataType.Bool },
        ice = { variable = 'PITOT ICE PCT', type = SimConnectDataType.Float64, units = 'percent' }
      },
      function(context, data)
        local ice = math.floor(data.ice)
        local prefix = 'off'

        if data.heat then
          prefix = 'on'
        end

        if ice >= 25 and ice <= 49 then
          SetState(context, prefix..'25To50')
        elseif ice >= 50 and ice <= 74 then
          SetState(context, prefix..'50To75')
        elseif ice >= 75 and ice <= 99 then
          SetState(context, prefix..'75To100')
        elseif ice = 100 then
          SetState(context, prefix..'100')
        else
          SetState(context, prefix..'0')
        end
      end)
  end
)











