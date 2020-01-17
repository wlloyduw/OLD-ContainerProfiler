#Creates a script based on graph_generation_config.ini to create a delta script to delta certain metrics, and avoids others.
import argparse
import os
import json
import ConfigParser


from collections import namedtuple

generated_script= open("auto_generated_delta_script.py","w")
generated_script.write("import argparse\nimport os\nimport shutil\nimport sys\nimport json\nimport copy\nimport ConfigParser\nfrom collections import namedtuple\n\n")

generated_script.write("parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')\n")
generated_script.write("parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')\n")
generated_script.write("parser.add_argument('delta_interval_time', action='store', help='stores time interval of when to take delta sample')\n")
generated_script.write("args= parser.parse_args()\n")
generated_script.write("file_path = args.file_path\n")

generated_script.write("if os.path.exists(file_path + \'/delta_json\'):\n")
generated_script.write("\tshutil.rmtree(file_path + \'/delta_json\')\n")


generated_script.write("if not os.path.exists(file_path + '/delta_json'):\n")
generated_script.write("\tos.makedirs(file_path + '/delta_json')\n\n")

generated_script.write("json_array = []\n")
generated_script.write("delta_name_array = []\n")
generated_script.write("dirs=  [i for i in os.listdir( file_path ) if i.endswith(\".json\")]\n")
generated_script.write("dirs.sort()\n")

generated_script.write("for file_name in dirs:\n")
generated_script.write("\twith open(file_path + '/' + file_name) as json_file: \n")
generated_script.write("\t\ttry:\n")

generated_script.write("\t\t\tnew_json_object = json.load(json_file)\n")#, object_hook=lambda d: namedtuple('X', d.keys())(*d.values()))\n")
generated_script.write("\t\t\tjson_array.append(new_json_object)\n")
generated_script.write("\t\t\tnew_name= ((file_path+'/delta_json/'+file_name).split('.json')[0] + '_delta.json')\n")

generated_script.write("\t\t\tdelta_name_array.append(new_name)\n\n")
generated_script.write("\t\texcept Exception as e:\n")

generated_script.write("\t\t\tprint (\"{} invalid file\".format(json_file))\n")
generated_script.write("\t\t\tpass\n")
config = ConfigParser.ConfigParser()
config.optionxform = str 
config.read('graph_generation_config.ini')


#script generation
generated_script.write("def file_subtraction(the_json_one, the_json_two):\n")
generated_script.write("\tjson_three = copy.deepcopy(the_json_two)\n")
for (each_key, each_val) in config.items('all'):
        if ( each_val == 'numeric_delta'): #and each_key.isdigit()):

		json_one = "the_json_one['" +each_key+"']"
		json_two = "the_json_two['" +each_key+"']"
		json_three = "json_three['" +each_key+"']"
		generated_script.write("\t" + json_three +"=" + json_two +'-' + json_one+"\n")

if (config.get('cprocessorstats','cCpu#TIME')):
	generated_script.write("\tfor (each_key) in the_json_two['cProcessorStats']:\n")
	generated_script.write("\t\tif ('cCpu' in each_key and 'TIME' in each_key):\n")
	generated_script.write("\t\t\tjson_three['cProcessorStats'][each_key] = the_json_two['cProcessorStats'][each_key] - the_json_one['cProcessorStats'][each_key]\n")
generated_script.write("\treturn json_three\n\n")

generated_script.write("delta_json_array=[]\n")
generated_script.write("count = 0\n")
generated_script.write("first = json_array[0]\n")

generated_script.write("for i in range(1, len(json_array)):\n")

generated_script.write("\tcount +=   (json_array[i][\"currentTime\"] - json_array[i-1][\"currentTime\"])\n")
generated_script.write("\tif count >= int(args.delta_interval_time):\n")
generated_script.write("\t\tdelta_json_array.append(file_subtraction(first, json_array[i]))\n")
generated_script.write("\t\tcount = 0\n")
generated_script.write("\t\tfirst = json_array[i]\n")


generated_script.write("\n")
generated_script.write("for i in range(len(delta_json_array)):\n")

     
generated_script.write("\twith open(delta_name_array[i], 'w') as fp:\n")
generated_script.write("\t\tjson.dump(delta_json_array[i], fp, sort_keys=True, indent=2)\n")


	
		
