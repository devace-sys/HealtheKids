@echo off
@echo off
rem *******************************************************
rem * Workflow.bat
rem *******************************************************
rem *
rem * This script calls Workflow-cmds.bat
rem * to run the Workflow app in reports mode
rem * 
rem *
rem * Usage:
rem *
rem * Workflow-tasks [1] [2]
rem *
rem *
rem * [1]  Environment
rem        1 = development, 2 = test, 3= production
rem * [2]  Report number
rem        1 = A&I report, 2 = Vic's report    
rem *******************************************************

if [%1]==[] goto usage
if [%2]==[] goto usage

if %1 equ 1 ( 
  echo Development machine
  call Workflow-cmds.bat c: dev@help4schools.com "sdhanala@help4schools.com" %2
  goto exit
)

if %1 equ 2 (
  echo Test server
  call Workflow-cmds.bat c: test@help4schools.com "sdhanala@help4schools.com" %2
  goto exit
)

if %1 equ 3 (
  echo Production server
  call Workflow-cmds.bat c: prod@help4schools.com "IT_Group@help4schools.com" %2
  goto exit
)

:usage

echo Please provide the environment and report number 
echo environment 1 = development, 2 = test, 3= production
echo Report number 1 = A and I Report, 2 = Vic's report

goto exit

:exit
