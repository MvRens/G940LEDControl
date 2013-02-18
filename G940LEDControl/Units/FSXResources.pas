unit FSXResources;

interface
const
  FSXProviderUID = 'fsx';
  FSXCategory = 'Flight Simulator X';
  FSXCategoryLights = FSXCategory + ' - Lights';

  FSXStateUIDOn = 'on';
  FSXStateUIDOff = 'off';

  FSXStateDisplayNameOn = 'On';
  FSXStateDisplayNameOff = 'Off';


  FSXFunctionUIDEngine = 'engine';
    FSXFunctionDisplayNameEngine = 'Engine';

    FSXStateUIDEngineNoEngines = 'noEngines';
    FSXStateUIDEngineAllRunning = 'allRunning';
    FSXStateUIDEnginePartiallyRunning = 'partiallyRunning';
    FSXStateUIDEngineAllOff = 'allOff';
    FSXStateUIDEngineFailed = 'failed';
    FSXStateUIDEngineOnFire = 'onFire';

    FSXStateDisplayNameEngineNoEngines = 'No engines';
    FSXStateDisplayNameEngineAllRunning = 'All running';
    FSXStateDisplayNameEnginePartiallyRunning = 'Partially running';
    FSXStateDisplayNameEngineAllOff = 'All off';
    FSXStateDisplayNameEngineFailed = 'Engine failure';
    FSXStateDisplayNameEngineOnFire = 'On fire';


  FSXFunctionUIDGear = 'gear';
    FSXFunctionDisplayNameGear = 'Landing gear';

    FSXStateUIDGearNotRetractable = 'notRetractable';
    FSXStateUIDGearRetracted = 'retracted';
    FSXStateUIDGearBetween = 'between';
    FSXStateUIDGearExtended = 'extended';
    FSXStateUIDGearSpeedExceeded = 'speedExceeded';
    FSXStateUIDGearDamageBySpeed = 'damageBySpeed';

    FSXStateDisplayNameGearNotRetractable = 'Not retractable';
    FSXStateDisplayNameGearRetracted = 'Retracted';
    FSXStateDisplayNameGearBetween = 'Extending / retracting';
    FSXStateDisplayNameGearExtended = 'Extended';
    FSXStateDisplayNameGearSpeedExceeded = 'Speed exceeded';
    FSXStateDisplayNameGearDamageBySpeed = 'Damage by speed';


  FSXFunctionUIDLandingLights = 'landingLights';
    FSXFunctionDisplayNameLandingLights = 'Landing lights';

  FSXFunctionUIDInstrumentLights = 'instrumentLights';
    FSXFunctionDisplayNameInstrumentLights = 'Instrument lights';

  FSXFunctionUIDBeaconLights = 'beaconLights';
    FSXFunctionDisplayNameBeaconLights = 'Beacon lights';

  FSXFunctionUIDNavLights = 'navLights';
    FSXFunctionDisplayNameNavLights = 'Nav lights';

  FSXFunctionUIDStrobeLights = 'strobeLights';
    FSXFunctionDisplayNameStrobeLights = 'Strobe lights';

  FSXFunctionUIDTaxiLights = 'taxiLights';
    FSXFunctionDisplayNameTaxiLights = 'Taxi lights';

  FSXFunctionUIDRecognitionLights = 'recognitionLights';
    FSXFunctionDisplayNameRecognitionLights = 'Recognition lights';


implementation

end.
