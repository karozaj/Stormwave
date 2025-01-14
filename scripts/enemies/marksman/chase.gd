extends State

@onready var state_owner:EnemyMarksman=get_owner()


func enter(_transition_data:Dictionary={})->void:
	state_owner.animation_tree.set("parameters/AttackOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	state_owner.update_target_position()
	state_owner.update_navigation_target_position()
	state_owner.update_navagent_target_position()
	state_owner.target_update_timer.start()

func physics_update(delta:float)->void: #move towards target, enter attack state if target in range
	#if NavigationServer3D.map_get_iteration_id(state_owner.navigation_agent.get_navigation_map()) == 0:
		#return
	#if state_owner.navigation_agent.is_navigation_finished():
		#return
	if state_owner.is_on_floor()==false:
		finished.emit(self,"Falling")
	#var target_position:Vector3=state_owner.target.aim_point.global_position
	var target_position:Vector3=state_owner.navigation_agent.get_next_path_position()
	#if state_owner.global_position.distance_to(target_position)<=state_owner.attack_range:
		#state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,state_owner.agility*delta)
		#if state_owner.cooldown_timer.is_stopped():
			#finished.emit(self, "Attack")
			

		
	var current_location=state_owner.global_transform.origin
	var next_location=Vector3(target_position.x,state_owner.global_position.y,target_position.z)
	var new_velocity=(next_location-current_location).normalized()*state_owner.move_speed
	if state_owner.navigation_agent.avoidance_enabled:
		state_owner.navigation_agent.set_velocity(new_velocity)
		state_owner.velocity=state_owner.velocity.move_toward(state_owner.new_safe_velocity,state_owner.agility*delta)
		state_owner.move_and_slide()
	else:
		state_owner.velocity=state_owner.velocity.move_toward(new_velocity,state_owner.agility*delta)
		state_owner.move_and_slide()
	
	#if state_owner.navigation_agent.is_target_reachable()==false:
		#print("unreachable")
		##state_owner.velocity.move_toward(Vector3.ZERO,state_owner.agility*delta)
		#state_owner.velocity=Vector3.ZERO

func update(_delta:float)->void:		
	var looking_position:Vector3=state_owner.global_position+state_owner.velocity.normalized()
	looking_position=Vector3(looking_position.x,state_owner.global_position.y,looking_position.z)
	if state_owner.global_position.distance_to(looking_position)>0.01:
		state_owner.look_at(looking_position)
	
	if state_owner.target==null:
		finished.emit(self,"Idle")
		return
		
	var opponent_position:Vector3=state_owner.target_position
	
	opponent_position=Vector3(opponent_position.x,state_owner.global_position.y,opponent_position.z)
	
	if state_owner.navigation_agent.is_target_reachable()==false:
		#if state_owner.target_position.y-state_owner.global_position.y>3.5:
			if state_owner.attack_cooldown_timer.time_left<=0.0:
				if state_owner.are_enemies_in_laser_path()==false:# and state_owner.is_wall_blocking_gun()==false:
					finished.emit(self,"Attack")
					return
	#
	#if state_owner.global_position.distance_to(opponent_position)<=state_owner.melee_range:
		#if state_owner.attack_melee_cooldown_timer.time_left<=0.0:
			#finished.emit(self,"AttackMelee")
			#return
			#
	if state_owner.global_position.distance_to(opponent_position)<=state_owner.attack_range:
		if state_owner.attack_cooldown_timer.time_left<=0.0:
			if state_owner.are_enemies_in_laser_path()==false:# and state_owner.is_wall_blocking_gun()==false:
				finished.emit(self,"Attack")
				return
	#

		

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})

func exit()->void:
	state_owner.target_update_timer.stop()
