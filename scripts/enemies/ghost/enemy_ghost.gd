extends EnemyBaseClass
class_name EnemyGhost

@onready var state_machine:StateMachine=$StateMachine
@onready var attack_area:Area3D=$AttackArea
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var collision_shape:CollisionShape3D=$CollisionShape3D
@onready var cooldown_timer:Timer=$CooldownTimer

@export var death_sound:AudioStream
@export var attack_sound:AudioStream
@export var pain_sound:AudioStream
## Determines surface material transparency. Intended to be used in animations.
@export_range(0.0,1.0) var material_alpha:float=0.7:
	set(value):
		material_alpha=value
		$skull.get_surface_override_material(0).albedo_color=Color(1,1,1,material_alpha)
		$skull/jaw.get_surface_override_material(0).albedo_color=Color(1,1,1,material_alpha)
## How quickly the enemy moves when beginning the attack
@export var dash_speed:float=17.0
## Attack state duration
@export var attack_time:float=1.0
## Determines how quickly the enemy can reorient itself


func _ready() -> void:
	#add_targets([Global.player])
	cooldown_timer.wait_time=attack_cooldown
	if infighting_allowed:
		allow_damaging_other_enemies()

func attack()->void:
	attack_area.monitoring=true
	animation_player.play("attack")
	var current_location=global_transform.origin
	#var next_location=target.global_position+Vector3(0,0.75,0)
	var next_location=target_position
	var new_velocity=(next_location-current_location).normalized()*dash_speed
	velocity=new_velocity
	

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	state_machine.current_state.damage(damage_points,origin,damage_dealer)

func take_damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	health-=damage_points
	var knockback_direction:Vector3=global_position-origin
	knockback_direction=knockback_direction.normalized()
	velocity=knockback_direction*damage_points/100*knockback_modifier
	if damage_dealer!=null:
		add_targets([damage_dealer])

func play_sound_effect(sound:AudioStream, pitch_from:float=-0.0,pitch_to:float=0.0, pitch_base:float=1.0)->void:
	audio_player.stream=sound
	audio_player.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
	audio_player.play()


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		if body!=self:
			body.damage(base_damage, global_position,self)

func allow_damaging_other_enemies()->void:
	attack_area.collision_mask=1|3|6|7
