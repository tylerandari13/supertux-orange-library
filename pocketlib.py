# This packages all of the api into one file for on the go... stuff

import os

cur_dir = os.path.dirname(os.path.realpath(__file__))
output_file = "liborange-pocket.nut"

temp = {}

def add_file(file):
	temp[file] = "// " + file + "\n\n" + open(cur_dir + "/orange-api/" + file).read() + "\n\n"

add_file("orange_api_util.nut")
for file in os.listdir(cur_dir + "/orange-api"):
	if(file.endswith(".nut") and file != "orange_api_util.nut"):
		add_file(file)

temp_file = ""
for line in open(cur_dir + "/liborange.nut").read().split("\n"):
	if(line.startswith("	")):
		temp_file += temp[line.split("\"")[1] + ".nut"]

temp = temp_file.split("\n")
temp_file = ""

for line in temp:
	if(line.find("import(")): # how does this work
		temp_file += line + "\n"

temp_file = "// auto generated by pocketlib.py\n// this is the entire orange library condensed into one script\n\n" + temp_file

open(cur_dir + "/" + output_file, "w").write(temp_file)
