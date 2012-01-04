/****f* Controls.Assignment.SDK/ControlsAssignmentSDK[1.00.002]
* NAME
*   Controls Assignment SDK
* COPYRIGHT
*   The Logitech Controls Assignment SDK, including all
*   accompanying documentation, is protected by intellectual property
*   laws. All rights not expressly granted by Logitech are reserved.
* PURPOSE
*   The Controls Assignment SDK enables developers to easily and
*   quickly create a bulletproof solution for assigning any controls
*   of any game controller to any functionality in their PC game.  The
*   wrapper also enables to directly calculate combined values for
*   pairs of game actions so the developer can directly feed the
*   values into his game.
*   The wrapper is an addition to Microsoft's DirectInput and XInput
*   and supports both.
*
*   See the following files to get started:
*       - readme.txt: tells you how to get started.
*       - Doc/SampleInGameImplementation.cpp: shows line by line how to
*       use the Controls Assignment SDK's interface to implement
*       control assignment in your game.
*       - Samples/ControlsAssignmentSDKDemo: VS2005 sample project that demonstrates
*       control assignment.
*         Just compile, run and plug in up to 4 DirectX or XInput
*         compatible game controllers (steering wheel, joystick,
*         gamepad, etc.).
*  NOTES
*   The Controls Assignment SDK uses the Logitech Controller Input
*   Wrapper (included in the package), which provides a simple
*   interface to:
*       - support both DirectInput and XInput hot plug/unplug
*       - integrate DInput and Xinput support seamlessly
*       - get controller positional information as well as general
*       info such as friendly name, VID, PID, connection status based
*       on various parameters such as controller type,manufacturer,
*       and model name, and whether it supports force feedback/rumble.
*       - get hooks to add force feedback or rumble (DirectInput
*       device interface and XInput ID).
*   For more details see Microsoft's DirectInput and XInput
*   documentation.
* AUTHOR
*   Christophe Juncker (cj@wingmanteam.com)
******
*/

#include "LogiControlsAssignment.h"
#include "LogiControlsAssignmentUtils.h"
#include <vector>

using namespace LogitechControlsAssignmentSDK;
using namespace LogitechControllerInput;

