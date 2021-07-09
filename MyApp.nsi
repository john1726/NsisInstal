!include "LogicLib.nsh"
!include "Sections.nsh"
    
;Include Modern UI
!include "MUI2.nsh"

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

# Installer:
############
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "MyAppLicense.txt"

!define MUI_PAGE_CUSTOMFUNCTION_PRE SelectFilesCheck
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ComponentsLeave
!insertmacro MUI_PAGE_COMPONENTS   
 
## This is the title on the MyApp Directory page
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(MUI_DIRECTORYPAGE_TEXT_TOP_A)"
!define MUI_PAGE_HEADER_TEXT "MyApp Configuration"
!define MUI_PAGE_HEADER_SUBTEXT "Select the folder in which to install MyApp."
 
!define MUI_PAGE_CUSTOMFUNCTION_PRE SelectFilesA
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
 
## This is the title on the FlexLM Directory page
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(MUI_DIRECTORYPAGE_TEXT_TOP_B)"
!define MUI_PAGE_HEADER_TEXT "FlexLM Configuration"
!define MUI_PAGE_HEADER_SUBTEXT "Select the folder in which to install FlexLM."
 
!define MUI_PAGE_CUSTOMFUNCTION_PRE SelectFilesB
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE DeleteSectionsINI
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro DeclareLanguages

;--------------------------------

LangString NoSectionsSelected ${LANG_ENGLSH} "You haven't selected any sections!"

LangString MUI_DIRECTORYPAGE_TEXT_TOP_A ${LANG_ENGLSH} "Setup will install \
${PRODUCT_NAME} in the following folder..."
LangString MUI_DIRECTORYPAGE_TEXT_TOP_B ${LANG_ENGLSH} "Setup will install \
${FLEX_LM} in the following folder..."

;--------------------------------
; Function
; StrContains
; This function does a case sensitive searches for an occurrence of a substring in a string. 
; It returns the substring if it is found. 
; Otherwise it returns null(""). 
; Written by kenglish_hi
; Adapted from StrReplace written by dandaman32
 
 
Var STR_HAYSTACK
Var STR_NEEDLE
Var STR_CONTAINS_VAR_1
Var STR_CONTAINS_VAR_2
Var STR_CONTAINS_VAR_3
Var STR_CONTAINS_VAR_4
Var STR_RETURN_VAR
 
Function StrContains
  Exch $STR_NEEDLE
  Exch 1
  Exch $STR_HAYSTACK
  ; Uncomment to debug
  ;MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
    StrCpy $STR_RETURN_VAR ""
    StrCpy $STR_CONTAINS_VAR_1 -1
    StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
    StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
    loop:
      IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
      StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
      StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
      StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 done
      Goto loop
    found:
      StrCpy $STR_RETURN_VAR $STR_NEEDLE
      Goto done
    done:
   Pop $STR_NEEDLE ;Prevent "invalid opcode" errors and keep the
   Exch $STR_RETURN_VAR  
FunctionEnd
 
!macro _StrContainsConstructor OUT NEEDLE HAYSTACK
  Push `${HAYSTACK}`
  Push `${NEEDLE}`
  Call StrContains
  Pop `${OUT}`
!macroend
 
!define StrContains '!insertmacro "_StrContainsConstructor"'

;--------------------------------
; Start sections

Section "MyApp" SEC1
	${StrContains} $0 "MyApp" "$INSTDIR"
    StrCmp $0 "" notfoundMyApp
      StrCpy $MyAppInstallDir "$INSTDIR"
      Goto installMyApp
    installMyApp:	
  
    ##All the files in Group 1 will be installed to the same location, $INSTDIR
    SetOutPath "$INSTDIR"
	
	!insertmacro WriteSignedUninstaller "$InstDir\Uninst.exe"

    File MyApp.exe
    File ReleaseNotes.txt
    File MyCompany_LandingPage_114.bmp
    File MyAppLicense.txt  
  
    # create a shortcut named "new shortcut" in the start menu programs directory
    CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}.lnk" "$InstDir\${PRODUCT_NAME}.exe" 

    # Add application to registry  
    ClearErrors
    WriteRegStr HKCU "SOFTWARE\${PRODUCT_NAME}" 'Company Name' "${COMPANY_NAME}"
    WriteRegStr HKCU "SOFTWARE\${PRODUCT_NAME}" 'Version' "${PRODUCT_VERSION}"
    WriteRegStr HKCU "SOFTWARE\${PRODUCT_NAME}" 'AppID' "{A0E84732-E2B2-46E5-8CA2-462B8DF92DCD}"
 
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
      
    notfoundMyApp:	

    ; Do nothing					 
