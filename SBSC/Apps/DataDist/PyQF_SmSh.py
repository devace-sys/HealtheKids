"""
Open database connection, open SmartSheet API, save data to SmartSheet
"""

########################################################################
# Link to modules
########################################################################

import sys					# Command-line arguments
import datetime				# Grab current date
import pymssql				# Database connection
import os					# File path parsing
import smartsheet			# Smartsheet API
import configparser	as cp	# Config file parser
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

api_token	= "13r9recdpouftb2xxnj2uscjou"
server		= config['db']['server']
database	= config['db']['database']
user		= config['db']['user']
password	= config['db']['password']

def PyQF_SmSh(sql,ssID,ssargs,logger,command=None):

	if command is None:
		result_dict = {}
		result_dict['sql'] = sql
		result_dict['ssID'] = ssID
		result_dict['ssargs'] = ssargs
		return result_dict
		
	else:
		sqlQuery = ""

		########################################################################
		# Execute if database connection successful
		########################################################################

		logger.info("...Connecting to SQL Server [{}].[{}]...".format(server, database))
		with pymssql.connect(server, user, password, database) as dbConn:
			logger.info('...Connection successful...')
			with dbConn.cursor(as_dict=True) as dbRows:
			
				# Open target sql file
				logger.info('...Opening query file...')
				with open(sql, 'r') as f:

					# Read query line by line and execute blocks denoted by 'GO', saving to seperate worksheets (unverified)
					for line in f:
						sqlQuery += line
					else:
						logger.info('...Executing query...')

						# Execute query (with conditional args)
						dbRows.execute(sqlQuery, ssargs)
						
						logger.info("...Data successfully pulled from database...")
						logger.info("...Proceeding to SmartSheet write...")
						
						smartsheet = smartsheet.Smartsheet(api_token)
						
						########################################################################
						# Get reference to sheet so we can delete old rows
						########################################################################

						sheet = smartsheet.Sheets.get_sheet(ssID,None,None,None,None,None,None,None)

						########################################################################
						# Clear sheet
						########################################################################

						if sheet.rows:
							logger.info("...Deleting old rows on sheet...")
							
							rowIds = []
							for item in sheet.rows:
								rowIds.append(item.id)
							finalrowIds = ','.join(str(item) for item in rowIds)
							smartsheet.Sheets.delete_rows(ssID, finalrowIds)

						########################################################################
						# Get reference to sheet again so we can get column info
						########################################################################

						sheet = smartsheet.Sheets.get_sheet(ssID,include='columnType')

						########################################################################
						# Get columns and store in a dict
						########################################################################

						columnIds = {}
						columnTypes  = {}

						for column in sheet.columns:
							key = column.title
							colId    = column.id
							colType  = column.type
							columnIds[key] = colId
							columnTypes[key] = colType

						########################################################################
						# Process results
						########################################################################
						
						logger.info("...Adding new rows from query result...")
						listRows = []
						for dbRow in dbRows:
							ssRow = smartsheet.models.Row()
							ssRow.to_bottom = True
								
							####################################################################
							# Get dbCells
							####################################################################

							for key, value in dbRow.items():
								colId = columnIds[key]
								colType = columnTypes[key]
								ssCell = smartsheet.models.Cell()
								ssCell.strict = False
								ssCell.column_id = colId
								ssCell.columnType = colType
								ssCell.value = value
								ssRow.cells.append(ssCell)
							listRows.append(ssRow)

						####################################################################
						# Add list of rows to sheet
						####################################################################

						action = smartsheet.Sheets.add_rows(ssID, listRows)
						
				# Save workbook
				logger.info("...Operation complete...")
		
if __name__ == "__main__":

	########################################################################
	# Reads arguments for query and file transformation
	########################################################################

	sqlQueryFile = sys.argv[1]	# SQL file name
	smartSheetId = sys.argv[2]	# SmartSheet target ID

	########################################################################
	# Format optional SQL arguments to pass
	########################################################################

	if len(sys.argv) == 4 and sys.argv[3] != 'None':
		strSqlArgs = sys.argv[3]
		tupleSqlArgs = strExplodeToTuple(strSqlArgs, 0)
		logger.debug(tupleSqlArgs)
	else:
		tupleSqlArgs = ()
		logger.debug("No args...")
		
	PyQF_SmSh(sqlQueryFile,smartSheetId,tupleSqlArgs,True)
