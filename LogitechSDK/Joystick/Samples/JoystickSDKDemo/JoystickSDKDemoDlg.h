// JoystickSDKDemoDlg.h : header file
//

#pragma once

#include "LogiControllerInput.h"

#include "LogiJoystick.h"
#pragma comment(lib,"LogiJoystick.lib")

// CJoystickSDKDemoDlg dialog
class CJoystickSDKDemoDlg : public CDialog
{
    // Construction
public:
    CJoystickSDKDemoDlg(CWnd* pParent = NULL);	// standard constructor

    // Dialog Data
    enum { IDD = IDD_JOYSTICKSDKDEMO_DIALOG };

protected:
    virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


    // Implementation
protected:
    HICON m_hIcon;
    LogitechControllerInput::ControllerInput* m_controllerInput;

    void SetText(INT id, LPCTSTR text);
    void EnableButtons(BOOL enable);

    // Generated message map functions
    virtual BOOL OnInitDialog();
    afx_msg void OnPaint();
    afx_msg HCURSOR OnQueryDragIcon();
    afx_msg void OnDestroy();
    afx_msg void OnTimer( UINT nIDEvent);
    DECLARE_MESSAGE_MAP()
public:
    afx_msg void OnBnClickedButtonSetColor();
    afx_msg void OnBnClickedButtonSetAllColor();
    afx_msg void OnBnClickedButtonIsColor();
    afx_msg void OnBnClickedButtonSetLeds();
    afx_msg void OnBnClickedButtonGetLeds();
    int m_radioPanelButton;
    int m_radioButtonColor;
};
