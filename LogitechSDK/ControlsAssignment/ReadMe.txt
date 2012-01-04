Logitech Controls Assignment SDK for PC
Copyright (C) 2009 Logitech Inc. All Rights Reserved


Introduction
--------------------------------------------------------------------------

This package enables developers to easily and quickly create a
bulletproof solution for assigning any controls of any game controller
to any functionality in their PC game.

The SDK also enables to easily calculate combined values for pairs of
game actions so the developer can directly feed the values into his
game.

NOTE: a game controller is any device that will appear in "Control
Panel/Game Controllers" in Windows.


Contents of the package
--------------------------------------------------------------------------

- Logitech Controls Assignment SDK Source Files
- Documentation
- Demo program
- Sample in-game implementation program file


Requisites
--------------------------------------------------------------------------

The SDK expects both DIJOYSTATE2 and XINPUT_STATE structures as
input. To obtain them easily and get full hot plug/unplug support, be
sure to use the Controller Input SDK.

The game also needs to have an options menu where the player can
assign controls to various game actions. That options menu should
offer a way to invert the controls if necessary (using checkboxes for
example, like the sample program).

If the concerned game is a driving title, you may use the Steering
Wheel SDK that will make it very easy to enumerate and read the
wheels, as well as doing force feedback.


The environment for use of the package
--------------------------------------------------------------------------

1. Microsoft DirectX 9.0c SDK or newer
(http://msdn.microsoft.com/downloads)

2. Visual Studio 2005 or newer to build and run the demo program

3. Drivers installed for particular wheels/joysticks/rumble pads. For
example if using Logitech wheels/joysticks/rumble pads make sure the
latest Gaming Software is installed
(http://www.logitech.com/index.cfm/support_downloads/&cl=us,en).


Testing setup
--------------------------------------------------------------------------

Devices used

Logitech gamepads
- Cordless Rumblepad™ 2
- Rumblepad™ 2 Vibration Feedback Gamepad
- Dual Action™ Gamepad
- Precision™ Gamepad 2

Logitech wheels
- MOMO® Racing
- Formula™ Force GP
- NASCAR® Racing Wheel
- Formula™ GP
- Driving Force Pro
- G25
- G27

Logitech joysticks
- Force™ 3D Pro
- Freedom 2.4™ Cordless Joystick
- Force™ 3D
- Extreme™ 3D Pro
- Attack™ 3 Joystick

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

For a demo program to see how controls get assigned (you may plug in
multiple controllers):

Launch ControlsAssignmentSDKDemo.exe.

Or:

1. Open up project in ControlsAssignment/Samples/ControlsAssignmentSDKDemo.

2. Compile and run

3. Plug in one or multiple PC wheel, joystick, gamepad or other game
   controllers at any time

4. Read instructions at top of program's window


To implement game controller support in your game:

1. Copy all the source files in the ControlsAssignment/Src folder to
   your game.

2. To use the Controller Input SDK, copy all the source files in the
   ControllerInput/Src folder to your game.

3. Read and follow ControlsAssignment/Doc/SampleInGameImplementation.cpp

4. Check method details in ControlsAssignment/Doc/api.html and
   ControllerInput/Doc/api.html


For questions/problems/suggestions send email to:
cj@wingmanteam.com
roland@wingmanteam.com


End-User License Agreement for Logitech Controls Assignment SDK
Agreement

This End-User License Agreement for Logitech Controls Assignment SDK
Agreement ( "Agreement") is a legal agreement between you, either an
individual or legal entity ("You" or "you") and Logitech
Inc. ("Logitech") for the pre-release alpha test version of the
Logitech Controls Assignment software development kit, which includes
computer software and related media and documentation (hereinafter
"Controls Assignment SDK"). By installing, copying or otherwise using the
Controls Assignment SDK, you agree to be bound by the terms of this
Agreement.  If you do not agree to the terms of this Agreement, do not
install or use the Controls Assignment SDK.


1 Grant of License and Restrictions. Logitech grants You a limited,
  non-exclusive, nontransferable license to install and use an
  unlimited number of copies of the Controls Assignment SDK on
  computers for any purpose.  All other rights are reserved to
  Logitech.

2 Intellectual Property Rights. The Controls Assignment SDK is
  licensed, not sold, to You for use only under the terms and
  conditions of this Agreement.  Logitech and its suppliers retain
  title to the Controls Assignment SDK and all intellectual property
  rights therein.  The Controls Assignment SDK is protected by
  intellectual property laws and international treaties, including
  U.S. copyright law and international copyright treaties.  All rights
  not expressly granted by Logitech are reserved.

3 Disclaimer of Warranty. TO THE MAXIMUM EXTENT PERMITTED BY
  APPLICABLE LAW, LOGITECH AND ITS SUPPLIERS PROVIDE THE CONTROLLER
  INPUT SDK AND OTHER LOGITECH PRODUCTS AND SERVICES (IF ANY) AS IS
  AND WITHOUT WARRANTY OF ANY KIND.  LOGITECH AND ITS SUPPLIERS
  EXPRESSLY DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING,
  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD-PARTY
  RIGHTS WITH RESPECT TO THE CONTROLS ASSIGNMENT SDK AND ANY
  WARRANTIES OF NON-INTERFERENCE OR ACCURACY OF INFORMATIONAL CONTENT.
  NO LOGITECH DEALER, AGENT, OR EMPLOYEE IS AUTHORIZED TO MAKE ANY
  MODIFICATION, EXTENSION, OR ADDITION TO THIS WARRANTY.  Some
  jurisdictions do not allow limitations on how long an implied
  warranty lasts, so the above limitation may not apply to you.

4 Limitation of Liability.  IN NO EVENT WILL LOGITECH OR ITS SUPPLIERS
  BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTE PRODUCTS OR
  SERVICES, LOST PROFITS, LOSS OF INFORMATION OR DATA, OR ANY OTHER
  SPECIAL, INDIRECT, CONSEQUENTIAL, OR INCIDENTAL DAMAGES ARISING IN
  ANY WAY OUT OF THE SALE OF, USE OF, OR INABILITY TO USE THE CONTROLS
  ASSIGNMENT SDK OR ANY LOGITECH PRODUCT OR SERVICE, EVEN IF LOGITECH
  HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. IN NO CASE
  SHALL LOGITECH'S AND ITS SUPPLIERS' TOTAL LIABILITY EXCEED THE
  ACTUAL MONEY PAID FOR THE LOGITECH PRODUCT OR SERVICE GIVING RISE TO
  THE LIABILITY.  Some jurisdictions do not allow the exclusion or
  limitation of incidental or consequential damages, so the above
  limitation or exclusion may not apply to you.  The above limitations
  will not apply in case of personal injury where and to the extent
  that applicable law requires such liability.
