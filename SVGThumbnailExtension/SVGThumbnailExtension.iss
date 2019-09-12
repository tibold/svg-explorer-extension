[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{4CA20D9A-98AC-4DD6-9C16-7449F29AC08A}
AppMutex=dotz_softwares__svg_explorer_extension
AppName="SVG Explorer Extension"
AppVersion="0.1.1"
AppVerName="SVG Explorer Extension 0.1.1"
AppPublisher="Dotz Softwares"
AppPublisherURL=http://www.dotzdev.com/
AppSupportURL=http://www.dotzdev.com/
AppUpdatesURL=http://www.dotzdev.com/
DefaultDirName="{pf}\Dotz Softwares\SVG Explorer Extension"
DefaultGroupName="SVG Explorer Extension"
OutputDir=..\installer
OutputBaseFilename="dssee_setup_i386"
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"; LicenseFile: "license.txt"

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "x86\release\msvcr90.dll"; DestDir: "{app}";
Source: "x86\release\msvcp90.dll"; DestDir: "{app}";
Source: "x86\release\msvcr100.dll"; DestDir: "{app}";
Source: "x86\release\QtCore4.dll"; DestDir: "{app}";
Source: "x86\release\QtGui4.dll"; DestDir: "{app}"; 
Source: "x86\release\QtSvg4.dll"; DestDir: "{app}";
Source: "..\SVGThumbnailExtension-build-x86_Release\release\SVGThumbnailExtension.dll"; DestDir: "{app}"; Flags: regserver         
; Licenses
; FIXME: the qt license should not be stored in this repository but be copied from the qt distribution
Source: "license\Qt.txt"; DestDir: "{app}\license\";
Source: "../LICENSE.md"; DestDir: "{app}\license\";

[Code]

// Automatically uninstalls the previously installed version if any
// IMPORTANT NOTE: The AppId is hardcoded below, since ExpandConstant did not want to substitute it!
Procedure CurStepChanged(CurStep: TSetupStep);
Var
  ResultCode: Integer;
  Uninstaller: String;
Begin
  If (CurStep = ssInstall) Then Begin
    If RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{4CA20D9A-98AC-4DD6-9C16-7449F29AC08A}_is1', 'UninstallString', Uninstaller) Then Begin
      // MsgBox('Your previously installed version will be uninstalled first.', mbInformation, MB_OK);
      Exec(RemoveQuotes(Uninstaller), ' /SILENT', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
    End;
  End;
End;
