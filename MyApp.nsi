!include "LogicLib.nsh"
    
;Include Modern UI
!include "MUI2.nsh"
!include "Sections.nsh"

!define MAJOR_VERSION "1" 
!define MINOR_VERSION "2" 
!define PATCH_VERSION "3" 
!define BUILD_VERSION "4" 
    
!define APP_COPYRIGHT "MyApp © MyCompany 2021"
!define COMPANY_NAME "MyCompany"
!define FLEX_LM "FlexLM"        
!define FLEX_DIR "FlexSQI"            
!define PRODUCT_NAME "MyApp"
!define PRODUCT_VERSION "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}.${BUILD_VERSION}"
!define SETUP_NAME "MyAppSetup.exe"

BrandingText "${COMPANY_NAME}"

OutFile ${SETUP_NAME}
Icon "favicon.ico"
UninstallIcon "favicon.ico"
!define MUI_ICON "favicon.ico"
!define MUI_UNICON "favicon.ico"
Name "${PRODUCT_NAME}"

InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}\"
InstallDirRegKey HKLM "Software\$PRODUCT_NAME" ""
ShowInstDetails hide
ShowUnInstDetails hide

SetCompressor /SOLID lzma
SetCompressorDictSize 12

;Request application privileges for Windows 
RequestExecutionLevel admin

!macro WriteSignedUninstaller Destination
!makensis '"/DGENRATINGUNINST=$%TEMP%\Uninst.exe" "${__FILE__}" "/XOutfile `$%TEMP%\tempinstaller.exe`"' = 0 ; Create fake installer
!system 'set __COMPAT_LAYER=RunAsInvoker&"$%TEMP%\tempinstaller.exe"' = 2 ; Run fake installer to generate the uninstaller
!system 'SIGNTOOL sign /f CodeSigningCertificate/MyCompany.pfx /p Test /tr http://timestamp.digicert.com /td SHA256 "$%TEMP%\Uninst.exe"' = 0 ; Change this line. As a demonstration, use !system 'echo Dummy >> "$%TEMP%\Uninst.exe"'
File "/oname=${Destination}" "$%TEMP%\Uninst.exe"
!macroend

!macro DeclareLanguages
	# Define languages that the installer has
	!insertmacro MUI_LANGUAGE "English"
!macroend

!ifndef GENRATINGUNINST
Var MyAppInstallDir
Var FlexLmInstallDir

## Create $PLUGINSDIR 
Function .onInit
  StrCpy $MyAppInstallDir "$PROGRAMFILES64\${PRODUCT_NAME}\"
  StrCpy $FlexLmInstallDir "C:\${FLEX_DIR}\"

  InitPluginsDir

  SetOutPath $TEMP
  File /oname=spltmp.bmp "MyCompany_LandingPage_114.bmp"

  splash::show 2000 $TEMP\spltmp

  Pop $0 ; $0 has '1' if the user closed the splash screen early,
  ; '0' if everything closed normally, and '-1' if some error occurred.

  Delete $TEMP\spltmp.bmp  
FunctionEnd

# Installer:
############
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "MyAppLicense.txt"

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ComponentsLeave
!insertmacro MUI_PAGE_COMPONENTS   
 
## This is the title on the MyApp Directory page
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(MUI_DIRECTORYPAGE_TEXT_TOP_A)"
!define MUI_PAGE_HEADER_TEXT "MyApp Configuration"
!define MUI_PAGE_HEADER_SUBTEXT "Select the folder in which to install MyApp."
!define MUI_PAGE_CUSTOMFUNCTION_PRE onFirstDirPre
!define MUI_DIRECTORYPAGE_VARIABLE $MyAppInstallDir
!insertmacro MUI_PAGE_DIRECTORY

## This is the title on the FlexLM Directory page 
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(MUI_DIRECTORYPAGE_TEXT_TOP_B)"
!define MUI_PAGE_HEADER_TEXT "FlexLM Configuration"
!define MUI_PAGE_HEADER_SUBTEXT "Select the folder in which to install FlexLM."
!define MUI_PAGE_CUSTOMFUNCTION_PRE onLastDirPre
!define MUI_DIRECTORYPAGE_VARIABLE $FlexLmInstallDir
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE DeleteSectionsINI
!insertmacro MUI_PAGE_FINISH
!insertmacro DeclareLanguages

;--------------------------------


LangString MUI_DIRECTORYPAGE_TEXT_TOP_A ${LANG_ENGLiSH} "Setup will install \
${PRODUCT_NAME} in the following folder..."
LangString MUI_DIRECTORYPAGE_TEXT_TOP_B ${LANG_ENGLiSH} "Setup will install \
${FLEX_LM} in the following folder..."


