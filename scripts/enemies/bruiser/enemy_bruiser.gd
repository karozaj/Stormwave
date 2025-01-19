extends EnemyNavigation
class_name EnemyBruiser

@onready var state_machine:StateMachine=$StateMachine
@onready var animation_tree:AnimationTree=$AnimationTree
@onready var hitboxes:Array[CollisionShape3D]=[
	$Armature/Skeleton3D/HeadAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/TorsoHitboxAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/LeftLegHitboxAttachment/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/RightLegHitboxAttachment2/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/LeftArmHitboxAttachment3/HitboxArea/CollisionShape3D,
	$Armature/Skeleton3D/RightArmHitboxAttachment4/HitboxArea/CollisionShape3D]
@onready var collision_shape:CollisionShape3D=$CollisionShape3D
@onready var particles:GPUParticles3D=$Armature/Skeleton3D/HeadAttachment/GPUParticles3D
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var audio_player2:AudioStreamPlayer3D=$AudioStreamPlayer3D2
@onready var footstep_audio_player:AudioStreamPlayer3D=$AudioStreamPlayerFootstep

#@onready var navigation_agent:NavigationAgent3D=$NavigationAgent3D
#@onready var target_update_timer:Timer=$TargetUpdateTimer
@onready var attack_cooldown_timer:Timer=$AttackCooldownTimer
@onready var projectile_direction_ray:RayCast3D=$ProjectileSpawnPoint/RayCast3D
@onready var wall_check_raycast:RayCast3D=$WallCheckRaycast
var projectile_rays:Array[RayCast3D]
var block_detector_rays:Array[RayCast3D]
@onready var melee_hitbox:Area3D=$MeleeAttackHitbox
@onready var attack_melee_cooldown_timer:Timer=$AttackMeleeCooldownTimer

@export_category("Combat")
## The projectile this enemy will shoot
@export var projectile_scene:PackedScene
## Projectile speed
@export var projectile_speed:float=25.0
## Melee attack damage
@export var melee_damage:int=30
## Melee attack range
@export var melee_range:float=1.25
## Melee attack cooldown
@export var melee_cooldown:float=0.5

## Sound played when walking
@export var footstep_sound:AudioStream

#var new_safe_velocity:Vector3=Vector3.ZERO

@export_category("Animation")
## Determines material transparency, intented to be used for animations
@export_range(0.0,1.0) var material_alpha:float=1.0:
	set(value):
		material_alpha=value
		$Armature/Skeleton3D/body.get_active_material(0).albedo_color=Color(1,1,1,material_alpha)
		$Armature/Skeleton3D/body.get_active_material(1).albedo_color=Color(1,1,1,material_alpha)
		$Armature/Skeleton3D/head.get_active_material(0).albedo_color=Color(1,1,1,material_alpha)
		$Armature/Skeleton3D/head.get_active_material(1).albedo_color=Color(1,1,1,material_alpha)
## Determines particle material transparency. Intended to be used in animations.
@export_range(0.0,1.0) var particle_alpha:float=1.0:
	set(value):
		particle_alpha=value
		particles.process_material.color=Color(1,1,1,particle_alpha)

func _ready() -> void:
	super._ready()
	var raycasts=$Raycasts.get_children()
	for r in raycasts:
		projectile_rays.append(r)
	for ray in projectile_rays:
		var raycast=ray as RayCast3D
		raycast.add_exception(self)
		for hitbox in hitboxes:
			raycast.add_exception(hitbox.get_parent())
	
	var block_rays=$BlockDetectorRaycasts.get_children()
	for ray in block_rays:
		block_detector_rays.append(ray)
	
	if infighting_allowed:
		allow_damaging_other_enemies()
	
	navigation_agent.max_speed=move_speed
	
	footstep_audio_player.stream=footstep_sound
	
	#add_targets([Global.player])


func _process(_delta: float) -> void:
	update_target_position()
	#calculate_navigation_target_position_offset()
	#update_navigation_target_position()
	update_animation_tree()

#updates walk and fall animations according to current state	
func update_animation_tree():
	animation_tree.set("parameters/IdleWalkBlend/blend_amount",clamp(velocity.length()/move_speed,0.0,1.0))
	animation_tree.set("parameters/FallBlend/blend_amount",float(!is_on_floor()))


