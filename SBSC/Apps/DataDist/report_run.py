########################################################################
# Module import
########################################################################

import datetime as dt
import configparser as cp
import glob
import os, shutil, sys, time
import logging as log
from PyQF import PyQF
from PyEmail import PyEmail
from perPyFuncLib import *

########################################################################
# Read and store config information
########################################################################

parser = cp.ConfigParser()
configFilePath = findConfigPath()
parser.read(configFilePath)

########################################################################
# Set up logging and priority handling
########################################################################

logger = loggerCreate()

########################################################################
# Set current date and time
########################################################################

if len(sys.argv) > 1:
	try:
		new_object = sys.argv[1].split("/")
		new_month, new_day, new_year = new_object[0], new_object[1], new_object[2]
		now = dt.datetime(int(new_year),int(new_month),int(new_day),0,0,0)
	except:
		logger.error("Optional 'datetime' argument in improper format.")
		logger.error("Usage: python report_run.py MM/DD/YYYY")
		logger.error("Proceeding with current DATETIME instead...")
		now = dt.datetime.today()
else:
	now = dt.datetime.today()

logger.debug('**** Beginning new run [{}] *****'.format(now))

########################################################################
# Run Python command
########################################################################

def runSBCommand(des,com):
	logger.debug("Run {} reports...".format(des))
	
	# Test report_run sub processes through unit tests
	if com is None:
		#~ sp.run(["python", parser[des]['test_file']])
		pass
	else:
		queryList 		= parser[des]['queries'].split(",")
		ssList 			= parser[des]['ss_queries'].split(",")
		emailList 		= parser[des]['email_list'].split(",")
		
		cfg_sql_path 	= parser['datadist']['sql_path']
		cfg_temp_path 	= parser['datadist']['template_path']
		cfg_rslts_path	= parser['datadist']['results_path']
		
		for item in queryList:
			pri = parser[item]
			try:
				PyQF(
					cfg_sql_path+pri['sql'],
					cfg_temp_path+pri['template'],
					int(pri['column']),
					int(pri['row']),
					int(pri['sheet']),
					logger
				)
			except:
				logger.debug("Unexpected error: ", sys.exc_info()[0])
				raise
				
		if ssList[0] != 'None':
			for item in ssList:
				sri = parser[item]
				try:
					PyQF_SmSh(
						cfg_sql_path+sri['sql'],
						sri['sheet_id'],
						sri['args'],
						logger,
						True
					)
				except:
					logger.debug("Unexpected error: ", sys.exc_info()[0])
					raise
					
		if emailList[0] != 'None':
			attachments = glob.glob(cfg_rslts_path+"*.xlsx")
			try:
				PyEmail(
					emailList,
					attachments,
					parser[des]['email_template'],
					logger,
					parser['email']['email_send']
				)
			except:
				logger.debug("Unexpected error: ", sys.exc_info()[0])
				raise
			for a in attachments:
				os.remove(a)

########################################################################					
# Based off of time, queue report designations for automation
########################################################################

def findReports(now=now):
	report_list = []
	if now.weekday() == 1:
		report_list.append("weekly")
	if now.day == 1:
		report_list.append("monthly")
		if now.month in [1,4,7,10]:
			report_list.append("quarterly")
	return report_list

########################################################################
# Run reports based off of queued report designations
########################################################################

def runReports(reports,command=None):
	while reports:
		designator = reports.pop()
		try:
			runSBCommand(designator,command)
		except KeyboardInterrupt:
			logger.debug("Caught keyboard interrupt, terminating processes.")
			return
		except:
			logger.debug("Unexpected error: ", sys.exc_info()[0])
			raise

if __name__ == '__main__':
	reports = findReports()
	logger.debug("Reports to be run: {}".format(reports))
	if reports:
		file_list = glob.glob(parser['datadist']['results_path']+"*.xlsx")
		for item in file_list:
			os.remove(item)
		runReports(reports,True)
