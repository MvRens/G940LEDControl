// ControllerInputSDKDemoDlg.h : header file
//

#pragma once

#include "LogiControllerInput.h"

typedef struct
{
    INT checkBoxConnected;
    INT checkBoxXInput;
    INT checkBoxForceFeedback;
    INT type;
    INT manufacturer;
    INT friendlyName;
    INT vendorID;
    INT productID;
    INT devicePointer;
    INT xAxis;
    INT deviceConnected;
    INT XInputID;
} LogiItems;

// CControllerInputSDKDemoDlg dialog
class CControllerInputSDKDemoDlg : public CDialog
{
// Construction
public:
	CControllerInputSDKDemoDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_DEMO_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;
    LogitechControllerInput::ControllerInput* m_controllerInput;
    LogiItems m_items[4];

    void DisplayController(INT ctrlNbr, LogiItems items);

    void SetText(INT id, LPCTSTR text);

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
    afx_msg void OnTimer( UINT nIDEvent);
    afx_msg void OnDestroy();
	DECLARE_MESSAGE_MAP()
};
