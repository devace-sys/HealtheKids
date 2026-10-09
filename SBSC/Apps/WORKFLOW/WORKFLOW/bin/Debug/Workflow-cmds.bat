@echo off
setlocal EnableDelayedExpansion

rem *******************************************************
rem * Workflow-cmds.bat
rem *******************************************************
rem *
rem * Executes workflow.exe in "report mode" and emails
rem * a distribution list if there was a problem running
rem * the exe.
rem *
rem * Usage:
rem *
rem * Workflow-cmds [1] [2] [3] [4]
rem *
rem *  [1]  batch path 
rem *       location of spedmon dir.. ie c: for c:\spedmon
rem *  [2]  Notification from email
rem *  [3]  Notification list (in double quotes seperated by 
rem *  ; for multiple emails)
rem *  [4]  Report number
rem         1 = A&I report, 2 = Vic's report
rem *******************************************************

rem ------------------------------------------------------
rem If the required arguments are blank, print usage and exit
rem ------------------------------------------------------

if [%1]==[] goto usage
if [%2]==[] goto usage
if [%3]==[] goto usage
if [%4]==[] goto usage

echo Running Workflow batch tasks please wait...

rem ------------------------------------------------------
rem Init flags
rem ------------------------------------------------------

set _haserrors=0

rem ------------------------------------------------------
rem Run Workflow app in "Report Mode"
rem ------------------------------------------------------

WORKFLOW.exe /rn:%4

if %ERRORLEVEL% equ 0 ( 
  echo Batch tasks completed normally  
) else ( 
  set _haserrors=1
  echo Exiting with errors
  if %4 equ 1 (
  set _noticetitle="A&I report completed with errors"
  set _noticemsg="WARNING! Batch tasks for A&I report completed with errors.  Please see logs for details."
  call %1\spedmon\tools\common\sendEmail.exe -f %2 -t %3 -u "A&I report completed with errors" -m "WARNING! A&I report completed with errors.  Please see logs for details." 
) else (  
  set _noticetitle="Workflow Summary report completed with errors"
  set _noticemsg="WARNING! Batch tasks for Workflow summary report completed with errors.  Please see logs for details."
  call %1\spedmon\tools\common\sendEmail.exe -f %2 -t %3 -u "Workflow summary report completed with errors" -m "WARNING! Workflow summary report completed with errors.   Please see logs for details." 
)  
)
goto exit

:usage

echo Please provide the drive letter, notification from email, and distribution list
set _haserrors=1
goto exit

:exit

exit /B  %_haserrors%

endlocal