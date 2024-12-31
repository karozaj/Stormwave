extends Area3D

@onready var hitbox_owner:EnemyBaseClass=owner

## Damage points are multiplied by this variable
@export var damage_modifier:float=1.0

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	print("hit")
	hitbox_owner.damage(damage_points,origin,damage_dealer)
