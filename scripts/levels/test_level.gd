extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_level=self
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
