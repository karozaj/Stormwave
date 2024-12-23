extends StaticBody3D
class_name BlockBaseClass
#base class for all blocks used for building

## The block's durability points
@export var durability:int=100
## Sound to be played when the block is destroyed
@export var destroyed_sound:AudioStream

#stores maximum possible durability for this block, used to calculate damage overlay transparency
var max_durability:int
#the gridmap where the block is placed
var gridmap:BlockGridMap

func _ready() -> void:
	max_durability=durability

#function that destroys the block, to be used either when the player destroys it in building mode
#or when its durability drops below 0
func destroy_block(world_coordinate:Vector3)->bool:
	if gridmap.destroy_block(world_coordinate)==true:
		call_deferred("queue_free")
		return true
	return false

#function called when a block is damaged by an enemy or by the player's weapons
#this function should be overwritten to include visual indication of the block's condition
func damage(dmg:int,_pos:Vector3):
	durability-=dmg
	if durability<0:
		destroy_block(global_position)

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
