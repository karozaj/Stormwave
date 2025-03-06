extends BlockBaseClass
## Targets and attacks enemies that enter its range

signal died(obj:Object)

@onready var ray:RayCast3D=$base/TurretPivot/turret/barrel/WeaponRaycast
@onready var bullet_hole_spawner:BulletHoleSpawner=$BulletHoleSpawner
@onready var cooldown_timer:Timer=$Timer
@onready var audio_player2:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d2
@onready var aim_point:Marker3D=$AimPoint
@onready var max_ammo:int=ammo
## Stores the available targets
var targets:Array[EnemyBaseClass]=[]

## The cooldown between attacks
@export var attack_cooldown:float=1.5
## How many points of damage attacks should deal
@export var base_damage:int=10
## How much ammo the turret has
@export var ammo:int=25
## Sound to be played when attacking
@export var attack_sound:AudioStream=preload("res://audio/sfx/shot.ogg")
## Sound to be played when detecting an enemy
@export var enemy_detected_sound:AudioStream=preload("res://audio/sfx/enemy_detected.ogg")
## Material for the laser effect
@export var laser_tracer_material:StandardMaterial3D

var can_shoot:bool=true
var is_dead:bool=false
var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if len(targets)>0:
		var trg=targets[0].aim_point.global_position
		if Vector2($base.global_position.x,$base.global_position.z).distance_to(Vector2(trg.x,trg.z)):
			$base.look_at(Vector3(trg.x,global_position.y,trg.z))
		if $base/TurretPivot.global_position.distance_to(trg):
			$base/TurretPivot.look_at(trg)
		if can_shoot and ammo>0:
			shoot()
			
func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	play_sound(damaged_sound, 0.1,damaged_pitch)
	$base.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	$base/TurretPivot/turret.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		destroy_block()

func destroy_block()->bool:
	if gridmap.destroy_block(global_position)==true:
		var effect:BlockDestroyedEffect=BlockDestroyedEffect.create_effect(destroyed_sound,destroyed_pitch)
		get_parent().add_child(effect)
		effect.global_position=global_position
		is_dead=true
		died.emit(self)
		call_deferred("queue_free")
		return true
	return false

func collect_block()->String:
	if gridmap.destroy_block(global_position)==true:
		if float(durability)>=float(max_durability)*0.9 and float(ammo)>0.8*float(max_ammo):
			call_deferred("queue_free")
			return block_name
		else:
			var effect:BlockDestroyedEffect=destroyed_effect.instantiate()
			effect.sound=destroyed_sound
			effect.pitch=destroyed_pitch
			get_parent().add_child(effect)
			effect.global_position=global_position
			call_deferred("queue_free")
			return "None"
	return "None"

#tries to shoot target
func shoot()->void:
	ray.force_raycast_update()
	var bullet_tracer
	if ray.is_colliding():
		bullet_tracer=BulletTracer.create_effect(ray.global_position,ray.get_collision_point(),laser_tracer_material,false,0.1,1.5)
		bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage, global_position,self)
	else:
		bullet_tracer=BulletTracer.create_effect(ray.global_position,to_global(ray.target_position),laser_tracer_material,false,0.1,1.5)
	Global.current_level.add_child(bullet_tracer)
	$AnimationPlayer2.play("shoot")
	play_sound(attack_sound)
	ammo-=1
	if ammo<=0:
		destroy_block()
	can_shoot=false
	cooldown_timer.start(attack_cooldown)

#removes target fromm target array
func remove_target(trg:EnemyBaseClass):
	if trg in targets:
		targets.erase(trg)
		trg.died.disconnect(remove_target)

#plays given sound
func play_sound(sound:AudioStream, v:float=0.1,pitch:float=1.0):
	if audio_player.playing==false:
		audio_player.play_sound(sound,pitch,v)
	else:
		audio_player2.play_sound(sound,pitch,v)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is EnemyBaseClass:
		var enemy:EnemyBaseClass=body as EnemyBaseClass
		if enemy.is_dead==false:
			targets.append(enemy)
			play_sound(enemy_detected_sound)
			enemy.died.connect(remove_target)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is EnemyBaseClass:
		remove_target(body)


func _on_timer_timeout() -> void:
	can_shoot=true
