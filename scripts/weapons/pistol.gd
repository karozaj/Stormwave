extends WeaponBaseClass
## Pistol weapon used by the player

@onready var ray:RayCast3D=$WeaponRaycast
@onready var animation_player=$AnimationPlayer
@onready var bullet_hole_spawner=$BulletHoleSpawner
@onready var muzzle_flash:Sprite3D=$Cube_001/MuzzleFlash

func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos


func shoot():
	animation_player.play("shoot")
	var bullet_tracer
	ray.force_raycast_update()
	if ray.is_colliding():
		bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		bullet_tracer=BulletTracer.create_effect(muzzle_flash.global_position,ray.get_collision_point(),bullet_tracer_material,true,0.15)
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage, global_position,weapon_owner)
	else:
		bullet_tracer=BulletTracer.create_effect(muzzle_flash.global_position,to_global(ray.target_position),bullet_tracer_material,true,0.15)
	Global.current_level.add_child(bullet_tracer)
