extends CharacterBody3D
class_name EnemyBaseClass

@export var health:int=100
@export var base_damage:int=25
@export var move_speed:float=5.0
@export var attack_range:float=2.0
@export var attack_cooldown:float=0.5
@export var knockback_modifier:float=20.0
@export var pain_time:float=0.25
var can_attack:bool=true
var is_dead:bool=false
var is_in_pain:bool=false
var target

func attack()->void:
	pass

func damage(damage_points:int, origin:Vector3)->void:
	if is_dead==false:
		health-=damage_points
		var knockback_direction:Vector3=global_position-origin
		knockback_direction=knockback_direction.normalized()
		velocity+=knockback_direction*damage_points/100*knockback_modifier
		if health<=0:
			die()

func die():
	queue_free()
