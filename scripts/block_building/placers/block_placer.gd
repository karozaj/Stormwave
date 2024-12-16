extends PlacerBaseClass

@onready var ray:RayCast3D=$RayCast3D

func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos


func destroy()->bool:
	if ray.is_colliding():
		if ray.get_collider().has_method("destroy_block"):
			if ray.get_collider().destroy_block(ray.get_collision_point()-ray.get_collision_normal()/2)==true:
				#audio_player.stream=destroy_block_sound
				audio_player.play()
				animation_player.play("use")
				return true
	return false

func place()->bool:
	if ray.is_colliding():
		if ray.get_collider().has_method("place_block"):
			if can_block_be_placed(ray.get_collision_point())==true:
				ray.get_collider().place_block(ray.get_collision_point()+ray.get_collision_normal()/2)
				#audio_player.stream=place_block_sound
				animation_player.play("use")
				audio_player.play()
				#animation_player.play("use")
				return true
	return false

func can_block_be_placed(target:Vector3)->bool:
	#check vertical distance
	if target.y>ray.global_position.y+1.25:
		return true
	elif target.y<(ray.global_position.y-player_height):
		return true
	#check horizontal distance
	elif Vector2(target.x,target.z).distance_to(Vector2(ray.global_position.x,ray.global_position.z))>player_radius+1.0:
		return true
	return false

func highlight():
	if ray.is_colliding():
		if ray.get_collider().has_method("highlight"):
			ray.get_collider().highlight(ray.get_collision_point()-ray.get_collision_normal()/2)
