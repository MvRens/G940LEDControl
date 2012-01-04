// JoystickSDKDemoDlg.cpp : implementation file
//

#include "stdafx.h"
#include "JoystickSDKDemo.h"
#include "JoystickSDKDemoDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CJoystickSDKDemoDlg dialog

using namespace LogitechControllerInput;


CJoystickSDKDemoDlg::CJoystickSDKDemoDlg(CWnd* pParent /*=NULL*/)
: CDialog(CJoystickSDKDemoDlg::IDD, pParent)
{
    m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CJoystickSDKDemoDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialog::DoDataExchange(pDX);
    DDX_Radio(pDX, IDC_RADIO_BUTTON_1, m_radioPanelButton);
    DDX_Radio(pDX, IDC_RADIO_OFF, m_radioButtonColor);
}

BEGIN_MESSAGE_MAP(CJoystickSDKDemoDlg, CDialog)
    ON_WM_PAINT()
    ON_WM_QUERYDRAGICON()
    ON_WM_DESTROY()
    ON_WM_TIMER()
    //}}AFX_MSG_MAP
    ON_BN_CLICKED(IDC_BUTTON_SET_COLOR, &CJoystickSDKDemoDlg::OnBnClickedButtonSetColor)
    ON_BN_CLICKED(IDC_BUTTON_SET_ALL_COLOR, &CJoystickSDKDemoDlg::OnBnClickedButtonSetAllColor)
    ON_BN_CLICKED(IDC_BUTTON_IS_COLOR, &CJoystickSDKDemoDlg::OnBnClickedButtonIsColor)
    ON_BN_CLICKED(IDC_BUTTON_SET_LEDS, &CJoystickSDKDemoDlg::OnBnClickedButtonSetLeds)
    ON_BN_CLICKED(IDC_BUTTON_GET_LEDS, &CJoystickSDKDemoDlg::OnBnClickedButtonGetLeds)
END_MESSAGE_MAP()


// CJoystickSDKDemoDlg message handlers

BOOL CJoystickSDKDemoDlg::OnInitDialog()
{
    CDialog::OnInitDialog();

    // Set the icon for this dialog.  The framework does this automatically
    //  when the application's main window is not a dialog
    SetIcon(m_hIcon, TRUE);			// Set big icon
    SetIcon(m_hIcon, FALSE);		// Set small icon

    SetText(IDC_EDIT_SET_GREEN, _T("AA"));
    SetText(IDC_EDIT_SET_RED, _T("55"));
    SetText(IDC_EDIT_GET_GREEN, _T("00"));
    SetText(IDC_EDIT_GET_RED, _T("00"));

    ((CButton*)GetDlgItem(IDC_RADIO_BUTTON_1))->SetCheck(TRUE);
    ((CButton*)GetDlgItem(IDC_RADIO_OFF))->SetCheck(TRUE);

    EnableButtons(FALSE);

    m_controllerInput = new ControllerInput(m_hWnd);

    SetTimer(1, 30, NULL);

    return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CJoystickSDKDemoDlg::OnPaint()
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
HCURSOR CJoystickSDKDemoDlg::OnQueryDragIcon()
{
    return static_cast<HCURSOR>(m_hIcon);
}


void CJoystickSDKDemoDlg::OnBnClickedButtonSetColor()
{
    UpdateData();

    for (INT index_ = 0; index_ < LG_MAX_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_, LG_MODEL_G940_THROTTLE))
        {
            SetButtonColor(m_controllerInput->GetDeviceHandle(index_), static_cast<LogiPanelButton>(m_radioPanelButton), static_cast<LogiColor>(m_radioButtonColor));
        }
    }
}

void CJoystickSDKDemoDlg::OnBnClickedButtonSetAllColor()
{
    UpdateData();

    for (INT index_ = 0; index_ < LG_MAX_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_, LG_MODEL_G940_THROTTLE))
        {
            SetAllButtonsColor(m_controllerInput->GetDeviceHandle(index_), static_cast<LogiColor>(m_radioButtonColor));
        }
    }
}

void CJoystickSDKDemoDlg::OnBnClickedButtonIsColor()
{
    UpdateData();

    for (INT index_ = 0; index_ < LG_MAX_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_, LG_MODEL_G940_THROTTLE))
        {
            BOOL isButtonColor_ = IsButtonColor(m_controllerInput->GetDeviceHandle(index_), static_cast<LogiPanelButton>(m_radioPanelButton), static_cast<LogiColor>(m_radioButtonColor));
            ((CButton*)GetDlgItem(IDC_CHECK_IS_BUTTON_COLOR))->SetCheck(isButtonColor_);
        }
    }
}

