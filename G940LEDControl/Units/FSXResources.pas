unit FSXResources;

interface
const
  FSXSimConnectAppName = 'G940 LED Control';

  FSXProviderUID = 'fsx';
  FSXCategory = 'Flight Simulator X';
  FSXCategorySystems = FSXCategory + ' - Systems';
  FSXCategoryEngines = FSXCategory + ' - Engines';
  FSXCategoryControlSurfaces = FSXCategory + ' - Control surfaces';
  FSXCategoryLights = FSXCategory + ' - Lights';
  FSXCategoryAutoPilot = FSXCategory + ' - Autopilot';
  FSXCategoryRadios = FSXCategory + ' - Radios';
  FSXCategoryATC = FSXCategory + ' - ATC';

  FSXStateUIDOn = 'on';
  FSXStateUIDOff = 'off';
  FSXStateUIDPartial = 'partial';

  FSXStateDisplayNameOn = 'On';
  FSXStateDisplayNameOff = 'Off';
  FSXStateDisplayNamePartial = 'Partial';


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


  FSXFunctionUIDThrottle = 'throttle';
    FSXFunctionDisplayNameThrottle = 'Throttle';

    FSXStateUIDThrottleNoEngines = 'noEngines';
    FSXStateUIDThrottleOff = 'off';
    FSXStateUIDThrottlePartial = 'partial';
    FSXStateUIDThrottleFull = 'full';
    FSXStateUIDThrottleReverse = 'reverse';

    FSXStateDisplayNameThrottleNoThrottles = 'No engines';
    FSXStateDisplayNameThrottleOff = 'Off';
    FSXStateDisplayNameThrottlePartial = 'Partial';
    FSXStateDisplayNameThrottleFull = 'Full';
    FSXStateDisplayNameThrottleReverse = 'Reversed';


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

  FSXFunctionUIDAllLights = 'allLights';
    FSXFunctionDisplayNameAllLights = 'All lights';


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
    FSXStateUIDFlapsSpeedExceeded = 'speedExceeded';
    FSXStateUIDFlapsDamageBySpeed = 'damageBySpeed';

    FSXStateDisplayNameFlapsNotAvailable = 'No flaps';
    FSXStateDisplayNameFlapsRetracted = 'Retracted';
    FSXStateDisplayNameFlapsBetween = 'Extending / retracting';
    FSXStateDisplayNameFlapsExtended = 'Extended';
    FSXStateDisplayNameFlapsSpeedExceeded = 'Speed exceeded';
    FSXStateDisplayNameFlapsDamageBySpeed = 'Damage by speed';


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

    FSXStateUIDEngineAntiIceNoEngines = 'noEngines';
    FSXStateUIDEngineAntiIceAll = 'all';
    FSXStateUIDEngineAntiIcePartial = 'partial';
    FSXStateUIDEngineAntiIceNone = 'none';

    FSXStateDisplayNameEngineAntiIceNoEngines = 'No engines';
    FSXStateDisplayNameEngineAntiIceAll = 'All';
    FSXStateDisplayNameEngineAntiIcePartial = 'Partial';
    FSXStateDisplayNameEngineAntiIceNone = 'None';


  FSXFunctionUIDDeIce = 'structuralDeIce';
    FSXFunctionDisplayNameDeIce = 'De-ice';


  FSXStateUIDAutoPilotNotAvailable = 'notAvailable';
  FSXStateDisplayNameAutoPilotNotAvailable = 'Not available';

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


  FSXFunctionUIDFuel = 'fuelLevel';
    FSXFunctionDisplayNameFuel = 'Fuel Level';

      FSXStateUIDFuelNotAvailable = 'notAvailable';
      FSXStateUIDFuelEmpty = 'empty';
      FSXStateUIDFuel0to1 = '0To1';
      FSXStateUIDFuel1to2 = '1To2';
      FSXStateUIDFuel2to5 = '2To5';
      FSXStateUIDFuel5to10 = '5To10';
      FSXStateUIDFuel10to20 = '10To20';
      FSXStateUIDFuel20to50 = '20To50';
      FSXStateUIDFuel50to75 = '50To75';
      FSXStateUIDFuel75to100 = '75To100';

      FSXStateDisplayNameFuelNotAvailable = 'Not available';
      FSXStateDisplayNameFuelEmpty = 'Empty';
      FSXStateDisplayNameFuel0to1 = '< 1%';
      FSXStateDisplayNameFuel1to2 = '< 2%';
      FSXStateDisplayNameFuel2to5 = '< 5%';
      FSXStateDisplayNameFuel5to10 = '< 10%';
      FSXStateDisplayNameFuel10to20 = '< 20%';
      FSXStateDisplayNameFuel20to50 = '< 50%';
      FSXStateDisplayNameFuel50to75 = '< 75%';
      FSXStateDisplayNameFuel75to100 = '75% - Full';


  FSXFunctionUIDATCVisibility = 'atcVisiblity';
    FSXFunctionDisplayNameATCVisibility = 'ATC Visibility (experimental)';

    FSXStateUIDATCHidden = 'hidden';
    FSXStateUIDATCVisible = 'visible';

    FSXStateDisplayNameATCHidden = 'Hidden';
    FSXStateDisplayNameATCVisible = 'Visible';



  FSXMenuProfiles = 'G940 Profile';
  FSXMenuProfileFormat = 'G940: %s';
  FSXMenuProfileFormatCascaded = '%s';


implementation

end.
