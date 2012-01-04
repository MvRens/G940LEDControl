/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights not 
expressly granted by Logitech are reserved.
*/

// This file shows how to use the Controls Assignment SDK to take care 
// of axis, button or POV assignments in a Controller Options menu. The
// Wrapper works in a way that any combination of controls of any type of
// gaming device (other than mouse and keyboard) can be used for any of 
// the game's functions (game actions), therefore providing maximum 
// controller support and customization.

// NOTE: Whatever is in these brackets (/***...***/) is what you need to 
// do in your game.
// NOTE: This file can't compile. Therefore it hasn't been tested and 
// there may be some errors.

// include the following
#include "LogiControllerInput.h"
#include "LogiControlsAssignment.h"

// Define game actions to be assigned in controller options screen, 
// similarly to the example below.
typedef enum
{
    LG_STRAFE_LEFT, 
    LG_STRAFE_RIGHT, 
    LG_MOVE_FORWARD, 
    LG_MOVE_BACKWARD, 
    LG_TURN_LEFT, 
    LG_TURN_RIGHT, 
    LG_LOOK_UP, 
    LG_LOOK_DOWN, 
    LG_SHOOT, 
    LG_CHANGE_VIEW,

    LG_NUMBER_GAME_ACTIONS
} GameAction;

//------------------------------------------------------------------------
// Global variables
//------------------------------------------------------------------------

// Create ControlsAssignment and ControllerInput instances. In this example we suppose a single 
// player. Create more instances if multiplayer on local system is 
// supported.

LogitechControllerInput::ControllerInput* g_logiControllerInput;
LogitechControlsAssignmentSDK::ControlsAssignment* g_logiControlsAssignment;

INT_PTR CALLBACK MainDlgProc( HWND hDlg, 
                             UINT msg, 
                             WPARAM wParam, 
                             LPARAM lParam )
{
    TCHAR changeViewName_[MAX_PATH] = {\0};
    HRESULT hr_ = E_FAIL;
    ControlAssignment tempAssignment_; // assignment data read from config file
    ...

    switch( msg ) 
    {
        case WM_INITDIALOG:
            ...

            // Init main objects
            g_logiControllerInput = new LogitechControllerInput::ControllerInput(hDlg);
            g_logiControlsAssignment = new LogitechControlsAssignmentSDK::ControlsAssignment(g_logiControllerInput, LogitechControllerInput::LG_DINPUT_RANGE_MIN, LogitechControllerInput::LG_DINPUT_RANGE_MAX);

            // Init game actions
            for (INT ii = 0; ii < LG_NUMBER_GAME_ACTIONS; ii++)
            {
                g_logiControlsAssignment->AddGameAction(ii);
            }

            // Get controller setup info from config file
            tempAssignment_.Init();
            /*** read data from config file for LG_STRAFE_LEFT and populate tempAssignment_ ***/
            hr_ = g_logiControlsAssignment->AssignActionToControl(LG_STRAFE_LEFT, tempAssignment_);

            tempAssignment_.Init();
            /*** read data from config file for LG_STRAFE_RIGHT and populate tempAssignment_ ***/
            hr_ = g_logiControlsAssignment->AssignActionToControl(LG_STRAFE_RIGHT, tempAssignment_);

            /*** do same for other game actions ***/

            ...

            return TRUE;

        case WM_COMMAND:
            ...

            if (/*** event received that user clicked on game action LG_STRAFE_LEFT to assign a control ***/)
            {
                g_logiControlsAssignment->StartCheckingForInput(LG_STRAFE_LEFT);
            }

            /*** Do same for other game actions ***/
            ...

            return TRUE;

        case WM_TIMER:
            ...


            // Call update in main loop for both objects
            g_logiControllerInput->Update();
            if (FAILED(g_logiControlsAssignment->Update()))
            {
                /*** deal with error ***/
            }

            // Get game action control name for Controller Menu name printing
            if (g_logiControlsAssignment->IsGameActionAssigned(LG_CHANGE_VIEW))
            {
                wsprintf( changeViewName_, TEXT("%s"), g_logiControlsAssignment->GetControlName(LG_CHANGE_VIEW));
            }
            /*** Do same for other game actions ***/
            ...

            // Get combined values
            if (g_logiControlsAssignment->IsGameActionAssigned(LG_STRAFE_LEFT) && g_logiControlsAssignment->IsGameActionAssigned(LG_STRAFE_RIGHT))
            {
                FLOAT strafeCombined_ = g_logiControlsAssignment->GetCombinedValue(LG_STRAFE_LEFT, LG_STRAFE_RIGHT, /*** reverse checkbox TRUE or FALSE ***/);
            }
            /*** Do same for other game actions ***/
            ...

            // Get non-combined values.
            if (g_logiControlsAssignment->IsGameActionAssigned(LG_SHOOT))
            {
                FLOAT shoot_ = g_logiControlsAssignment->GetValue(LG_SHOOT);
            }
            // NOTE: if the game action is not assigned, the GetValue() method will return 0.0f.
            /*** Do same for other game actions ***/
            ...

            // save settings to config file
            if (/*** user controller settings need to be saved ***/)
            {
                g_logiControlsAssignment->GetAssignedActionInfo(tempAssignment_, LG_TURN_LEFT);
                /*** write info to config file based on data in tempAssignment_ ***/

                /*** do same for all other game actions ***/
                ...
            }

            return TRUE;


        case WM_DESTROY:
            ...
                if (NULL != g_logiControllerInput)
                {
                    delete g_logiControllerInput;
                    g_logiControllerInput = NULL;
                }

                if (NULL != g_logiControlsAssignment)
                {
                    delete g_logiControlsAssignment;
                    g_logiControlsAssignment = NULL;
                }
                ...
                return TRUE;
    }

    return FALSE; // Message not handled 
}
