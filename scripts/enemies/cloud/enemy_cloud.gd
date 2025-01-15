extends EnemyBaseClass
class_name EnemyCloud

@onready var lightning:Node3D=$Lightning
@onready var raycast:RayCast3D=$RayCast3D
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var cooldown_timer:Timer=$CooldownTimer
@onready var lightning_timer:Timer=$LightningTimer
@onready var eye:MeshInstance3D=$eye
@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var state_machine:StateMachine=$StateMachine

@export var thunder_sound:AudioStream
@export var charging_sound:AudioStream
@export var death_sound:AudioStream
@export var pain_sound:AudioStream
## Determines surface material transparency. Intended to be used in animations.
@export_range(0.0,1.0) var material_alpha:float=1.0:
	set(value):
		material_alpha=value
		$eye.get_surface_override_material(0).albedo_color=Color(1,1,1,material_alpha)
## Determines particle material transparency. Intended to be used in animations.
@export_range(0.0,1.0) var particle_alpha:float=1.0:
	set(value):
		particle_alpha=value
		$GPUParticles3D.process_material.color=Color(1,1,1,particle_alpha)
## How high over the target should the enemy's target position be
@export var height_over_target:float=4.0
## How long the enemy needs to charge its attack before firing
@export var attack_charging_time:float=1.0
## Sound effect pitch
@export var base_pitch:float=0.5


func _ready() -> void:
	#add_targets([Global.player])
	cooldown_timer.wait_time=attack_cooldown
	if infighting_allowed:
		allow_damaging_other_enemies()

func _process(_delta: float) -> void:
	update_target_position()
	update_navigation_target_position()
	
func update_navigation_target_position()->void:
	navigation_target_position=target_position+Vector3(0.0,height_over_target,0.0)

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

## stretches lightning sprite between enemy center and given position
func calculate_lightning_size(target_pos:Vector3):
	lightning.look_at(Vector3(target_pos.x, lightning.global_position.y,target_pos.z))
	var distance:float=lightning.global_position.distance_to(target_pos)
	var lightning_height:float=64.0*$Lightning/LightningSprite.pixel_size
	lightning.scale.y=distance/lightning_height
	var distance_v=abs(lightning.global_position.y-target_pos.y)
	var lightning_rotation=acos(distance_v/distance)
	lightning.global_rotation.x=lightning_rotation


func shoot_lightning()->void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		calculate_lightning_size(raycast.get_collision_point())
		lightning.visible=true
		play_sound_effect(thunder_sound,0.15,0.15,1.0)
		if raycast.get_collider().has_method("damage"):
			raycast.get_collider().damage(base_damage,global_position,self)
		elif raycast.get_collider().has_method("electrify"):
			raycast.get_collider().electrify()
		lightning_timer.start(0.1)

func play_sound_effect(sound:AudioStream, pitch_from:float=-0.0,pitch_to:float=0.0, pitch_base:float=1.0)->void:
	audio_player.stream=sound
	audio_player.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
	audio_player.play()

func _on_lightning_timer_timeout() -> void:
	lightning.visible=false

func allow_damaging_other_enemies()->void:
	raycast.collision_mask=1|2|3|5|6|7
