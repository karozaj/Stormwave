extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_level=self
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	#$NavRegion/BlockGridmap.map_changed.connect($NavRegion.update_navmesh)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("TEST_BUTTON"):
		$EnemySpawnArea.spawn_enemy(load("res://scenes/enemies/enemy_bruiser.tscn").instantiate(),$Enemies)
#
#func _on_tree_exiting() -> void:
	#$NavigationRegion3D.queue_free()