void CJoystickSDKDemoDlg::OnBnClickedButtonSetLeds()
{
    TCHAR setRedLeds_[MAX_PATH] = {'\0'};
    GetDlgItem(IDC_EDIT_SET_RED)->GetWindowText(setRedLeds_, MAX_PATH);
    TCHAR setGreenLeds_[MAX_PATH] = {'\0'};
    GetDlgItem(IDC_EDIT_SET_GREEN)->GetWindowText(setGreenLeds_, MAX_PATH);

    BYTE* setRedLedsByte_ = new BYTE[MAX_PATH];
    _stscanf_s(setRedLeds_, _T("%x"), setRedLedsByte_);

    BYTE* setGreenLedsByte_ = new BYTE[MAX_PATH];
    _stscanf_s(setGreenLeds_, _T("%x"), setGreenLedsByte_);

    for (INT index_ = 0; index_ < LG_MAX_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_, LG_MODEL_G940_THROTTLE))
        {
            SetLEDs(m_controllerInput->GetDeviceHandle(index_), *setRedLedsByte_, *setGreenLedsByte_);
            break;
        }
    }

    delete [] setRedLedsByte_;
    delete [] setGreenLedsByte_;
}

void CJoystickSDKDemoDlg::OnBnClickedButtonGetLeds()
{
    BYTE redLEDs_;
    BYTE greenLEDs_;
    for (INT index_ = 0; index_ < LG_MAX_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_, LG_MODEL_G940_THROTTLE))
        {
            GetLEDs(m_controllerInput->GetDeviceHandle(index_), redLEDs_, greenLEDs_);
            break;
        }
    }

    TCHAR strText_[MAX_PATH] = {'\0'};

    wsprintf( strText_, TEXT("%.2x"), redLEDs_);
    ::SetWindowText( ::GetDlgItem(m_hWnd, IDC_EDIT_GET_RED ), strText_ );

    wsprintf( strText_, TEXT("%.2x"), greenLEDs_);
    ::SetWindowText( ::GetDlgItem(m_hWnd, IDC_EDIT_GET_GREEN ), strText_ );
}

void CJoystickSDKDemoDlg::SetText(INT id, LPCTSTR text)
{
    TCHAR currentText_[MAX_PATH];
    GetDlgItem(id)->GetWindowText(currentText_, MAX_PATH);
    if (0 != _tcscmp(currentText_, text))
    {
        GetDlgItem(id)->SetWindowText(text);
    }
}

void CJoystickSDKDemoDlg::EnableButtons(BOOL enable)
{
    ::EnableWindow( ::GetDlgItem( m_hWnd, IDC_BUTTON_SET_COLOR ), enable );
    ::EnableWindow( ::GetDlgItem( m_hWnd, IDC_BUTTON_IS_COLOR ), enable );
    ::EnableWindow( ::GetDlgItem( m_hWnd, IDC_BUTTON_SET_ALL_COLOR ), enable );
    ::EnableWindow( ::GetDlgItem( m_hWnd, IDC_BUTTON_SET_LEDS ), enable );
    ::EnableWindow( ::GetDlgItem( m_hWnd, IDC_BUTTON_GET_LEDS ), enable );
}

void CJoystickSDKDemoDlg::OnDestroy()
{
    if (NULL != m_controllerInput)
    {
        delete m_controllerInput;
    }
}

void CJoystickSDKDemoDlg::OnTimer(UINT nIDEvent) 
{
    m_controllerInput->Update();

    static BOOL wasThrottleConnected_[LG_MAX_CONTROLLERS] = {FALSE, FALSE, FALSE, FALSE};
    for (INT index_ = 0; index_ < LG_MAX_CONTROLLERS; index_++)
    {
        if (m_controllerInput->IsConnected(index_, LG_MODEL_G940_THROTTLE))
        {
            if (!wasThrottleConnected_[index_])
            {
                EnableButtons(TRUE);
                wasThrottleConnected_[index_] = TRUE;
            }
        }
        else
        {
            if (wasThrottleConnected_[index_])
            {
                EnableButtons(FALSE);
                wasThrottleConnected_[index_] = FALSE;
            }
        }
    }
}
