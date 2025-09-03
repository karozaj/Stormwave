extends WeaponBaseClass
## plasma rifle weapon used by the player

@onready var ray:RayCast3D=$WeaponRaycast
@onready var animation_player=$AnimationPlayer
@onready var bullet_hole_spawner=$BulletHoleSpawner
@onready var muzzle_flash:Sprite3D=$plasma_gun/MuzzleFlash

func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos


func shoot():
	animation_player.play("shoot")
	scan_and_damage_targets()


func scan_and_damage_targets():
	var current_damage=base_damage
	var next_target_damage_modifier=0.8
	var ray_exceptions=[]
	var max_targets=16
	var hit_targets=0
	var tracer_target=ray.target_position
	
	while(hit_targets<max_targets):#we can only hit as many targets as max_targets
		ray.force_raycast_update()
		if ray.is_colliding():
			if ray.get_collider().has_method("damage"):
				ray.get_collider().damage(current_damage, global_position,weapon_owner)
				ray_exceptions.append(ray.get_collider())
				ray.add_exception(ray.get_collider())
				hit_targets+=1
				current_damage=current_damage*next_target_damage_modifier
				bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
				tracer_target=ray.get_collision_point()
			else:#ray hit something that can't be damaged, so draw a tracer and don't do anything else
				tracer_target=ray.get_collision_point()
				break
		else:#ray didn't collide with anything, so we stop the loop and draw the bulelt tracer
			break
	
	_draw_bullet_tracer(tracer_target)
	
	for ray_exception in ray_exceptions:
		ray.remove_exception(ray_exception)


func _draw_bullet_tracer(target:Vector3):
	var bullet_tracer
	var tracer_visibility_time:float=0.5
	bullet_tracer=BulletTracer.create_effect(muzzle_flash.global_position,target,bullet_tracer_material,true,tracer_visibility_time)
	Global.current_level.add_child(bullet_tracer)
	
