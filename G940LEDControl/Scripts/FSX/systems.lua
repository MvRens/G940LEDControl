local basefunctions = require './lib/basefunctions'
local strings = require './lib/strings'


-- Battery master
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Systems,
  uid = 'batteryMaster',
  displayName = 'Battery Master',
  variable = 'ELECTRICAL MASTER BATTERY'
})


-- De-ice
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Systems,
  uid = 'structuralDeIce',
  displayName = "De-ice",
  variable = 'STRUCTURAL DEICE SWITCH'
})


-- Exit door
RegisterFunction(
  {
    uid = 'exitDoor',
    category = strings.Category.FSX.Systems,
    displayName = 'Exit door',
    states = {
      closed = { displayName = 'Closed', default = LEDColor.Green, order = 1 },
      between = { displayName = 'Opening / closing', default =  LEDColor.Amber, order = 2 },
      open = { displayName = 'Open', default = LEDColor.Red, order = 3 }
    }
  },
  function(context)
    SetState(context, 'closed')

    OnSimConnect(context,
      {
        canopyOpen = { variable = 'CANOPY OPEN', type = SimConnectDataType.Float64, units = 'percent' }
      },
      function(context, data)
        if data.canopyOpen >= 0 and data.canopyOpen <= 5 then
          SetState(context, 'closed')
        elseif data.canopyOpen >= 95 and data.canopyOpen <= 100 then
          SetState(context, 'open')
        else
          SetState(context, 'between')
        end
      end)
  end
)


-- Landing gears
local function registerGearFunction(functionUid, functionDisplayName, variableName, isFloat)
  RegisterFunction(
    {
      uid = functionUid,
      category = strings.Category.FSX.Systems,
      displayName = functionDisplayName,
      states = {
        notRetractable = { displayName = 'Not retractable', default = LEDColor.Off, order = 1 },
        retracted = { displayName = 'Retracted', default = LEDColor.Red, order = 2 },
        between = { displayName = 'Extending / retracting', default = LEDColor.Amber, order = 3 },
        extended = { displayName = 'Extended', default = LEDColor.Green, order = 4 },
        speedExceeded = { displayName = 'Speed exceeded', default = LEDColor.FlashingAmberNormal, order = 5 },
        damageBySpeed = { displayName = 'Damage by speed', default = LEDColor.FlashingRedFast, order = 6 }
      }
    },
    function(context)
      SetState(context, 'notRetractable')

      OnSimConnect(context,
        {
          isGearRetractable = { variable = 'IS GEAR RETRACTABLE', type = SimConnectDataType.Bool },
          percentageExtended = { variable = variableName, type = SimConnectDataType.Float64, units = 'percent' },
          damageBySpeed = { variable = 'GEAR DAMAGE BY SPEED', type = SimConnectDataType.Bool },
          speedExceeded = { variable = 'GEAR SPEED EXCEEDED', type = SimConnectDataType.Bool },
        },
        function(context, data)
          if data.damageBySpeed then
            SetState(context, 'damageBySpeed')
          elseif data.speedExceeded then
            SetState(context, 'speedExceeded')
          elseif data.isGearRetractable then
            local extended = data.percentageExtended

            if isFloat then
              extended = extended * 100
            end

            extended = math.floor(extended)
            if extended == 0 then
              SetState(context, 'retracted')
            elseif extended >= 95 and extended <= 100 then
              SetState(context, 'extended')
            else
              SetState(context, 'between')
            end
          else
            SetState(context, 'notRetractable')
          end
        end)
    end
  )
end


registerGearFunction('gear', 'Landing gear', 'GEAR TOTAL PCT EXTENDED', true)
registerGearFunction('leftGear', 'Left main landing gear', 'GEAR LEFT POSITION', false)
registerGearFunction('rightGear', 'Right main landing gear', 'GEAR RIGHT POSITION', false)
registerGearFunction('centerGear', 'Nose landing gear', 'GEAR CENTER POSITION', false)
registerGearFunction('tailGear', 'Tail landing gear', 'GEAR TAIL POSITION', false)


-- Parking brake
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Systems,
  uid = 'parkingBrake',
  displayName = 'Parking brake',
  variable = 'BRAKE PARKING INDICATOR'
})


-- Auto brake
RegisterFunction(
  {
    uid = 'autoBrake',
    category = strings.Category.FSX.Systems,
    displayName = 'Auto brake',
    states = {
      ['0'] = { displayName = 'Off / not available', default = LEDColor.Green, order = 1 },
      ['1'] = { displayName = '1', default = LEDColor.Amber, order = 2 },
      ['2'] = { displayName = '2', default = LEDColor.Amber, order = 3 },
      ['3'] = { displayName = '3', default = LEDColor.Amber, order = 4 },
      ['4'] = { displayName = '4', default = LEDColor.Red, order = 5 }
    }
  },
  function(context)
    SetState(context, '0')

    OnSimConnect(context,
      {
        switch = { variable = 'AUTO BRAKE SWITCH CB', type = SimConnectDataType.Int32, units = 'number' }
      },
      function(context, data)
        local switch = 4

        if data.switch >= 0 and data.switch <= 4 then
          switch = data.switch
        end

        SetState(context, tostring(switch))
      end)
  end
)


