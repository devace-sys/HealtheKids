;*******************************************************************************
;* Inno Setup Installation Script for the Payroll Application
;*******************************************************************************
#define AppName   "Payroll App"
#define Publisher "SBSC"

;*******************************************************************************
;* Setup
;*******************************************************************************
[Setup]
AppName                    ={#AppName}
AppVerName                 ={#AppName}
AppPublisher               ={#Publisher}
DefaultDirName             ={pf}\sbsc\payrollapp\
DefaultGroupName           ={#Publisher}
AlwaysShowGroupOnReadyPage =yes
OutputBaseFilename         =setup-HRMngTool
OutputDir                  =installers
Compression                =lzma
SolidCompression           =yes
PrivilegesRequired         =admin
AlwaysShowDirOnReadyPage   =yes

;*******************************************************************************
;* Languages
;*******************************************************************************
[Languages]
Name: english; MessagesFile: compiler:Default.isl

;*******************************************************************************
;* Files
;*******************************************************************************
[Files]
Source: bin\Release\*; DestDir: {app}; Flags: ignoreversion

;*******************************************************************************
;* Added by tool
;*******************************************************************************

[Icons]
Name: {group}\Payroll; Filename: {app}\Payroll.exe

