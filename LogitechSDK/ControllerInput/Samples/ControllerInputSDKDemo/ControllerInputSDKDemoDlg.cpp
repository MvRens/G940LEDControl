// ControllerInputSDKDemoDlg.cpp : implementation file
//

#include "stdafx.h"
#include "ControllerInputSDKDemo.h"
#include "ControllerInputSDKDemoDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CControllerInputSDKDemoDlg dialog


using namespace LogitechControllerInput;

CControllerInputSDKDemoDlg::CControllerInputSDKDemoDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CControllerInputSDKDemoDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CControllerInputSDKDemoDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CControllerInputSDKDemoDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
    ON_WM_TIMER()
    ON_WM_DESTROY()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


// CControllerInputSDKDemoDlg message handlers

BOOL CControllerInputSDKDemoDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

    SetTimer(1, 30, NULL);
    m_controllerInput = new ControllerInput(m_hWnd);

    // fill item structures for all 4 controllers
    for (INT index_ = 0; index_ < 4; index_++)
    {
        ZeroMemory(&m_items[index_], sizeof(LogiItems));
    }

    m_items[0].checkBoxConnected = IDC_CHECK_0_CONNECTED;
    m_items[0].checkBoxXInput = IDC_CHECK_0_XINPUT;
    m_items[0].checkBoxForceFeedback = IDC_CHECK_0_FF;
    m_items[0].type = IDC_EDIT_0_TYPE;
    m_items[0].manufacturer = IDC_EDIT_0_MANUFACTURER;
    m_items[0].friendlyName = IDC_EDIT_0_FRIENDLY_NAME;
    m_items[0].vendorID = IDC_EDIT_0_VID;
    m_items[0].productID = IDC_EDIT_0_PID;
    m_items[0].devicePointer = IDC_EDIT_0_DEVICE_POINTER;
    m_items[0].xAxis = IDC_EDIT_0_X_AXIS;
    m_items[0].deviceConnected = IDC_EDIT_0_DEVICE_CONN;
    m_items[0].XInputID = IDC_EDIT_0_XINPUT_ID;

    m_items[1].checkBoxConnected = IDC_CHECK_1_CONNECTED;
    m_items[1].checkBoxXInput = IDC_CHECK_1_XINPUT;
    m_items[1].checkBoxForceFeedback = IDC_CHECK_1_FF;
    m_items[1].type = IDC_EDIT_1_TYPE;
    m_items[1].manufacturer = IDC_EDIT_1_MANUFACTURER;
    m_items[1].friendlyName = IDC_EDIT_1_FRIENDLY_NAME;
    m_items[1].vendorID = IDC_EDIT_1_VID;
    m_items[1].productID = IDC_EDIT_1_PID;
    m_items[1].devicePointer = IDC_EDIT_1_DEVICE_POINTER;
    m_items[1].xAxis = IDC_EDIT_1_X_AXIS;
    m_items[1].deviceConnected = IDC_EDIT_1_DEVICE_CONN;
    m_items[1].XInputID = IDC_EDIT_1_XINPUT_ID;

    m_items[2].checkBoxConnected = IDC_CHECK_2_CONNECTED;
    m_items[2].checkBoxXInput = IDC_CHECK_2_XINPUT;
    m_items[2].checkBoxForceFeedback = IDC_CHECK_2_FF;
    m_items[2].type = IDC_EDIT_2_TYPE;
    m_items[2].manufacturer = IDC_EDIT_2_MANUFACTURER;
    m_items[2].friendlyName = IDC_EDIT_2_FRIENDLY_NAME;
    m_items[2].vendorID = IDC_EDIT_2_VID;
    m_items[2].productID = IDC_EDIT_2_PID;
    m_items[2].devicePointer = IDC_EDIT_2_DEVICE_POINTER;
    m_items[2].xAxis = IDC_EDIT_2_X_AXIS;
    m_items[2].deviceConnected = IDC_EDIT_2_DEVICE_CONN;
    m_items[2].XInputID = IDC_EDIT_2_XINPUT_ID;

    m_items[3].checkBoxConnected = IDC_CHECK_3_CONNECTED;
    m_items[3].checkBoxXInput = IDC_CHECK_3_XINPUT;
    m_items[3].checkBoxForceFeedback = IDC_CHECK_3_FF;
    m_items[3].type = IDC_EDIT_3_TYPE;
    m_items[3].manufacturer = IDC_EDIT_3_MANUFACTURER;
    m_items[3].friendlyName = IDC_EDIT_3_FRIENDLY_NAME;
    m_items[3].vendorID = IDC_EDIT_3_VID;
    m_items[3].productID = IDC_EDIT_3_PID;
    m_items[3].devicePointer = IDC_EDIT_3_DEVICE_POINTER;
    m_items[3].xAxis = IDC_EDIT_3_X_AXIS;
    m_items[3].deviceConnected = IDC_EDIT_3_DEVICE_CONN;
    m_items[3].XInputID = IDC_EDIT_3_XINPUT_ID;

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CControllerInputSDKDemoDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CControllerInputSDKDemoDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CControllerInputSDKDemoDlg::DisplayController(INT ctrlNbr, LogiItems items)
{
    TCHAR strText_[MAX_PATH] = {'\0'};

    if (NULL == m_controllerInput)
        return;

    CheckDlgButton(items.checkBoxConnected, m_controllerInput->IsConnected(ctrlNbr));
    CheckDlgButton(items.checkBoxXInput, m_controllerInput->IsXInputDevice(ctrlNbr));
    CheckDlgButton(items.checkBoxForceFeedback, m_controllerInput->HasForceFeedback(ctrlNbr));

    if (m_controllerInput->IsConnected(ctrlNbr, LG_DEVICE_TYPE_JOYSTICK))
    {
        SetText(items.type, _T("Joystick"));
    }
    else if (m_controllerInput->IsConnected(ctrlNbr, LG_DEVICE_TYPE_WHEEL))
    {
        SetText(items.type, _T("Wheel"));
    }
    else if (m_controllerInput->IsConnected(ctrlNbr, LG_DEVICE_TYPE_GAMEPAD))
    {
        SetText(items.type, _T("Gamepad"));
    }
    else if (m_controllerInput->IsConnected(ctrlNbr, LG_DEVICE_TYPE_OTHER))
    {
        SetText(items.type, _T("Other"));
    }
    else
    {
        SetText(items.type, _T(""));
    }

    if (m_controllerInput->IsConnected(ctrlNbr))
    {
        if (m_controllerInput->IsConnected(ctrlNbr, LG_MANUFACTURER_LOGITECH))
        {
            SetText(items.manufacturer, _T("Logitech"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MANUFACTURER_MICROSOFT))
        {
            SetText(items.manufacturer, _T("Microsoft"));
        }
        else
        {
            SetText(items.manufacturer, _T("Unknown"));
        }
    }
    else
    {
        SetText(items.manufacturer, _T(""));
    }

    SetText(items.friendlyName, m_controllerInput->GetFriendlyProductName(ctrlNbr));

    DWORD vid_ = m_controllerInput->GetVendorID(ctrlNbr);

    if (0 != vid_)
    {
        wsprintf( strText_, TEXT("0x%.4x"), vid_);
        SetText(items.vendorID, strText_);
    }
    else
    {
        SetText(items.vendorID, _T(""));
    }

    DWORD pid_ = m_controllerInput->GetProductID(ctrlNbr);

    if (0 != pid_)
    {
        wsprintf( strText_, TEXT("0x%.4x"), pid_);
        SetText(items.productID, strText_);
    }
    else
    {
        SetText(items.productID, _T(""));
    }

    LPDIRECTINPUTDEVICE8 device_ = m_controllerInput->GetDeviceHandle(ctrlNbr);

    if (NULL != device_)
    {
        wsprintf( strText_, TEXT("0x%.8x"), device_);
        SetText(items.devicePointer, strText_);
    }
    else
    {
        SetText(items.devicePointer, _T(""));
    }

    INT xAxis_ = 0;
    if (m_controllerInput->IsConnected(ctrlNbr))
    {
        if (m_controllerInput->IsXInputDevice(ctrlNbr))
        {
            XINPUT_STATE* state_ = m_controllerInput->GetStateXInput(ctrlNbr);
            xAxis_ = state_->Gamepad.sThumbLX;
        }
        else
        {
            DIJOYSTATE2* state_ = m_controllerInput->GetStateDInput(ctrlNbr);
            xAxis_ = state_->lX;
            //xAxis_ = m_controller->GetNonLinearValue(ctrlNbr, state_->lX);
        }

        wsprintf( strText_, TEXT("%d"), xAxis_);
        SetText(items.xAxis, strText_);

    }
    else
    {
        SetText(items.xAxis, _T(""));
    }

    if (m_controllerInput->IsConnected(ctrlNbr))
    {
        if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_G27))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_G27"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_DRIVING_FORCE_GT))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_DRIVING_FORCE_GT"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_G25))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_G25"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_EXTREME_3D_PRO))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_EXTREME_3D_PRO"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_MOMO_RACING))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_MOMO_RACING"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_MOMO_FORCE))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_MOMO_FORCE"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_DRIVING_FORCE_PRO))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_DRIVING_FORCE_PRO"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_DRIVING_FORCE))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_DRIVING_FORCE"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_NASCAR_RACING_WHEEL))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_NASCAR_RACING_WHEEL"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_FORCE_3D_PRO))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_FORCE_3D_PRO"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_FREEDOM_24))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_FREEDOM_24"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_ATTACK_3))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_ATTACK_3"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_FORCE_3D))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_FORCE_3D"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_STRIKE_FORCE_3D))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_STRIKE_FORCE_3D"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_G940_JOYSTICK))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_G940_JOYSTICK"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_G940_THROTTLE))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_G940_THROTTLE"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_G940_PEDALS))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_G940_PEDALS"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_RUMBLEPAD))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_RUMBLEPAD"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_RUMBLEPAD_2))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_RUMBLEPAD_2"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_CORDLESS_RUMBLEPAD_2))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_CORDLESS_RUMBLEPAD_2"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_CORDLESS_GAMEPAD))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_CORDLESS_GAMEPAD"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_DUAL_ACTION_GAMEPAD))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_DUAL_ACTION_GAMEPAD"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_PRECISION_GAMEPAD_2))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_PRECISION_GAMEPAD_2"));
        }
        else if (m_controllerInput->IsConnected(ctrlNbr, LG_MODEL_CHILLSTREAM))
        {
            SetText(items.deviceConnected, _T("LG_MODEL_CHILLSTREAM"));
        }
        else
        {
            SetText(items.deviceConnected, _T("Unknown"));
        }
    }
    else
    {
        SetText(items.deviceConnected, _T(""));
    }

    if (m_controllerInput->IsConnected(ctrlNbr))
    {
        wsprintf( strText_, TEXT("%d"), m_controllerInput->GetDeviceXInputID(ctrlNbr));
        SetText(items.XInputID, strText_);
    }
    else
    {
        SetText(items.XInputID, _T(""));
    }
}

void CControllerInputSDKDemoDlg::SetText(INT id, LPCTSTR text)
{
    TCHAR currentText_[MAX_PATH];
    GetDlgItem(id)->GetWindowText(currentText_, MAX_PATH);
    if (0 != _tcscmp(currentText_, text))
    {
        GetDlgItem(id)->SetWindowText(text);
    }
}

void CControllerInputSDKDemoDlg::OnTimer(UINT nIDEvent) 
{
    UNREFERENCED_PARAMETER(nIDEvent);

    if (m_controllerInput)
    {
        m_controllerInput->Update();

        m_controllerInput->GenerateNonLinearValues(0, 40);
        m_controllerInput->GenerateNonLinearValues(1, 80);
        m_controllerInput->GenerateNonLinearValues(2, -30);
        m_controllerInput->GenerateNonLinearValues(3, -60);
    }

    for (INT index_ = 0; index_ < 4; index_++)
    {
        DisplayController(index_, m_items[index_]);
    }
}

void CControllerInputSDKDemoDlg::OnDestroy()
{
    if (NULL != m_controllerInput)
    {
        delete m_controllerInput;
    }
}
