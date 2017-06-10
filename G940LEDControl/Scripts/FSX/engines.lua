local strings = require './lib/strings'


-- Carb heat / engine anti-ice
RegisterFunction(
  {
    uid = 'engineAntiIce',
    category = strings.Category.FSX.Engines,
    displayName = 'Carb heat / engine anti-ice',
    states = {
      noEngines = { displayName = 'No engines', default = LEDColor.Off, order = 1 },
      all = { displayName = 'All', default =  LEDColor.Red, order = 2 },
      partial = { displayName = 'Partial', default = LEDColor.Amber, order = 3 },
      none = { displayName = 'None', default = LEDColor.Green, order = 4 }
    }
  },
  function(context)
    SetState(context, 'noEngines')

    OnSimConnect(context,
      {
        engineCount = { variable = 'NUMBER OF ENGINES', type = SimConnectDataType.Int32, units = 'number' },
        engine1 = { variable = 'ENG ANTI ICE:1', type = SimConnectDataType.Bool },
        engine2 = { variable = 'ENG ANTI ICE:2', type = SimConnectDataType.Bool },
        engine3 = { variable = 'ENG ANTI ICE:3', type = SimConnectDataType.Bool },
        engine4 = { variable = 'ENG ANTI ICE:4', type = SimConnectDataType.Bool }
      },
      function(context, data)
        if data.engineCount > 0 then
          local antiIceCount = 0

          if data.engine1 then antiIceCount = antiIceCount + 1 end
          if data.engineCount >= 2 and data.engine2 then antiIceCount = antiIceCount + 1 end
          if data.engineCount >= 3 and data.engine3 then antiIceCount = antiIceCount + 1 end
          if data.engineCount >= 4 and data.engine4 then antiIceCount = antiIceCount + 1 end

          if antiIceCount == 0 then
            SetState(context, 'none')
          elseif antiIceCount == data.engineCount then
            SetState(context, 'all')
          else
            SetState(context, 'partial')
          end
        else
          SetState(context, 'noEngines')
        end
      end)
  end
)


-- Engine
RegisterFunction(
  {
    uid = 'engine',
    category = strings.Category.FSX.Engines,
    displayName = 'Engine',
    states = {
      noEngines = { displayName = 'No engines', default = LEDColor.Off, order = 1 },
      allRunning = { displayName = 'All running', default =  LEDColor.Green, order = 2 },
      partiallyRunning = { displayName = 'Partially running', default = LEDColor.Amber, order = 3 },
      allOff = { displayName = 'All off', default = LEDColor.Red, order = 4 },
      failed = { displayName = 'Engine failure', default = LEDColor.FlashingRedNormal, order = 5 },
      onFire = { displayName = 'On fire', default = LEDColor.FlashingRedFast, order = 6 },
    }
  },
  function(context)
    SetState(context, 'noEngines')

    OnSimConnect(context,
      {
        engineCount = { variable = 'NUMBER OF ENGINES', type = SimConnectDataType.Int32, units = 'number' },
        combustion1 = { variable = 'GENERAL ENG COMBUSTION:1', type = SimConnectDataType.Bool },
        combustion2 = { variable = 'GENERAL ENG COMBUSTION:2', type = SimConnectDataType.Bool },
        combustion3 = { variable = 'GENERAL ENG COMBUSTION:3', type = SimConnectDataType.Bool },
        combustion4 = { variable = 'GENERAL ENG COMBUSTION:4', type = SimConnectDataType.Bool },
        failed1 = { variable = 'ENG FAILED:1', type = SimConnectDataType.Bool },
        failed2 = { variable = 'ENG FAILED:2', type = SimConnectDataType.Bool },
        failed3 = { variable = 'ENG FAILED:3', type = SimConnectDataType.Bool },
        failed4 = { variable = 'ENG FAILED:4', type = SimConnectDataType.Bool },
        onfire1 = { variable = 'ENG ON FIRE:1', type = SimConnectDataType.Bool },
        onfire2 = { variable = 'ENG ON FIRE:2', type = SimConnectDataType.Bool },
        onfire3 = { variable = 'ENG ON FIRE:3', type = SimConnectDataType.Bool },
        onfire4 = { variable = 'ENG ON FIRE:4', type = SimConnectDataType.Bool }
      },
      function(context, data)
        if data.engineCount > 0 then
          local runningCount = 0
          local hasFailed = false
          local hasFire = false

          if data.combustion1 then runningCount = runningCount + 1 end
          if data.failed1 then hasFailed = true end
          if data.onfire1 then hasFire = true end

          if data.engineCount >= 2 and data.combustion2 then runningCount = runningCount + 1 end
          if data.engineCount >= 2 and data.failed2 then hasFailed = true end
          if data.engineCount >= 2 and data.onfire2 then hasFire = true end

          if data.engineCount >= 3 and data.combustion3 then runningCount = runningCount + 1 end
          if data.engineCount >= 3 and data.failed3 then hasFailed = true end
          if data.engineCount >= 3 and data.onfire3 then hasFire = true end

          if data.engineCount >= 4 and data.combustion4 then runningCount = runningCount + 1 end
          if data.engineCount >= 4 and data.failed4 then hasFailed = true end
          if data.engineCount >= 4 and data.onfire4 then hasFire = true end

          if hasFire then
            SetState(context, 'onFire')
          elseif hasFailed then
            SetState(context, 'failed')
          elseif runningCount == 0 then
            SetState(context, 'allOff')
          elseif runningCount == data.engineCount then
            SetState(context, 'partiallyRunning')
          else
            SetState(context, 'allRunning')
          end
        else
          SetState(context, 'noEngines')
        end
      end)
  end
)



