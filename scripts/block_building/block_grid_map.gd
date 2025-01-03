extends GridMap
class_name BlockGridMap

## Maximum height above base at which it's possible to place blocks
@export var max_building_height:int=10
#raycast is used to check if the player is building within set boundaries
@onready var ray:RayCast3D=$RayCast3D
var highlighted_block_coordinate:Vector3i

func _ready() -> void:
	ray.target_position=Vector3(0,-max_building_height,0)

func destroy_block(world_coordinate:Vector3)->bool:
	var map_coordinate=local_to_map(world_coordinate)
	if get_cell_item(map_coordinate)==2 or get_cell_item(map_coordinate)==3:
		set_cell_item(map_coordinate,-1)
		return true
	return false
	
func place_block(world_coordinate:Vector3, block:PackedScene)->bool:
	var map_coordinate=local_to_map(world_coordinate)
	if get_cell_item_orientation(map_coordinate)==-1:
		ray.position=map_to_local(map_coordinate)
		ray.force_raycast_update()
		#check if position where player is trying to build is above base block
		if ray.is_colliding():
			var block_scene=block.instantiate()
			block_scene.gridmap=self
			Global.current_level.add_child(block_scene)
			block_scene.position=map_to_local(map_coordinate)
			#print("place")
			#print(map_coordinate)
			set_cell_item(map_coordinate,2)
			print(map_coordinate)
			return true
		else:
			print("ray not colliding")
	return false

func highlight(world_coordinate:Vector3)->void:
	var map_coordinate=local_to_map(world_coordinate)
	#print(world_coordinate)
	#print(map_to_local(map_coordinate))
	if highlighted_block_coordinate!=null and map_coordinate!=highlighted_block_coordinate:
		if get_cell_item(highlighted_block_coordinate)==1:
			set_cell_item(highlighted_block_coordinate, 0)
		elif get_cell_item(highlighted_block_coordinate)==3:
			set_cell_item(highlighted_block_coordinate,2)
			
	if get_cell_item(map_coordinate)==0:
		set_cell_item(map_coordinate, 1)
	elif get_cell_item(map_coordinate)==2:
		set_cell_item(map_coordinate,3)
	
	highlighted_block_coordinate=map_coordinate

func reset_block_highlight()->void:
	var cells=get_used_cells()
	for cell_coordinate in cells:
		if get_cell_item(cell_coordinate)==1:
			set_cell_item(cell_coordinate, 0)
		elif get_cell_item(cell_coordinate)==3:
			set_cell_item(cell_coordinate,2)
