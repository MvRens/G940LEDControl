#ifndef LGWHEELS_H_INCLUDED_
#define LGWHEELS_H_INCLUDED_

#include "LogiControllerForceManager.h"
#include "LogiControllerInput.h"
#include "LogiControllerProperties.h"
#include "LogiLeds.h"
#include <dbt.h>

namespace LogitechSteeringWheel
{
    class Wheel
    {
    public:
        Wheel(LogitechControllerInput::ControllerInput* controllerInput);
        ~Wheel();

        VOID Update();
        DIJOYSTATE2* GetState(CONST INT index);
        LPCTSTR GetFriendlyProductName(CONST INT index);
        BOOL IsConnected(CONST INT index);
        BOOL IsConnected(CONST INT index, CONST LogitechControllerInput::DeviceType deviceType);
        BOOL IsConnected(CONST INT index, CONST LogitechControllerInput::ManufacturerName manufacturerName);
        BOOL IsConnected(CONST INT index, CONST LogitechControllerInput::ModelName modelName);
        BOOL ButtonTriggered(CONST INT index, CONST INT buttonNbr);
        BOOL ButtonReleased(CONST INT index, CONST INT buttonNbr);
        BOOL ButtonIsPressed(CONST INT index, CONST INT buttonNbr);
        HRESULT GenerateNonLinearValues(CONST INT index, CONST INT nonLinCoeff);
        INT GetNonLinearValue(CONST INT index, CONST INT inputValue);

        BOOL HasForceFeedback(CONST INT index);
        BOOL IsPlaying(CONST INT index, CONST ForceType forceType);
        HRESULT PlaySpringForce(CONST INT index, CONST INT offsetPercentage, CONST INT saturationPercentage, CONST INT coefficientPercentage);
        HRESULT StopSpringForce(CONST INT index);
        HRESULT PlayConstantForce(CONST INT index, CONST INT magnitudePercentage);
        HRESULT StopConstantForce(CONST INT index);
        HRESULT PlayDamperForce(CONST INT index, CONST INT coefficientPercentage);
        HRESULT StopDamperForce(CONST INT index);
        HRESULT PlaySideCollisionForce(CONST INT index, CONST INT magnitudePercentage);
        HRESULT PlayFrontalCollisionForce(CONST INT index, CONST INT magnitudePercentage);
        HRESULT PlayDirtRoadEffect(CONST INT index, CONST INT magnitudePercentage);
        HRESULT StopDirtRoadEffect(CONST INT index);
        HRESULT PlayBumpyRoadEffect(CONST INT index, CONST INT magnitudePercentage);
        HRESULT StopBumpyRoadEffect(CONST INT index);
        HRESULT PlaySlipperyRoadEffect(CONST INT index, CONST INT magnitudePercentage);
        HRESULT StopSlipperyRoadEffect(CONST INT index);
        HRESULT PlaySurfaceEffect(CONST INT index, CONST PeriodicType type, CONST INT magnitudePercentage, CONST INT period);
        HRESULT StopSurfaceEffect(CONST INT index);
        HRESULT PlayCarAirborne(CONST INT index);
        HRESULT StopCarAirborne(CONST INT index);
        HRESULT PlaySoftstopForce(CONST INT index, CONST INT usableRangePercentage);
        HRESULT StopSoftstopForce(CONST INT index);

        HRESULT SetPreferredControllerProperties(CONST ControllerPropertiesData properties);
        BOOL GetCurrentControllerProperties(CONST INT index, ControllerPropertiesData& properties);
        INT GetShifterMode(CONST INT index);

        HRESULT PlayLeds(CONST INT index, CONST FLOAT currentRPM, CONST FLOAT rpmFirstLedTurnsOn, CONST FLOAT rpmRedLine);

    private:
        BOOL m_isAirborne[LG_MAX_CONTROLLERS];

        BOOL m_damperWasPlaying[LG_MAX_CONTROLLERS];
        BOOL m_springWasPlaying[LG_MAX_CONTROLLERS];
        BOOL m_wasPlayingBeforeAirborne[LG_MAX_CONTROLLERS][LG_NUMBER_FORCE_EFFECTS];

        ControllerForceManager* m_controllerForce[LG_MAX_CONTROLLERS];
        LogitechControllerInput::ControllerInput* m_controllerInput;
        ControllerProperties* m_controllerProperties;

        Leds m_leds;

        VOID InitVars(CONST INT index);

        // Forces below will only play if created before and using last known parameters
        HRESULT PlaySpringForce(CONST INT index);
        HRESULT PlayConstantForce(CONST INT index);
        HRESULT PlayDamperForce(CONST INT index);
        HRESULT PlayDirtRoadEffect(CONST INT index);
        HRESULT PlayBumpyRoadEffect(CONST INT index);
        HRESULT PlaySlipperyRoadEffect(CONST INT index);
        HRESULT PlaySurfaceEffect(CONST INT index);
    };
}

#endif // LGWHEELS_H_INCLUDED_
