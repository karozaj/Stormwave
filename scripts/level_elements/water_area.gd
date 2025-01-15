extends Area3D
class_name WaterArea
## An area representing water, can be electrified by electric attacks

## The [WaterEffect] used to visualize the water
@export var water_effect:WaterEffect
## How much damage should be dealt to bodies in the water when it is electrified
@export var electrify_damage:int=10
## Sound that
@export var water_footstep_sound:AudioStream
## How ofthen the water can be electrified
@export var electrify_cooldown:float=1.0

@onready var electrify_timer:Timer=$ElectrifyTimer

var bodies_in_water:Array=[]
var can_be_electrified:bool=true

func electrify():
	if can_be_electrified:
		can_be_electrified=false
		water_effect.play_electrify_animation()
		for body in bodies_in_water:
			if is_instance_valid(body) and body.has_method("damage"):
				if body is not EnemyBaseClass:
					body.damage(electrify_damage,body.global_position,null)
		electrify_timer.start(electrify_cooldown)


func _on_body_entered(body: Node3D) -> void:
	if is_instance_valid(body):
		if body not in bodies_in_water and body.has_method("set_footstep_sound"):
			bodies_in_water.append(body)
			body.set_footstep_sound(water_footstep_sound)

func _on_body_exited(body: Node3D) -> void:
	if is_instance_valid(body):
		if body in bodies_in_water:
			bodies_in_water.erase(body)
			if body.has_method("set_footstep_sound"):
				body.set_footstep_sound()


func _on_electrify_timer_timeout() -> void:
	can_be_electrified=true
