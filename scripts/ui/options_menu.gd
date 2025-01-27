extends Control


func _ready() -> void:
	$VBoxContainer/GridContainer/VBoxContainer/SFXSlider.value=Global.get_volume("SFX")
	$VBoxContainer/GridContainer/VBoxContainer2/MusicSlider.value=Global.get_volume("Music")
	$VBoxContainer/FullscreenButton.button_pressed=Global.is_fullscreen()
	Input.mouse_mode=Input.MOUSE_MODE_CONFINED
	



func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	if toggled_on==true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	if toggled_on==false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);


func _on_sfx_slider_value_changed(value: float) -> void:
	Global.update_bus_volume("SFX",value)



func _on_music_slider_value_changed(value: float) -> void:
	Global.update_bus_volume("Music",value)
	$VBoxContainer/GridContainer/VBoxContainer2/MusicSlider/AudioStreamPlayer.play()
