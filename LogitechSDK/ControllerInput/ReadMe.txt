Logitech Controller Input SDK for PC
Copyright (C) 2009 Logitech Inc. All Rights Reserved


Introduction
--------------------------------------------------------------------------

This package enables developers to easily add support in their games
for hot plug/unplug of game controllers, and enables to gracefully
combine XInput and DirectInput devices.
Any controller simply gets a number upon plug in corresponding to the
lowest number available (from 0 to 3), and then the developer can get
both positional and descriptive information about the controller (such
as whether it is XInput or DirectInput, friendly name, VID/PID,
connection status including connection based on manufacturer type and
product name, and whether it supports force feedback/rumble or not).
Furthermore the developer can get the device handle for DirectInput
devices in order for example to do force feedback, or the XInput ID to
do rumble or other XInput operations.

NOTE: a game controller is any device that will appear in "Control
Panel/Game Controllers" in Windows.


Contents of the package
--------------------------------------------------------------------------

- Logitech Controller Input SDK Source Files
- Demo executable
- Documentation
- Sample in-game implementation program file


The environment for use of the package
--------------------------------------------------------------------------

1. Microsoft DirectX 9 SDK or higher
   (http://msdn.microsoft.com/downloads)

2. DirectX Runtime 9.0c or higher (October 2006 update or higher).

3. Visual Studio 2005 to build and run the demo program

4. Drivers installed for particular wheels/joysticks/rumble pads. For
example if using Logitech wheels/joysticks/rumble pads make sure the
latest Gaming Software is installed
(http://www.logitech.com/index.cfm/support_downloads/&cl=us,en).


Testing setup
--------------------------------------------------------------------------

Devices used

Logitech gamepads
- Cordless Rumblepad 2
- Rumblepad 2 Vibration Feedback Gamepad
- Dual Action Gamepad
- Precision Gamepad 2

Logitech wheels
- G27
- G25
- Driving Force Pro
- MOMO Racing
- Formula Force GP
- NASCAR Racing Wheel
- Formula GP

Logitech joysticks
- G940
- Force 3D Pro
- Freedom 2.4 Cordless Joystick
- Force 3D
- Extreme 3D Pro
- Attack 3 Joystick

Microsoft
- Sidewinder Force Feedback 2 (Stick)
- Sidewinder Force (Wheel)

Other (Immersion drivers)
- Gravis gamepad (XTerminator Force)

Operating Systems
- Windows XP/Vista

DirectX versions
- 9.0c


Disclaimer
--------------------------------------------------------------------------

This is work in progress. If you find anything wrong with either
documentation or code, please let us know so we can improve on it.


Where to start
--------------------------------------------------------------------------

For a demo program to try plugging and unplugging controllers and
getting their X axis values and descriptive information:

Execute ControllerInputSDKDemo.exe.

Or:

1. Go to Samples/ControllerInputSDKDemo folder and open the project in
   Visual Studio.

2. Set the DirectX SDK include and lib folders in Visual Studio.

3. Compile and run.

4. Plug in one or multiple PC wheel, joystick, gamepad or other game
   controllers at any time.


To implement game controller support in your game:

1. Copy the following source files from the Src folder to your game:

- LogiControllerInput.h/cpp
- LogiGameController.h/cpp
- LogiGameControllerDI.h/cpp
- LogiGameControllerXInput.h/cpp
- LogiControllerInputGlobals.h
- LogiControllerInputUtils.h/cpp

2. Read and follow Doc/SampleInGameImplementation.cpp

3. Check method details in Doc/api.html


For questions/problems/suggestions email to:
cj@wingmanteam.com
roland@wingmanteam.com


End-User License Agreement for Logitech Controller Input SDK
Agreement

This End-User License Agreement for Logitech Controller Input SDK
Agreement ( "Agreement") is a legal agreement between you, either an
individual or legal entity ("You" or "you") and Logitech
Inc. ("Logitech") for the pre-release alpha test version of the
Logitech Controller Input software development kit, which includes
computer software and related media and documentation (hereinafter
"Controller Input SDK"). By installing, copying or otherwise using the
Controller Input SDK, you agree to be bound by the terms of this
Agreement.  If you do not agree to the terms of this Agreement, do not
install or use the Controller Input SDK.


1 Grant of License and Restrictions. Logitech grants You a limited,
  non-exclusive, nontransferable license to install and use an
  unlimited number of copies of the Controller Input SDK on
  computers for any purpose.  All other rights are reserved to
  Logitech.

2 Intellectual Property Rights. The Controller Input SDK is
  licensed, not sold, to You for use only under the terms and
  conditions of this Agreement.  Logitech and its suppliers retain
  title to the Controller Input SDK and all intellectual
  property rights therein.  The Controller Input SDK is
  protected by intellectual property laws and international treaties,
  including U.S. copyright law and international copyright treaties.
  All rights not expressly granted by Logitech are reserved.

3 Disclaimer of Warranty. TO THE MAXIMUM EXTENT PERMITTED BY
  APPLICABLE LAW, LOGITECH AND ITS SUPPLIERS PROVIDE THE CONTROLLER
  INPUT SDK AND OTHER LOGITECH PRODUCTS AND SERVICES (IF ANY) AS IS
  AND WITHOUT WARRANTY OF ANY KIND.  LOGITECH AND ITS SUPPLIERS
  EXPRESSLY DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING,
  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD-PARTY
  RIGHTS WITH RESPECT TO THE CONTROLLER INPUT SDK AND ANY WARRANTIES
  OF NON-INTERFERENCE OR ACCURACY OF INFORMATIONAL CONTENT.  NO
  LOGITECH DEALER, AGENT, OR EMPLOYEE IS AUTHORIZED TO MAKE ANY
  MODIFICATION, EXTENSION, OR ADDITION TO THIS WARRANTY.  Some
  jurisdictions do not allow limitations on how long an implied
  warranty lasts, so the above limitation may not apply to you.

4 Limitation of Liability.  IN NO EVENT WILL LOGITECH OR ITS SUPPLIERS
  BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTE PRODUCTS OR
  SERVICES, LOST PROFITS, LOSS OF INFORMATION OR DATA, OR ANY OTHER
  SPECIAL, INDIRECT, CONSEQUENTIAL, OR INCIDENTAL DAMAGES ARISING IN
  ANY WAY OUT OF THE SALE OF, USE OF, OR INABILITY TO USE THE
  CONTROLLER INPUT SDK OR ANY LOGITECH PRODUCT OR SERVICE, EVEN IF
  LOGITECH HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. IN NO
  CASE SHALL LOGITECH'S AND ITS SUPPLIERS' TOTAL LIABILITY EXCEED THE
  ACTUAL MONEY PAID FOR THE LOGITECH PRODUCT OR SERVICE GIVING RISE TO
  THE LIABILITY.  Some jurisdictions do not allow the exclusion or
  limitation of incidental or consequential damages, so the above
  limitation or exclusion may not apply to you.  The above limitations
  will not apply in case of personal injury where and to the extent
  that applicable law requires such liability.
