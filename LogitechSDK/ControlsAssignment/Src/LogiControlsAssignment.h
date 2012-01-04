/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LG_ASSIGN_CONTROLS_H_INCLUDED_
#define LG_ASSIGN_CONTROLS_H_INCLUDED_

#include "LogiGameAction.h"
#include "LogiControllerDInput.h"
#include "LogiControllerXInput.h"
#include "LogiControlsAssignmentUtils.h"
#include "LogiControllerInput.h"
#include <map>

namespace LogitechControlsAssignmentSDK
{
    class ControlsAssignment
    {
    public:
        ControlsAssignment(LogitechControllerInput::ControllerInput* controllerInput, CONST LONG axesDInputRangeMin, CONST LONG axesDInputRangeMax);
        ~ControlsAssignment();

        HRESULT AddGameAction(CONST INT gameActionID);
        HRESULT StartCheckingForInput(CONST INT gameActionID);
        HRESULT StopCheckingForInput(CONST INT gameActionID);
        BOOL IsCheckingForInput(CONST INT gameActionID);
        BOOL IsGameActionAssigned(CONST INT gameActionID);
        FLOAT GetValue(CONST INT gameActionID);
        FLOAT GetCombinedValue(CONST INT gameAction1ID, CONST INT gameAction2ID, CONST BOOL reverseFlag);
        LPCTSTR GetControlName(CONST INT gameActionID);
        HRESULT AssignActionToControl(CONST INT gameActionID, CONST ControlAssignment& controlAssignment); // for default or initial settings
        HRESULT GetAssignedActionInfo(ControlAssignment& controlAssignment, CONST INT gameActionID);
        HRESULT Update();
        HRESULT Reset(CONST INT gameActionID);

    private:
        GameAction* GetGameAction(CONST INT gameActionID);

        typedef std::map<INT, GameAction*> ActionMap;
        ActionMap m_gameActions;
        ControllerDInput m_controllerDInput[LG_MAX_NUMBER_SUPPORTED_CONTROLLERS];
        ControllerXInput m_controllerXInput[LG_MAX_NUMBER_SUPPORTED_CONTROLLERS];
        LogitechControllerInput::ControllerInput* m_controllerInput;

        HRESULT GetControlNameDInput(LPTSTR name, Control* control);
        HRESULT GetControlNameXInput(LPTSTR name, Control* control);
    };
}

#endif // LG_ASSIGN_CONTROLS_H_INCLUDED_
