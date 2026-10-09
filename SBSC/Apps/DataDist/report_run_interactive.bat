@echo off

rem *******************************************************
rem * report_run_interactive.bat
rem *******************************************************
rem *
rem * Runs the data distribution app in an interactive mode
rem * suitable for end user direct use.
rem *
rem * Usage:
rem *
rem *   report_run_interactive.bat  
rem *
rem * Sample Call:
rem *
rem *   C:\SBSC\Spedmon\Apps\DataDist\report_run_interactive
rem *******************************************************

mode con:cols=120 lines=40
py manual_report_run.py