Section App1 SID_APP1
    StrCpy $InstDir $MyAppInstallDir
    SetOutPath $InstDir
	!insertmacro WriteSignedUninstaller "$InstDir\Uninst.exe"

    File MyApp.exe
    File ReleaseNotes.txt
    File MyCompany_LandingPage_114.bmp
    File MyAppLicense.txt  
  
    # create a shortcut named "new shortcut" in the start menu programs directory
    CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}.lnk" "$InstDir\${PRODUCT_NAME}.exe" 

    # Add application to registry  
    ClearErrors
	WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'Contact' "https://www.mycompany.com/contact"
    WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'Company Name' "${COMPANY_NAME}"
	WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'DisplayName' "${PRODUCT_NAME}"
    WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'DisplayVersion' "${PRODUCT_VERSION}"
    WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'AppID' "{A0E84732-E2B2-46E5-8CA2-462B8DF92DCD}"
	WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'HelpLink' "http://www.myproduct.com/MyApp/HelpDocs/index.htm"
	WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'URLInfoAbout' "https://www.mycompany.com/myapp"
	WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'InstallLocation' "$MyAppInstallDir"	
	WriteRegStr HKCU "SOFTWARE\${COMPANY_NAME}" 'Publisher' "${COMPANY_NAME}"
 
    # Add program to Add/Remove programs 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayIcon" "$PROGRAMFILES64\${PRODUCT_NAME}\${PRODUCT_NAME}.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "AppID" "{A0E84732-E2B2-46E5-8CA2-462B8DF92DCD}"				 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayVersion" "${PRODUCT_VERSION}"				 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "InstallLocation" "$INSTDIR"						 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "Publisher" "${COMPANY_NAME}"				 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "UninstallString" "$\"$INSTDIR\Uninst.exe$\""
    ;MessageBox '' "Installing App1 to $InstDir"
SectionEnd

Section /o App2 SID_APP2
    StrCpy $InstDir $FlexLmInstallDir
    SetOutPath $InstDir
    File installs.exe
    File lmdown.exe
	File lmflex.exe
    ; MessageBox '' "Installing App2 to $InstDir"
SectionEnd


Function onFirstDirPre
${IfNot} ${SectionIsSelected} ${SID_APP1}
  Abort ; skip page
${EndIf}
${IfNot} ${SectionIsSelected} ${SID_APP2}
  GetDlgItem $0 $hwndParent 1
  SendMessage $0 ${WM_SETTEXT} "" "STR:$(^InstallBtn)"
${EndIf}
FunctionEnd

Function onLastDirPre
${IfNot} ${SectionIsSelected} ${SID_APP2}
  Abort ; skip page
${EndIf}
FunctionEnd

Function ComponentsLeave
StrCpy $0 0
StrCpy $1 ""
loop:
    ClearErrors
    SectionGetText $0 $2
    IfErrors end
    ${If} ${SectionIsSelected} $0
    ${AndIf} $2 != ""
        StrCpy $1 1
    ${EndIf}
    IntOp $0 $0 + 1
    Goto loop
end:
${If} $1 == ""
  MessageBox mb_iconstop "You haven't selected any sections!"
  Abort ; stay on page
${EndIf}
FunctionEnd

## Here we are deleting the temp INI file at the end of installation
Function DeleteSectionsINI
  FlushINI "$INSTDIR\Sections.ini"
  Delete "$INSTDIR\Sections.ini"

  Delete $MyAppInstallDir\MyCompany_LandingPage_114.bmp
FunctionEnd

!else
# Uninstaller:
##############
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro DeclareLanguages

!verbose push 2
SilentInstall Silent
Section
WriteUninstaller "${GENRATINGUNINST}"
Quit
SectionEnd
!verbose pop

Section -Uninstall
  # now delete installed files and registry keys for MyApp
  ReadRegStr $0 HKCU "SOFTWARE\${COMPANY_NAME}" "InstallLocation"
  ;MessageBox MB_OK 'Uninstall InstallLocation = $0'
  Delete $0\config.dat
  Delete $0\MyApp.exe
  Delete $0\ReleaseNotes.txt  
  Delete $0\MyCompany_LandingPage_114.bmp
  Delete $0\MyAppLicense.txt
  Delete "$SMPROGRAMS\MyApp.lnk"
  DeleteRegKey HKCU "SOFTWARE\${COMPANY_NAME}\${PRODUCT_NAME}"  
  DeleteRegKey HKCU "SOFTWARE\${COMPANY_NAME}"    
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
  DeleteRegKey /ifempty HKCU "Software\Modern UI Test" 

  # Final cleanup 
  Delete "$InstDir\Uninst.exe"
  RMDir $0
  RMDir "$InstDir"
SectionEnd

!endif

