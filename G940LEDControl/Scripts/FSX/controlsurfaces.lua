local strings = require './lib/strings'


-- Flaps
RegisterFunction(
  {
    uid = 'flaps',
    category = strings.Category.FSX.ControlSurfaces,
    displayName = 'Flaps',
    states = {
      notAvailable = { displayName = 'No flaps', default = LEDColor.Off, order = 1 },
      retracted = { displayName = 'Retracted', default = LEDColor.Green, order = 2 },
      between = { displayName = 'Extending / retracting', default = LEDColor.Amber, order = 3 },
      extended = { displayName = 'Extended', default = LEDColor.Red, order = 4 },
      speedExceeded = { displayName = 'Speed exceeded', default = LEDColor.FlashingAmberNormal, order = 5 },
      damageBySpeed = { displayName = 'Damage by speed', default = LEDColor.FlashingRedFast, order = 6 }
    }
  },
  function(context)
    SetState(context, 'notAvailable')

    OnSimConnect(context,
      {
        flapsAvailable = { variable = 'FLAPS AVAILABLE', type = SimConnectDataType.Bool },
        percentageExtended = { variable = 'FLAPS HANDLE PERCENT', type = SimConnectDataType.Float64, units = 'percent' },
        damageBySpeed = { variable = 'FLAP DAMAGE BY SPEED', type = SimConnectDataType.Bool },
        speedExceeded = { variable = 'FLAP SPEED EXCEEDED', type = SimConnectDataType.Bool },
      },
      function(context, data)
        if data.damageBySpeed then
          SetState(context, 'damageBySpeed')
        elseif data.speedExceeded then
          SetState(context, 'speedExceeded')
        elseif data.flapsAvailable then
          local extended = math.floor(data.percentageExtended)

          if extended >= 0 and extended <= 5 then
            SetState(context, 'retracted')
          elseif extended >= 95 and extended <= 100 then
            SetState(context, 'extended')
          else
            SetState(context, 'between')
          end
        else
          SetState(context, 'notAvailable')
        end
      end)
  end
)

-- Flaps (handle position)
RegisterFunction(
  {
    uid = 'flapsHandleIndex',
    category = strings.Category.FSX.ControlSurfaces,
    displayName = 'Flaps (handle position)',
    states = {
      ['notAvailable'] = { displayName = 'Not available', default = LEDColor.Off, order = 1 },
      ['0'] = { displayName = 'Position 0 (Up)', default = LEDColor.Green, order = 2 },
      ['1'] = { displayName = 'Position 1', default = LEDColor.Amber, order = 3 },
      ['2'] = { displayName = 'Position 2', default = LEDColor.Amber, order = 4 },
      ['3'] = { displayName = 'Position 3', default = LEDColor.Amber, order = 5 },
      ['4'] = { displayName = 'Position 4', default = LEDColor.Amber, order = 6 },
      ['5'] = { displayName = 'Position 5', default = LEDColor.Amber, order = 7 },
      ['6'] = { displayName = 'Position 6', default = LEDColor.Amber, order = 8 },
      ['7'] = { displayName = 'Position 7', default = LEDColor.Amber, order = 9 },
    }
  },
  function(context)
    SetState(context, 'notAvailable')

    OnSimConnect(context,
      {
        flapsAvailable = { variable = 'FLAPS AVAILABLE', type = SimConnectDataType.Bool },
        index = { variable = 'FLAPS HANDLE INDEX', type = SimConnectDataType.Int32, units = 'number' }
      },
      function(context, data)
        if data.flapsAvailable then
          local index = data.index
          if index < 0 then
            index = 0
          end

          if index > 7 then
            index = 7
          end

          SetState(context, tostring(index))
        else
          SetState(context, 'notAvailable')
        end
      end)
  end
)


