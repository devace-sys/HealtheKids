# Custom Library of commonly used Python functions
import configparser	as cp
import string, random, os

########################################################################
# Find app's absolute path for reference to local directories
########################################################################

def findConfigPath():
	currentFolderPath = os.path.dirname(os.path.abspath(__file__))
	configFilePath = currentFolderPath + '\DataDist.ini'
	return configFilePath

########################################################################
# Read and store config information
########################################################################

parser = cp.ConfigParser()
configFilePath = findConfigPath()
parser.read(configFilePath)

########################################################################
# Trim off command-line identifier, "=[" and "]"
########################################################################

def trimString(input, start):
	return input[start:len(input)]

########################################################################
# Explode string by commas after trim to create LIST
########################################################################

def strExplodeToList(input, start):
	return trimString(input, start).split(',')
	
########################################################################
# Explode string by commas after trim to create TUPLE
########################################################################

def strExplodeToTuple(input, start):
	return tuple(trimString(input, start).split(','))
	
########################################################################
# Random hash generator
########################################################################

def id_generator(size=10, chars=string.ascii_uppercase + string.digits):
	return ''.join(random.choice(chars) for _ in range(size))

########################################################################
# Logger instance creator
########################################################################

def loggerCreate():
	import logging as log
	import datetime as dt
	
	log.basicConfig(format='%(asctime)s - [%(levelname)s] - %(message)s', level=log.DEBUG)
	logger = log.getLogger(__name__)
	now = dt.datetime.today()
	logFileName = parser['datadist']['log_path']+'DataDist-SYSTEM-'+str(now.day)+'-'+str(now.month)+'-'+str(now.year)+'.log'
	handler = log.FileHandler(logFileName)
	handler.setLevel(log.DEBUG)
	formatter = log.Formatter('%(asctime)s - [%(levelname)s] - %(message)s')
	handler.setFormatter(formatter)
	logger.addHandler(handler)
	return logger
