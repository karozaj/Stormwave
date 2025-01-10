extends Node3D
class_name WeaponBaseClass
#All player weapons should inherit from this class

@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
## Used to ensure pull out animations aren't interrupted
@export var is_being_pulled_out:bool=false
## The sound played when using the weapon
@export var shooting_sound:AudioStream
## Default pitch of audio effects
@export var default_pitch:float=1.0
## How much pitch of audio effects can change
@export var pitch_variance:float=0.1
## How long the user must wait to use the weapon again
@export var cooldown:float=0.8
## How much damage the weapon deals
@export var base_damage:int=10
## The player that owns the weapon
@export var weapon_owner:Player
var rng:RandomNumberGenerator=RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func shoot():
	pass

func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
	audio_player.play()
