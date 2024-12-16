extends CharacterBody3D
class_name EnemyBaseClass
#All enemies should inherit from this class

#signal to notify about death (for example to prevent turrets from attacking while death animation plays)
@warning_ignore("unused_signal")
signal died(enemy:EnemyBaseClass)

## Enemy health
@export var health:int=100
## How much damage the enemy's attack deals
@export var base_damage:int=25
## How quickly the enemy can move in chase state
@export var move_speed:float=5.0
## Enemy attack range
@export var attack_range:float=2.0
## Determines how much time passes before the enemy can attack again
@export var attack_cooldown:float=0.5
## Determines how far the enemy gets knocked back when receiving damage
@export var knockback_modifier:float=20.0
## Pain state duration
@export var pain_time:float=0.5
var can_attack:bool=true
var is_dead:bool=false
var is_in_pain:bool=false
var target #enemy will chase and attack its target (usually the player)

#damage function should be overwritten to call damage function for current state
#enemy should also enter 'pain' state upon receiving damage
func damage(damage_points:int, origin:Vector3)->void:
	if is_dead==false:
		health-=damage_points
		var knockback_direction:Vector3=global_position-origin
		knockback_direction=knockback_direction.normalized()
		velocity+=knockback_direction*damage_points/100*knockback_modifier
		if health<=0:
			die()
#enemies should have a 'die' state instead of using this function
func die():
	is_dead=true
	queue_free()
