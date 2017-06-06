Scripting reference
===================

G940LEDControl uses Lua 5.2. Please refer to the `Lua 5.2 Reference Manual <https://www.lua.org/manual/5.2/>`_ for more information.

.. contents::
  :local:

Global functions
----------------

.. _ref-log:

Log functions
~~~~~~~~~~~~~

::

  Log.Verbose(msg, ...)
  Log.Info(msg, ...)
  Log.Warning(msg, ...)
  Log.Error(msg, ...)

Writes a message to the application log. If you pass more than one parameter, they will be concatenated in the log message separated by spaces. The parameters do not need to be strings, other simple types will be converted and tables will be output as '{ key = value, ... }'.

The application log can be opened on the Configuration tab of the main screen.

.. _ref-registerfunction:

RegisterFunction
~~~~~~~~~~~~~~~~
::

  RegisterFunction(info, setupCallback)

Registers a button function.

**Parameters**

| **info**: table
| A Lua table describing the function. The following keys are recognized:
|
|   **uid**: string
|   *Required.* A unique ID for this function. Used to save and load profiles.
|
|   **category**: string
|   The category under which this function is grouped in the button function selection screen.
|
|   **displayName**: string
|   The name of the function which is shown in the main screen and button function selection screen.
|
|   **states**: table
|   A table of states supported by this function.
|   Each state has it's own unique key and a table describing the state. The following keys are recognized for the table:
|
|     **displayName**: string
|     The name of the state which is shown in the button function selection screen.
|
|     **default**: string
|     The default color and/or animation assigned to the state when it is first selected. See :ref:`ref-ledcolor` for a list of valid values.
|
|     **order**: number (optional)
|     Specifies the order in which the state is shown in the button function selection screen. If not specified, defaults to 0. States with an equal order are sorted alphabetically.
|
| **setupCallback**: function
| A Lua function which is called when the button function is configured. Please note that if a button function is linked to multiple G940 throttle buttons, setupCallback is called multiple times, so be careful with variables which are outside of the setupCallback's scope (global or script-local)!
|
| setupCallback is passed a single parameter 'context'.
|

**Example**
::

  RegisterFunction(
    {
      uid = 'autoPilotAirspeed',
      category = strings.Category.FSX.AutoPilot,
      displayName = 'Autopilot airspeed',
      states = {
        on = { displayName = 'On', default = LEDColor.Green },
        off = { displayName = 'Off', default =  LEDColor.Red },
        notAvailable = { displayName = 'Not available', default = LEDColor.Off }
      }
    },
    function(context)
      -- implementation of setupCallback
    end)

.. _ref-setstate:

SetState
~~~~~~~~
::

  SetState(context, newState)

Sets the current state of a button function.

**Parameters**

| **context**
| The context parameter as passed to setupCallback which determines the button function to be updated.
|
| **newState**: string
| The new state. Must be the name of a state key as passed to :ref:`ref-registerfunction`.
|

**Example**
::

  SetState(context, 'on')


.. _ref-onsimconnect:

OnSimConnect
~~~~~~~~~~~~
::

  OnSimConnect(context, variables, variablesChangedCallback)

Registers a Lua function to be called when the specified SimConnect variable(s) change. For a list of variables please refer to `Simulation variables <https://msdn.microsoft.com/en-us/library/cc526981.aspx>`_.

**Parameters**

| **context**
| The context parameter as passed to setupCallback.
|
| **variables**: table
| A table containing information about the simulation variables you want to monitor. Each key will be reflected in the 'data' table passed to the variablesChangedCallback. Each value is a Lua table describing the variable.
|
|   **variable**: string
|   The name of the variable as described in `Simulation variables <https://msdn.microsoft.com/en-us/library/cc526981.aspx>`_.
|
|   **type**: string
|   One of the :ref:`ref-simconnectdatatype` values.
|
|   **units**: string
|   If relevant to the variable, one of the `Units of Measurement <https://msdn.microsoft.com/en-us/library/cc526981.aspx#UnitsofMeasurement>`_ supported by SimConnect. For example, 'percent'. If type is SimConnectDataType.Bool, this will be automatically set to 'bool'.
|
| **variablesChangedCallback**: function
| A Lua function which is called when the variable's value changes. It receives 2 parameters: 'context' and 'data'. The data parameter is a Lua table where each key corresponds to a variable defined in the 'variables' parameter and it's value is the current value of the simulation variable.
|

