extends GridMap
class_name BuildingBlockGridMap
## [GridMap] used for setting buildable blocks in the map

## The [BlockGridMap] where to blocks will be placed
@export var block_grid_map:BlockGridMap

## index in mesh library -> scene of the block
@onready var blocks_dict={
	0:preload("res://scenes/block_building/blocks/block.tscn"),
	1:preload("res://scenes/block_building/blocks/reinforced_block.tscn"),
	2:preload("res://scenes/block_building/blocks/turret.tscn"),
	3:preload("res://scenes/block_building/blocks/mine.tscn"),
	4:preload("res://scenes/block_building/blocks/explosive_block.tscn"),
	
	"Block":0,
	"Reinforced Block":1,
	"Turret":2,
	"Mine":3,
	"Explosive":4
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_blocks()

## Creates the actual blocks inside the block_grid_map
func place_blocks()->void:
	var used_cells:Array[Vector3i]=get_used_cells()
	for cell in used_cells:
		var block_index:int=get_cell_item(cell)
		var block_scene:PackedScene=blocks_dict[block_index]
		var block_position:Vector3=map_to_local(cell)
		block_grid_map.place_block(block_position,block_scene,true)
		set_cell_item(cell,-1)
