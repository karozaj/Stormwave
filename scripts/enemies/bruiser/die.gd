extends State

@onready var state_owner:EnemyBruiser=get_owner()
var timer:Timer

func enter(_transition_data:Dictionary={})->void:
	state_owner.is_dead=true
	state_owner.died.emit(state_owner)
	timer=Timer.new()
	state_owner.add_child(timer)
	timer.start(2)
	timer.timeout.connect(state_owner.queue_free)
	state_owner.animation_tree.set("parameters/AttackOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	state_owner.animation_tree.set("parameters/AttackMeleeOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)	
	state_owner.animation_tree.set("parameters/DeathOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	state_owner.particles.emitting=false
	#disable hitboxes so enemy can't be damaged after death
	for hitbox in state_owner.hitboxes:
		hitbox.set_deferred("disabled",true)

func physics_update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3(0.0,state_owner.velocity.y,0.0),delta*state_owner.agility)
	state_owner.velocity.y -= state_owner.gravity * delta
	state_owner.move_and_slide()
