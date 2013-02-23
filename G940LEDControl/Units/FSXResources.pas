unit FSXResources;

interface
const
  FSXSimConnectAppName = 'G940 LED Control';

  FSXProviderUID = 'fsx';
  FSXCategory = 'Flight Simulator X';
  FSXCategoryLights = FSXCategory + ' - Lights';
  FSXCategoryAutoPilot = FSXCategory + ' - Autopilot';

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

  FSXFunctionUIDParkingBrake = 'parkingBrake';
    FSXFunctionDisplayNameParkingBrake = 'Parking brake';

  FSXFunctionUIDExitDoor = 'exitDoor';
    FSXFunctionDisplayNameExitDoor = 'Exit door';

    FSXStateUIDExitDoorClosed = 'closed';
    FSXStateUIDExitDoorBetween = 'between';
    FSXStateUIDExitDoorOpen = 'open';

    FSXStateDisplayNameExitDoorClosed = 'Closed';
    FSXStateDisplayNameExitDoorBetween = 'Opening / closing';
    FSXStateDisplayNameExitDoorOpen = 'Open';

  FSXFunctionUIDTailHook = 'tailHook';
    FSXFunctionDisplayNameTailHook = 'Tail hook';

    FSXStateUIDTailHookRetracted = 'retracted';
    FSXStateUIDTailHookBetween = 'between';
    FSXStateUIDTailHookExtended = 'extended';

    FSXStateDisplayNameTailHookRetracted = 'Retracted';
    FSXStateDisplayNameTailHookBetween = 'Extending / retracting';
    FSXStateDisplayNameTailHookExtended = 'Extended';


  FSXFunctionUIDFlaps = 'flaps';
    FSXFunctionDisplayNameFlaps = 'Flaps';

    FSXStateUIDFlapsNotAvailable = 'notAvailable';
    FSXStateUIDFlapsRetracted = 'retracted';
    FSXStateUIDFlapsBetween = 'between';
    FSXStateUIDFlapsExtended = 'extended';

    FSXStateDisplayNameFlapsNotAvailable = 'No flaps';
    FSXStateDisplayNameFlapsRetracted = 'Retracted';
    FSXStateDisplayNameFlapsBetween = 'Extending / retracting';
    FSXStateDisplayNameFlapsExtended = 'Extended';


  FSXFunctionUIDSpoilers = 'spoilers';
    FSXFunctionDisplayNameSpoilers = 'Spoilers';

    FSXStateUIDSpoilersNotAvailable = 'notAvailable';
    FSXStateUIDSpoilersRetracted = 'retracted';
    FSXStateUIDSpoilersBetween = 'between';
    FSXStateUIDSpoilersExtended = 'extended';

    FSXStateDisplayNameSpoilersNotAvailable = 'No spoilers';
    FSXStateDisplayNameSpoilersRetracted = 'Retracted';
    FSXStateDisplayNameSpoilersBetween = 'Extending / retracting';
    FSXStateDisplayNameSpoilersExtended = 'Extended';


  FSXFunctionUIDBatteryMaster = 'batteryMaster';
    FSXFunctionDisplayNameBatteryMaster = 'Battery master';

  FSXFunctionUIDAvionicsMaster = 'avionicsMaster';
    FSXFunctionDisplayNameAvionicsMaster = 'Avionics master';

  FSXFunctionUIDPressDumpSwitch = 'pressurizationDumpSwitch';
    FSXFunctionDisplayNamePressDumpSwitch = 'Pressurization dump switch';

  FSXFunctionUIDEngineAntiIce = 'engineAntiIce';
    FSXFunctionDisplayNameEngineAntiIce = 'Engine anti-ice';

  FSXFunctionUIDFuelPump = 'fuelPump';
    FSXFunctionDisplayNameFuelPump = 'Fuel pump';

  FSXFunctionUIDDeIce = 'structuralDeIce';
    FSXFunctionDisplayNameDeIce = 'De-ice';

  FSXFunctionUIDAutoPilot = 'autoPilotMaster';
    FSXFunctionDisplayNameAutoPilot = 'Autopilot master';

  FSXFunctionUIDAutoPilotHeading = 'autoPilotHeading';
    FSXFunctionDisplayNameAutoPilotHeading = 'Autopilot heading';

  FSXFunctionUIDAutoPilotApproach = 'autoPilotApproach';
    FSXFunctionDisplayNameAutoPilotApproach = 'Autopilot approach';

  FSXFunctionUIDAutoPilotBackcourse = 'autoPilotBackcourse';
    FSXFunctionDisplayNameAutoPilotBackcourse = 'Autopilot backcourse';

  FSXFunctionUIDAutoPilotAltitude = 'autoPilotAltitude';
    FSXFunctionDisplayNameAutoPilotAltitude = 'Autopilot altitude';

  FSXFunctionUIDAutoPilotNav = 'autoPilotNav';
    FSXFunctionDisplayNameAutoPilotNav = 'Autopilot nav';




implementation

end.