SectionEnd

Section /o "FlexLM" SEC3 
	${StrContains} $0 "Flex" "$INSTDIR"
    StrCmp $0 "" notfoundFlex
      StrCpy $FlexLmInstallDir "$INSTDIR"
      Goto installFlex
	installFlex:	  

    ##All the files in Group 2 will be installed to the same location, $INSTDIR
    SetOutPath "$INSTDIR"
    File installs.exe
    File lmdown.exe
	File lmflex.exe
	
	notfoundFlex:
	    ; Do nothing
SectionEnd
	
;--------------------------------
; Settings

!define PROG1_InstDir    "$PROGRAMFILES64\${PRODUCT_NAME}"
!define PROG1_StartIndex ${SEC1}
!define PROG1_EndIndex   ${SEC1}
 
!define PROG2_InstDir "C:\${FLEX_DIR}\"
!define PROG2_StartIndex ${SEC3}
!define PROG2_EndIndex   ${SEC3}

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecMyApp ${LANG_ENGLISH} "MyAppTM software is an easy-to-use suite of tools."
  LangString DESC_SecFlexLM ${LANG_ENGLISH} "FlexSQI contains all the files necessary to implement the FlexLM license server."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN    
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC1} $(DESC_SecMyApp)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC3} $(DESC_SecFlexLM)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------
; Please don`t modify below here unless you`re a NSIS 'wiz-kid'
 

      
  ## Create $PLUGINSDIR 
Function .onInit
  InitPluginsDir

  SetOutPath $TEMP
  File /oname=spltmp.bmp "MyCompany_LandingPage_114.bmp"

  splash::show 2000 $TEMP\spltmp

  Pop $0 ; $0 has '1' if the user closed the splash screen early,
  ; '0' if everything closed normally, and '-1' if some error occurred.

  Delete $TEMP\spltmp.bmp  
FunctionEnd
 
## If user goes back to this page from 1st Directory page
## we need to put the sections back to how they were before
Var IfBack
Function SelectFilesCheck
 StrCmp $IfBack 1 0 NoCheck
  Call ResetFiles
 NoCheck:
FunctionEnd
 
## Also if no sections are selected, warn the user!
Function ComponentsLeave
Push $R0
Push $R1
 
 Call IsPROG1Selected
  Pop $R0
 Call IsPROG2Selected
  Pop $R1
 StrCmp $R0 1 End
 StrCmp $R1 1 End
  Pop $R1
  Pop $R0
 MessageBox MB_OK|MB_ICONEXCLAMATION "$(NoSectionsSelected)"
 Abort
 
End:
Pop $R1
Pop $R0
FunctionEnd
 
Function IsPROG1Selected
Push $R0
 
 StrCpy $R0 ${PROG1_StartIndex} # Group 1 start
 
   SectionGetFlags 0 $R0 			# Get section flags
    IntOp $R0 $R0 & ${SF_SELECTED}
    StrCmp $R0 ${SF_SELECTED} 0 +3		# If section is selected, done
     StrCpy $R0 1
 
Exch $R0
FunctionEnd
 
Function IsPROG2Selected
Push $R1
 
 StrCpy $R1 ${PROG2_StartIndex}    # Group 2 start
 
   IntOp $R1 $R1 + 1
   SectionGetFlags 1 $R1 			# Get section flags
    IntOp $R1 $R1 & ${SF_SELECTED}
    StrCmp $R1 ${SF_SELECTED} 0 +3		# If section is selected, done
     StrCpy $R1 1
 
