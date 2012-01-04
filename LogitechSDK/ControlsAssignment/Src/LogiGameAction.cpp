/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiGameAction.h"

using namespace LogitechControlsAssignmentSDK;

GameAction::GameAction()
{
    m_isCheckingForInput = FALSE;
    m_control = NULL;
    m_ID = -1;
}

GameAction::~GameAction()
{
}

VOID GameAction::SetControl(Control* control)
{
    m_control = control;

    StopCheckingForInput();
}

Control* GameAction::GetControl()
{
    return m_control;
}

FLOAT GameAction::GetValue()
{
    if (NULL == m_control)
        return 0.0f;

    return m_control->GetValue();
}

VOID GameAction::StartCheckingForInput()
{
    m_isCheckingForInput = TRUE;

    // Reset m_control to NULL in case there was sth assigned before
    m_control = NULL;
}

VOID GameAction::StopCheckingForInput()
{
    m_isCheckingForInput = FALSE;
}

BOOL GameAction::IsCheckingForInput()
{
    return m_isCheckingForInput;
}

VOID GameAction::ResetIfSameControl(CONST Control* control)
{
    if (m_control == control)
    {
        m_control = NULL;
    }
}

VOID GameAction::SetID(CONST INT ID)
{
    m_ID = ID;
}

INT GameAction::GetID()
{
    return m_ID;
}
