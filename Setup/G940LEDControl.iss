#define AppName "G940 LED Control"
#define AppExeName "G940LEDControl.exe"
#define AppVersion GetFileVersion("..\G940LEDControl\Bin\" + AppExeName)
#define AppPublisher "X²Software"
#define AppURL "http://g940.x2software.net/"

[Setup]
AppId={{704baf93-d22e-471b-bdcf-d21d82d73398}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
;LicenseFile=..\license.txt
OutputDir=output
OutputBaseFilename=G940LEDControlSetup-{#AppVersion}
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\G940LEDControl\Bin\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\G940LEDControl\Bin\LogiJoystickDLL.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\G940LEDControl\Bin\FSX-SimConnect.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\G940LEDControl\Bin\FSX-SE-SimConnect.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\G940LEDControl\Scripts\*.lua"; DestDir: "{app}\Scripts"; Flags: ignoreversion recursesubdirs

[Dirs]
Name: "{userappdata}\G940LEDControl\Scripts\FSX"

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

