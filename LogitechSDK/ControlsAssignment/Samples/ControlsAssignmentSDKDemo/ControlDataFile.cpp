/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "StdAfx.h"
#include "ControlDataFile.h"

using namespace LogitechControlsAssignmentSDK;

CControlDataFile::CControlDataFile(void)
{
}

CControlDataFile::~CControlDataFile(void)
{
}

void CControlDataFile::LoadFile(CString filename, ControlsAssignment &assigner)
{
    CStdioFile InFile;
    bool usefile = true;
    if( !InFile.Open(filename, CFile::modeRead | CFile::typeText) )
    {
        TRACE( _T("Could not open file.\n") );
        usefile = false;
    }

    int curraction;
    ControlAssignment currassignment;
    CString currline;
    for( curraction = LG_ZERO_ACTION+1; curraction < LG_NUMBER_GAME_ACTIONS; curraction++ )
    {
        assigner.AddGameAction(curraction);

        if( !usefile ) continue;

        InFile.ReadString(currline);
        currline.Trim();

        INT controllerNbr = -1;
        ControllerType controllerType = LG_CONTROLLER_TYPE_NONE;
        ControlType controlType = CONTROL_TYPE_NONE;
        INT axis = -1;
        INT axisRangeType = -1;
        INT button = -1;
        INT povNbr = -1;
        INT povDirection = -1;

        //Parse the data
        CString left, remainder = currline;
        int i;
        for( i = 0; i < 8; i++ )
        {
            if( i == 7 )
            {
                povDirection = _tstoi(remainder);
                break;
            }

            int index = remainder.Find(_T(" "));

            if( index < 0 ) 
                break;

            left = remainder.Left(index);
            remainder = remainder.Mid(index+1);
            left.Trim();
            remainder.Trim();

            switch(i)
            {
            case 0:
                controllerNbr = _tstoi(left);
                break;
            case 1:
                controllerType = (ControllerType)_tstoi(left);
                break;
            case 2:
                controlType = (ControlType)_tstoi(left);
                break;
            case 3:
                axis = _tstoi(left);
                break;
            case 4:
                axisRangeType = _tstoi(left);
                break;
            case 5:
                button = _tstoi(left);
                break;
            case 6:
                povNbr = _tstoi(left);
            default:
                break;
            }
        }

        ControlAssignment addme;
        addme.controllerIndex = controllerNbr;
        addme.controllerType = controllerType;
        addme.controlType = controlType;
        addme.axis = axis;
        addme.axisRangeType = axisRangeType;
        addme.button = button;
        addme.povNbr = povNbr;
        addme.povDirection = povDirection;      

        if( addme.controllerIndex >=0 )
            assigner.AssignActionToControl(curraction, addme);
    }
}

void CControlDataFile::SaveFile(CString filename, ControlsAssignment &assigner)
{
    //Iterate through the actions and write to file
    int curraction;

    CStdioFile OutFile;
    if( !OutFile.Open(filename, CFile::modeCreate | CFile::modeWrite | CFile::typeText) )
    {
        TRACE( _T("Could not open file.\n") );
        return;
    }

    ControlAssignment DefaultControlAssignment;



    for( curraction = LG_ZERO_ACTION+1; curraction < LG_NUMBER_GAME_ACTIONS; curraction++ )
    {
        if( assigner.IsGameActionAssigned(curraction) )
        {
            ControlAssignment ctrl;
            assigner.GetAssignedActionInfo( ctrl, curraction );

            //write it to file
            INT controllerNbr = ctrl.controllerIndex;
            ControllerType controllerType = ctrl.controllerType;
            ControlType controlType = ctrl.controlType;

            INT axis = ctrl.axis;
            INT axisRangeType = ctrl.axisRangeType;
            INT button = ctrl.button;
            INT povNbr = ctrl.povNbr;
            INT povDirection = ctrl.povDirection; 

            TCHAR entry[540];
            _stprintf_s(entry, _countof(entry),_T("%d %d %d %d %d %d %d %d\n"), 
                controllerNbr, controllerType, controlType, axis, axisRangeType, button, povNbr, povDirection);

            OutFile.WriteString( entry );
        }
        else
        {           
            //write the default to file
            INT controllerNbr = DefaultControlAssignment.controllerIndex;
            ControllerType controllerType = DefaultControlAssignment.controllerType;
            ControlType controlType = DefaultControlAssignment.controlType;

            INT axis = DefaultControlAssignment.axis;
            INT axisRangeType = DefaultControlAssignment.axisRangeType;
            INT button = DefaultControlAssignment.button;
            INT povNbr = DefaultControlAssignment.povNbr;
            INT povDirection = DefaultControlAssignment.povDirection; 

            TCHAR entry[540];
            _stprintf_s(entry, _countof(entry), _T("%d %d %d %d %d %d %d %d\n"), 
                controllerNbr, controllerType, controlType, axis, axisRangeType, button, povNbr, povDirection);

            OutFile.WriteString( entry );
        }
    }

    OutFile.Close();
}