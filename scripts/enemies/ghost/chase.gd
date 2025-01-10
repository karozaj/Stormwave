extends State

@onready var state_owner:EnemyGhost=get_owner()

func enter(_transition_data:Dictionary={})->void:
	state_owner.animation_player.play("idle")

func update(delta:float)->void: #move towards target, enter attack state if target in range
	if state_owner.target==null:
		finished.emit(self,"Idle")
		return
	
	var target_position:Vector3=state_owner.target_position
	if state_owner.global_position.distance_to(target_position)<=state_owner.attack_range:
		state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,state_owner.agility*delta)
		if state_owner.cooldown_timer.is_stopped():
			finished.emit(self, "Attack")
	var current_location=state_owner.global_transform.origin
	var next_location=state_owner.navigation_target_position
	var new_velocity=(next_location-current_location).normalized()*state_owner.move_speed
	state_owner.velocity=state_owner.velocity.move_toward(new_velocity,state_owner.agility*delta)
	var looking_position:Vector3=state_owner.global_position+state_owner.velocity.normalized()
	if state_owner.global_position.distance_to(looking_position)>0.01:
		state_owner.look_at(looking_position)
	## check if the ghost is colliding with a wall, if so the ghost will try to break through it
	if state_owner.move_and_slide():
		if state_owner.cooldown_timer.is_stopped():
			finished.emit(self, "Attack")

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
	