-- Pressurization dump switch
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Systems,
  uid = 'pressurizationDumpSwitch',
  displayName = 'Pressurization dump switch',
  variable = 'PRESSURIZATION DUMP SWITCH'
})


-- Tail hook
RegisterFunction(
  {
    uid = 'tailHook',
    category = strings.Category.FSX.Systems,
    displayName = 'Tail hook',
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
        position = { variable = 'TAILHOOK POSITION', type = SimConnectDataType.Float64, units = 'percent' }
      },
      function(context, data)
        if data.position >= 0 and data.position <= 5 then
          SetState(context, 'retracted')
        elseif data.position >= 95 and data.position <= 100 then
          SetState(context, 'extended')
        else
          SetState(context, 'between')
        end
      end)
  end
)


-- Tail wheel lock
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Systems,
  uid = 'tailWheelLock',
  displayName = 'Tail wheel lock',
  variable = 'TAILWHEEL LOCK ON'
})


-- Float (left)
local function RegisterFloatFunction(functionUid, functionDisplayName, variableName)
  RegisterFunction(
    {
      uid = functionUid,
      category = strings.Category.FSX.Systems,
      displayName = functionDisplayName,
      states = {
        retracted = { displayName = 'Retracted', default = LEDColor.Red, order = 1 },
        between = { displayName = 'Extending / retracting', default = LEDColor.Amber, order = 2 },
        extended = { displayName = 'Extended', default = LEDColor.Green, order = 3 }
      }
    },
    function(context)
      SetState(context, 'retracted')

      OnSimConnect(context,
        {
          position = { variable = variableName, type = SimConnectDataType.Float64, units = 'percent' }
        },
        function(context, data)
          if data.position >= 0 and data.position <= 5 then
            SetState(context, 'retracted')
          elseif data.position >= 95 and data.position <= 100 then
            SetState(context, 'extended')
          else
            SetState(context, 'between')
          end
        end)
    end
  )
end

RegisterFloatFunction('floatLeft', 'Float (left)', 'RETRACT LEFT FLOAT EXTENDED')
RegisterFloatFunction('floatRight', 'Float (right)', 'RETRACT RIGHT FLOAT EXTENDED')


-- Fuel level
RegisterFunction(
  {
    uid = 'fuelLevel',
    category = strings.Category.FSX.Systems,
    displayName = 'Fuel level',
    states = {
      ['notAvailable'] = { displayName = 'Not available', default = LEDColor.Off, order = 1 },
      ['empty'] = { displayName = 'Empty', default = LEDColor.FlashingRedFast, order = 2 },
      ['0To1'] = { displayName = '< 1%', default = LEDColor.FlashingRedNormal, order = 3 },
      ['1To2'] = { displayName = '< 2%', default = LEDColor.FlashingRedNormal, order = 4 },
      ['2To5'] = { displayName = '< 5%', default = LEDColor.Red, order = 5 },
      ['5To10'] = { displayName = '< 10%', default = LEDColor.Amber, order = 6 },
      ['10To20'] = { displayName = '< 20%', default = LEDColor.Amber, order = 7 },
      ['20To50'] = { displayName = '< 50%', default = LEDColor.Green, order = 8 },
      ['50To75'] = { displayName = '< 75%', default = LEDColor.Green, order = 9 },
      ['75To100'] = { displayName = '75% - Full', default = LEDColor.Green, order = 10 }
    }
  },
  function(context)
    SetState(context, '75To100')

    OnSimConnect(context,
      {
        capacity = { variable = 'FUEL TOTAL CAPACITY', type = SimConnectDataType.Float64, units = 'number' },
        quantity = { variable = 'FUEL TOTAL QUANTITY', type = SimConnectDataType.Float64, units = 'number' }
      },
      function(context, data)
        if data.capacity > 0 then
          local percentage = math.ceil(data.quantity / data.capacity * 100)

          if percentage == 0 then
            SetState(context, 'empty')
          elseif percentage == 1 then
            SetState(context, '0To1')
          elseif percentage == 2 then
            SetState(context, '1To2')
          elseif percentage >= 3 and percentage <= 5 then
            SetState(context, '2To5')
          elseif percentage >= 6 and percentage <= 10 then
            SetState(context, '5To10')
          elseif percentage >= 11 and percentage <= 20 then
            SetState(context, '10To20')
          elseif percentage >= 21 and percentage <= 50 then
            SetState(context, '20To50')
          elseif percentage >= 51 and percentage <= 75 then
            SetState(context, '50To75')
          else
            SetState(context, '75To100')
          end
        else
          SetState(context, 'notAvailable')
        end
      end)
  end
)