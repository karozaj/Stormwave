extends Node3D
class_name PlacerBaseClass

@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer

@export_category("Audio")
## Sound to be played when placing block
@export var place_sound:AudioStream
## Sound to be played when destroying block
@export var destroy_sound:AudioStream
## Default sound pitch
@export var default_pitch:float=1.0
## How much the sound pitch should change
@export var pitch_variance:float=0.1

@export_category("Building")
## Is the currently selected placer being pulled out, used in animations to make sure player can't place blocks while the animation is playing
@export var is_being_pulled_out:bool=true
## Cooldown between placing blocks
@export var cooldown:float=0.8

var rng:RandomNumberGenerator=RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

#method for placing blocks
func place():
	pass

#method for  blocks
func destroy():
	pass

func play_place_sound():
	if place_sound!=null:
		audio_player.stream=place_sound
		audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
		audio_player.play()

func play_destroy_sound():
	if destroy_sound!=null:
		audio_player.stream=destroy_sound
		audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
		audio_player.play()
