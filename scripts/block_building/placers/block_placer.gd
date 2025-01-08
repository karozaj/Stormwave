extends PlacerBaseClass


#sets ray position to align with player camera
func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos

#destroys the block, returns true if block was destroyed succesfullt
func collect()->String:
	print("collect")
	var block_name:String="None"
	if ray.is_colliding():
		if ray.get_collider().has_method("collect_block"):
			block_name= ray.get_collider().collect_block()
			animation_player.play("use")
	return block_name

#places the block, returns true if block was placed succesfully
func place()->bool:
	if ray.is_colliding():
		if ray.get_collider()!=null and ray.get_collider().has_method("place_block"):
			if can_block_be_placed(ray.get_collision_point())==true:
				if ray.get_collider().place_block(ray.get_collision_point()+ray.get_collision_normal()/2,block):
					play_place_sound()
					animation_player.play("use")
					return true
	return false

#checks if there's enough space to place the block
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
