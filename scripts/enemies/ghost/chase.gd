extends State

@onready var state_owner:EnemyGhost=get_owner()

func enter(_transition_data:Dictionary={})->void:
	state_owner.animation_player.play("idle")

func update(delta:float)->void: #move towards target, enter attack state if target in range
	if state_owner.global_position.distance_to(state_owner.target.global_position)<=state_owner.attack_range:
		state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,state_owner.agility*delta)
		if state_owner.cooldown_timer.is_stopped():
			finished.emit(self, "Attack")
	var current_location=state_owner.global_transform.origin
	#add 0.75 to y axis because the player global position is at the player character's center and we want to aim a bit higher
	var next_location=state_owner.target.global_position+Vector3(0,0.75,0)
	var new_velocity=(next_location-current_location).normalized()*state_owner.move_speed
	state_owner.velocity=state_owner.velocity.move_toward(new_velocity,state_owner.agility*delta)
	state_owner.look_at(state_owner.global_position+state_owner.velocity.normalized())
	state_owner.move_and_slide()

func damage(damage_points:int, origin:Vector3)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin})
	
