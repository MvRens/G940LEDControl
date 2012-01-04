// This file shows how to use the Controller Input SDK to get
// both positional and descriptive information about the controller
// such as:
// - DIJOYSTATE2 for corresponding controller
// - XINPUT_STATE for corresponding controller
// - connection status (general or based on controller type or
//   controller model)
// - XInput or DirectInput
// - friendly name
// - Vendor ID (VID)
// - Product ID (PID)
// - has force feedback/rumble or not
// - device handle
// - XInput ID

// NOTE: This file can't compile. Therefore it hasn't been tested and
// there may be some errors.

/*
The Logitech Controller Input SDK, including all accompanying
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiControllerInput.h"

using namespace LogitechControllerInput;

ControllerInput* g_controller;

BOOL CSampleDlg::OnInitDialog()
{
    ...
    // Init main object
    g_controller = new ControllerInput(/*<game window handle>*/);

    ...

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CSampleDlg::OnTimer(UINT nIDEvent)
{
    UNREFERENCED_PARAMETER(nIDEvent);

    // Call Update function every frame to get latest positional
    // information and deal with unplug/replug and controller number
    // assignment.
    g_controller->Update();

    // For each controller, check if connected, get info, get
    // positional info based on controller type.
    for (INT ii = 0; ii < LG_MAX_CONTROLLERS; ii++)
    {
        if (g_controller->IsConnected(ii))
        {
            // If wanting to use non-linear values (for example for
            // single turn steering wheel), generate tables of
            // non-linear values.  Do it in main loop so that hot plug
            // in of controller still results in the values being
            // generated. Calling the method repeatedly has no
            // performance impact.
            g_controller->GenerateNonLinearValues(0, 40);
            g_controller->GenerateNonLinearValues(1, 80);
            g_controller->GenerateNonLinearValues(2, -30);
            g_controller->GenerateNonLinearValues(3, -60);

            // Get positional info
            if (g_controller->IsXInputDevice(ii))
            {
                XINPUT_STATE* state_ = g_controller->GetStateXInput(ii);
                // feed the info to wherever it needs to go
                ...
            }
            else
            {
                DIJOYSTATE2* state_ = g_controller->GetStateDInput(ii);
                // feed the info to wherever it needs to go
                ...

                // Get non-linear value
                INT nonLinValue_ = g_controller->GetNonLinearValue(ii, state_->lX); // non-linear
            }

            // Check if any of the buttons are pressed, triggered or
            // released, by using the ButtonIsPressed(),
            // ButtonTriggered, and ButtonReleased methods.

            // Check if we have a specific device connected, such as
            // for example a G25
            if (g_controller->IsConnected(ii, LG_MODEL_G25))
            {
                // Assign a corresponding default button and axis
                // assignment, display correct picture
                ...
            }

            // Check if we have a wheel, joystick, or gamepad
            if (g_controller->IsConnected(ii, LG_DEVICE_TYPE_JOYSTICK))
            {
                ...
            }
            else if (g_controller->IsConnected(ii, LG_DEVICE_TYPE_WHEEL))
            {
                ...
            }
            else if (g_controller->IsConnected(ii, LG_DEVICE_TYPE_GAMEPAD))
            {
                ...
            }
            else
            {
                ...
            }

            // Check if controller can do force feedback or rumble
            if (g_controller->HasForceFeedback(ii))
            {
                // If DirectInput device, get device handle to do
                // force feedback
                LPDIRECTINPUTDEVICE8 device_ = g_controller->GetDeviceHandle(ii);
                ...

                // If XInput device, get XInput ID to do rumble
                INT xinputID_ = g_controller->GetDeviceXInputID(ii);
                ...
            }

            // Get controller friendly name
            LPCTSTR friendlyName_ = g_controller->GetFriendlyProductName(ii);

            // Get controller Vendor ID
            DWORD vid_ = g_controller->GetVendorID(ii);

            // Get controller Product ID
            DWORD pid_ = g_controller->GetProductID(ii);
        }
    }
    ...
}

void CSampleDlg::OnDestroy()
{
    if (NULL != g_controller)
    {
        delete g_controller;
    }
}
