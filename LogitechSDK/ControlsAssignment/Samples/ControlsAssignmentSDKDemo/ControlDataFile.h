/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#pragma once

#include "Actions.h"
#include "LogiControlsAssignment.h"

class CControlDataFile
{
public:
    CControlDataFile(void);
    ~CControlDataFile(void);

    void LoadFile(CString filename, LogitechControlsAssignmentSDK::ControlsAssignment &assigner);
    void SaveFile(CString filename, LogitechControlsAssignmentSDK::ControlsAssignment &assigner);
private:
};
