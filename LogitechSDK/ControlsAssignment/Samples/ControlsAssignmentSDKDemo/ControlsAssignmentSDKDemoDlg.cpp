/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

// ControlsAssignmentSDKDemoDlg.cpp : implementation file
//

#include "stdafx.h"
#include "ControlsAssignmentSDKDemo.h"
#include "ControlsAssignmentSDKDemoDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
    CAboutDlg();

    // Dialog Data
    enum { IDD = IDD_ABOUTBOX };

protected:
    virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

    // Implementation
protected:
    DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CControlsAssignmentSDKDemoDlg dialog




CControlsAssignmentSDKDemoDlg::CControlsAssignmentSDKDemoDlg(CWnd* pParent /*=NULL*/)
: CDialog(CControlsAssignmentSDKDemoDlg::IDD, pParent)
, m_bStrafeRev(FALSE)
, m_bMoveRev(FALSE)
, m_bTurnRev(FALSE)   
, m_Alt1Value(_T(""))
, m_Alt2Value(_T(""))
, m_Alt3Value(_T(""))
, m_Alt4Value(_T(""))
, m_Alt5Value(_T(""))
, m_Alt6Value(_T(""))
, m_Alt7Value(_T(""))
, m_Alt8Value(_T(""))
, m_Alt9Value(_T(""))
, m_Norm1Value(0)
, m_Norm2Value(0)
, m_Norm3Value(0)
, m_Norm4Value(0)
, m_Norm5Value(0)
, m_Norm6Value(0)
, m_Norm7Value(0)
, m_Norm8Value(0)
, m_Norm9Value(0)
, m_Comb1Value(0)
, m_Comb2Value(0)
, m_Comb3Value(0)
{
    m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);   
}

CControlsAssignmentSDKDemoDlg::~CControlsAssignmentSDKDemoDlg()
{
    if (NULL != m_LogiControllerInput)
    {
        delete m_LogiControllerInput;
        m_LogiControllerInput = NULL;
    }

    if (NULL != m_LogiControls)
    {
        delete m_LogiControls;
        m_LogiControls = NULL;
    }
}

void CControlsAssignmentSDKDemoDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialog::DoDataExchange(pDX);
    DDX_Check(pDX, IDC_REV1, m_bStrafeRev);
    DDX_Check(pDX, IDC_REV2, m_bMoveRev);
    DDX_Check(pDX, IDC_REV3, m_bTurnRev);
    DDX_Text(pDX, IDC_ALT1, m_Alt1Value);
    DDX_Text(pDX, IDC_ALT2, m_Alt2Value);
    DDX_Text(pDX, IDC_ALT3, m_Alt3Value);
    DDX_Text(pDX, IDC_ALT4, m_Alt4Value);
    DDX_Text(pDX, IDC_ALT5, m_Alt5Value);
    DDX_Text(pDX, IDC_ALT6, m_Alt6Value);
    DDX_Text(pDX, IDC_ALT7, m_Alt7Value);
    DDX_Text(pDX, IDC_ALT8, m_Alt8Value);
    DDX_Text(pDX, IDC_ALT9, m_Alt9Value);
    DDX_Text(pDX, IDC_NORM1, m_Norm1Value);
    DDX_Text(pDX, IDC_NORM2, m_Norm2Value);
    DDX_Text(pDX, IDC_NORM3, m_Norm3Value);
    DDX_Text(pDX, IDC_NORM4, m_Norm4Value);
    DDX_Text(pDX, IDC_NORM5, m_Norm5Value);
    DDX_Text(pDX, IDC_NORM6, m_Norm6Value);
    DDX_Text(pDX, IDC_NORM7, m_Norm7Value);
    DDX_Text(pDX, IDC_NORM8, m_Norm8Value);
    DDX_Text(pDX, IDC_NORM9, m_Norm9Value);
    DDX_Text(pDX, IDC_COMB1, m_Comb1Value);
    DDX_Text(pDX, IDC_COMB2, m_Comb2Value);
    DDX_Text(pDX, IDC_COMB3, m_Comb3Value);
}

