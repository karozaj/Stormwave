extends WeaponBaseClass
class_name ProjectileWeapon



## The projectile shot by this weapon
@export var projectile_scene:PackedScene
## The [RayCast3D] that determines the direction the projectiles will go in
@export var projectile_direction_ray:RayCast3D
## [Marker3D] that determines the spawn position of the projectile
@export var projectile_spawn_marker:Marker3D
## Determines projectile speed
@export var projectile_speed:float

func shoot():
	var projectile:Projectile=projectile_scene.instantiate()
	projectile.transform.basis=projectile_direction_ray.global_transform.basis
	projectile.projectile_owner=weapon_owner
	projectile.projectile_speed=projectile_speed
	if Global.current_level!=null:
		Global.current_level.add_child(projectile)
	projectile.global_position=projectile_spawn_marker.global_position
