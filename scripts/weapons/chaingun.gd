extends WeaponBaseClass

@onready var ray:RayCast3D=$RayCast3D
@onready var animation_player=$AnimationPlayer
@onready var bullet_hole_spawner=$BulletHoleSpawner
@export var bullet_spread:float=10.0
var shooting_sound:AudioStream=preload("res://audio/sfx/pistol.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.stream=shooting_sound


func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos
	
	
func shoot():
	animation_player.play("shoot")
	var x_rot:float=deg_to_rad(rng.randf_range(-bullet_spread,bullet_spread))
	var y_rot:float=deg_to_rad(rng.randf_range(-bullet_spread,bullet_spread))
	ray.rotation=Vector3(x_rot,y_rot,0.0)
	ray.force_raycast_update()
	if ray.is_colliding():
		bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage, global_position)