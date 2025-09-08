extends MenuWithNavigation

@export var sfx_slider:Slider
@export var music_slider:Slider
@export var fov_slider:Slider
@export var sensitivity_sldier:Slider

@export var fullscreen_button:CheckButton
@export var headbob_button:CheckButton

##DEFAULT VALUES
const DEFAULT_FULLSCREEN:bool=false
const DEFAULT_HEADBOB:bool=true
const DEFAULT_SENSITIVITY:float=1.0
const DEFAULT_SFX:float=1.0
const DEFAULT_MUSIC:float=0.5
const DEFAULT_FOV:float=90.0


func _ready() -> void:
	super._ready()
	update_all_controls_state()
	Input.mouse_mode=Input.MOUSE_MODE_CONFINED
	


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

func reset_to_defaults():
	
	if DEFAULT_FULLSCREEN==true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	if DEFAULT_FULLSCREEN==false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
	
	Global.player_headbob_enabled=DEFAULT_HEADBOB
	Global.player_sensitivity=DEFAULT_SENSITIVITY
	Global.update_bus_volume("SFX",DEFAULT_SFX)
	Global.update_bus_volume("Music",DEFAULT_MUSIC)
	Global.player_fov=DEFAULT_FOV
	
	update_all_controls_state()

func update_all_controls_state():
	sfx_slider.value=Global.get_volume("SFX")
	music_slider.value=Global.get_volume("Music")
	fov_slider.value=Global.player_fov
	sensitivity_sldier.value=Global.player_sensitivity
	fullscreen_button.button_pressed=Global.is_fullscreen()
	headbob_button.button_pressed=Global.player_headbob_enabled