/****f* Controls.Assignment.SDK/ControlsAssignment(ControllerInput*.controllerInput,LONG.axesDInputRangeMin,LONG.axesDInputRangeMax)
* NAME
*  ControlsAssignment(ControllerInput* controllerInput, LONG
*  axesDInputRangeMin, LONG axesDInputRangeMax) -- Does necessary
*  initialization.
* INPUTS
*  controllerInput: handle to instance of Controller Input SDK.
*
*  axesDInputRangeMin: minimum value to be used by DirectInput for
*  axes. Should be -32768 to be consistent with XInput.
*
*  axesDInputRangeMax: maximum value to be used by DirectInput for
*  axes. Should b 32767 to be consistent with XInput.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
ControlsAssignment::ControlsAssignment(ControllerInput* controllerInput, CONST LONG axesDInputRangeMin, CONST LONG axesDInputRangeMax)
{
    for (INT ii = 0; ii < LG_MAX_NUMBER_SUPPORTED_CONTROLLERS; ii++)
    {
        m_controllerDInput[ii].Init(axesDInputRangeMin, axesDInputRangeMax);
    }

    _ASSERT(NULL != controllerInput);
    m_controllerInput = controllerInput;
}

ControlsAssignment::~ControlsAssignment()
{
    for (UINT ii = 0; ii < m_gameActions.size(); ii++)
    {
        delete m_gameActions[ii];
    }
}

/****f* Controls.Assignment.SDK/AddGameAction(INT.gameActionID)
* NAME
*  HRESULT AddGameAction(INT gameActionID) -- Add a game action (such
*  as for example Turn Left, or Shoot).
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* NOTES
*  Every game action needs to be added during initialization.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::AddGameAction(CONST INT gameActionID)
{
    GameAction* action_ = new GameAction();
    if (NULL == action_)
        return E_FAIL;

    action_->SetID(gameActionID);
    m_gameActions.insert(std::make_pair(gameActionID, action_));

    return S_OK;
}

GameAction* ControlsAssignment::GetGameAction(CONST INT gameActionID)
{
    ActionMap::iterator it_ = m_gameActions.find(gameActionID);
    if (it_ == m_gameActions.end())
    {
        return NULL;
    }

    return it_->second;
}

/****f* Controls.Assignment.SDK/StartCheckingForInput(INT.gameActionID)
* NAME
*  HRESULT StartCheckingForInput(INT gameActionID) -- This needs to be
*  called to indicate that the game action is now in the state where
*  it is checking for a control to be moved.
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::StartCheckingForInput(CONST INT gameActionID)
{
    GameAction* gameAction_ = GetGameAction(gameActionID);

    if (NULL == gameAction_)
        return E_FAIL;

    gameAction_->StartCheckingForInput();

    // Set all initial values for axes.
    for (INT kk = 0; kk < LG_MAX_NUMBER_SUPPORTED_CONTROLLERS; kk++)
    {
        m_controllerDInput[kk].SetInitialValues();
        m_controllerXInput[kk].SetInitialValues();
    }

    return S_OK;
}

/****f* Controls.Assignment.SDK/StopCheckingForInput(INT.gameActionID)
* NAME
*  HRESULT StopCheckingForInput(INT gameActionID) -- Stop checking for
*  input. If it is necessary to stop checking for input without having
*  assigned a control, call this function.
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::StopCheckingForInput(CONST INT gameActionID)
{
    GameAction* gameAction_ = GetGameAction(gameActionID);
    if (NULL == gameAction_)
        return E_FAIL;

    if (NULL != gameAction_)
    {
        gameAction_->StopCheckingForInput();
    }

    return S_OK;
}

/****f* Controls.Assignment.SDK/IsCheckingForInput(INT.gameActionID)
* NAME
*  BOOL IsCheckingForInput(INT gameActionID) -- Indicates whether the
*  wrapper is currently in the state where it is checking for a
*  control to be moved.
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  TRUE if the wrapper is currently checking for controller movement.
*  FALSE otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControlsAssignment::IsCheckingForInput(CONST INT gameActionID)
{
    GameAction* gameAction_ = GetGameAction(gameActionID);
    if (NULL == gameAction_)
    {
        LOGIASSIGNTRACE(_T("ERROR: ControlsAssignment::IsCheckingForInput"));
        return FALSE;
    }

    return gameAction_->IsCheckingForInput();
}

/****f* Controls.Assignment.SDK/IsGameActionAssigned(INT.gameActionID)
* NAME
*  BOOL IsGameActionAssigned(INT gameActionID) -- Indicates whether
*  the game action has a control assigned to it.
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  TRUE if the corresponding game action has a control assigned.
*  FALSE otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControlsAssignment::IsGameActionAssigned(CONST INT gameActionID)
{
    GameAction* gameAction_ = GetGameAction(gameActionID);
    if (NULL == gameAction_)
    {
        return FALSE;
    }

    if (NULL != gameAction_->GetControl())
    {
        return TRUE;
    }

    return FALSE;
}

/****f* Controls.Assignment.SDK/GetValue(INT.gameActionID)
* NAME
*  FLOAT GetValue(INT gameActionID) -- Returns current value of the
*  game action (0.0 or 1.0 for buttons and POVs, 0.0 to 1.0 or -1.0 to
*  0.0 for axes).
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  Current value of the game action if a control is assigned to it.
*  0.0 otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
FLOAT ControlsAssignment::GetValue(CONST INT gameActionID)
{
    GameAction* gameAction_ = GetGameAction(gameActionID);
    if (NULL == gameAction_)
    {
        return 0.0f;
    }

    return gameAction_->GetValue();
}

/****f* Controls.Assignment.SDK/GetCombinedValue(INT.gameAction1ID,INT.gameAction2ID,BOOL.reverseFlag)
* NAME
*  FLOAT GetCombinedValue(INT gameAction1ID, INT gameAction2ID, BOOL
*  reverseFlag) -- Returns a value that is the combination of 2 game
*  actions. For example if giving it Turn Left and Turn Right, the
*  return value will be the combination of those two actions. If the
*  reverseFlag is set, the return value will be inverted.
* INPUTS
*  gameAction1ID: identification number of the first game action.
*
*  gameAction2ID: identification number of the second game action.
*
*  reverseFlag: indicates whether output should be inverted.
* RETURN VALUE
*  Combined value of 2 game actions.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
FLOAT ControlsAssignment::GetCombinedValue(CONST INT gameAction1ID, CONST INT gameAction2ID, CONST BOOL reverseFlag)
{
    GameAction* gameAction1_ = GetGameAction(gameAction1ID);
    GameAction* gameAction2_ = GetGameAction(gameAction2ID);
    if (NULL == gameAction1_ || NULL == gameAction2_)
    {
        return 0.0f;
    }

    return Utils::Combine(gameAction1_->GetControl(), gameAction2_->GetControl(), reverseFlag);
}

/****f* Controls.Assignment.SDK/GetControlName(INT.gameActionID)
* NAME
*  LPCTSTR GetControlName(INT gameActionID) -- Get name of the control
*  assigned to the current game action.
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  Name of the control assigned to the current game action.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
LPCTSTR ControlsAssignment::GetControlName(CONST INT gameActionID)
{
    static TCHAR name_[MAX_PATH];
    ZeroMemory(name_, sizeof(name_));

    GameAction* gameAction_ = GetGameAction(gameActionID);
    if (NULL == gameAction_)
        return _T("");

    Control* control_ = gameAction_->GetControl();
    if (NULL == control_)
        return _T("");

    if (control_->GetControllerType() == LG_CONTROLLER_TYPE_DINPUT)
    {
        if (SUCCEEDED(GetControlNameDInput(name_, control_)))
        {
            return name_;
        }
    }
    else if (control_->GetControllerType() == LG_CONTROLLER_TYPE_XINPUT)
    {
        if (SUCCEEDED(GetControlNameXInput(name_, control_)))
        {
            return name_;
        }
    }

    return _T("");
}

/****f* Controls.Assignment.SDK/Update()
* NAME
*  HRESULT Update() -- Updates all axes, buttons and POVs inside the
*  wrapper.  Calculates their normalized values depending on the
*  minimum and maximum output of DirectInput or default values for
*  XInput. If an action is currently in the special state where it
*  checks for controller movement, this function assigns a control to
*  the game action and leaves the special state. Use
*  IsGameActionAssigned() to check if the wrapper still is in the
*  special state or not. If another game action had the same control
*  assigned, it gets reset.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* SEE ALSO
*  IsGameActionAssigned(INT.gameActionID)
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::Update()
{
    if (NULL == m_controllerInput)
        return E_FAIL;

    // Do the update on DInput and XInput devices. Check the
    // controller number in the input, and assign to corresponding
    // DInput or XInput controller structure.
    for (INT index_ = 0; index_ < LG_MAX_NUMBER_SUPPORTED_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_))
        {
            if (m_controllerInput->IsXInputDevice(index_))
            {
                if (FAILED(m_controllerXInput[index_].Update(index_, m_controllerInput->GetStateXInput(index_))))
                    return E_FAIL;
            }
            else
            {
                // it's a DirectInput device
                if (FAILED(m_controllerDInput[index_].Update(index_, m_controllerInput->GetStateDInput(index_))))
                    return E_FAIL;
            }
        }
    }

    INT counter1_ = 0;
    ActionMap::iterator it1_;
    for( it1_ = m_gameActions.begin(); it1_ != m_gameActions.end(); it1_++ )
    {
        ++counter1_;
        GameAction* currAction1_ = it1_->second;

        if (currAction1_->IsCheckingForInput())
        {
            Control* tempControl_ = NULL;

            // Check each controller to see if any control moved
            for (INT kk = 0; kk < LG_MAX_NUMBER_SUPPORTED_CONTROLLERS; kk++)
            {
                tempControl_ = m_controllerDInput[kk].ControlMoved();
                if (NULL == tempControl_)
                    tempControl_ = m_controllerXInput[kk].ControlMoved();
                if (NULL != tempControl_)
                    break;
            }

            if (NULL != tempControl_)
            {
                currAction1_->SetControl(tempControl_);

                INT counter2_ = 0;
                // Make sure there are no conflicts by resetting other game actions' control if it's the same
                ActionMap::iterator it2_;
                for( it2_ = m_gameActions.begin(); it2_ != m_gameActions.end(); it2_++ )
                {
                    ++counter2_;

                    if (counter1_ != counter2_)
                    {
                        GameAction* currAction2_ = it2_->second;
                        currAction2_->ResetIfSameControl(currAction1_->GetControl());
                    }
                }
            }
        }
    }

    return S_OK;
}

/****f* Controls.Assignment.SDK/Reset(INT.gameActionID)
* NAME
*  HRESULT Reset(INT gameActionID) -- Resets a game action.
* INPUTS
*  gameActionID: identification number of the game action.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::Reset(CONST INT gameActionID)
{
    GameAction* gameAction_ = GetGameAction(gameActionID);
    if (NULL == gameAction_)
        return E_FAIL;

    gameAction_->SetControl(NULL);

    return S_OK;
}

HRESULT ControlsAssignment::GetControlNameDInput(LPTSTR name, Control* control)
{
    if (NULL == control)
    {
        _tcscpy_s(name, MAX_PATH, _T(""));
        return E_FAIL;
    }

    TCHAR temp_[MAX_PATH] = {'\0'};

    Axis* axis_ = NULL;
    Button* button_ = NULL;
    PovDirection* povControl_ = NULL;

    switch (control->GetType())
    {
    case CONTROL_TYPE_AXIS:
        _tcscpy_s(name, MAX_PATH, _T(""));
        _tcscat_s(name, MAX_PATH, NAME_DINPUT_CONTROLLER);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _itot_s(control->GetControllerIndex() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));
        axis_ = static_cast<Axis*>(control);
        _tcscat_s(name, MAX_PATH, axis_->GetAxisName());
        _tcscat_s(name, MAX_PATH, _T(" "));
        switch (axis_->GetRangeType())
        {
        case LG_POSITIVE_RANGE:
            _tcscat_s(name, MAX_PATH, SIGN_POSITIVE_RANGE);
            break;
        case LG_NEGATIVE_RANGE:
            _tcscat_s(name, MAX_PATH, SIGN_NEGATIVE_RANGE);
            break;
        case LG_FULL_RANGE:
            _tcscat_s(name, MAX_PATH, SIGN_FULL_RANGE);
            break;
        default:
            _ASSERT(0);
        }
        break;
    case CONTROL_TYPE_BUTTON:
        _tcscpy_s(name, MAX_PATH, _T(""));
        _tcscat_s(name, MAX_PATH, NAME_DINPUT_CONTROLLER);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _itot_s(control->GetControllerIndex() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _tcscat_s(name, MAX_PATH, NAME_DINPUT_BUTTON);
        _tcscat_s(name, MAX_PATH, _T(" "));
        button_ = static_cast<Button*>(control);
        _itot_s(button_->GetNumber() + 1, temp_, sizeof(button_->GetNumber()), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        break;
    case CONTROL_TYPE_POV:
        _tcscat_s(name, MAX_PATH, NAME_DINPUT_CONTROLLER);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _itot_s(control->GetControllerIndex() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _tcscat_s(name, MAX_PATH, NAME_DINPUT_POV);
        _tcscat_s(name, MAX_PATH, _T(" "));
        povControl_= static_cast<PovDirection*>(control);
        _itot_s(povControl_->GetPovNumber() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));

        switch (povControl_->GetDirection())
        {
        case LG_POV_UP:
            _tcscat_s(name, MAX_PATH, NAME_DINPUT_POV_UP);
            break;
        case LG_POV_DOWN:
            _tcscat_s(name, MAX_PATH, NAME_DINPUT_POV_DOWN);
            break;
        case LG_POV_LEFT:
            _tcscat_s(name, MAX_PATH, NAME_DINPUT_POV_LEFT);
            break;
        case LG_POV_RIGHT:
            _tcscat_s(name, MAX_PATH, NAME_DINPUT_POV_RIGHT);
            break;
        default:
            _ASSERT(0);
        }
        break;
    default:
        _ASSERT(0);
    }

    return S_OK;
}

HRESULT ControlsAssignment::GetControlNameXInput(LPTSTR name, Control* control)
{
    if (NULL == control)
    {
        _tcscpy_s(name, MAX_PATH, _T(""));
        return E_FAIL;
    }

    TCHAR temp_[MAX_PATH] = {'\0'};

    Axis* axis_ = NULL;
    Button* button_ = NULL;
    PovDirection* povControl_ = NULL;

    switch (control->GetType())
    {
    case CONTROL_TYPE_AXIS:
        _tcscpy_s(name, MAX_PATH, _T(""));
        _tcscat_s(name, MAX_PATH, NAME_XINPUT_CONTROLLER);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _itot_s(control->GetControllerIndex() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));
        axis_ =  static_cast<Axis*>(control);
        _tcscat_s(name, MAX_PATH, axis_->GetAxisName());
        _tcscat_s(name, MAX_PATH, _T(" "));
        switch (axis_->GetRangeType())
        {
        case LG_POSITIVE_RANGE:
            _tcscat_s(name, MAX_PATH, SIGN_POSITIVE_RANGE);
            break;
        case LG_NEGATIVE_RANGE:
            _tcscat_s(name, MAX_PATH, SIGN_NEGATIVE_RANGE);
            break;
        case LG_FULL_RANGE:
            _tcscat_s(name, MAX_PATH, SIGN_FULL_RANGE);
            break;
        default:
            _ASSERT(0);
        }
        break;
    case CONTROL_TYPE_BUTTON:
        _tcscpy_s(name, MAX_PATH, _T(""));
        _tcscat_s(name, MAX_PATH, NAME_XINPUT_CONTROLLER);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _itot_s(control->GetControllerIndex() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON);
        _tcscat_s(name, MAX_PATH, _T(" "));
        button_ =  static_cast<Button*>(control);
        switch(button_->GetNumber())
        {
        case LG_BUTTON_START:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_START);
            break;
        case LG_BUTTON_BACK:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_BACK);
            break;
        case LG_BUTTON_LEFT_THUMB:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_LEFT_THUMB);
            break;
        case LG_BUTTON_RIGHT_THUMB:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_RIGHT_THUMB);
            break;
        case LG_BUTTON_LEFT_SHOULDER:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_LEFT_SHOULDER);
            break;
        case LG_BUTTON_RIGHT_SHOULDER:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_RIGHT_SHOULDER);
            break;
        case LG_BUTTON_A:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_A);
            break;
        case LG_BUTTON_B:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_B);
            break;
        case LG_BUTTON_X:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_X);
            break;
        case LG_BUTTON_Y:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_BUTTON_Y);
            break;
        default:
            _ASSERT(0);
        }
        break;
    case CONTROL_TYPE_POV:
        _tcscat_s(name, MAX_PATH, NAME_XINPUT_CONTROLLER);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _itot_s(control->GetControllerIndex() + 1, temp_, _countof(temp_), 10);
        _tcscat_s(name, MAX_PATH, temp_);
        _tcscat_s(name, MAX_PATH, _T(" "));
        _tcscat_s(name, MAX_PATH, NAME_XINPUT_POV);
        _tcscat_s(name, MAX_PATH, _T(" "));
        povControl_=  static_cast<PovDirection*>(control);

        switch (povControl_->GetDirection())
        {
        case LG_POV_UP:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_POV_UP);
            break;
        case LG_POV_DOWN:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_POV_DOWN);
            break;
        case LG_POV_LEFT:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_POV_LEFT);
            break;
        case LG_POV_RIGHT:
            _tcscat_s(name, MAX_PATH, NAME_XINPUT_POV_RIGHT);
            break;
        default:
            _ASSERT(0);
        }
        break;
    default:
        _ASSERT(0);
    }

    return S_OK;
}

/****f* Controls.Assignment.SDK/AssignActionToControl(INT.gameActionID,ControlAssignment&.controlAssignment)
* NAME
*  HRESULT AssignActionToControl(INT gameActionID, ControlAssignment&
*  controlAssignment) -- Do initial assignment between game actions
*  and controls.
* INPUTS
*  gameActionID: identification number of the game action.
*
*  controlAssignment: assigned control info such as controller number,
*  type, control type, axis, button and POV.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* NOTES
*  A game will typically read a config file to find out which control
*  is assigned to which game action, and then call this function.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::AssignActionToControl(CONST INT gameActionID, CONST ControlAssignment& controlAssignment)
{
    if (controlAssignment.controllerIndex < 0 || controlAssignment.controllerIndex >= LG_MAX_NUMBER_SUPPORTED_CONTROLLERS)
        return E_FAIL;

    // Get corresponding control
    Control* control_ = NULL;

    if (controlAssignment.controllerType == LG_CONTROLLER_TYPE_NONE)
        return E_FAIL;

    if (controlAssignment.controllerType == LG_CONTROLLER_TYPE_DINPUT)
        control_ = m_controllerDInput[controlAssignment.controllerIndex].GetControl(controlAssignment);
    else if (controlAssignment.controllerType == LG_CONTROLLER_TYPE_XINPUT)
        control_ = m_controllerXInput[controlAssignment.controllerIndex].GetControl(controlAssignment);

    if (NULL == control_)
        return E_FAIL;

    // set action to control
    m_gameActions[gameActionID]->SetControl(control_);

    return S_OK;
}

/****f* Controls.Assignment.SDK/GetAssignedActionInfo(ControlAssignment&.controlAssignment,INT.gameActionID)
* NAME
*  HRESULT GetAssignedActionInfo(ControlAssignment& controlAssignment,
*  INT gameActionID) -- Get game action and corresponding control
*  info.
* INPUTS
*  gameActionID: identification number of the game action.
*
*  controlAssignment: assigned control info such as controller number,
*  type, control type, axis, button and POV.
* RETURN VALUE
*  S_OK if the wrapper successfully entered the control checking
*  state.
*  E_FAIL otherwise.
* NOTES
*  A game can use the resulting info to write to a config file in
*  order to save user controller settings.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControlsAssignment::GetAssignedActionInfo(ControlAssignment& controlAssignment, CONST INT gameActionID)
{
    controlAssignment.Init();

    // Get control corresponding to game action
    Control* control_ = GetGameAction(gameActionID)->GetControl();

    if (NULL == control_)
        return E_FAIL;

    Axis* axis_ = NULL;
    Button* button_ = NULL;
    PovDirection* povDirection_ = NULL;

    controlAssignment.controllerIndex = control_->GetControllerIndex();
    controlAssignment.controllerType = static_cast<ControllerType>(control_->GetControllerType());
    controlAssignment.controlType = static_cast<ControlType>(control_->GetType());

    switch(controlAssignment.controlType)
    {
    case CONTROL_TYPE_AXIS:
        axis_ = static_cast<Axis*>(control_);
        controlAssignment.axis = axis_->GetAxisID();
        controlAssignment.axisRangeType = axis_->GetRangeType();
        break;
    case CONTROL_TYPE_BUTTON:
        button_ = static_cast<Button*>(control_);
        controlAssignment.button = button_->GetNumber();
        break;
    case CONTROL_TYPE_POV:
        povDirection_ = static_cast<PovDirection*>(control_);
        controlAssignment.povNbr = povDirection_->GetPovNumber();
        controlAssignment.povDirection = povDirection_->GetDirection();
        break;
    default:
        _ASSERT(0);
    }

    return S_OK;
}
