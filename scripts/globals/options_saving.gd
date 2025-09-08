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

	var result=config.save(SAVE_FILE_PATH)
	if(result!=OK):
		printerr("Error while saving settings: "+result)

func load_settings():
	var config=ConfigFile.new()
	
	var result=config.load(SAVE_FILE_PATH)
	if(result!=OK):
		if(result==ERR_FILE_NOT_FOUND):
			print("Settings config file does not exist")
			return
		printerr("Error when loading settings from config file: "+result)
		return

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
