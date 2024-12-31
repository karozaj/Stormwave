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
## How quickly the enemy can reorient itself
@export var agility:float=10.0
## The gravity value used when the enemy is falling
@export var gravity:float=10.0
## Enemy attack range
@export var attack_range:float=2.0
## Determines how much time passes before the enemy can attack again
@export var attack_cooldown:float=0.5
## Determines how far the enemy gets knocked back when receiving damage
@export var knockback_modifier:float=20.0
## Pain state duration
@export var pain_time:float=0.5
## Indicates where enemies should aim when targeting this object
@export var aim_point:Marker3D
## Determines if this enemy can attack other enemies
@export var infighting_allowed:bool=false
var can_attack:bool=true
var is_dead:bool=false
var is_in_pain:bool=false
var target #enemy will chase and attack its target (usually the player)
var targets:Array=[]
var target_position:Vector3=Vector3.ZERO

func add_targets(trgts:Array,prefix:bool=true):
	if prefix==true:
		for trg in trgts:
			if trg not in targets:
				if trg is EnemyBaseClass and infighting_allowed==false:
					continue
				targets.push_front(trg)
				trg.died.connect(switch_target)
	else:
		for trg in trgts:
			if trg not in targets:
				if trg is EnemyBaseClass and infighting_allowed==false:
					continue
				targets.push_back(trg)
				trg.died.connect(switch_target)
	if len(targets)>0:
		target=targets[0]

func switch_target(trg):
	print(targets)
	if trg in targets:
		targets.erase(trg)
		if len(targets)>0:
			target=targets[0]
		else:
			target=null
	print(targets)


#damage function should be overwritten to call damage function for current state
#enemy should also enter 'pain' state upon receiving damage
func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	if is_dead==false:
		health-=damage_points
		var knockback_direction:Vector3=global_position-origin
		knockback_direction=knockback_direction.normalized()
		velocity+=knockback_direction*damage_points/100*knockback_modifier
		if health<=0:
			die()
			
func _process(_delta: float) -> void:
	if target!=null:
		target_position=target.aim_point.global_position

#enemies should have a 'die' state instead of using this function
func die():
	is_dead=true
	died.emit()
	queue_free()
