extends Node3D

@onready var animation_player=$AnimationPlayer
@onready var audio_player=$AudioStreamPlayer3D
@onready var hitbox:Area3D=$Cube/Hitbox
@export var default_pitch:float=1.0
@export var pitch_variance:float=0.05
var rng:RandomNumberGenerator=RandomNumberGenerator.new()
@export var base_damage:int=35
var cooldown:float=.6
@export var is_being_pulled_out:bool=false


func _ready() -> void:
	rng.randomize()


func shoot():
	animation_player.play("swing")
	hitbox.monitoring=true


func play_attack_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
	audio_player.play()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(base_damage, global_position)
