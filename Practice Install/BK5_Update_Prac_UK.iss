[Setup]
;--------------------------------------------------------------
;   UK Practice Update Setup file
;--------------------------------------------------------------
#Include "Bin\BankLinkPracticeUpdate.txt"
#include "Bin\BankLinkCopyRight.txt"
DefaultDirName={sd}\BK5
DisableStartupPrompt=yes
LicenseFile=Bin\BK5_EULA.RTF
MinVersion=4.1,5
Uninstallable=no
OutputDir=..\Binaries\Prac_Update_UK
OutputBaseFilename=setup_update_uk
Compression=lzma
SolidCompression=yes
DirExistsWarning=false
AppendDefaultDirName=no
InfoBeforeFile=Practice CD Files\infoPRAC.txt

[Files]
;*Application files*
Source: "..\Binaries\BK5WIN.EXE"; DestDir: "{app}"
Source: "..\Binaries\bkLookup.dll"; DestDir: "{app}"
Source: "..\Binaries\BKHandler\bkHandlerSetup.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Binaries\bkmap.exe"; DestDir: "{app}"

Source: "Bin\bkExtMapi.dll"; DestDir: "{app}"
Source: "Bin\BK5WIN.EXE.Manifest"; DestDir: "{app}"
Source: "Bin\bkinstall.exe"; DestDir: "{app}"
Source: "Bin\bkupgcor.dll"; DestDir: "{app}"

Source: "Fixes\bkNetHelpFix.exe"; DestDir: "{app}"

;*Help*
Source: "Practice Help\guide_uk.chm"; DestDir: "{app}"; DestName: "guide.chm"

;*Mail Merge*
Source: "Mail Merge\BKDataSource.csv"; DestDir: "{app}"
Source: "Mail Merge\BKPrintMerge.doc"; DestDir: "{app}"
Source: "Mail Merge\BKEmailMerge.doc"; DestDir: "{app}"

;*3rd party components*
Source: "3rd Party\ipwssl6.dll"; DestDir: "{app}"
;PDF
Source: "3rd Party\wPDF200a.DLL"; DestDir: "{app}"
Source: "3rd Party\wPDFView01.DLL"; DestDir: "{app}"
Source: "3rd Party\BKCASYS.EXE"; DestDir: "{app}"
;Acclipse
Source: "3rd Party\Expat_License.txt"; DestDir: "{app}"
Source: "3rd Party\WDDX_License.html"; DestDir: "{app}"
Source: "3rd Party\wddx_com.dll"; DestDir: "{app}"
Source: "3rd Party\xmlparse.dll"; DestDir: "{app}"
Source: "3rd Party\xmltok.dll"; DestDir: "{app}"

;Source: "AuthorityForms\Client Authority Form.pdf"; DestDir: "{app}"

Source: "AuthorityForms\UK_CAF_Template.pdf"; DestDir: "{app}\TEMPLATE"
Source: "AuthorityForms\UK_HSBC_Template.pdf"; DestDir: "{app}\TEMPLATE"

[Run]
Filename: "{app}\BK5WIN.EXE"; Description : "Start BankLink Practice"; WorkingDir: "{app}"; Flags: postinstall nowait;

[Registry]
Root: HKCU; Subkey: "Software\BankLink"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\BankLink\"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not FileExists(ExpandConstant('{app}') + '\BK5WIN.exe') then
    begin
      MsgBox('A previous version of BankLink Practice must exist in the install folder for the upgrade to complete successfully.' + #13#13 + 'Please change the installation folder to your current BankLink Practice folder.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
