extends State

@onready var state_owner:EnemyCloud=get_owner()
var timer:Timer
#play death animation and delete owner
func enter(_transition_data:Dictionary={})->void:
	state_owner.is_dead=true
	timer=Timer.new()
	state_owner.add_child(timer)
	timer.start(3)
	timer.timeout.connect(die)
	state_owner.animation_player.play("die")
	state_owner.play_sound_effect(state_owner.death_sound,0.0,0.0,state_owner.base_pitch)
	state_owner.died.emit(state_owner)
	
#stop moving
func update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,5*state_owner.agility*delta)
	state_owner.move_and_slide()

func die()->void:
	state_owner.queue_free()
