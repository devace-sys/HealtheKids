@echo off
setlocal EnableDelayedExpansion

rem *******************************************************
rem * IncomingInputBatches.bat
rem *******************************************************
rem *
rem * This script runs every days
rem *
rem * Usage:
rem *
rem * IncomingInputBatches-cmds [1] 
rem *
rem *  [1]   batch path 
rem *       location of spedmon dir.. ie c: for c:\spedmon
rem *
rem * Sample Call
rem c:

rem *******************************************************

rem ------------------------------------------------------
rem If the required arguments are blank, print usage and exit
rem ------------------------------------------------------

if [%1]==[] goto usage

echo Running Workflow batch tasks please wait...

rem ------------------------------------------------------
rem Init flags
rem ------------------------------------------------------

set _haserrors=0

set _1=172.16.100.10
set _2=test@help4schools.com 
set _3="sdhanala@help4schools.com" 

:usage

echo Please provide the drive letter.
set _haserrors=1
goto exit2

rem ------------------------------------------------------
rem Run report distribution app
rem ------------------------------------------------------
:exit
call IncomingInputBatches.exe   /rn:1
if %ERRORLEVEL% neq 0 (
  set _haserrors=1
  echo Exiting with errors
  set _noticetitle="IncomingInputBatches completed with errors"
  set _noticemsg="WARNING! Batch tasks for IncomingInputBatches completed with errors.  Please see logs for details."
  call %1\spedmon\tools\sendEmail\sendEmail.exe -s "%_1%" -f "%_2%" -t "%_3%" -u "IncomingInputBatches completed with errors" -m "WARNING! IncomingInputBatches completed with errors. Please see logs." -a %1\spedmon\batch\IncomingInputBatches-tasks.log
  goto exit2
)

:exit2

exit /B  %_haserrors%

endlocal