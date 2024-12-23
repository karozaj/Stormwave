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
## The scene of the block that can be placed by this placer
@export var block:PackedScene
## Cooldown between placing blocks
@export var cooldown:float=0.8
## Is the currently selected placer being pulled out, used in animations to make sure player can't place blocks while the animation is playing
@export var is_being_pulled_out:bool=false
#used to check if block can be placed
var player_height:float=1.75
var player_radius:float=0.35

var rng:RandomNumberGenerator=RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

#sets raycast position to align with the camera
func set_ray_position(_pos:Vector3)->void:
	pass
	
#method for placing blocks, should return false when block could not be placed
#and true when the block was succesfully placed
func place()->bool:
	return false

#method for destroying blocks, should return false when block could not be destroyed
#and true when the block was succesfully destroyed
func destroy()->bool:
	return false

#plays sound when placing a block
func play_place_sound()->void:
	if place_sound!=null:
		audio_player.stream=place_sound
		audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
		audio_player.play()

#plays sound when destroying block
func play_destroy_sound()->void:
	if destroy_sound!=null:
		audio_player.stream=destroy_sound
		audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
		audio_player.play()

#checks if the block can be placed
func can_block_be_placed(_target:Vector3)->bool:
	return false
