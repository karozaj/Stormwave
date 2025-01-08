extends State

@onready var state_owner:EnemyGhost=get_owner()
var timer:Timer

func enter(transition_data:Dictionary={})->void:
	timer=Timer.new()
	state_owner.add_child(timer)
	timer.start(state_owner.pain_time)
	timer.timeout.connect(finished.emit.bind(self,"Chase"))
	state_owner.take_damage(transition_data["damage_points"],transition_data["origin"],transition_data["damage_dealer"])
	state_owner.animation_player.play("pain")
	state_owner.play_sound_effect(state_owner.pain_sound,-0.15,0.15)


func update(delta:float)->void:
	if state_owner.health<=0:
		finished.emit(self, "Die")
	state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,state_owner.agility*delta)
	state_owner.move_and_slide()

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})

func exit()->void:
	timer.queue_free()
	state_owner.animation_player.play("RESET")
