extends State

@onready var state_owner:EnemyBruiser=get_owner()

func enter(_transition_data:Dictionary={})->void:
	state_owner.animation_tree.set("parameters/AttackMeleeOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)	
	state_owner.animation_tree.set("parameters/AttackOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)


func update(_delta:float)->void:
	if state_owner.is_on_floor():
		finished.emit(self,"Chase")

func physics_update(delta: float) -> void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3(0.0,state_owner.velocity.y,0.0),delta*state_owner.agility)
	state_owner.velocity.y -= state_owner.gravity * delta
	state_owner.move_and_slide()

#func update(delta:float)->void:
	#state_owner.velocity=state_owner.velocity.move_toward(Vector3(0.0,state_owner.velocity.y,0.0),delta*state_owner.agility)
	#state_owner.velocity.y -= state_owner.gravity * delta
	#if state_owner.is_on_floor():
		#finished.emit(self,"Chase")
	#state_owner.move_and_slide()

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
