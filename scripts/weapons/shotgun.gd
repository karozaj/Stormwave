extends WeaponBaseClass

@onready var rays:Node3D=$Rays
@onready var muzzle_flash=$Cylinder/MuzzleFlash
@onready var animation_player=$AnimationPlayer
@onready var bullet_hole_spawner=$BulletHoleSpawner
var rays_array:Array
## The bullet spread of this weapon in degrees
@export var bullet_spread:float=15.0

func _ready() -> void:
	audio_player.stream=shooting_sound
	audio_player.volume_db=-30
	rays_array=rays.get_children()

func set_ray_position(pos:Vector3)->void:
	rays.global_position=pos


func shoot():
	animation_player.play("shoot")
	for ray in rays_array:
		var x_rot:float=deg_to_rad(rng.randf_range(-bullet_spread,bullet_spread))/2
		var y_rot:float=deg_to_rad(rng.randf_range(-bullet_spread,bullet_spread))
		ray.rotation=Vector3(x_rot,y_rot,0.0)
		ray.force_raycast_update()
		if ray.is_colliding():
			bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal(),1.25)
			if ray.get_collider().has_method("damage"):
				ray.get_collider().damage(base_damage, global_position,weapon_owner)
