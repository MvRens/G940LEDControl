Logitech Steering Wheel SDK for PC
Copyright (C) 2009 Logitech Inc. All Rights Reserved


Introduction
--------------------------------------------------------------------------

This package is aimed at driving games and enables to quickly and
easily make a complete implementation for reading input data, doing
force feedback, and getting/setting wheel properties.


Contents of the package
--------------------------------------------------------------------------

- Logitech Steering Wheel SDK Source Files
- Documentation
- Demo program
- Sample in-game implementation program file


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
------------------------------

Devices used

Logitech
- G27
- G25
- Driving Force Pro
- MOMO Force
- MOMO Racing
- Formula Force GP
- Driving Force
- Formula Force
- Force 3D
- Strike Force 3D
- Freedom 2.4 Cordless Joystick
- Cordless Rumblepad
- Cordless Rumblepad 2
- Rumblepad

Microsoft
- Sidewinder Force Feedback 2 (Stick)
- Sidewinder Force (Wheel)

Other (Immersion drivers)
- Saitek Cyborg 3D Force
- Act-Labs Force RS Wheel

Operating Systems
- Windows XP, Vista

DirectX versions
- 9.0c

Driver versions
- Logitech Gaming Software 5.04 or later


Disclaimer
--------------------------------------------------------------------------
This is work in progress. If you find anything wrong with either
documentation or code, please let us know so we can improve on it.


Where to start
--------------------------------------------------------------------------

For a demo program to see what some forces do:

Launch SteeringWheelSDKDemo.exe.

Or:

1. Open up project in SteeringWheel/Samples/SteeringWheelSDKDemo.

2. Compile and run

3. Plug in one or multiple PC wheel, joystick, gamepad or other game
   controllers at any time.

4. Read instructions at top of program's window


To implement game controller support in your game:

1. Copy all the source files in the SteeringWheel/Src folder to
   your game.

2. To use the Controller Input SDK, copy all the source files in the
   ControllerInput/Src folder to your game.

3. Read and follow SteeringWheel/Doc/SampleInGameImplementation.cpp

4. Check method details in SteeringWheel/Doc/api.html and
   ControllerInput/Doc/api.html


For questions/problems/suggestions send email to:
cj@wingmanteam.com
roland@wingmanteam.com


End-User License Agreement for Logitech Steering Wheel SDK Agreement

This End-User License Agreement for Logitech Steering Wheel SDK
Agreement ( "Agreement") is a legal agreement between you, either an
individual or legal entity ("You" or "you") and Logitech
Inc. ("Logitech") for the pre-release alpha test version of the
Logitech Steering Wheel software development kit, which includes
computer software and related media and documentation (hereinafter
"Steering Wheel SDK"). By installing, copying or otherwise using the
Steering Wheel SDK, you agree to be bound by the terms of this
Agreement.  If you do not agree to the terms of this Agreement, do not
install or use the Steering Wheel SDK.


1 Grant of License and Restrictions. Logitech grants You a limited,
  non-exclusive, nontransferable license to install and use an
  unlimited number of copies of the Steering Wheel SDK on computers
  for any purpose.  All other rights are reserved to Logitech.

2 Intellectual Property Rights. The Steering Wheel SDK is licensed,
  not sold, to You for use only under the terms and conditions of this
  Agreement.  Logitech and its suppliers retain title to the Steering
  Wheel SDK and all intellectual property rights therein.  The
  Steering Wheel SDK is protected by intellectual property laws and
  international treaties, including U.S. copyright law and
  international copyright treaties.  All rights not expressly granted
  by Logitech are reserved.

3 Disclaimer of Warranty. TO THE MAXIMUM EXTENT PERMITTED BY
  APPLICABLE LAW, LOGITECH AND ITS SUPPLIERS PROVIDE THE CONTROLLER
  INPUT SDK AND OTHER LOGITECH PRODUCTS AND SERVICES (IF ANY) AS IS
  AND WITHOUT WARRANTY OF ANY KIND.  LOGITECH AND ITS SUPPLIERS
  EXPRESSLY DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING,
  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD-PARTY
  RIGHTS WITH RESPECT TO THE STEERING WHEEL SDK AND ANY WARRANTIES OF
  NON-INTERFERENCE OR ACCURACY OF INFORMATIONAL CONTENT.  NO LOGITECH
  DEALER, AGENT, OR EMPLOYEE IS AUTHORIZED TO MAKE ANY MODIFICATION,
  EXTENSION, OR ADDITION TO THIS WARRANTY.  Some jurisdictions do not
  allow limitations on how long an implied warranty lasts, so the
  above limitation may not apply to you.

4 Limitation of Liability.  IN NO EVENT WILL LOGITECH OR ITS SUPPLIERS
  BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTE PRODUCTS OR
  SERVICES, LOST PROFITS, LOSS OF INFORMATION OR DATA, OR ANY OTHER
  SPECIAL, INDIRECT, CONSEQUENTIAL, OR INCIDENTAL DAMAGES ARISING IN
  ANY WAY OUT OF THE SALE OF, USE OF, OR INABILITY TO USE THE STEERING
  WHEEL SDK OR ANY LOGITECH PRODUCT OR SERVICE, EVEN IF LOGITECH HAS
  BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. IN NO CASE SHALL
  LOGITECH'S AND ITS SUPPLIERS' TOTAL LIABILITY EXCEED THE ACTUAL
  MONEY PAID FOR THE LOGITECH PRODUCT OR SERVICE GIVING RISE TO THE
  LIABILITY.  Some jurisdictions do not allow the exclusion or
  limitation of incidental or consequential damages, so the above
  limitation or exclusion may not apply to you.  The above limitations
  will not apply in case of personal injury where and to the extent
  that applicable law requires such liability.