BEGIN_MESSAGE_MAP(CControlsAssignmentSDKDemoDlg, CDialog)
    ON_WM_SYSCOMMAND()
    ON_WM_PAINT()
    ON_WM_QUERYDRAGICON()
    //}}AFX_MSG_MAP
    ON_WM_TIMER()
    ON_EN_SETFOCUS(IDC_ALT1, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt1)
    ON_EN_SETFOCUS(IDC_ALT2, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt2)
    ON_EN_SETFOCUS(IDC_ALT3, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt3)
    ON_EN_SETFOCUS(IDC_ALT4, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt4)
    ON_EN_SETFOCUS(IDC_ALT5, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt5)
    ON_EN_SETFOCUS(IDC_ALT6, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt6)
    ON_EN_SETFOCUS(IDC_ALT7, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt7)
    ON_EN_SETFOCUS(IDC_ALT8, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt8)
    ON_EN_SETFOCUS(IDC_ALT9, &CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt9)
    ON_BN_CLICKED(IDC_STOPCHECKING, &CControlsAssignmentSDKDemoDlg::OnBnClickedStopchecking)
    ON_BN_CLICKED(IDC_SAVE, &CControlsAssignmentSDKDemoDlg::OnBnClickedSave)
    ON_BN_CLICKED(IDC_CLEARALL, &CControlsAssignmentSDKDemoDlg::OnBnClickedClearall)
END_MESSAGE_MAP()


// CControlsAssignmentSDKDemoDlg message handlers

BOOL CControlsAssignmentSDKDemoDlg::OnInitDialog()
{
    CDialog::OnInitDialog();

    // Set the icon for this dialog.  The framework does this automatically
    //  when the application's main window is not a dialog
    SetIcon(m_hIcon, TRUE);			// Set big icon
    SetIcon(m_hIcon, FALSE);		// Set small icon


    m_LogiControllerInput = new LogitechControllerInput::ControllerInput(m_hWnd);

    m_LogiControls = new LogitechControlsAssignmentSDK::ControlsAssignment(m_LogiControllerInput, LogitechControllerInput::LG_DINPUT_RANGE_MIN, LogitechControllerInput::LG_DINPUT_RANGE_MAX);

    m_CurrControl = LG_ZERO_ACTION;

    m_ControlFile.LoadFile( _T("DataFile.txt"), *m_LogiControls );

    SetTimer(0xbada, 50, NULL);

    m_pCurrControlName = NULL;

    m_Alt1Value = m_LogiControls->GetControlName(LG_STRAFE_LEFT);
    m_Alt2Value = m_LogiControls->GetControlName(LG_STRAFE_RIGHT);
    m_Alt3Value = m_LogiControls->GetControlName(LG_MOVE_FORWARD);
    m_Alt4Value = m_LogiControls->GetControlName(LG_MOVE_BACKWARD);
    m_Alt5Value = m_LogiControls->GetControlName(LG_TURN_LEFT);
    m_Alt6Value = m_LogiControls->GetControlName(LG_TURN_RIGHT);
    m_Alt7Value = m_LogiControls->GetControlName(LG_FIRE);
    m_Alt8Value = m_LogiControls->GetControlName(LG_CHANGE_VIEW);
    m_Alt9Value = m_LogiControls->GetControlName(LG_ZOOM_MAP);

    UpdateData(FALSE);

    GetDlgItem(IDC_STOPCHECKING)->EnableWindow(FALSE);
    GetDlgItem(IDC_SAVE)->EnableWindow(FALSE);

    return TRUE;  // return TRUE  unless you set the focus to a control
}

void CControlsAssignmentSDKDemoDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
    if ((nID & 0xFFF0) == IDM_ABOUTBOX)
    {
        CAboutDlg dlgAbout;
        dlgAbout.DoModal();
    }
    else
    {
        CDialog::OnSysCommand(nID, lParam);
    }
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CControlsAssignmentSDKDemoDlg::OnPaint()
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
HCURSOR CControlsAssignmentSDKDemoDlg::OnQueryDragIcon()
{
    return static_cast<HCURSOR>(m_hIcon);
}


void CControlsAssignmentSDKDemoDlg::OnOK()
{
    CDialog::OnOK();
}

void CControlsAssignmentSDKDemoDlg::OnCancel()
{ 
    CDialog::OnCancel();
}

