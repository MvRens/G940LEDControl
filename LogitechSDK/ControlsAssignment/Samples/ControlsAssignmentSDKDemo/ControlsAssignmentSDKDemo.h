/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

// ControlsAssignmentSDKDemo.h : main header file for the PROJECT_NAME application
//

#pragma once

#ifndef __AFXWIN_H__
#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"		// main symbols


// CControlsAssignmentSDKDemoApp:
// See ControlsAssignmentSDKDemo.cpp for the implementation of this class
//

class CControlsAssignmentSDKDemoApp : public CWinApp
{
public:
    CControlsAssignmentSDKDemoApp();

    // Overrides
public:
    virtual BOOL InitInstance();

    // Implementation

    DECLARE_MESSAGE_MAP()
};

extern CControlsAssignmentSDKDemoApp theApp;