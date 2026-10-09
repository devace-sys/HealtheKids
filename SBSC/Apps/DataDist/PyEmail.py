"""
Creates email, adds relevant attachments, sends SMTP email
"""

########################################################################
# Link to modules
########################################################################

import sys										# Command-line arguments
import smtplib									# Email debugger
import os										# File path parsing
import datetime									# Grab current date
from email.mime.multipart import MIMEMultipart	# Email
from email.mime.base import MIMEBase			# Email
from email.mime.text import MIMEText			# Email
from email.utils import COMMASPACE, formatdate	# Email
from email import encoders						# Email
import configparser	as cp						# Config file parser
from perPyFuncLib import *						# Custom functions

########################################################################
# Load and parse config
########################################################################

config = cp.ConfigParser()
configFilePath = findConfigPath()
config.read(configFilePath)

########################################################################
# Set server variables
########################################################################

serverHost	= config['email']['host']
serverPort	= config['email']['port']
emailFrom	= config['email']['from']
outputDir	= config['datadist']['email_path']

def PyEmail(listAddresses,listAttachments,templateFile,logger,command=None):

	if command is None:
		result_dict = {}
		result_dict['listAddresses'] = listAddresses
		result_dict['listAttachments'] = listAttachments
		result_dict['templateFile'] = templateFile
		return result_dict
	else:
		logger.debug("Beginning email construction")
		outputFile = outputDir+id_generator(10)+'-EMAILLOG.eml'
		templateFile = config['datadist']['email_temp_path']+templateFile

		########################################################################
		# Check for non-valid file paths
		# If non-valid found, warn and remove from attachments
		########################################################################

		logger.debug("Checking for invalid attachments")
		nonValidAttachments = []
		for file in listAttachments:
			if os.path.isfile(file) is False:
				nonValidAttachments.insert(0, file)
		if nonValidAttachments:
			print(nonValidAttachments)
			logger.warning("\nWARNING: INVALID FILES WERE DETECTED AND REMOVED FROM ATTACHMENTS LIST")
		for file in nonValidAttachments:
			listAttachments.remove(file)

		########################################################################
		# File read/write, email construct
		########################################################################
			
		# Specify delimiter to be joined on
		COMMASPACE = ", "

		# Open and read email template to 'msg'
		logger.debug("Opening HTML template ({}) for email".format(templateFile))
		with open(templateFile) as fp:
			text = MIMEText(fp.read(), 'html')
		fp.close()

		# Construct email requirements
		logger.debug("Combining email elements")
		msg = MIMEMultipart()
		msg['Subject'] = 'Help4Schools Reports'
		msg['From'] = emailFrom
		msg['To'] = COMMASPACE.join(listAddresses)
		msg['Attachments'] = COMMASPACE.join(listAttachments)

		# Append template text to message body
		msg.attach(text)

		########################################################################
		# Attach validated attachments
		########################################################################

		logger.debug("Attaching attachments")
		for f in listAttachments:
			part = MIMEBase('application', "octet-stream")
			fo = open(f,"rb")
			part.set_payload( fo.read() )
			fo.close()
			encoders.encode_base64(part)
			part.add_header('Content-Disposition', 'attachment; filename="{0}"'.format(os.path.basename(f)))
			msg.attach(part)

		########################################################################
		# Open file to write to (Email send block)
		########################################################################\

		outf = open(outputFile, 'a')
		outf.write(str(msg))
		outf.write("\n")
		outf.close()

		########################################################################
		# Email send via SMTP
		########################################################################
		
		if command == 'True':
			logger.debug("Command is {}, so sending email".format(command))
			server = smtplib.SMTP(serverHost, serverPort)
			server.send_message(msg)
			server.quit()
		else:
			logger.debug("Command is not True, so only storing email to dir")

if __name__ == "__main__":

	########################################################################
	# Grab arguments and store
	########################################################################
	addr = sys.argv[1]
	if isinstance(addr,str):
		listAddresses = addr.split(",")
	attch = sys.argv[2]
	if isinstance(attch,str):
		listAttachments = attch.split(",")
	templateFile = config['datadist']['email_temp_path']+sys.argv[3]

	logger.debug("List of addresses: {}".format(listAddresses))
	logger.debug("List of attachments: {}".format(listAttachments))
	logger.debug("Template file to be used: {}".format(templateFile))
	
	PyEmail(listAddresses,listAttachments,templateFile,True)
