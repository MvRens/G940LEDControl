/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

// ControlsAssignmentSDKDemoDlg.h : header file
//

#pragma once

#include "LogiControlsAssignment.h"
#include "LogiControllerInput.h"

#include "Actions.h"
#include "ControlDataFile.h"

// CControlsAssignmentSDKDemoDlg dialog
class CControlsAssignmentSDKDemoDlg : public CDialog
{
    // Construction
public:
    CControlsAssignmentSDKDemoDlg(CWnd* pParent = NULL);	// standard constructor
    ~CControlsAssignmentSDKDemoDlg();

    // Dialog Data
    enum { IDD = IDD_CONTROLSASSIGNMENTSDKDEMO_DIALOG };

protected:
    virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


    // Implementation
protected:
    HICON m_hIcon;

    LogitechControlsAssignmentSDK::ControlsAssignment* m_LogiControls;
    LogitechControllerInput::ControllerInput* m_LogiControllerInput;
    CControlDataFile m_ControlFile;

    GameActionEnum m_CurrControl; //action you are currently assigning
    CString* m_pCurrControlName;

    void StartChecking(GameActionEnum action);

    // Generated message map functions
    virtual BOOL OnInitDialog();
    afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
    afx_msg void OnPaint();
    afx_msg HCURSOR OnQueryDragIcon();
    DECLARE_MESSAGE_MAP()
public:
    afx_msg void OnBnClickedButton2();
    afx_msg void OnEnChangeComb1();
protected:
    virtual void OnOK();
public:
    BOOL m_bStrafeRev;
    BOOL m_bMoveRev;
    BOOL m_bTurnRev;
protected:
    virtual void OnCancel();
public:
    afx_msg void OnTimer(UINT_PTR nIDEvent);
    afx_msg void OnEnSetfocusAlt1();
    afx_msg void OnEnSetfocusAlt2();
    afx_msg void OnEnSetfocusAlt3();
    afx_msg void OnEnSetfocusAlt4();
    afx_msg void OnEnSetfocusAlt5();
    afx_msg void OnEnSetfocusAlt6();
    afx_msg void OnEnSetfocusAlt7();
    afx_msg void OnEnSetfocusAlt8();
    afx_msg void OnEnSetfocusAlt9();
    CString m_Alt1Value;
    CString m_Alt2Value;
    CString m_Alt3Value;
    CString m_Alt4Value;
    CString m_Alt5Value;
    CString m_Alt6Value;
    CString m_Alt7Value;
    CString m_Alt8Value;
    CString m_Alt9Value;
    float m_Norm1Value;
    float m_Norm2Value;
    float m_Norm3Value;
    float m_Norm4Value;
    float m_Norm5Value;
    float m_Norm6Value;
    float m_Norm7Value;
    float m_Norm8Value;
    float m_Norm9Value;
    float m_Comb1Value;
    float m_Comb2Value;
    float m_Comb3Value;
    afx_msg void OnBnClickedStopchecking();
    afx_msg void OnBnClickedSave();
    afx_msg void OnBnClickedClearall();
};
