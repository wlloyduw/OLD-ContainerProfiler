import argparse
import os, sys
import json
import ConfigParser
from collections import namedtuple
#^.*cCpu[0-9]*TIME regex

generated_script= open("auto_generated_delta_script.py","w")
generated_script.write("import argparse\nimport os\nimport sys\nimport json\nimport ConfigParser\nfrom collections import namedtuple\n\n")

generated_script.write("parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')\n")
generated_script.write("parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')\n")
generated_script.write("args= parser.parse_args()\n")
generated_script.write("file_path = args.file_path\n")

generated_script.write("json_array = []\n")
generated_script.write("dirs=  [i for i in os.listdir( file_path ) if i.endswith(\".json\")]\n")
generated_script.write("dirs.sort()\n")
generated_script.write("for file_name in dirs:\n")
generated_script.write("	with open(file_path + '/' + file_name) as json_file: \n")
generated_script.write("		new_json_object = json.load(json_file)\n")#, object_hook=lambda d: namedtuple('X', d.keys())(*d.values()))\n")
generated_script.write("    		json_array.append(new_json_object)\n\n")


parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')
args= parser.parse_args()
file_path = args.file_path

json_array = []
dirs=  [i for i in os.listdir( file_path ) if i.endswith(".json")]
dirs.sort()
for file_name in dirs:
	with open(file_path + '/' + file_name) as json_file: 
		new_json_object = json.load(json_file)#, object_hook=lambda d: namedtuple('X', d.keys())(*d.values()))
    		json_array.append(new_json_object)

config = ConfigParser.ConfigParser()
config.optionxform = str 
config.read('graph_generation_config.ini')

#script generation
generated_script.write("def file_subtraction(the_json_one, the_json_two):\n")

for (each_key, each_val) in config.items('all'):
        if ( each_val == 'numeric_delta'): #and each_key.isdigit()):
		json_two = "the_json_two['" +each_key+ "']"
		json_one = "the_json_one['" +each_key+"']"
		generated_script.write("\t" + json_two +"=" + json_two +'-' + json_one+"\n")

if (config.get('cprocessorstats','cCpu#TIME')):
	generated_script.write("\tfor (each_key) in the_json_two['cProcessorStats']:\n")
	generated_script.write("\t\tif ('cCpu' in each_key and 'TIME' in each_key):\n")
	generated_script.write("\t\t\tthe_json_two['cProcessorStats'][each_key] = the_json_two['cProcessorStats'][each_key] - the_json_one['cProcessorStats'][each_key]\n")


generated_script.write("\n")
generated_script.write("file_subtraction(json_array[0], json_array[1])\n")

     


#with open('result2.json', 'w') as fp:
 #   json.dump(json_array[2], fp, sort_keys=True, indent=2)


	
		
