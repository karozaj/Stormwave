extends Node
## Used for loading and saving settings

const SAVE_FILE_PATH:String="user://settings.cfg"

const audio_section_name:String="AUDIO"
const camera_section_name:String="CAMERA"
const display_section_name:String="DISPLAY"

const sfx_volume:String="sfx_volume"
const music_volume:String="music_volume"
const player_sensitivity:String="player_sensitivity"
const player_fov:String="player_fov"
const player_headbob_enabled:String="player_headbob_enabled"
const fullscreen:String="fullscreen"



func save_settings():
	print("saving settings")
	var config=ConfigFile.new()
	config.set_value(audio_section_name,sfx_volume,Global.get_volume("SFX"))
	config.set_value(audio_section_name,music_volume,Global.get_volume("Music"))

	config.set_value(camera_section_name,player_sensitivity,Global.player_sensitivity)
	config.set_value(camera_section_name,player_fov,Global.player_fov)
	config.set_value(camera_section_name,player_headbob_enabled,Global.player_headbob_enabled)

	config.set_value(display_section_name,fullscreen,Global.is_fullscreen())

	save_file(config,SAVE_FILE_PATH)
	#var result=config.save(SAVE_FILE_PATH)
	#if(result!=OK):
		#printerr("Error while saving settings: "+result)

func load_settings():
	var config=ConfigFile.new()
	
	if load_file(config,SAVE_FILE_PATH)==false:
		return
	#var result=config.load(SAVE_FILE_PATH)
	#if(result!=OK):
		#if(result==ERR_FILE_NOT_FOUND):
			#print("Settings config file does not exist")
			#return
		#printerr("Error when loading settings from config file: "+result)
		#return

	Global.update_bus_volume("SFX",config.get_value(audio_section_name,sfx_volume))
	Global.update_bus_volume("Music",config.get_value(audio_section_name,music_volume))
	
	Global.player_sensitivity=config.get_value(camera_section_name,player_sensitivity)
	Global.player_fov=config.get_value(camera_section_name,player_fov)
	Global.player_headbob_enabled=config.get_value(camera_section_name,player_headbob_enabled)

	var is_fullscreen=config.get_value(display_section_name,fullscreen)
	if is_fullscreen==true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	if is_fullscreen==false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);


const KEYBINDS_FILE_PATH:String="user://keybinds.cfg"
const keybinds_section_name:String="KEYBINDS"

func load_keybinds():
	var config=ConfigFile.new()
	
	if load_file(config,KEYBINDS_FILE_PATH)==false:
		return
	var actions = KeyRebinding.get_actions_array()
	for action in actions:
		var saved_action_event:InputEvent=config.get_value(keybinds_section_name,action,null)
		if(saved_action_event!=null):
			InputMap.action_erase_events(action)
			#Input.action_press()
			InputMap.action_add_event(action,saved_action_event)
		
	

func save_keybinds():
	var config=ConfigFile.new()
	var actions = KeyRebinding.get_actions_array()
	for action in actions:
		if(InputMap.action_get_events(action).size()>0):
			config.set_value(keybinds_section_name,action,InputMap.action_get_events(action)[0])
	
	save_file(config,KEYBINDS_FILE_PATH)

func save_file(config_file:ConfigFile, filepath:String):
	var result=config_file.save(filepath)
	if(result!=OK):
		printerr("Error while saving settings: "+result)

func load_file(config_file:ConfigFile, filepath:String)->bool:
	var result=config_file.load(filepath)
	if(result!=OK):
		if(result==ERR_FILE_NOT_FOUND):
			print("Settings config file does not exist")
			return false
		printerr("Error when loading settings from config file: "+result)
		return false
	else:
		return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	load_keybinds()
