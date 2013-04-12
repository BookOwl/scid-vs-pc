
#define AppVersion '4.9'
#define AppName    'Scid vs PC'
#define ActiveTclUrl 'http://www.activestate.com/activetcl/downloads'



[Setup]
AppName={# AppName}
AppVerName={# AppName} {# AppVersion}
AppVersion={# AppVersion}
AppPublisher=Steven Atkinson
AppPublisherURL=http://http://scidvspc.sourceforge.net
AppCopyright=Steven Atkinson (C) 2009 - 2013  Steven Atkinson
DefaultDirName={pf}\{# AppName}-{# AppVersion}
DefaultGroupName={# AppName}
DisableStartupPrompt=yes
WindowShowCaption=yes
WindowVisible=no

LicenseFile=COPYING.txt

Compression=bzip/9
SourceDir=.
OutputDir=.
OutputBaseFilename={# AppName}-{# AppVersion}
ChangesAssociations=yes

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"
Name: associate_pgn; Description: "&Associate PGN files"; GroupDescription: "Other tasks:";
Name: associate_si4; Description: "&Associate SI4 files"; GroupDescription: "Other tasks:";


[Registry]
Root: HKCR; Subkey: ".pgn"; ValueType: string; ValueName: ""; ValueData: "PGN"; Flags: uninsdeletevalue; Tasks: "associate_pgn"
Root: HKCR; Subkey: "PGN"; ValueType: string; ValueName: ""; ValueData: "Portable Game Notation"; Flags: uninsdeletekey; Tasks: "associate_pgn"
Root: HKCR; Subkey: "PGN\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\bin\scid.exe,0"; Tasks: "associate_pgn"
Root: HKCR; Subkey: "PGN\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\bin\scid"" ""%1"""; Tasks: "associate_pgn"
  
Root: HKCR; Subkey: ".si4"; ValueType: string; ValueName: ""; ValueData: "si4"; Flags: uninsdeletevalue; Tasks: "associate_si4"
Root: HKCR; Subkey: "si4"; ValueType: string; ValueName: ""; ValueData: "Scid database"; Flags: uninsdeletekey; Tasks: "associate_si4"
Root: HKCR; Subkey: "si4\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\bin\scid.exe,0"; Tasks: "associate_si4"
Root: HKCR; Subkey: "si4\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\bin\scid"" ""%1""" ; Tasks: "associate_si4" 

[Files]
Source: "bin\*";  DestDir: "{app}\bin"; CopyMode: normal; Flags: recursesubdirs
Source: "lib\*"; DestDir: "{app}\lib";  CopyMode: normal; Flags: recursesubdirs
Source: "doc\*"; DestDir: "{app}\doc";  CopyMode: normal; Flags: recursesubdirs
Source: "COPYING.txt"; DestDir: "{app}";  CopyMode: normal; Flags: recursesubdirs
Source: "README_ScidvsPC.txt"; DestDir: "{app}";  CopyMode: normal; Flags: recursesubdirs
Source: "README_ScidvsPC.htm"; DestDir: "{app}";  CopyMode: normal; Flags: recursesubdirs
Source: "images\*"; DestDir: "{app}\images";  CopyMode: normal; Flags: recursesubdirs



[Icons]
Name: "{group}\{# AppName}"; Filename: "{app}\bin\scid.exe"; Comment: "{# AppName}!"; WorkingDir: {app}\bin
Name: "{group}\Uninstall {# AppName}"; Filename: "{uninstallexe}";
Name: "{userdesktop}\{# AppName}"; Filename: "{app}\bin\scid.exe"; Tasks: desktopicon; Comment: "Desktop {# AppName}!"; WorkingDir: {app}\bin


[Code]

procedure URLLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', '{# ActiveTclUrl}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure CreateTheWizardPage;
var
  Page: TWizardPage;
  Line1, Line2: TNewStaticText;
     URLLabel: TNewStaticText;
     
begin

  Page := CreateCustomPage(wpSelectComponents, 'Active Tcl', 'Active Tcl');


  Line1 := TNewStaticText.Create(Page);
  Line1.Top :=  ScaleY(8);
  Line1.Caption := 'Optionally, ActiveTcl may also be installed.';
  
  Line1.AutoSize := True;
  Line1.Parent := Page.Surface;
  
    Line2 := TNewStaticText.Create(Page);
  Line2.Top :=  Line1.Top + Line1.Height + ScaleY(8);
  Line2.Caption := 'You can get it free from ';
  Line2.AutoSize := True;
  Line2.Parent := Page.Surface;

  URLLabel := TNewStaticText.Create(Page);
  URLLabel.Caption := '{# ActiveTclUrl}';
  URLLabel.Cursor := crHand;
  URLLabel.OnClick := @URLLabelOnClick;
  URLLabel.Parent := Page.Surface;
  
  URLLabel.Font.Style := URLLabel.Font.Style + [fsUnderline];
  URLLabel.Font.Color := clBlue;
  URLLabel.Top := Line2.Top;
  URLLabel.Left := Line2.Left + Line2.Width + ScaleX(1);

end;



var
  tclPage: TOutputMsgWizardPage;

procedure InitializeWizard();
begin
CreateTheWizardPage;

end;










