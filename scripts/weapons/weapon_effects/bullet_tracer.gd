extends Node3D
class_name BulletTracer

var origin_point:Vector3
var target_point:Vector3
var fadeout:bool=true
var visibility_time:float=0.1
var material:StandardMaterial3D
var thickness_scale:float=1.0
@onready var tracer_line=$Node3D
@onready var timer:Timer=$Timer
var tween

## Use this function to create a bullet tracer
static func create_effect(tracer_origin_point:Vector3, tracer_target_point:Vector3, tracer_material:StandardMaterial3D,  tracer_fadeout:bool=true, tracer_visibility_time:float=0.1, tracer_thickness_scale=1.0):
	var tracer:BulletTracer=load("res://scenes/weapons/weapon_effects/bullet_tracer.tscn").instantiate()
	tracer.origin_point=tracer_origin_point
	tracer.target_point=tracer_target_point
	tracer.fadeout=tracer_fadeout
	tracer.visibility_time=tracer_visibility_time
	tracer.material=tracer_material.duplicate()
	tracer.thickness_scale=tracer_thickness_scale
	
	return tracer

func _ready() -> void:
	$Node3D/MeshInstance3D.material_override=material
	$Node3D/MeshInstance3D2.material_override=material
	global_position=origin_point
	look_at(target_point)
	if (origin_point-target_point).length()<=0.05:
		tracer_line.scale.z=0.05
	else:
		tracer_line.scale.z=(origin_point-target_point).length()/2
	tracer_line.scale.x=thickness_scale
	tracer_line.scale.y=thickness_scale
	timer.wait_time=visibility_time
	timer.start()
	if fadeout:
		tween=create_tween()
		tween.tween_property(material, "albedo_color:a", 0, visibility_time)

func _on_timer_timeout() -> void:
	if is_instance_valid(tween):
		tween.kill()
	queue_free()
