;*******************************************************************************
;* Inno Setup Installation Script for the speEdMon website
;*******************************************************************************
#define AppName   "Users Database T-SQL Components"
#define Publisher "MBA"

;*******************************************************************************
;* Setup
;*******************************************************************************
[Setup]
AppName                  ={#AppName}
AppVerName               ={#AppName}
AppPublisher             ={#Publisher}
DefaultDirName           =C:\spedmon\data\install\common\
DisableProgramGroupPage  =yes
OutputBaseFilename       =setupUsersDatabase
Compression              =none
;SolidCompression         =yes
Uninstallable            =no
PrivilegesRequired       =admin
AlwaysShowDirOnReadyPage =yes

;*******************************************************************************
;* Languages
;*******************************************************************************
[Languages]
Name: english; MessagesFile: compiler:Default.isl

;*******************************************************************************
;* Files
;*******************************************************************************
[Files]
Source: C:\MBA\Common\Database\*; DestDir: {app}; Flags: ignoreversion

;*******************************************************************************
;* Added by tool
;*******************************************************************************
[_ISTool]
OutputExeFilename=C:\MBA\Common\Build\Output\setupUsersDatabase.exe
[Run]
Filename: setup.bat; Flags: postinstall; WorkingDir: {app}; Description: Run setup.bat; Tasks: 
[Messages]
WelcomeLabel2=This will install fresh copies of all T-SQL objects.  You must run setup.bat to complete the installation.  You must also have administrator access to the database.
