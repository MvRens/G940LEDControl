// SteeringWheelSDKDemoDlg.h : header file
//

#pragma once

#include "LogiWheel.h"

// CSteeringWheelSDKDemoDlg dialog
class CSteeringWheelSDKDemoDlg : public CDialog
{
// Construction
public:
	CSteeringWheelSDKDemoDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_STEERINGWHEELSDKDEMO_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

    void FillGetPropertiesFields(CONST LogitechSteeringWheel::ControllerPropertiesData propertiesData, CONST INT isGatedShifter);
    void EmptyGetPropertiesFields();
    HRESULT RetrieveFieldsForSet(LogitechSteeringWheel::ControllerPropertiesData &propertiesData);

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
    afx_msg void OnTimer(UINT nIDEvent);
    afx_msg void OnDestroy( );
	DECLARE_MESSAGE_MAP()
public:
    afx_msg void OnBnClickedButtonGetWheelProperties0();
    afx_msg void OnBnClickedButtonGetWheelProperties1();
    afx_msg void OnBnClickedButtonDefaults();
    afx_msg void OnBnClickedButtonSetPreferred();
    afx_msg void OnBnKillfocusButtonSetPreferred();
};
