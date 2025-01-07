extends Node
## Used for loading and saving scores

var scores:Dictionary
const SAVE_FILE_PATH:String="user://stormwave_scores.dat"

func _ready() -> void:
	load_scores()
	print(scores)

## Adds a new score for the level, if a score already exists checks if
## the passed score is higher and overwrites the old score
## returns true if score was saved and false if there already exists a higher score
func add_score(level_identifier:String,score:int)->bool:
	if scores.has(level_identifier):
		if scores[level_identifier]>=score:
			return false
	scores[level_identifier]=score
	return true

## Loads high score for specific level, returns 0 if no score was found
func get_score(level_identifier:String)->int:
	var score:int=0
	if scores.has(level_identifier):
		score=scores[level_identifier]
	return score

## Loads score dictionary from file
func load_scores()->Dictionary:
	var dict:Dictionary={}
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_file:FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if save_file.get_error()!=OK:
			printerr("Error loading score")
			save_file.close()
			scores=dict
			return dict
		var loaded_var=save_file.get_var()
		if loaded_var is Dictionary:
			dict=loaded_var
			save_file.close()
			scores=dict
			return dict
	scores=dict
	return dict

## Saves the scores dictionary in the save file, returns false if saving failed
func save_scores()->bool:
	var save_file:FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file.get_error()!=OK:
		printerr("Saving score failed")
		return false
	save_file.store_var(scores)
	return true
