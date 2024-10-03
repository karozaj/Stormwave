extends Node3D

@onready var animation_player=$AnimationPlayer
@onready var audio_player=$AudioStreamPlayer3D
@onready var hitbox:Area3D=$Cube/Hitbox
@export var default_pitch:float=1.0
@export var pitch_variance:float=0.05
var rng:RandomNumberGenerator=RandomNumberGenerator.new()
@export var base_damage:int=20
var cooldown:float=.6
@export var is_being_pulled_out:bool=false


func _ready() -> void:
	rng.randomize()


func shoot():
	animation_player.play("swing")
	hitbox.monitoring=true
	#ray.force_raycast_update()
	#if ray.is_colliding():
		#spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		#print(ray.get_collider().name)
		#if ray.get_collider().has_method("damage"):
			#ray.get_collider().damage(base_damage)



func play_attack_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
	audio_player.play()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(base_damage)
