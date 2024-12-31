extends NavigationRegion3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BlockGridmap.map_changed.connect(update_navmesh)
	#var rid=NavigationServer3D.get_maps()[0]

func update_navmesh():
	if is_inside_tree():
		if is_baking()==false:
			bake_navigation_mesh()
