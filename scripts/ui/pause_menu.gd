extends Control
class_name PauseMenu

## Load settings values
func _ready() -> void:
	$VBoxContainer/GridContainer/VBoxContainer/SFXSlider.value=Global.get_volume("SFX")
	$VBoxContainer/GridContainer/VBoxContainer2/MusicSlider.value=Global.get_volume("Music")
	$VBoxContainer/GridContainer/VBoxContainer3/FOVSlider.value=Global.player_fov
	$VBoxContainer/GridContainer/VBoxContainer4/SensitivitySlider.value=Global.player_sensitivity
	$VBoxContainer/FullscreenButton.button_pressed=Global.is_fullscreen()
	$VBoxContainer/HeadbobButton.button_pressed=Global.player_headbob_enabled
	get_tree().paused=true
	show()
	Input.mouse_mode=Input.MOUSE_MODE_CONFINED

## resume game if pause button is pressed again
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_on_resume_button_pressed()

func _on_resume_button_pressed():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	get_tree().paused=false
	queue_free()
## TODO: change scene to main menu when pressing quit
func _on_quit_button_pressed():
	MusicPlayer.fade_out()
	get_tree().paused=false
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


func _on_fov_slider_value_changed(value: int) -> void:
	Global.player_fov=value


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Global.player_sensitivity=value


func _on_headbob_button_toggled(toggled_on: bool) -> void:
	if toggled_on==true:
		Global.player_headbob_enabled=true
	if toggled_on==false:
		Global.player_headbob_enabled=false
