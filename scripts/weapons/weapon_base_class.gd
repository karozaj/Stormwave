extends Node3D
class_name WeaponBaseClass
#All player weapons should inherit from this class

@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D

@export var is_being_pulled_out:bool=true
@export var default_pitch:float=1.0
@export var pitch_variance:float=0.1
@export var cooldown:float=0.8
@export var base_damage:int=10
var rng:RandomNumberGenerator=RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func shoot():
	pass

func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
	audio_player.play()
