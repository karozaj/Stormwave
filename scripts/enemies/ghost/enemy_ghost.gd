extends EnemyBaseClass
class_name EnemyGhost

@onready var state_machine:StateMachine=$StateMachine
@onready var attack_area:Area3D=$AttackArea
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var collision_shape:CollisionShape3D=$CollisionShape3D
@onready var cooldown_timer:Timer=$CooldownTimer
var death_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_death.ogg")
var attack_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_attack.ogg")
var pain_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_pain.ogg")
## Determines surface material transparency. Intended to be used in animations.
@export var material_alpha:float=0.7:
	set(value):
		material_alpha=value
		$skull.get_surface_override_material(0).albedo_color=Color(1,1,1,material_alpha)
		$skull/jaw.get_surface_override_material(0).albedo_color=Color(1,1,1,material_alpha)
## How quickly the enemy moves when beginning the attack
@export var dash_speed:float=20.0
## Attack state duration
@export var attack_time:float=1.0
## Determines how quickly the enemy can reorient itself
@export var agility:float=15.0


func _ready() -> void:
	target=Global.player
	cooldown_timer.wait_time=attack_cooldown
#

func attack()->void:
	attack_area.monitoring=true
	animation_player.play("attack")
	var current_location=global_transform.origin
	var next_location=target.global_position+Vector3(0,0.75,0)
	var new_velocity=(next_location-current_location).normalized()*dash_speed
	velocity=new_velocity
	

func damage(damage_points:int, origin:Vector3)->void:
	state_machine.current_state.damage(damage_points,origin)

func take_damage(damage_points:int, origin:Vector3)->void:
	health-=damage_points
	var knockback_direction:Vector3=global_position-origin
	knockback_direction=knockback_direction.normalized()
	velocity=knockback_direction*damage_points/100*knockback_modifier

func play_sound_effect(sound:AudioStream, pitch_from:float=0.0,pitch_to:float=0.0, pitch_base:float=1.0)->void:
	audio_player.stream=sound
	audio_player.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
	audio_player.play()


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		target.damage(base_damage, global_position)