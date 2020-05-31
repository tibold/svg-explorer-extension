#ifndef arch
; Default to x64 if nothing was defined.
#define arch 'x64'
#endif
[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{4CA20D9A-98AC-4DD6-9C16-7449F29AC08A}
AppMutex=github_tibold_svg_explorer_extension
AppName="SVG See"
AppVersion="1.0.0"
AppVerName="SVG See 1.1.0"
AppPublisher="Tibold Kandrai"
AppPublisherURL=https://tibold.kandrai.rocks/
AppSupportURL=https://github.com/tibold/svg-explorer-extension/issues
AppUpdatesURL=https://github.com/tibold/svg-explorer-extension/releases
DefaultGroupName="SvgSee"
OutputDir=..\var\installer
OutputBaseFilename="svg_see_{#arch}"
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes
; This is to support both IS 5 and 6
#if arch == 'x64'
#ifdef commonpf64
DefaultDirName="{commonpf64}\SvgSee"
#else
DefaultDirName="{pf64}\SvgSee"
#endif
#else
#ifdef commonpf32
DefaultDirName="{commonpf32}\SvgSee"
#else
DefaultDirName="{pf32}\SvgSee"
#endif
#endif

#if arch == "x64"
ArchitecturesInstallIn64BitMode=x64
#else
ArchitecturesInstallIn64BitMode=
#endif

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"; LicenseFile: "..\LICENSE.md"

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "..\var\dist\{#arch}\release\*"; DestDir: "{app}"; Flags: recursesubdirs                   
Source: "..\var\dist\{#arch}\release\SvgSee.dll"; DestDir: "{app}"; Flags: regserver           
; Licenses
; FIXME: the qt license should not be stored in this repository but be copied from the qt distribution
Source: "..\var\licenses\Qt.txt"; DestDir: "{app}\license\";
Source: "..\LICENSE.md"; DestDir: "{app}\license\";

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
      //MsgBox('Your previously installed version will be uninstalled first.', mbInformation, MB_OK);
      Exec(RemoveQuotes(Uninstaller), ' /SILENT', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
    End;
    ExtractTemporaryFile(ExpandConstant('vc_redist.{#arch}.exe'));
    Exec(ExpandConstant('{tmp}\vc_redist.{#arch}.exe'), '/install /passive /norestart', '', SW_SHOWNORMAL, ewWaitUntilTerminated,ResultCode);
  End;
End;