**Example**

::

  OnSimConnect(context,
    {
      autoPilotAvailable = { variable = 'AUTOPILOT AVAILABLE', type = SimConnectDataType.Bool },
      autoPilotAirspeed = { variable = 'AUTOPILOT AIRSPEED HOLD', type = SimConnectDataType.Bool }
    },
    function(context, data)
      if data.autoPilotAvailable then
        if data.autoPilotAirspeed then
          SetState(context, 'on')
        else
          SetState(context, 'off')
        end
      else
        SetState(context, 'notAvailable')
      end
    end)


.. _ref-ontimer:

OnTimer
~~~~~~~
::

  OnTimer(context, interval, timerCallback)

Registers a Lua function to be called when the specified interval elapses.

**Parameters**

| **context**
| The context parameter as passed to setupCallback.
|
| **interval**
| The interval between calls to timerCallback in milliseconds. At the time of writing the minimum value is 100 milliseconds.
|
| **timerCallback**
| A Lua function which is called when the interval elapses. It is passed a single parameter 'context'.
|

**Example**

::

  OnTimer(context, 1000,
    function(context)
      if FSXWindowVisible('ATC Menu') then
        SetState(context, 'visible')
      else
        SetState(context, 'hidden')
      end
    end)



.. _ref-windowvisible:

WindowVisible
~~~~~~~~~~~~~

Checks if a window is currently visible. This is a thin wrapper around the FindWindow/FindWindowEx/IsWindowVisible Windows API. In the context of FSX panels you are probably looking for :ref:`ref-fsxwindowvisible`.

All parameters are optional, but at least one parameter is required. To skip a parameter simply pass nil instead.

To get a window's class name, use a tool like `Greatis Windowse <https://www.greatis.com/delphicb/windowse/>`_.

**Parameters**

| **className**
| The window class name of the window
|
| **title**
| The title / caption / text of the window
|
| **parentClassName**
| The parent window's class name. If specified, the first two parameters are considered to be a child window of this parent.
|
| **parentTitle**
| The parent window's title / caption / text. If specified, the first two parameters are considered to be a child window of this parent.
|

.. _ref-fsxwindowvisible:

FSXWindowVisible
~~~~~~~~~~~~~~~~

Checks if an FSX window is currently visible. Uses WindowVisible as a workaround because SimConnect does not expose this information directly.

**Parameters**

| **title**
| The title of the panel.
|

Checks for both docked and undocked windows. Equal to:

::

  WindowVisible('FS98CHILD', title, 'FS98MAIN') or WindowVisible('FS98FLOAT', title)



Global variables
----------------

.. _ref-ledcolor:

LEDColor
~~~~~~~~

**Keys**

- Off
- Green
- Amber
- Red
- FlashingGreenFast
- FlashingGreenNormal
- FlashingAmberFast
- FlashingAmberNormal
- FlashingRedFast
- FlashingRedNormal

The 'Fast' flashing versions stay on and off for half a second, the 'Normal' version for 1 second.

**Example**

::

  { default = LEDColor.Green }


.. _ref-simconnectdatatype:

SimConnectDataType
~~~~~~~~~~~~~~~~~~

**Keys**

- Float64
- Float32
- Int64
- Int32
- String
- Bool
- XYZ
- LatLonAlt
- Waypoint

The XYZ, LatLonAlt and Waypoint data types will return a table in the 'data' parameter for the OnSimConnect callback with the following keys:

**XYZ**

- X
- Y
- Z

**LatLonAlt**

- Latitude
- Longitude
- Altitude

**Waypoint**

- Latitude
- Longitude
- Altitude
- KtsSpeed
- PercentThrottle
- Flags

The Flags value is a table containing the following keys, where each is a boolean:

- SpeedRequested
- ThrottleRequested
- ComputeVerticalSpeed
- IsAGL
- OnGround
- Reverse
- WrapToFirst