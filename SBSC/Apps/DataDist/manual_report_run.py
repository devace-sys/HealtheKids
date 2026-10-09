import subprocess as sp
import os
import os.path 		as op
import fnmatch		as fn
import configparser	as cp
import glob
from collections import OrderedDict as od
from copy import deepcopy as dc

# Read and store config information
parser = cp.ConfigParser()
parser.read('DataDist.ini')

menu_dict = {
	'1':'View All Reports (Available)',
	'2':'View All Reports (Created)',
	'3':'SQL to Excel Report Generation',
	'4':'Send All Reports Generated',
	'5':'SQL to Smartsheet Generation',
	'6':'Quit'}
options = od(sorted(menu_dict.items()))

def divider():
	print(" ****************************************")
	
def s_divider():
	print(" *                                      *")
	
def dtop():
	divider()
	s_divider()
	
def dmid():
	s_divider()
	divider()
	s_divider()
	
def dbot():
	s_divider()
	divider()
	
def menu():
	cls()
	dtop()
	print(" *         Welcome to the Manual        *")
	print(" *           Data Distribution          *")
	print(" *            Platform(Beta)!           *")
	dmid()
	print(" *      Please choose a report type     *")
	print(" *          from the menu below         *")
	dmid()
	menu_options()
	dbot()
	
def cls():
	sp.run(["cls"],shell=True)
	print("\n")

def menu_options():
	for k,v in options.items():
		print(" * ({}) {:32} *".format(k,v))
	
def files_gather(path,pattern):
	file_dict = {}
	option = 1
	for root, dirs, files in os.walk(path):
		for filename in fn.filter(files, pattern):
			file_dict[option] = filename
			option+=1
	return file_dict
	
def files_show(file_dict):
	print()
	for k,v in file_dict.items():
		print(" ({:2}) {}".format(k,v))
		
def run_report_gen(report_type):
	pattern = '* {} - *.sql'.format(report_type)
	file_dict = files_gather('SQL\\',pattern)
	report_key = 'sql'
	valid_file_dict = validate_report_display_menu(report_key, file_dict)
	files_show(valid_file_dict)
	sql_id = int(input("\n Choose SQL file to run: "))
	sql = valid_file_dict[sql_id]
	sql_index = sql[0:(sql.find(" Query - "))].lower()
	if sql_index[0] is '0':
		sql_index = sql_index[1:]
	try:
		sp.run(["python",
			parser['datadist']['main'],
			parser[sql_index]['sql'],
			parser[sql_index]['template'],
			parser[sql_index]['column'],
			parser[sql_index]['row'],
			parser[sql_index]['sheet']
		])
	except KeyError:
		print("\n ERROR: Sorry, that query has not been authorized for public use.\n Please contact your administrator with any questions or concerns.")
		input("\n [ PRESS ENTER TO CONTINUE ]\n")
		
def send_all_instance_files():
	file_list = glob.glob("Query_Results\\*.xlsx")
	if file_list:
		print("\n ...Files detected...\n")
		count = 1
		for item in file_list:
			print(" {}) {}".format(count,item))
			count+=1
		strEmails = input("\n Enter all email recipient addresses separated by a comma:\n ")
		strAttachments = ",".join(file_list)
		htmlTemplate = 'standard.html'
		try:
			sp.run(["python",
				parser['datadist']['email'],
				strEmails,
				strAttachments,
				htmlTemplate
			])
			print("\n Email successfully sent!")
		except ConnectionRefusedError:
			print("Caught!")
		file_dump = input("\n Dump original files? (Y/N)\n ")
		if file_dump.lower() == 'y':
			clear_files(file_list)
		input("\n [ PRESS ENTER TO CONTINUE ]\n")
	else:
		print("\n ...No files detected...\n\n Please run report generator to compile a list of reports to send.")
		input("\n [ PRESS ENTER TO CONTINUE ]\n")
		
def validate_report_display_menu(report_key, file_dict):
	compare_list = []
	for k,v in parser.items():
		for key,val in v.items():
			if key == report_key:
				compare_list.append(val[4:])
	tmp_file_dict = dc(file_dict)
	for k,v in file_dict.items():
		if v not in compare_list:
			del tmp_file_dict[k]
	tmp_file_list = list(tmp_file_dict.values())
	tmp_file_list.sort()
	valid_file_dict = {}
	count = 1
	for item in tmp_file_list:
		valid_file_dict[count] = item
		count+=1
	return valid_file_dict
		
def clear_files(file_list):
	for item in file_list:
		os.remove(item)
		
def manual_datadist():
	menu()
	choice = input("\n Choice: ")
	if choice is '1':
	
		# View All Reports (Available)
		file_dict = files_gather('SQL\\','*.sql')
		valid_file_dict = validate_report_display_menu('sql', file_dict)
		print()
		if valid_file_dict:
			for k,v in valid_file_dict.items():
				if v[0] == '0':
					des = v[1:3].lower().strip()
				else:
					des = v[:3].lower().strip()
				print(" {})\tSQL: {}\n\tDesc: {}".format(k,v,parser[des]['summary']))
			input("\n [ PRESS ENTER TO CONTINUE ]\n")
		else:
			print("\n ...No files detected...\n\n Please run report generator to compile a list of reports to send.")
			input("\n [ PRESS ENTER TO CONTINUE ]\n")
			return True
		return True

	elif choice is '2':
	
		# View All Reports (Created)
		file_dict = files_gather('Query_Results\\','*.xlsx')
		if file_dict:
			print("\n Files detected...\n")
			for k,v in file_dict.items():
				print(" {}".format(v))
			input("\n [ PRESS ENTER TO CONTINUE ]\n")
		else:
			print("\n ...No files detected...\n\n Please run report generator to compile a list of reports to send.")
			input("\n [ PRESS ENTER TO CONTINUE ]\n")
			return True
		return True
	elif choice is '3':
	
		# SQL to Excel Report Generation
		run_report_gen('Query')
		return True
		
	elif choice is '4':
		
		# Send All Reports Generated
		send_all_instance_files()
		return True
		
	elif choice is '5':
	
		# SQL to Smartsheet Generation
		run_report_gen('Smartsheet')
		return True
		
	else:
	
		# Quit
		clear_files(glob.glob("Query_Results\\*.xlsx"))
		return False
	
if __name__ == '__main__':
	valid=True
	while(valid):
		valid = manual_datadist()
	print("\n Terminating program. Have a nice day!")
