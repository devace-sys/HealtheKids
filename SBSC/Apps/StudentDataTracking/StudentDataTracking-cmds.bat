@echo off
setlocal EnableDelayedExpansion

rem *******************************************************
rem * StudentDataTracking-cmds.bat
rem *******************************************************
rem *
rem * Executes StudentDataTracking.exe in "report mode" and emails
rem * a distribution list if there was a problem running
rem * the exe.
rem *
rem * Usage:
rem *
rem * StudentDataTracking-cmds [1] [2] [3] [4]
rem *
rem *  [1]  batch path 
rem *       location of spedmon dir.. ie c: for c:\spedmon
rem *  [2]  Notification from email
rem *  [3]  Notification list(in double quotes seperated by ; for multiple emails)
rem *  [4]  Task number
rem         1 = Auto requests to Client contact 
rem         2 = Reminder to IT after one week of scheduled date to request
rem         3 = Reminder to IT after two weeks of initial request
rem         4 = Reminder to IT after four weeks of initial request
rem *******************************************************

rem ------------------------------------------------------
rem If the required arguments are blank, print usage and exit
rem ------------------------------------------------------

if [%1]==[] goto usage
if [%2]==[] goto usage
if [%3]==[] goto usage
if [%4]==[] goto usage

echo Running StudentDataTracking batch tasks please wait...

rem ------------------------------------------------------
rem Init flags
rem ------------------------------------------------------

set _haserrors=0

rem ------------------------------------------------------
rem Run StudentDataTracking app in "Report Mode"
rem ------------------------------------------------------

StudentDataTracking.exe /n:%4

if %ERRORLEVEL% equ 0 ( 
  echo Batch tasks completed normally  
) else ( 
  set _haserrors=1
  echo Exiting with errors
  if %4 equ 1 (
  set _noticetitle="Student data tracking completed with errors"
  set _noticemsg="WARNING! Batch tasks for Student data tracking completed with errors.  Please see logs for details."
  call %1\spedmon\tools\common\sendEmail.exe -f %2 -t %3 -u "StudentData app completed with errors" -m "WARNING! Sending auto request emails failed. Please see logs for details." 
) else if %4 equ 2 (  
  set _noticetitle="StudentDataTracking Summary report completed with errors"
  set _noticemsg="WARNING! Batch tasks for StudentDataTracking summary report completed with errors.  Please see logs for details."
  call %1\spedmon\tools\common\sendEmail.exe -f %2 -t %3 -u "StudentData app completed with errors" -m "WARNING! Sending reminder emails failed. Please see logs for details." 
) else if %4 equ 3 (  
  set _noticetitle="StudentDataTracking Summary report completed with errors"
  set _noticemsg="WARNING! Batch tasks for StudentDataTracking summary report completed with errors.  Please see logs for details."
  call %1\spedmon\tools\common\sendEmail.exe -f %2 -t %3 -u "StudentData app completed with errors" -m "WARNING! Sending reminder emails failed. Please see logs for details." 
) else if %4 equ 4 (  
  set _noticetitle="StudentDataTracking Summary report completed with errors"
  set _noticemsg="WARNING! Batch tasks for StudentDataTracking summary report completed with errors.  Please see logs for details."
  call %1\spedmon\tools\common\sendEmail.exe -f %2 -t %3 -u "StudentData app completed with errors" -m "WARNING! Sending reminder emails failed. Please see logs for details." 
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