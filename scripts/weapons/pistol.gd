extends WeaponBaseClass

@onready var ray:RayCast3D=$RayCast3D
@onready var animation_player=$AnimationPlayer
@onready var bullet_hole_spawner=$BulletHoleSpawner
var shooting_sound:AudioStream=preload("res://audio/sfx/pistol.ogg")


func _ready() -> void:
	audio_player.stream=shooting_sound


func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos


func shoot():
	animation_player.play("shoot")
	ray.force_raycast_update()
	if ray.is_colliding():
		bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage, global_position)
