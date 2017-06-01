Introduction
============

G940LEDControl allows you to bind functions to the throttle's buttons which control the LEDs. Each function may contains several states, each of which can be configured for a certain colour and/of flashing pattern.

Since version 2.0 all functions are implemented using Lua scripts. This means it is fairly easy to create customized versions of the standard functions, or even add a completely new function. For more information, see the page on :doc:`scripting`.

Source code
-----------

Since version 2.0, G940LEDControl is released as open-source under the GNU General Public License v3.0. The main Git repository is located at `<https://git.x2software.net/delphi/g940ledcontrol>`_ with a clone being kept up to date at `<https://github.com/PsychoMark/G940LEDControl>`_.

G940LEDControl is compiled using Delphi XE2. The following additional libraries are required:

* `X2Log <https://git.x2software.net/delphi/x2log>`_
* `X2Utils <https://git.x2software.net/delphi/x2utils>`_
* ToDo: any more?

A copy of `DelphiLua <https://git.x2software.net/delphi/delphilua>`_ is already included in the G940LEDControl repository.