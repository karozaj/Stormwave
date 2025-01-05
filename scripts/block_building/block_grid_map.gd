extends GridMap
class_name BlockGridMap

signal map_changed

## Maximum height above base at which it's possible to place blocks
@export var max_building_height:int=10
#raycast is used to check if the player is building within set boundaries
@onready var ray:RayCast3D=$RayCast3D
var highlighted_block_coordinate:Vector3i

func _ready() -> void:
	ray.target_position=Vector3(0,-max_building_height,0)

#removes block at given coordinate
func destroy_block(world_coordinate:Vector3)->bool:
	var map_coordinate=local_to_map(world_coordinate)
	if get_cell_item(map_coordinate)==2 or get_cell_item(map_coordinate)==3:
		set_cell_item(map_coordinate,-1)
		return true
	return false

#creates a given block at the given position in the grid
func place_block(world_coordinate:Vector3, block:PackedScene)->bool:
	var map_coordinate=local_to_map(world_coordinate)
	if get_cell_item_orientation(map_coordinate)==-1:
		ray.position=map_to_local(map_coordinate)
		ray.force_raycast_update()
		#check if position where player is trying to build is above base block
		if ray.is_colliding():
			var block_scene=block.instantiate()
			block_scene.gridmap=self
			add_child(block_scene)
			block_scene.position=map_to_local(map_coordinate)
			set_cell_item(map_coordinate,2)
			print(map_coordinate)
			#connect tree exited signal so navmesh can update when map changes
			map_changed.emit()
			block_scene.tree_exited.connect(map_changed.emit)
			return true
		else:
			print("ray not colliding")
	return false

#highlights a block at the given coordinate
func highlight(world_coordinate:Vector3)->bool:
	var map_coordinate=local_to_map(world_coordinate)
	var was_highlighted:bool=false
	if highlighted_block_coordinate!=null and map_coordinate!=highlighted_block_coordinate:
		if get_cell_item(highlighted_block_coordinate)==1:
			set_cell_item(highlighted_block_coordinate, 0)
		elif get_cell_item(highlighted_block_coordinate)==3:
			set_cell_item(highlighted_block_coordinate,2)
			
	if get_cell_item(map_coordinate)==0:
		set_cell_item(map_coordinate, 1)
		was_highlighted=true
	elif get_cell_item(map_coordinate)==2:
		set_cell_item(map_coordinate,3)
		was_highlighted=true
	
	highlighted_block_coordinate=map_coordinate
	return was_highlighted

#resets highlight the previously highlighted block
func reset_block_highlight()->void:
	if get_cell_item(highlighted_block_coordinate)==1:
		set_cell_item(highlighted_block_coordinate, 0)
	elif get_cell_item(highlighted_block_coordinate)==3:
		set_cell_item(highlighted_block_coordinate,2)
