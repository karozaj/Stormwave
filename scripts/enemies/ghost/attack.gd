extends State

@onready var state_owner:EnemyGhost=get_owner()
var timer:Timer

func enter(_transition_data:Dictionary={})->void:
	timer=Timer.new()
	state_owner.add_child(timer)
	timer.start(state_owner.attack_time)
	timer.timeout.connect(finished.emit.bind(self,"Chase"))
	state_owner.attack()
	state_owner.play_sound_effect(state_owner.attack_sound,-0.15,0.15)

func update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,delta*state_owner.agility)
	state_owner.move_and_slide()

func exit()->void:
	state_owner.cooldown_timer.start()
	state_owner.attack_area.set_deferred("monitoring",false)
	timer.queue_free()

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