void CControlsAssignmentSDKDemoDlg::OnTimer(UINT_PTR nIDEvent)
{
    UpdateData(TRUE);

    m_LogiControllerInput->Update();

    if (FAILED(m_LogiControls->Update()))
    {
        MessageBox( TEXT("Error doing Controls Assignment SDK Update"), 
            TEXT("DirectInput Sample"), MB_ICONERROR | MB_OK );
    }

    //No longer checking for input?   
    if( m_CurrControl > LG_ZERO_ACTION &&
        m_LogiControls->IsCheckingForInput(m_CurrControl) == FALSE )
    {
        m_CurrControl = LG_ZERO_ACTION;
        GetDlgItem(IDC_STOPCHECKING)->EnableWindow(FALSE);
        GetDlgItem(IDC_SAVE)->EnableWindow(TRUE);

        m_Alt1Value = m_LogiControls->GetControlName(LG_STRAFE_LEFT);
        m_Alt2Value = m_LogiControls->GetControlName(LG_STRAFE_RIGHT);
        m_Alt3Value = m_LogiControls->GetControlName(LG_MOVE_FORWARD);
        m_Alt4Value = m_LogiControls->GetControlName(LG_MOVE_BACKWARD);
        m_Alt5Value = m_LogiControls->GetControlName(LG_TURN_LEFT);
        m_Alt6Value = m_LogiControls->GetControlName(LG_TURN_RIGHT);
        m_Alt7Value = m_LogiControls->GetControlName(LG_FIRE);
        m_Alt8Value = m_LogiControls->GetControlName(LG_CHANGE_VIEW);
        m_Alt9Value = m_LogiControls->GetControlName(LG_ZOOM_MAP);
    }

    //Update the display for the values
    m_Norm1Value = m_LogiControls->GetValue(LG_STRAFE_LEFT);
    m_Norm2Value = m_LogiControls->GetValue(LG_STRAFE_RIGHT);
    m_Norm3Value = m_LogiControls->GetValue(LG_MOVE_FORWARD);
    m_Norm4Value = m_LogiControls->GetValue(LG_MOVE_BACKWARD);
    m_Norm5Value = m_LogiControls->GetValue(LG_TURN_LEFT);
    m_Norm6Value = m_LogiControls->GetValue(LG_TURN_RIGHT);
    m_Norm7Value = m_LogiControls->GetValue(LG_FIRE);
    m_Norm8Value = m_LogiControls->GetValue(LG_CHANGE_VIEW);
    m_Norm9Value = m_LogiControls->GetValue(LG_ZOOM_MAP);

    m_Comb1Value = m_LogiControls->GetCombinedValue(LG_STRAFE_LEFT, LG_STRAFE_RIGHT, m_bStrafeRev);
    m_Comb2Value = m_LogiControls->GetCombinedValue(LG_MOVE_FORWARD, LG_MOVE_BACKWARD, m_bMoveRev);
    m_Comb3Value = m_LogiControls->GetCombinedValue(LG_TURN_LEFT, LG_TURN_RIGHT, m_bTurnRev);

    UpdateData(FALSE);

    CDialog::OnTimer(nIDEvent);
}

void CControlsAssignmentSDKDemoDlg::StartChecking(GameActionEnum action)
{
    //If you are still checking for a previous input, stop it
    if( m_CurrControl > LG_ZERO_ACTION &&
        m_LogiControls->IsCheckingForInput(m_CurrControl) )
    {
        m_LogiControls->StopCheckingForInput(m_CurrControl);

        // Erase "Move a control on device to assign" if it is somewhere in another box
        m_Alt1Value = m_LogiControls->GetControlName(LG_STRAFE_LEFT);
        m_Alt2Value = m_LogiControls->GetControlName(LG_STRAFE_RIGHT);
        m_Alt3Value = m_LogiControls->GetControlName(LG_MOVE_FORWARD);
        m_Alt4Value = m_LogiControls->GetControlName(LG_MOVE_BACKWARD);
        m_Alt5Value = m_LogiControls->GetControlName(LG_TURN_LEFT);
        m_Alt6Value = m_LogiControls->GetControlName(LG_TURN_RIGHT);
        m_Alt7Value = m_LogiControls->GetControlName(LG_FIRE);
        m_Alt8Value = m_LogiControls->GetControlName(LG_CHANGE_VIEW);
        m_Alt9Value = m_LogiControls->GetControlName(LG_ZOOM_MAP);
    }

    //Assign a new action to look foor
    m_CurrControl = action;

    //Now start checking for it
    //(stops in OnTimer, or if cancelled)
    m_LogiControls->StartCheckingForInput(m_CurrControl);

    //Display some text to say what to do
    *m_pCurrControlName = _T("Move a control on device to assign");
    UpdateData(FALSE);
    GetDlgItem(IDC_STOPCHECKING)->EnableWindow(TRUE);
    GetDlgItem(IDOK)->SetFocus();
}

