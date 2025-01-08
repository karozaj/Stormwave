extends MeshInstance3D
class_name LaserEffect

@onready var timer:Timer=$Timer
## How long the laser is visible
@export var laser_visibility_time:float=0.1
#draws a laser effect between the target and origin position
func show_laser_effect(origin_pos:Vector3,target_pos:Vector3):
	global_position=(target_pos+origin_pos)/2
	var laser_scale:float=1.0/0.1*target_pos.distance_to(origin_pos)
	scale=Vector3(1,1,laser_scale)
	if global_position.distance_to(target_pos)>0.01:
		look_at(target_pos)
	visible=true
	timer.start(laser_visibility_time)


func _on_timer_timeout() -> void:
	visible=false
