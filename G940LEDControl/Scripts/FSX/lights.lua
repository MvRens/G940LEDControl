local strings = require './lib/strings'

-- Lights
local function RegisterLightsFunction(functionUid, functionDisplayName, lightsMask)
  RegisterFunction(
    {
      uid = functionUid,
      category = strings.Category.FSX.Lights,
      displayName = functionDisplayName,
      states = {
        on = { displayName = 'On', default = LEDColor.Green, order = 1 },
        off = { displayName = 'Off', default =  LEDColor.Red, order = 2 }
      }
    },
    function(context)
      SetState(context, 'on')

      OnSimConnect(context,
        {
          states = { variable = 'LIGHT ON STATES', type = SimConnectDataType.Int32, units = 'mask' }
        },
        function(context, data)
          if bit32.band(data.states, lightsMask) ~= 0 then
            SetState(context, 'on')
          else
            SetState(context, 'off')
          end
        end)
    end
)
end


local LightsMaskNav = 0x0001
local LightsMaskBeacon = 0x0002
local LightsMaskLanding = 0x0004
local LightsMaskTaxi = 0x0008
local LightsMaskStrobe = 0x0010
local LightsMaskPanel = 0x0020
local LightsMaskRecognition = 0x0040
local LightsMaskWing = 0x0080
local LightsMaskLogo = 0x0100
local LightsMaskCabin = 0x0200

local LightsMaskAll = bit32.bor(
  LightsMaskNav,
  LightsMaskBeacon,
  LightsMaskLanding,
  LightsMaskTaxi,
  LightsMaskStrobe,
  LightsMaskPanel,
  LightsMaskRecognition,
  LightsMaskWing,
  LightsMaskLogo,
  LightsMaskCabin
)


RegisterLightsFunction('beaconLights', 'Beacon lights', LightsMaskBeacon)
RegisterLightsFunction('instrumentLights', 'Instrument lights', LightsMaskPanel)
RegisterLightsFunction('landingLights', 'Landing lights', LightsMaskLanding)
RegisterLightsFunction('navLights', 'Nav lights', LightsMaskNav)
RegisterLightsFunction('strobeLights', 'Strobe lights', LightsMaskStrobe)
RegisterLightsFunction('taxiLights', 'Taxi lights', LightsMaskTaxi)
RegisterLightsFunction('recognitionLights', 'Recognition lights', LightsMaskRecognition)
RegisterLightsFunction('allLights', 'All lights', LightsMaskAll)
