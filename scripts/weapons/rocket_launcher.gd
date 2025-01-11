extends ProjectileWeapon

@onready var animation_player:AnimationPlayer=$AnimationPlayer
## The projectile shot by this weapon

func _ready() -> void:
	audio_player.stream=shooting_sound

func shoot():
	animation_player.play("shoot")
	var projectile:Projectile=projectile_scene.instantiate()
	#this is so that the rocket doesnt collide with the player when they shoot downward
	projectile.set_collision_mask_value(1,false)
	projectile.transform.basis=projectile_direction_ray.global_transform.basis
	projectile.projectile_owner=weapon_owner
	projectile.projectile_speed=projectile_speed
	if Global.current_level!=null:
		Global.current_level.add_child(projectile)
	projectile.global_position=projectile_spawn_marker.global_position
	projectile_direction_ray.force_raycast_update()
	if projectile_direction_ray.is_colliding():
		projectile.explode()
