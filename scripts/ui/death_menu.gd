extends Control
class_name DeathMenu

@onready var death_label:Label=$VBoxContainer/Label
@onready var cause_label:Label=$VBoxContainer/LabelCause
@onready var score_label:Label=$VBoxContainer/LabelScore
@onready var tween = create_tween()

var message:String="You died."
var score_message:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().paused=true
	cause_label.text=message
	score_label.text=score_message
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
	get_tree().change_scene_to_file("res://scenes/ui/loading_screen.tscn")



func _on_button_quit_pressed() -> void:
	tween.kill()
	#get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
