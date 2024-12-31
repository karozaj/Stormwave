extends StaticBody3D
class_name BlockBaseClass
#base class for all blocks used for building

@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D

## The block's durability points
@export var durability:int=100
## The block's name (used when the player tries to collect the block)
@export var block_name:String="Block"
## Sound to be played when the block is damaged
@export_category("Audio")
@export var damaged_sound:AudioStream
## Damaged sound effect pitch
@export var damaged_pitch:float=1.0
## Sound to be played when the block is destroyed
@export var destroyed_sound:AudioStream
## Destroyed sound effect pitch
@export var destroyed_pitch:float=1.0

#stores maximum possible durability for this block, used to calculate damage overlay transparency
var max_durability:int
#the gridmap where the block is placed
var gridmap:BlockGridMap


func _ready() -> void:
	max_durability=durability

#function that destroys the block, to be used either when its durability drops below 0
func destroy_block()->bool:
	if gridmap.destroy_block(global_position)==true:
		call_deferred("queue_free")
		return true
	return false

#function that destroys the block when player tries to collect it in building mode 
#and returns the name of the block if conditions are met
func collect_block()->String:
	if gridmap.destroy_block(global_position)==true:
		if float(durability)>=float(max_durability)*0.9:
			call_deferred("queue_free")
			return block_name
		else:
			call_deferred("queue_free")
			return "None"
	return "None"

#function called when a block is damaged by an enemy or by the player's weapons
#this function should be overwritten to include visual indication of the block's condition
func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	audio_player.pitch_scale=damaged_pitch+randf_range(-0.1,0.1)
	audio_player.stream=damaged_sound
	audio_player.play()
	if durability<0:
		destroy_block()

#shows an outline around the block to indicate the player is looking at it and 
#that it's in the player's range
func highlight(world_coordinate:Vector3)->void:
	gridmap.highlight(world_coordinate)

#asks gridmap if a block can be placed, returns true if the block was placed or returns false if
#the block could not be placed
func place_block(world_coordinate:Vector3,block:PackedScene)->bool:
	if gridmap.place_block(world_coordinate,block):
		return true
	else:
		return false
