extends State

@onready var state_owner:EnemyCloud=get_owner()
var timer:Timer

func enter(_transition_data:Dictionary={})->void:
	timer=Timer.new()
	state_owner.add_child(timer)
	#if charging time elapses before leaving attack state, perform attack and leave state
	timer.start(state_owner.attack_charging_time)
	timer.timeout.connect(finished.emit.bind(self,"Chase"))
	timer.timeout.connect(state_owner.shoot_lightning)
	state_owner.play_sound_effect(state_owner.charging_sound,0.0,0.0,state_owner.base_pitch)
	state_owner.animation_player.play("attack")

func update(delta:float)->void:
	var current_location=state_owner.global_transform.origin
	var target_position:Vector3=state_owner.target_position
	var target_location=state_owner.navigation_target_position#target_position+Vector3(0,state_owner.height_over_target,0)
	#look at target if target is not directly underneath
	if Vector2(current_location.x,current_location.z).distance_to(Vector2(target_location.x,target_location.z))>0.01:
		state_owner.eye.look_at(target_position)
		#aim attack raycast at target if target in range
		if Vector2(current_location.x,current_location.z).distance_to(Vector2(target_location.x,target_location.z))<=state_owner.attack_range:
			state_owner.raycast.look_at(target_position)
	#stop moving before performing attack
	state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,delta*state_owner.agility)
	state_owner.move_and_slide()

func exit()->void:
	state_owner.animation_player.play("RESET")
	state_owner.cooldown_timer.start()
	timer.queue_free()

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
