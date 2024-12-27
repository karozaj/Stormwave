extends Node3D
class_name BulletHoleSpawner

var bullet_hole=preload("res://scenes/weapons/weapon_effects/bullet_hole.tscn")

func spawn_bullet_hole(pos:Vector3, normal:Vector3,hole_size:float=1.0):
	var instance=bullet_hole.instantiate()
	Global.current_level.add_child(instance)
	instance.global_position=pos
	instance.size=hole_size*instance.size
	var target:Vector3=instance.global_transform.origin+normal
	if normal!=Vector3.UP and normal!=Vector3.DOWN:
		instance.look_at(target,Vector3.UP)
		instance.rotate_object_local(Vector3(1,0,0),90)
