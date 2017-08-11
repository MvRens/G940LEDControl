local basefunctions = require './lib/basefunctions'
local strings = require './lib/strings'


-- Avionics master
basefunctions.RegisterOnOffFunction({
  category = strings.Category.FSX.Radios,
  uid = 'avionicsMaster',
  displayName = 'Avionics master',
  variable = 'AVIONICS MASTER SWITCH'
})