//Here is the set of 9 actions you can click on in the dialog's UI
void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt1()
{
    m_pCurrControlName = &m_Alt1Value;
    StartChecking(LG_STRAFE_LEFT);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt2()
{
    m_pCurrControlName = &m_Alt2Value;
    StartChecking(LG_STRAFE_RIGHT);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt3()
{
    m_pCurrControlName = &m_Alt3Value;
    StartChecking(LG_MOVE_FORWARD);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt4()
{
    m_pCurrControlName = &m_Alt4Value;
    StartChecking(LG_MOVE_BACKWARD);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt5()
{
    m_pCurrControlName = &m_Alt5Value;
    StartChecking(LG_TURN_LEFT);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt6()
{
    m_pCurrControlName = &m_Alt6Value;
    StartChecking(LG_TURN_RIGHT);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt7()
{
    m_pCurrControlName = &m_Alt7Value;
    StartChecking(LG_FIRE);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt8()
{
    m_pCurrControlName = &m_Alt8Value;
    StartChecking(LG_CHANGE_VIEW);
}

void CControlsAssignmentSDKDemoDlg::OnEnSetfocusAlt9()
{
    m_pCurrControlName = &m_Alt9Value;
    StartChecking(LG_ZOOM_MAP);
}

void CControlsAssignmentSDKDemoDlg::OnBnClickedStopchecking()
{
    //If you are still checking for a previous input, stop it
    if( m_CurrControl > LG_ZERO_ACTION &&
        m_LogiControls->IsCheckingForInput(m_CurrControl) )
    {
        m_LogiControls->StopCheckingForInput(m_CurrControl);

        m_Alt1Value = m_LogiControls->GetControlName(LG_STRAFE_LEFT);
        m_Alt2Value = m_LogiControls->GetControlName(LG_STRAFE_RIGHT);
        m_Alt3Value = m_LogiControls->GetControlName(LG_MOVE_FORWARD);
        m_Alt4Value = m_LogiControls->GetControlName(LG_MOVE_BACKWARD);
        m_Alt5Value = m_LogiControls->GetControlName(LG_TURN_LEFT);
        m_Alt6Value = m_LogiControls->GetControlName(LG_TURN_RIGHT);
        m_Alt7Value = m_LogiControls->GetControlName(LG_FIRE);
        m_Alt8Value = m_LogiControls->GetControlName(LG_CHANGE_VIEW);
        m_Alt9Value = m_LogiControls->GetControlName(LG_ZOOM_MAP);
    }

    m_CurrControl = LG_ZERO_ACTION;

    UpdateData(FALSE);
}

void CControlsAssignmentSDKDemoDlg::OnBnClickedSave()
{
    m_ControlFile.SaveFile( _T("DataFile.txt"), *m_LogiControls );
    GetDlgItem(IDC_SAVE)->EnableWindow(FALSE);
}

void CControlsAssignmentSDKDemoDlg::OnBnClickedClearall()
{
    for( INT a = LG_ZERO_ACTION; a < LG_NUMBER_GAME_ACTIONS; ++a )
    {
        m_LogiControls->Reset(a);
    }

    m_Alt1Value.Empty();
    m_Alt2Value.Empty();
    m_Alt3Value.Empty();
    m_Alt4Value.Empty();
    m_Alt5Value.Empty();
    m_Alt6Value.Empty();
    m_Alt7Value.Empty();
    m_Alt8Value.Empty();
    m_Alt9Value.Empty();
    m_Norm1Value = 0.0f;
    m_Norm2Value = 0.0f;
    m_Norm3Value = 0.0f;
    m_Norm4Value = 0.0f;
    m_Norm5Value = 0.0f;
    m_Norm6Value = 0.0f;
    m_Norm7Value = 0.0f;
    m_Norm8Value = 0.0f;
    m_Norm9Value = 0.0f;
    m_Comb1Value = 0.0f;
    m_Comb2Value = 0.0f;
    m_Comb3Value = 0.0f;
    m_bStrafeRev = FALSE;
    m_bMoveRev = FALSE;
    m_bTurnRev = FALSE;

    GetDlgItem(IDC_STOPCHECKING)->EnableWindow(FALSE);
    GetDlgItem(IDC_SAVE)->EnableWindow(TRUE);

    UpdateData(FALSE);
}
