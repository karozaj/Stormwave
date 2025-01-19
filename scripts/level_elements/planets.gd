extends Node3D

@export var rotation_speed:float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotate(Vector3(0,1,0),rotation_speed*delta)
	rotate(Vector3(0,1,0),rotation_speed*delta)
