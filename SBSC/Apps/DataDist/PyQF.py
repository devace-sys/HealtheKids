"""
Open database connection, grab data, format, save to output directory
"""

########################################################################
# Link to modules
########################################################################

import sys					# Command-line arguments
import datetime				# Grab current date
import pymssql				# Database connection
import os					# File path parsing
import configparser	as cp	# Config file parser
import glob
from perPyFuncLib import *	# Custom functions

########################################################################
# Load and parse config
########################################################################

config = cp.ConfigParser()
configFilePath = findConfigPath()
config.read(configFilePath)

########################################################################
# Establish database login credentials
########################################################################

server		= config['db']['server']
database	= config['db']['database']
user		= config['db']['user']
password	= config['db']['password']

def PyQF(sql,form,scol,srow,sheet,logger,sqlArgs=()):

	logger.info("{} {} {} {} {} {}".format(sql,form,scol,srow,sheet,sqlArgs))

	########################################################################
	# Deconstruct formatterFile name, construct output file name and grab
	# extension
	########################################################################

	formFileName, formExt = os.path.splitext(os.path.basename(form))
	logger.info("Filename: {}".format(formFileName))
	outputFileName = config['datadist']['results_path'] + formFileName[16:] + " " + datetime.date.today().strftime("%m%d%Y")
	outputFile = outputFileName + formExt
	logger.info("Outputfile: {}".format(outputFile))

	########################################################################
	# Open database connection, branch by template extension and execute
	########################################################################

	logger.info("Connecting to SQL Server [{}].[{}]".format(server, database))
	with pymssql.connect(server, user, password, database) as dbConn:
		logger.info('Connection successful')
		with dbConn.cursor() as dbRows:
			sqlQuery = ""
			if formExt == '.xlsx':
			
				# Conditional Imports for XLSX read/write/copy
				from openpyxl import load_workbook
				from openpyxl.styles import colors, Font
				import warnings, traceback
				
				# Check to see if output file exists before writing to anything (True = overwrite, False = create new output file)
				warnings.simplefilter("ignore")
				if os.path.exists(outputFile):
					wb = load_workbook(outputFile)
				else:
					wb = load_workbook(form)
				warnings.simplefilter("default")
				ws = wb.worksheets[sheet]
				
				# Open target sql file
				logger.info('Opening query file')
				with open(sql, 'r') as f:

					# Read query line by line and execute blocks denoted by 'GO', saving to seperate worksheets (unverified)
					for line in f:
						if(line == 'GO\n' or line == 'GO;' or line == 'GO'):
							if sqlQuery:
								logger.info('Executing query')

								try:
									
									# Execute query (with conditional args)
									dbRows.execute(sqlQuery, sqlArgs)
									
									# Grab all data from query
									data = dbRows.fetchall()
									logger.info("Data successfully pulled from database")
									logger.info("Proceeding to file write")
									#~ ft = Font(name='Times New Roman', size=10)
									
									# Iterate through results
									try:
										for i, row in enumerate(data):
											for j, col in enumerate(row):
												r=i+srow+1
												c=j+scol+1
												ws.cell(row=r, column=c).value = col
												#~ ws.cell(row=r, column=c).font = ft
									except ValueError:
										logger.warning("WARNING: Max number of rows reached")
										logger.warning("Truncated results possible")
									sqlQuery = ""
								except BaseException as e:
									logger.error("Error: {}".format(str(e)))
						else:
							sqlQuery = sqlQuery + line

				########################################################################
				# Close and save workbook
				########################################################################

				wb.save(outputFile)
			else:
				logger.error("{} is not a recognized formatter file extension".format(formExt))
			logger.info("Operation complete")
		
if __name__ == "__main__":
	if len(sys.argv) >= 6 and len(sys.argv) < 8:

		########################################################################
		# Reads arguments for query and file transformation
		########################################################################

		sqlQueryFile	= sys.argv[1]			# SQL file name
		formatterFile	= sys.argv[2]			# Excel template name	
		startCellCol	= int(sys.argv[3])		# Target cell column
		startCellRow	= int(sys.argv[4])		# Target cell row
		targetSheet		= int(sys.argv[5])		# Target Excel sheet
		
		########################################################################
		# Format optional SQL arguments to pass
		########################################################################

		if len(sys.argv) >= 7:
			strSqlArgs = sys.argv[6]
			tupleSqlArgs = strExplodeToTuple(strSqlArgs, 0)
		else:
			tupleSqlArgs = ()
			
		PyQF(sqlQueryFile,formatterFile,startCellCol,startCellRow,targetSheet,tupleSqlArgs)
	else:
		print("ERROR: Incorrect number of arguments.\nUsage: python PyQF.py <sql file> <template> <target Excel column> <target Excel row> <target Excel sheet> (optional args)\n")
