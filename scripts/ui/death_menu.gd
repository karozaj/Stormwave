extends Control

@onready var death_label:Label=$VBoxContainer/Label
@onready var tween = create_tween()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().paused=true
	show()
	Input.mouse_mode=Input.MOUSE_MODE_CONFINED
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 1)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		_on_button_quit_pressed()
	elif event.is_action_pressed("enter"):
		_on_button_retry_pressed()

func _on_button_retry_pressed() -> void:
	tween.kill()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	#get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")



func _on_button_quit_pressed() -> void:
	tween.kill()
	#get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