func update_navigation_target_position()->void:
	navigation_target_position=target_position+navigation_target_position_offset
	#print("nav: "+str(navigation_target_position))
	#print("target: "+str(target_position))

#updates navigation agent target position
# this is DIFFERENT FROM update_navigation_target_position
#func update_navagent_target_position():
	#if navigation_agent.target_position.distance_to(navigation_target_position)>1.0:
		#navigation_agent.target_position=navigation_target_position

func calculate_navigation_target_position_offset()->Vector3:
	if navigation_agent.is_target_reachable()==false:
		if target_position.y-global_position.y>3.5:
			var vector2d:Vector2=Vector2(global_position.x,global_position.y)-Vector2(target_position.x,target_position.y)
			vector2d=vector2d.rotated(deg_to_rad(randf_range(-30.0,30.0))).normalized()
			var vector3d:Vector3=Vector3(vector2d.x,0.0,vector2d.y)
			vector3d=vector3d*(target_position.y-global_position.y)
			navigation_target_position_offset=vector3d
			return navigation_target_position_offset
			
	navigation_target_position_offset=Vector3(0.5,0.0,0.5).rotated(Vector3(0,1,0).normalized(),deg_to_rad(randf_range(-45.0,45.0)))
	return navigation_target_position_offset

#checks if block detector rays are detecting any blocks
func are_blocks_in_the_way()->bool:
	for ray in block_detector_rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			return true
	return false

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
		#if damage_dealer is EnemyBaseClass and infighting_allowed==false:
			#return
		#elif damage_dealer not in targets:
		add_targets([damage_dealer])
			#targets.push_front(damage_dealer)
			#target=damage_dealer
			#damage_dealer.died.connect(switch_target)

#spawns projectile
func shoot_projectile():
	projectile_direction_ray.look_at(target_position)
	var projectile:Projectile=projectile_scene.instantiate()
	projectile.direct_damage=base_damage
	projectile.projectile_speed=projectile_speed
	projectile.projectile_owner=self
	projectile.transform.basis=projectile_direction_ray.global_transform.basis
	if Global.current_level!=null:
		Global.current_level.add_child(projectile)
	projectile.global_position=projectile_direction_ray.global_position

#checks if there are other enemies or indestructible walls in the path of the projectile
func are_enemies_in_projectile_path()->bool:
	if infighting_allowed==false:
		for ray in projectile_rays:
			ray.target_position=ray.to_local(target_position)+ray.position
			ray.force_raycast_update()
			if ray.is_colliding():
				#print("ray is colliding")
				return true
	wall_check_raycast.target_position=wall_check_raycast.to_local(target_position)
	wall_check_raycast.force_raycast_update()
	if wall_check_raycast.is_colliding():
		return true
	return false

#to be used during melee attack animation
func enable_melee_hitbox():
	melee_hitbox.monitorable=true
	melee_hitbox.monitoring=true

func _on_melee_attack_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		if body!=self:
			body.damage(melee_damage, global_position,self)


func play_sound_effect(sound:AudioStream, pitch_from:float=-0.1,pitch_to:float=0.1, pitch_base:float=1.0)->void:
	if audio_player.playing==false:
		audio_player.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
		audio_player.stream=sound
		audio_player.play()
	else:
		audio_player2.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
		audio_player2.stream=sound
		audio_player2.play()

func play_foostep_sound():
	footstep_audio_player.pitch_scale=1.0+randf_range(-0.1,0.1)
	footstep_audio_player.play()
#
#func _on_target_update_timer_timeout() -> void:
	#update_navagent_target_position()
	#target_update_timer.start()


#func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	#new_safe_velocity=safe_velocity
	##velocity = velocity.move_toward(safe_velocity,agility)
	##move_and_slide()

func allow_damaging_other_enemies()->void:
	melee_hitbox.collision_mask=1|3|6|7
	navigation_agent.avoidance_enabled=false

func set_footstep_sound(new_sound:AudioStream=footstep_sound)->void:
	footstep_audio_player.stream=new_sound
