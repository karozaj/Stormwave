extends NavigationRegion3D
class_name NavRegion
## Navigation region that updates with the block gridmap
##
## A navigation region that can be updated when the block gridmap changes
## (when blocks are placed or destroyed)

@onready var timer:Timer=$Timer

## Determines if the navmesh will update
@export var rebaking_enabled:bool=true
## Determines how many seconds will pass before the navmesh can update again
@export var rebaking_wait_time:float=0.1
## Called when the node enters the scene tree for the first time.

func _ready() -> void:
	for child in get_children():
		if child is BlockGridMap:
			child.map_changed.connect(update_navmesh)
	#$BlockGridmap.map_changed.connect(update_navmesh)
	##var rid=NavigationServer3D.get_maps()[0]

func update_navmesh():
	if rebaking_enabled==true:
		#if timer.is_stopped()==true:
		if is_inside_tree():
			if is_baking()==false:
				#bake_navigation_mesh()
				timer.start(rebaking_wait_time)


func _on_timer_timeout() -> void:
	#print("rebaking")
	bake_navigation_mesh()
