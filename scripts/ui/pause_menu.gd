extends Control
class_name PauseMenu

func _ready() -> void:
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
	
func _on_quit_button_pressed():
	MusicPlayer.fade_out()
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
