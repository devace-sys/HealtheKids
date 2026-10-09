@echo off
rem ------------------------------------------------------
rem install.bat
rem ------------------------------------------------------
rem This script invokes install.sql with a user provided
rem database server name\instance
rem Usage
rem install.bat [1]
rem [1] database server name\instance
rem Example
rem install.bat "PCALDEVOLD\SQLEXPRESS2008"
rem ------------------------------------------------------
mode con:cols=140 lines=2500
if "%1"=="" goto usage
SQLCMD -C -I -E -S"%1" -dSPEDMON -i install.sql
goto exit
:usage
echo Please provide the database server name\instance
goto exit
:exit
echo exiting...
pause