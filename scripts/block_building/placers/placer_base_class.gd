extends Node3D
class_name PlacerBaseClass


@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer

@export_category("Audio")
## Sound to be played when placing block
@export var place_sound:AudioStream
## Place sound pitch
@export var place_pitch:float=1.0
## Sound to be played when collecting block
@export var pitch_variance:float=0.1

@export_category("Building")
## The scene of the block that can be placed by this placer
@export var block:PackedScene
## Cooldown between placing blocks
@export var cooldown:float=0.8
## Raycast used for building and destroying blocks
@export var ray:RayCast3D
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
func collect()->String:
	return "None"

#plays sound when placing a block
func play_place_sound()->void:
	if place_sound!=null:
		audio_player.stream=place_sound
		audio_player.pitch_scale=place_pitch+rng.randf_range(-pitch_variance,pitch_variance)
		audio_player.play()


#checks if the block can be placed
func can_block_be_placed(_target:Vector3)->bool:
	return false

#highlights the block when the raycast is colliding with it
func highlight()->bool:
	if ray.is_colliding():
		if ray.get_collider()!=null and ray.get_collider().has_method("highlight"):
			ray.get_collider().highlight(ray.get_collision_point()-ray.get_collision_normal()/2)
		return true
	return false
