extends Node

var current_level:BaseLevel=null
var scene_to_load:String
var player:Player=null
var player_fov:int=90:
	get:
		return player_fov
	set(value):
		player_fov=value
		player.base_fov=player_fov
var player_sensitivity:float=1.0:
	get:
		return player_sensitivity
	set(value):
		player_sensitivity=value
		player.mouse_sensitivity=player_sensitivity
var player_headbob_enabled:bool=true:
	get:
		return player_headbob_enabled
	set(value):
		player_headbob_enabled=value
		player.headbob_enabled=player_headbob_enabled

func get_volume(bus_name:String)->float:
	var bus_index= AudioServer.get_bus_index(bus_name)
	var volume_db:float=AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func update_bus_volume(bus_name:String,value:float)->void:
	var bus_index= AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(value))

func is_fullscreen()->bool:
	if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN:
		return true
	else:
		return false
