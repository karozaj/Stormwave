extends BaseLevel


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#Global.current_level=self
	#Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	##$NavRegion/BlockGridmap.map_changed.connect($NavRegion.update_navmesh)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("TEST_BUTTON"):
		#print($EnemySpawner/EnemySpawnArea.is_occupied)
		#print($EnemySpawner/EnemySpawnArea2.is_occupied)
		#print($EnemySpawner/EnemySpawnArea3.is_occupied)
		#print($EnemySpawner/EnemySpawnArea4.is_occupied)
		#print($EnemySpawner/EnemySpawnArea5.is_occupied)
		#print($EnemySpawner/EnemySpawnArea6.is_occupied)
		#print($EnemySpawner.enemy_spawn_areas)
		$EnemySpawner.begin_wave()
		#var test
		#test=await $EnemySpawner.spawn_enemies($EnemySpawner.current_wave_scenes)
		#print(test)
		#$EnemySpawnArea.spawn_enemy(load("res://scenes/enemies/enemy_cloud.tscn").instantiate(),$Enemies,$Player)
#
#func _on_tree_exiting() -> void:
	#$NavigationRegion3D.queue_free()