-- Throttle
RegisterFunction(
  {
    uid = 'throttle',
    category = strings.Category.FSX.Engines,
    displayName = 'Throttle',
    states = {
      noEngines = { displayName = 'No engines', default = LEDColor.Off, order = 1 },
      off = { displayName = 'Off', default =  LEDColor.Green, order = 2 },
      partial = { displayName = 'Partial', default = LEDColor.Amber, order = 3 },
      full = { displayName = 'Full', default = LEDColor.Red, order = 4 },
      reverse = { displayName = 'Reversed', default = LEDColor.FlashingAmberNormal, order = 5 }
    }
  },
  function(context)
    SetState(context, 'noEngines')

    OnSimConnect(context,
      {
        engineCount = { variable = 'NUMBER OF ENGINES', type = SimConnectDataType.Int32, units = 'number' },
        position1 = { variable = 'GENERAL ENG THROTTLE LEVER POSITION:1', type = SimConnectDataType.Float64, units = 'percent' },
        position2 = { variable = 'GENERAL ENG THROTTLE LEVER POSITION:2', type = SimConnectDataType.Float64, units = 'percent' },
        position3 = { variable = 'GENERAL ENG THROTTLE LEVER POSITION:3', type = SimConnectDataType.Float64, units = 'percent' },
        position4 = { variable = 'GENERAL ENG THROTTLE LEVER POSITION:4', type = SimConnectDataType.Float64, units = 'percent' }
      },
      function(context, data)
        if data.engineCount > 0 then
          local totalPosition = 0
          local reverse = false

          if data.position1 < 0 then reverse = true else totalPosition = totalPosition + data.position1 end
          if data.engineCount >= 2 and data.position2 < 0 then reverse = true else totalPosition = totalPosition + data.position2 end
          if data.engineCount >= 3 and data.position3 < 0 then reverse = true else totalPosition = totalPosition + data.position3 end
          if data.engineCount >= 4 and data.position4 < 0 then reverse = true else totalPosition = totalPosition + data.position4 end

          if reverse then
            SetState(context, 'reverse')
          else
            local position = math.floor(totalPosition / data.engineCount)

            if position >= 0 and position <= 5 then
              SetState(context, 'off')
            elseif position >= 95 and position <= 100 then
              SetState(context, 'full')
            else
              SetState(context, 'partial')
            end
          end
        else
          SetState(context, 'noEngines')
        end
      end)
  end
)