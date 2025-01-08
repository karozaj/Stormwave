extends State

@onready var state_owner:EnemyMarksman=get_owner()

var timer:Timer

func enter(transition_data:Dictionary={})->void:
	state_owner.take_damage(transition_data["damage_points"],transition_data["origin"],transition_data["damage_dealer"])
	#print(state_owner.health)
	timer=Timer.new()
	state_owner.add_child(timer)
	timer.start(state_owner.pain_time)
	timer.timeout.connect(finished.emit.bind(self,"Chase"))
	state_owner.animation_tree.set("parameters/AttackOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	state_owner.animation_tree.set("parameters/PainOneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#when in pain state, owner will stop moving and performing any actions/attacks
func update(_delta:float)->void:
	if state_owner.health<=0:
		finished.emit(self, "Die")
	if state_owner.is_on_floor()==false:
		finished.emit(self,"Falling")

func physics_update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3(0.0,state_owner.velocity.y,0.0),delta*state_owner.agility)
	state_owner.move_and_slide()

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})

func exit()->void:
	timer.queue_free()
