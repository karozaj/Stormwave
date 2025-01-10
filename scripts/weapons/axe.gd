extends WeaponBaseClass

@onready var animation_player=$AnimationPlayer
@onready var hitbox:Area3D=$Hitbox
#used when deflecting projectiles
@onready var ray:RayCast3D=$WeaponRaycast

func _ready() -> void:
	audio_player.stream=shooting_sound


func shoot():
	animation_player.play("swing")

func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(base_damage, global_position,weapon_owner)


func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.has_method("deflect"):
		print("deflect")
		area.deflect(weapon_owner,ray.global_basis)
