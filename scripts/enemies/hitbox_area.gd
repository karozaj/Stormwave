extends Area3D

@onready var hitbox_owner=owner

## Damage points are multiplied by this variable
@export var damage_modifier:float=1.0

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	@warning_ignore("narrowing_conversion")
	hitbox_owner.damage(damage_points*damage_modifier,origin,damage_dealer)
