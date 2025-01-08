extends State

@onready var state_owner:EnemyMarksman=get_owner()
var timer:Timer

func enter(_transition_data:Dictionary={})->void:
	timer=Timer.new()
	state_owner.add_child(timer)
	timer.start(1)
	timer.timeout.connect(finished.emit.bind(self,"Chase"))
	if state_owner.target!=null:
		var looking_position:Vector3=state_owner.target_position
		looking_position=Vector3(looking_position.x,state_owner.global_position.y,looking_position.z)
		if state_owner.global_position.distance_to(looking_position)>0.01:
			state_owner.look_at(looking_position)
		if state_owner.weapon_raycast.global_position.distance_to(state_owner.target_position)>0.01:
			state_owner.weapon_raycast.look_at(state_owner.target_position)
	state_owner.animation_tree.set("parameters/AttackOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#state_owner.play_sound_effect(state_owner.pain_sound,0,0.3, state_owner.base_pitch)

#func update(_delta:float)->void:
	#if state_owner.target!=null:
		#var looking_position:Vector3=state_owner.target_position
		#looking_position=Vector3(looking_position.x,state_owner.global_position.y,looking_position.z)
		#state_owner.look_at(looking_position)
	
func physics_udpate(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3(0.0,state_owner.velocity.y,0.0),delta*state_owner.agility)
	state_owner.move_and_slide()

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})

func exit()->void:
	timer.queue_free()
	state_owner.attack_cooldown_timer.start(state_owner.attack_cooldown)
	#state_owner.animation_player.play("RESET")