Exch $R1
FunctionEnd
 
## This will set all sections to how they were on the components page
## originally
Function ResetFiles
Push $R0
Push $R1
 StrCpy $R0 ${PROG2_StartIndex}    # Group 2 start
 
  Loop:
   IntOp $R0 $R0 + 1
   ReadINIStr "$R1" "$PLUGINSDIR\sections.ini" Sections $R0 # Get sec flags
    SectionSetFlags $R0 $R1				  # Re-set flags for this sec
    StrCmp $R0 ${PROG2_EndIndex} 0 Loop
 
Pop $R1
Pop $R0
FunctionEnd
 
## Here we are selecting first sections to install
## by unselecting all the others!
Function SelectFilesA
 # If user clicks Back now, we will know to reselect Group 2`s sections for
 # Components page
 StrCpy $IfBack 1
 
 # We need to save the state of the Group 2 Sections
 # for the next InstFiles page
Push $R0
Push $R1
 
 StrCpy $R0 ${PROG2_StartIndex} # Group 2 start
 
 # Don`t install prog 1?
 Call IsPROG1Selected
 Pop $R0
 StrCmp $R0 1 +4
  Pop $R1
  Pop $R0
  Abort
 
 # Set current $INSTDIR to PROG1_InstDir define
 StrCpy $INSTDIR "${PROG1_InstDir}"
 
Pop $R1
Pop $R0
FunctionEnd
 
## Here we need to unselect all Group 1 sections
## and then re-select those in Group 2 (that the user had selected on
## Components page)
Function SelectFilesB
Push $R0
;Push $R1
 
 StrCpy $R0 ${PROG1_StartIndex}    # Group 1 start
 
 # Don't install prog 2?
 Call IsPROG2Selected
 Pop $R0
 StrCmp $R0 1 +4
  Pop $R1
  Pop $R0
  Abort
 
 # Set current $INSTDIR to PROG2_InstDir define
 StrCpy $INSTDIR "${PROG2_InstDir}"
 
;Pop $R1
Pop $R0
FunctionEnd

## Here we are deleting the temp INI file at the end of installation
Function DeleteSectionsINI
  FlushINI "$PLUGINSDIR\Sections.ini"
  Delete "$PLUGINSDIR\Sections.ini"
 
  # FlexLM libs 
  ;MessageBox MB_OK "DeleteSectionsINI #1 MyAppInstallDir is $MyAppInstallDir"
  Delete $MyAppInstallDir\installs.exe
  Delete $MyAppInstallDir\lmdown.exe
  Delete $MyAppInstallDir\lmflex.exe
  Delete $MyAppInstallDir\MyAppLicense.txt
  Delete $MyAppInstallDir\MyCompany_LandingPage_114.bmp
  
  # MyApp files 
  Delete $FlexLmInstallDir\config.dat
  Delete $FlexLmInstallDir\MyApp.exe
  Delete $FlexLmInstallDir\ReleaseNotes.txt
  Delete $FlexLmInstallDir\MyCompany_LandingPage_114.bmp
  Delete $FlexLmInstallDir\MyAppLicense.txt
  Delete $FlexLmInstallDir\vcruntime140_1.dll 
    
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
  DeleteRegKey HKCU "SOFTWARE\${COMPANY_NAME}"
  Delete $0\config.dat
  Delete $0\MyApp.exe
  Delete $0\ReleaseNotes.txt  
  Delete $0\MyCompany_LandingPage_114.bmp
  Delete $0\MyAppLicense.txt
  Delete "$SMPROGRAMS\MyApp.lnk"
  DeleteRegKey HKCU "SOFTWARE\${PRODUCT_NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
  DeleteRegKey /ifempty HKCU "Software\Modern UI Test" 

  # Final cleanup 
  RMDir $0
  Delete "$InstDir\Uninst.exe"
  RMDir "$InstDir"
SectionEnd

!endif