-- Flaps (handle position - percentage)
RegisterFunction(
  {
    uid = 'flapsHandlePercentage',
    category = strings.Category.FSX.ControlSurfaces,
    displayName = 'Flaps (handle position - percentage)',
    states = {
      ['notAvailable'] = { displayName = 'Not available', default = LEDColor.Off, order = 1 },
      ['0To10'] = { displayName = 'Position 0 (Up)', default = LEDColor.Green, order = 2 },
      ['1'] = { displayName = 'Position 1', default = LEDColor.Amber, order = 3 },
      ['2'] = { displayName = 'Position 2', default = LEDColor.Amber, order = 4 },
      ['3'] = { displayName = 'Position 3', default = LEDColor.Amber, order = 5 },
      ['4'] = { displayName = 'Position 4', default = LEDColor.Amber, order = 6 },
      ['5'] = { displayName = 'Position 5', default = LEDColor.Amber, order = 7 },
      ['6'] = { displayName = 'Position 6', default = LEDColor.Amber, order = 8 },
      ['7'] = { displayName = 'Position 7', default = LEDColor.Amber, order = 9 },
    }
  },
  function(context)
    SetState(context, 'notAvailable')

    OnSimConnect(context,
      {
        flapsAvailable = { variable = 'FLAPS AVAILABLE', type = SimConnectDataType.Bool },
        index = { variable = 'FLAPS HANDLE INDEX', type = SimConnectDataType.Int32, units = 'number' }
      },
      function(context, data)
        if data.flapsAvailable then
          local index = data.index
          if index < 0 then
            index = 0
          end

          if index > 7 then
            index = 7
          end

          SetState(context, tostring(index))
        else
          SetState(context, 'notAvailable')
        end
      end)
  end
)


-- Spoilers
RegisterFunction(
  {
    uid = 'spoilers',
    category = strings.Category.FSX.ControlSurfaces,
    displayName = 'Spoilers',
    states = {
      notAvailable = { displayName = 'No spoilers', default = LEDColor.Off, order = 1 },
      retracted = { displayName = 'Retracted', default = LEDColor.Green, order = 2 },
      between = { displayName = 'Extending / retracting', default = LEDColor.Amber, order = 3 },
      extended = { displayName = 'Extended', default = LEDColor.Red, order = 4 }
    }
  },
  function(context)
    SetState(context, 'notAvailable')

    OnSimConnect(context,
      {
        available = { variable = 'SPOILER AVAILABLE', type = SimConnectDataType.Bool },
        percentageExtended = { variable = 'SPOILERS HANDLE POSITION', type = SimConnectDataType.Float64, units = 'percent' }
      },
      function(context, data)
        if data.available then
          local extended = math.floor(data.percentageExtended)

          if extended >= 0 and extended <= 5 then
            SetState(context, 'retracted')
          elseif extended >= 95 and extended <= 100 then
            SetState(context, 'extended')
          else
            SetState(context, 'between')
          end
        else
          SetState(context, 'notAvailable')
        end
      end)
  end
)


-- Auto-spoilers armed
RegisterFunction(
  {
    uid = 'spoilersArmed',
    category = strings.Category.FSX.ControlSurfaces,
    displayName = 'Auto-spoilers armed',
    states = {
      notAvailable = { displayName = 'No spoilers', default = LEDColor.Off, order = 1 },
      on = { displayName = 'On', default = LEDColor.Red, order = 2 },
      off = { displayName = 'Off', default = LEDColor.Green, order = 3 }
    }
  },
  function(context)
    SetState(context, 'notAvailable')

    OnSimConnect(context,
      {
        available = { variable = 'SPOILER AVAILABLE', type = SimConnectDataType.Bool },
        armed = { variable = 'SPOILERS ARMED', type = SimConnectDataType.Bool }
      },
      function(context, data)
        if data.available then
          if data.armed then
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


-- Water rudder
RegisterFunction(
  {
    uid = 'waterRudder',
    category = strings.Category.FSX.ControlSurfaces,
    displayName = 'Water rudder',
    states = {
      retracted = { displayName = 'Retracted', default = LEDColor.Green, order = 1 },
      between = { displayName = 'Extending / retracting', default = LEDColor.Amber, order = 2 },
      extended = { displayName = 'Extended', default = LEDColor.Red, order = 3 }
    }
  },
  function(context)
    SetState(context, 'retracted')

    OnSimConnect(context,
      {
        position = { variable = 'WATER RUDDER HANDLE POSITION', type = SimConnectDataType.Float64, units = 'percent' }
      },
      function(context, data)
        local position = math.floor(data.position)

        if position >= 0 and position <= 5 then
          SetState(context, 'retracted')
        elseif position >= 95 and position <= 100 then
          SetState(context, 'extended')
        else
          SetState(context, 'between')
        end
      end)
  end
)