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
  FSXCategoryInstruments = FSXCategory + ' - Instruments';

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


  FSXFunctionUIDFloatLeft = 'floatLeft';
    FSXFunctionDisplayNameFloatLeft = 'Float (left)';

    FSXStateUIDFloatRetracted = 'retracted';
    FSXStateUIDFloatBetween = 'between';
    FSXStateUIDFloatExtended = 'extended';

    FSXStateDisplayNameFloatRetracted = 'Retracted';
    FSXStateDisplayNameFloatBetween = 'Extending / retracting';
    FSXStateDisplayNameFloatExtended = 'Extended';

  FSXFunctionUIDFloatRight = 'floatRight';
    FSXFunctionDisplayNameFloatRight = 'Float (right)';


  FSXFunctionUIDLeftGear = 'leftGear';
    FSXFunctionDisplayNameLeftGear = 'Left main landing gear';

  FSXFunctionUIDRightGear = 'rightGear';
    FSXFunctionDisplayNameRightGear = 'Right main landing gear';

  FSXFunctionUIDCenterGear = 'centerGear';
    FSXFunctionDisplayNameCenterGear = 'Nose landing gear';

  FSXFunctionUIDTailGear = 'tailGear';
    FSXFunctionDisplayNameTailGear = 'Tail landing gear';


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


  FSXFunctionUIDTailWheelLock = 'tailWheelLock';
    FSXFunctionDisplayNameTailWheelLock = 'Tail wheel lock';

      FSXStateUIDTailWheelUnlocked = FSXStateUIDOff;
      FSXStateUIDTailWheelLocked = FSXStateUIDOn;

      FSXStateDisplayNameTailWheelUnlocked = 'Unlocked';
      FSXStateDisplayNameTailWheelLocked = 'Locked';


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


  FSXFunctionUIDFlapsHandleIndex = 'flapsHandleIndex';
    FSXFunctionDisplayNameFlapsHandleIndex = 'Flaps (handle position)';

    FSXStateUIDFlapsHandleIndexNotAvailable = 'notAvailable';
    FSXStateUIDFlapsHandleIndex0 = '0';
    FSXStateUIDFlapsHandleIndex1 = '1';
    FSXStateUIDFlapsHandleIndex2 = '2';
    FSXStateUIDFlapsHandleIndex3 = '3';
    FSXStateUIDFlapsHandleIndex4 = '4';
    FSXStateUIDFlapsHandleIndex5 = '5';
    FSXStateUIDFlapsHandleIndex6 = '6';
    FSXStateUIDFlapsHandleIndex7 = '7';

    FSXStateDisplayNameFlapsHandleIndexNotAvailable = 'notAvailable';
    FSXStateDisplayNameFlapsHandleIndex0 = 'Position 0 (Up)';
    FSXStateDisplayNameFlapsHandleIndex1 = 'Position 1';
    FSXStateDisplayNameFlapsHandleIndex2 = 'Position 2';
    FSXStateDisplayNameFlapsHandleIndex3 = 'Position 3';
    FSXStateDisplayNameFlapsHandleIndex4 = 'Position 4';
    FSXStateDisplayNameFlapsHandleIndex5 = 'Position 5';
    FSXStateDisplayNameFlapsHandleIndex6 = 'Position 6';
    FSXStateDisplayNameFlapsHandleIndex7 = 'Position 7';


  FSXFunctionUIDFlapsHandlePercentage = 'flapsHandlePercentage';
    FSXFunctionDisplayNameFlapsHandlePercentage = 'Flaps (handle position - percentage)';

    FSXStateUIDFlapsHandlePercentageNotAvailable = 'notAvailable';
    FSXStateUIDFlapsHandlePercentage0To10 = '0To10';
    FSXStateUIDFlapsHandlePercentage10To20 = '10To20';
    FSXStateUIDFlapsHandlePercentage20To30 = '20To30';
    FSXStateUIDFlapsHandlePercentage30To40 = '30To40';
    FSXStateUIDFlapsHandlePercentage40To50 = '40To50';
    FSXStateUIDFlapsHandlePercentage50To60 = '50To60';
    FSXStateUIDFlapsHandlePercentage60To70 = '60To70';
    FSXStateUIDFlapsHandlePercentage70To80 = '70To80';
    FSXStateUIDFlapsHandlePercentage80To90 = '80To90';
    FSXStateUIDFlapsHandlePercentage90To100 = '90To100';

    FSXStateDisplayNameFlapsHandlePercentageNotAvailable = 'No flaps';
    FSXStateDisplayNameFlapsHandlePercentage0To10 = '0% - 10%';
    FSXStateDisplayNameFlapsHandlePercentage10To20 = '10% - 20%';
    FSXStateDisplayNameFlapsHandlePercentage20To30 = '20% - 30%';
    FSXStateDisplayNameFlapsHandlePercentage30To40 = '30% - 40%';
    FSXStateDisplayNameFlapsHandlePercentage40To50 = '40% - 50%';
    FSXStateDisplayNameFlapsHandlePercentage50To60 = '50% - 60%';
    FSXStateDisplayNameFlapsHandlePercentage60To70 = '60% - 70%';
    FSXStateDisplayNameFlapsHandlePercentage70To80 = '70% - 80%';
    FSXStateDisplayNameFlapsHandlePercentage80To90 = '80% - 90%';
    FSXStateDisplayNameFlapsHandlePercentage90To100 = '90% - 100%';


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


  FSXFunctionUIDWaterRudder = 'waterRudder';
    FSXFunctionDisplayNameWaterRudder = 'Water rudder';

    FSXStateUIDWaterRudderRetracted = 'retracted';
    FSXStateUIDWaterRudderBetween = 'between';
    FSXStateUIDWaterRudderExtended = 'extended';

    FSXStateDisplayNameWaterRudderRetracted = 'Retracted';
    FSXStateDisplayNameWaterRudderBetween = 'Extending / retracting';
    FSXStateDisplayNameWaterRudderExtended = 'Extended';


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


  FSXFunctionUIDPitotOnOff = 'pitotOnOff';
    FSXFunctionDisplayNamePitotOnOff = 'Pitot heat (on / off only)';


  FSXFunctionUIDPitotWarning = 'pitotWarning';
    FSXFunctionDisplayNamePitotWarning = 'Pitot heat (including warnings)';

      FSXStateUIDPitotOffIceNone = 'off0';
      FSXStateUIDPitotOffIce25to50 = 'off25To50';
      FSXStateUIDPitotOffIce50to75 = 'off50To75';
      FSXStateUIDPitotOffIce75to100 = 'off75To100';
      FSXStateUIDPitotOffIceFull = 'off100';
      FSXStateUIDPitotOnIceNone = 'on0';
      FSXStateUIDPitotOnIce25to50 = 'on25To50';
      FSXStateUIDPitotOnIce50to75 = 'on50To75';
      FSXStateUIDPitotOnIce75to100 = 'on75To100';
      FSXStateUIDPitotOnIceFull = 'on100';

      FSXStateDisplayNamePitotOffIceNone = 'Heat off - No ice';
      FSXStateDisplayNamePitotOffIce25to50 = 'Heat off - > 25% iced';
      FSXStateDisplayNamePitotOffIce50to75 = 'Heat off - > 50% iced';
      FSXStateDisplayNamePitotOffIce75to100 = 'Heat off - > 75% iced';
      FSXStateDisplayNamePitotOffIceFull = 'Heat off - Fully iced';
      FSXStateDisplayNamePitotOnIceNone = 'Heat on - No ice';
      FSXStateDisplayNamePitotOnIce25to50 = 'Heat on - > 25% iced';
      FSXStateDisplayNamePitotOnIce50to75 = 'Heat on - > 50% iced';
      FSXStateDisplayNamePitotOnIce75to100 = 'Heat on - > 75% iced';
      FSXStateDisplayNamePitotOnIceFull = 'Heat on - Fully iced';


  FSXFunctionUIDAutoBrake = 'autoBrake';
    FSXFunctionDisplayNameAutoBrake = 'Auto brake';

    FSXStateUIDAutoBrake0 = '0';
    FSXStateUIDAutoBrake1 = '1';
    FSXStateUIDAutoBrake2 = '2';
    FSXStateUIDAutoBrake3 = '3';
    FSXStateUIDAutoBrake4 = '4';

    FSXStateDisplayNameAutoBrake0 = 'Off / not available';
    FSXStateDisplayNameAutoBrake1 = '1';
    FSXStateDisplayNameAutoBrake2 = '2';
    FSXStateDisplayNameAutoBrake3 = '3';
    FSXStateDisplayNameAutoBrake4 = '4';


  FSXFunctionUIDSpoilersArmed = 'spoilersArmed';
    FSXFunctionDisplayNameSpoilersArmed = 'Auto-spoilers armed';


  FSXMenuProfiles = 'G940 Profile';
  FSXMenuProfileFormat = 'G940: %s';
  FSXMenuProfileFormatCascaded = '%s';

  FSXMenuRestart = 'Restart G940LEDControl';


implementation

end.
