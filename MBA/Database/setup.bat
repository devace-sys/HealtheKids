@echo off
rem ------------------------------------------------------
rem setup.bat
rem ------------------------------------------------------
rem This is an interactive script.
rem This script presents the user with a choice of what
rem environment to install the various T-SQL components in
rem and calls install.bat with the appropriate db connection
rem string 
rem ------------------------------------------------------
mode con:cols=140 lines=2500
cls
color 9f
echo ------------------------
echo Install T-SQL Components
echo for Users
echo ------------------------
echo.
set _db=""
set _conn=""
echo Install components to: 
echo (1) Dev Database (Workstation)
echo (2) Testing Database
echo (3) Production Database
echo (4) Demo Database
echo (0) Remote/Custom Database
echo (Enter) Exit
set /P _db=Select option or Press Enter to Exit:
if "%_db%"=="" goto exit
if /i "%_db%"=="1" goto sub_dev
if /i "%_db%"=="2" goto sub_test
if /i "%_db%"=="3" goto sub_prod
if /i "%_db%"=="4" goto sub_demo
if /i "%_db%"=="0" goto sub_cust
goto exit

:sub_dev
cls
color 2f
echo ----------------------
echo Install to Development
echo ----------------------
echo.
set _conn=localhost\SQLDEV2017
goto confirm_db

:sub_test
cls
color e0
echo ----------------------
echo Install to Test
echo ----------------------
echo.
set _conn=SBSCITTEST2\SQLTEST2017
goto confirm_db

:sub_prod
cls
color 4f
echo ----------------------
echo Install to Production
echo ----------------------
echo.
echo *****************************************************
echo * WARNING! YOU ARE INSTALLING TO A PRODUCTION SYSTEM *
echo *****************************************************
echo.
echo Installing to production
set _conn=SBSCSQL5\SBSCSQL5
goto confirm_db

:sub_demo
cls
color cf
echo ----------------------
echo Install to Demo
echo ----------------------
echo.
set _conn=SBSCSQL3\SBSCSQL3
goto confirm_db

:sub_cust
cls
color 17
echo ----------------------
echo Remote or Custom Database Connection String
echo ----------------------
echo.
echo Enter desired DB connection string
echo.
set /P _conn=""
echo.
goto confirm_db

rem  -- TODO: Would be nice if we could have an interactive, editable field for this.
rem  -- There is a freeware widget here:
rem  -- https://stackoverflow.com/a/23619890
rem  -- That said, I wouldn't use it unless we could compile it from source.
rem  -- Maybe we can find the source code for this input utility, or a similar one.

:confirm_db

echo You will be using
echo.
echo %_conn%
set /P _yn=Do you accept? (y/n):
if "%_yn%"=="" goto exit
if /i "%_yn%"=="y" goto next_q
goto exit

:next_q
if /i NOT "%_db%"=="3" goto start_install
set _yn=""
set /P _yn=Are you SURE you wish to install the production server? (y/n):
if "%_yn%"=="" goto exit
if /i "%_yn%"=="y" goto start_install
goto exit

:start_install 
call install.bat %_conn%

echo all done
:exit
echo exiting...
sleep 4
cls
color 0f
exit