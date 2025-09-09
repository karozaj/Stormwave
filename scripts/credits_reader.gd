extends Node
class_name CreditsReader

const FILE_NAME:String="res://StormwaveCredits.csv"

#first row - titles
# col 0 - name
# col 1 - creator
# col 2 - link
# col 3 -type
# col 4 - license

var types_dictionary:Dictionary


func read_credits_file():
	var file=FileAccess.open(FILE_NAME, FileAccess.READ)
	if(!file.eof_reached()):
		file.get_csv_line(";") #skip first line
		
	while !file.eof_reached():
		var csv = file.get_csv_line(";")
		csv.resize(5)
		add_line_to_dictionary(csv)

	file.close()
	
func add_line_to_dictionary(line:PackedStringArray):
	if(len(line)<4 or line[0].is_empty()):
		return
	#print(get_string_line_richtext(line))
	var asset_type=line[3]
	if(types_dictionary.keys().has(asset_type)):
		types_dictionary[asset_type].append(line)
	elif(asset_type.is_empty()==false):
		types_dictionary[asset_type]=[]
		types_dictionary[asset_type].append(line)

func get_credits_string_richtext():
	read_credits_file()
	var credits_string="[center]Assets used in this game:\n\n"
	var keys=types_dictionary.keys()
	for key in keys:
		credits_string+=key+":\n"
		for line in types_dictionary[key]:
			credits_string+=get_string_line_richtext(line)+"\n"
		credits_string+="\n"
	credits_string+="[/center]"
	return credits_string

func add_credits_text_to_rich_text_label(label:RichTextLabel):
	read_credits_file()
	label.text="Assets used in this game:\n\n"
	var keys=types_dictionary.keys()
	for key in keys:
		label.append_text(key+":\n")
		for line in types_dictionary[key]:
			label.append_text(get_string_line_richtext(line)+"\n")
		label.append_text("\n")

func get_string_line_richtext(line:PackedStringArray)->String:
#	[url=https://opengameart.org/content/water-texture-pack]Water texture pack[/url] by Proxy Games
	var string="[url=%s]%s[/url] by %s"
	string=string%[line[2],line[0],line[1]]
	return string
