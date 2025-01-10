extends State

@onready var state_owner:EnemyCloud=get_owner()


func update(delta:float)->void: #move towards target, enter attack state if target in range
	if state_owner.target==null:
		finished.emit(self,"Idle")
		return
		
	var target_position:Vector3=state_owner.target_position
	var current_location=state_owner.global_transform.origin
	var next_location=state_owner.navigation_target_position#target_position+Vector3(0,state_owner.height_over_target,0)
	if Vector2(current_location.x,current_location.z).distance_to(Vector2(next_location.x,next_location.z))>0.01: #make sure target isn't directly below
		state_owner.eye.look_at(target_position)
	if Vector2(current_location.x,current_location.z).distance_to(Vector2(next_location.x,next_location.z))>state_owner.attack_range:
		var new_velocity=(next_location-current_location).normalized()*state_owner.move_speed
		state_owner.velocity=state_owner.velocity.move_toward(new_velocity,state_owner.agility*delta)
	else: # if target in range, stop
		state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,state_owner.agility*delta)
		if state_owner.cooldown_timer.is_stopped(): #if attack isn't on cooldown, begin attack
			finished.emit(self,"Attack")
		
	## check if the enemy is colliding with a wall, if so it will try to break through it
	if state_owner.move_and_slide():
		if state_owner.cooldown_timer.is_stopped():
			finished.emit(self, "Attack")

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
	
