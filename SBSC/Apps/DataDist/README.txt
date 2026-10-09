GENERAL INFORMATION

PROJECT NAME: Chuck's Internal Python-SQL Report Automation
CLIENT: Practi-Cal, Inc.
DEVELOPERS: Jon Shamber, Daniel Wolfe
DESCRIPTION: Automates all queries contained in Chuck's Internal Management directory, outputs
	result data to Excel format given template, and then emails results to specific
	addresses and/or updates relevant SmartSheets. To be done at predefined times and
	days.
TECHNOLOGIES: Primarily Python (3.5.2) language and modules, SQL Server 2008 database
RELATED PROJECTS: None
RESOURCE LINKS: None

GETTING STARTED

Installables:
	Python 3.5.2
	  Modules:
		dateparser (0.4.0),
		DateTime (4.1.1),
		openpyxl (2.3.5),
		pymssql (2.1.3),
		smartsheet-python-sdk (1.0.1),
		xlrd (1.0.0),
		XlsxWriter (0.9.3),
		xlutils (2.0.0),
		xlwt (1.1.2)
	Program files, templates and directories need to be copied as-is in order to work
		properly on a system
		
Run Instructions:
	1. Verify that config files are loaded correctly (PyQF.py [line 12-14], PyEmail.py
		[lines 26-28, uncomment 106-111])
	
	To run manually:
	2. Open command prompt within the directory where all .py and .bat files are located
	3. Run the program by typing: python_sql_updater_[weekly, monthly or quarterly].bat
	
	To run through task or crontab:
	(Windows)
	2. Import all 3 tasks from "WinTaskExports"
	3. Verify permissions and access rights to allow for operation on machine
	
	(Linux/Unix)
	2. Copy to local crontab the contents of "cron.d"
	3. Verify permissions and access rights to allow for operation on machine
	
	4. Verify and debug output on scheduled dates or after local manual run by checking "logs",
		"Email\Debug", and "Query Results\"

TESTING

STAGING AND PRODUCTION ENVIRONMENT

Program currently being developed on the 'DEV' branch. 'TEST' branch is being used to test
	SMTP email capability. 'PRODUCTION' branch will have final production-ready automation.
	
NOTES & TODOS

08/11/2016 - Tested program through Windows 8 task scheduler to send, via SMTP, to personal
	Gmail address. Success with tasks, email transmission, data, format, and debug info.
	Ready for preliminary presentation of 1st half of program to client.
	TODO: Still need to figure out SmartSheet implementation, but don't exactly have clear
	target in mind as of yet. Need to test with dummy sheets, gain clarification, and then
	move forward with 2nd half of project goal.
	
08/15/2016 - Made a change to table function CONST_STANDARD_BUDGET_TARGET_PER_PATIENT
	(allowed user [webuser] to execute the function)