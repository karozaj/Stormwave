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

var thunder_sound:AudioStream=preload("res://audio/sfx/thunder.ogg")
var charging_sound:AudioStream=preload("res://audio/sfx/charge.ogg")
var death_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_death.ogg")
var pain_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_pain.ogg")
## Determines surface material transparency. Intended to be used in animations.
@export var material_alpha:float=1.0:
	set(value):
		material_alpha=value
		$eye.get_surface_override_material(0).albedo_color=Color(1,1,1,material_alpha)
## Determines particle material transparency. Intended to be used in animations.
@export var particle_alpha:float=1.0:
	set(value):
		particle_alpha=value
		$GPUParticles3D.process_material.color=Color(1,1,1,particle_alpha)
## Determines how quickly the enemy can reorient itself
@export var agility:float=2.5
## How high over the target should the enemy's target position be
@export var height_over_target:float=5.0
## How long the enemy needs to charge its attack before firing
@export var attack_charging_time:float=1.5
## Sound effect pitch
@export var base_pitch:float=0.5


func _ready() -> void:
	target=Global.player
	cooldown_timer.wait_time=attack_cooldown


func _process(delta: float) -> void:
	state_machine.current_state.update(delta)
	

func damage(damage_points:int, origin:Vector3)->void:
	state_machine.current_state.damage(damage_points,origin)


func take_damage(damage_points:int, origin:Vector3)->void:
		health-=damage_points
		var knockback_direction:Vector3=global_position-origin
		knockback_direction=knockback_direction.normalized()
		velocity+=knockback_direction*damage_points/100*knockback_modifier

## stretches lightning sprite between enemy center and given position
func calculate_lightning_size(target_position:Vector3):
	lightning.look_at(Vector3(target_position.x, lightning.global_position.y,target_position.z))
	var distance:float=lightning.global_position.distance_to(target_position)
	var lightning_height:float=64.0*$Lightning/LightningSprite.pixel_size
	lightning.scale.y=distance/lightning_height
	var distance_v=abs(lightning.global_position.y-target_position.y)
	var lightning_rotation=acos(distance_v/distance)
	print(rad_to_deg(lightning_rotation))
	lightning.global_rotation.x=lightning_rotation
	print(lightning.global_rotation.x)


func shoot_lightning()->void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		calculate_lightning_size(raycast.get_collision_point())
		lightning.visible=true
		play_sound_effect(thunder_sound,0.15,0.15,1.0)
		if raycast.get_collider().has_method("damage"):
			raycast.get_collider().damage(base_damage,global_position)
		lightning_timer.start(0.1)

func play_sound_effect(sound:AudioStream, pitch_from:float=0.0,pitch_to:float=0.0, pitch_base:float=1.0)->void:
	audio_player.stream=sound
	audio_player.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
	audio_player.play()

func _on_lightning_timer_timeout() -> void:
	lightning.visible=false