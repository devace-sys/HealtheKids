@echo off
@echo off
rem *******************************************************
rem * StudentDataTracking.bat
rem *******************************************************
rem *
rem * This script calls StudentDataTracking-cmds.bat
rem * to run the StudentDataTracking app 
rem * 
rem *
rem * Usage:
rem *
rem * Student data tracking -tasks [1] [2]
rem *
rem *
rem * [1]  Environment
rem        1 = development, 2 = test, 3= production
rem * [2]  Task number
rem        1 = Auto requests to Client contact 
rem        2 = Reminder to IT after one week of initial request
rem        3 = Reminder to IT after two weeks of initial request
rem        4 = Reminder to IT after four weeks of initial request
rem *******************************************************

if [%1]==[] goto usage
if [%2]==[] goto usage

if %1 equ 1 ( 
  echo Development machine
  call StudentDataTracking-cmds.bat c: dev@help4schools.com "sdhanala@help4schools.com" %2
  goto exit
)

if %1 equ 2 (
  echo Test server
  call StudentDataTracking-cmds.bat c: test@help4schools.com "sdhanala@help4schools.com" %2
  goto exit
)

if %1 equ 3 (
  echo Production server
  call StudentDataTracking-cmds.bat c: prod@help4schools.com "IT_Group@help4schools.com" %2
  goto exit
)

:usage

echo Please provide the environment and report number 
echo environment 1 = development, 2 = test, 3= production
echo Report number 1 = A and I Report, 2 = Vic's report

goto exit

:exit
