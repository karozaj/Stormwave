extends EnemyNavigation
class_name EnemyMarksman
## Marksman enemy type. Shoots lasers and keeps its distance

@onready var state_machine:StateMachine=$StateMachine
@onready var animation_tree:AnimationTree=$AnimationTree
@onready var particles:GPUParticles3D=$Armature/Skeleton3D/HeadAttachment/HitboxArea/GPUParticles3D
@onready var hitboxes:Array[CollisionShape3D]=[
	$Armature/Skeleton3D/HeadAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/TorsoAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/LeftLegAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/RightLegAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/HipAttachment/HitboxArea/CollisionShape3D]
@onready var collision_shape:CollisionShape3D=$CollisionShape3D
@onready var weapon_raycast:RayCast3D=$LaserSpawnPoint/WeaponRay
var enemy_check_raycasts:Array[RayCast3D]
@onready var laser_spawn_point:Marker3D=$LaserSpawnPoint
@onready var bullet_hole_spawner:BulletHoleSpawner=$BulletHoleSpawner
@onready var attack_cooldown_timer:Timer=$AttackCooldownTimer
@onready var check_wall_ray:RayCast3D=$CheckWallRay
@onready var wall_check_raycast:RayCast3D=$WallCheckRaycast
@onready var audio_player:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d
@onready var audio_player2:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d2
@onready var footstep_audio_player:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d3

var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")
var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")

## How far away the navigation target position should be from the target
@export var target_offset_radius:float=6.0
## Sound played when the enemy is destroyed
@export var destroyed_sound:AudioStream
## Footstep sound
@export var footstep_sound:AudioStream
## Material for the laser effect
@export var laser_tracer_material:StandardMaterial3D

@export_category("Animation")
## Determines material transparency, intented to be used for animations
@export_range(0.0,1.0) var material_alpha:float=1.0:
	set(value):
		material_alpha=value
		$Armature/Skeleton3D/skull.get_active_material(0).albedo_color=Color(1,1,1,material_alpha)
## Determines particle material transparency. Intended to be used in animations.
@export_range(0.0,1.0) var particle_alpha:float=1.0:
	set(value):
		particle_alpha=value
		particles.process_material.color=Color(1,1,1,particle_alpha)


func _ready() -> void:
	super._ready()
	for hitbox in hitboxes:
		weapon_raycast.add_exception(hitbox.get_parent())
	if infighting_allowed:
		allow_damaging_other_enemies()
	
	for ray in $EnemyCheckRays.get_children():
		enemy_check_raycasts.append(ray)
		
	navigation_agent.max_speed=move_speed
	set_footstep_sound(footstep_sound)
	
	
func _process(_delta: float) -> void:
	update_target_position()
	update_animation_tree()

## calls current state 'damage' method
func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	state_machine.current_state.damage(damage_points,origin,damage_dealer)

## damage and knock back this enemy, usually called from state 'damage' method
func take_damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	health-=damage_points
	var knockback_direction:Vector3=global_position-origin
	knockback_direction=knockback_direction.normalized()
	velocity+=knockback_direction*damage_points/100*knockback_modifier
	if damage_dealer!=null:
		add_targets([damage_dealer])

func explode()->void:
		var expl=explosion.instantiate()
		Global.current_level.add_child(expl)
		expl.global_position=aim_point.global_position
		expl.explode()
		var effect:BlockDestroyedEffect=destroyed_effect.instantiate()
		effect.sound=destroyed_sound
		Global.current_level.add_child(effect)
		effect.global_position=aim_point.global_position
		queue_free()

#updates walk and fall animations according to current state	
func update_animation_tree():
	animation_tree.set("parameters/IdleWalkBlend/blend_amount",clamp(velocity.length()/move_speed,0.0,1.0))
	animation_tree.set("parameters/FallBlend/blend_amount",float(!is_on_floor()))

func shoot_laser()->void:
	check_wall_ray.force_raycast_update()
	if check_wall_ray.is_colliding():
		if check_wall_ray.get_collider().has_method("damage"):
			check_wall_ray.get_collider().damage(base_damage,global_position,self)
			return
	weapon_raycast.force_raycast_update()
	var bullet_tracer
	if weapon_raycast.is_colliding():
		bullet_tracer=BulletTracer.create_effect(laser_spawn_point.global_position,weapon_raycast.get_collision_point(),laser_tracer_material,false,0.1,1.5)
		bullet_hole_spawner.spawn_bullet_hole(weapon_raycast.get_collision_point(),weapon_raycast.get_collision_normal())
		if weapon_raycast.get_collider().has_method("damage"):
			weapon_raycast.get_collider().damage(base_damage, global_position,self)
	else:
		bullet_tracer=BulletTracer.create_effect(laser_spawn_point.global_position,to_global(weapon_raycast.target_position),laser_tracer_material,false,0.1,1.5)
	Global.current_level.add_child(bullet_tracer)

func are_enemies_in_laser_path()->bool:
	if infighting_allowed==false:
		for ray in enemy_check_raycasts:
			ray.target_position=ray.to_local(target_position)+ray.position
			ray.force_raycast_update()
			if ray.is_colliding()==true:
				return true
	wall_check_raycast.target_position=wall_check_raycast.to_local(target_position)
	wall_check_raycast.force_raycast_update()
	if wall_check_raycast.is_colliding():
		return true
	return false

func is_wall_blocking_gun()->bool:
	if check_wall_ray.global_position.distance_to(target_position)>0.01:
		check_wall_ray.look_at(target_position)
	check_wall_ray.force_raycast_update()
	if check_wall_ray.is_colliding():
		return true
	return false

func calculate_navigation_target_position_offset()->Vector3:
	var vector2d:Vector2=Vector2(global_position.x,global_position.y)-Vector2(target_position.x,target_position.y)
	vector2d=vector2d.rotated(deg_to_rad(randf_range(-30.0,30.0))).normalized()
	var vector3d:Vector3=Vector3(vector2d.x,0.0,vector2d.y)
	
	if navigation_agent.is_target_reachable()==false:
		if target_position.y-global_position.y>3.5:
			vector3d=vector3d*max((target_position.y-global_position.y),target_offset_radius)
			navigation_target_position_offset=vector3d
			return navigation_target_position_offset
			
	vector3d=vector3d*target_offset_radius
	navigation_target_position_offset=vector3d
	return navigation_target_position_offset


func play_sound_effect(sound:AudioStream, pitch_base:float=1.0, pitch_var:float=-0.1)->void:
	if audio_player.playing==false:
		audio_player.play_sound(sound,pitch_base,pitch_var)
	else:
		audio_player2.play_sound(sound,pitch_base,pitch_var)

func play_footstep_sound():
	footstep_audio_player.play_current_sound()

func set_footstep_sound(new_sound:AudioStream=footstep_sound)->void:
	footstep_audio_player.stream=new_sound
