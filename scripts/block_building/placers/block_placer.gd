extends PlacerBaseClass

@onready var ray:RayCast3D=$RayCast3D


func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos

#func _process(_delta: float) -> void:
	#highlight()
	#if Input.is_action_just_pressed("shoot"):
		#destroy()
		#animation_player.play("use")
	#if Input.is_action_just_pressed("place_block"):
		#place()
		#animation_player.play("use")


func destroy()->bool:
	if ray.is_colliding():
		if ray.get_collider().has_method("destroy_block"):
			if ray.get_collider().destroy_block(ray.get_collision_point()-ray.get_collision_normal()/2)==true:
				#audio_player.stream=destroy_block_sound
				audio_player.play()
				animation_player.play("use")
				#animation_player.play("use")
				return true
	return false

func place()->bool:
	if ray.is_colliding():
		if ray.get_collider().has_method("place_block"):
			if check_block_clearance(ray.get_collision_point())==true:
				ray.get_collider().place_block(ray.get_collision_point()+ray.get_collision_normal()/2)
				#audio_player.stream=place_block_sound
				animation_player.play("use")
				audio_player.play()
				#animation_player.play("use")
				return true
	return false

func check_block_clearance(target:Vector3)->bool:
	var distance=target.distance_to(ray.global_position-Vector3(0.0,0.775,0.0))
	if distance>1.5:
		return true
	return false

func highlight():
	if ray.is_colliding():
		if ray.get_collider().has_method("highlight"):
			ray.get_collider().highlight(ray.get_collision_point()-ray.get_collision_normal()/2)
