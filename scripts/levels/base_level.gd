extends Node3D
class_name BaseLevel
## Base class for levels
##
## Should include a player, an enemy spawner and a nav region

## Emitted when 1 second passes in build phase
signal build_time_remaining_updated
## Emitted when the building phase starts
signal build_phase_started

## The player in this level
@export var player:Player
## The navigation region in this level
@export var nav_region:NavRegion
## The enemy spawner in this level
@export var enemy_spawner:EnemySpawner
## The block gridmap in this level
@export var block_gridmap:BlockGridMap
## the level's worldenvironment
@export var world_environment:WorldEnvironment
## Measures time left in building phase
@export var build_phase_timer:Timer
## How long the building phase is
@export var build_phase_duration:int=60
## How many blocks should player be rewarded after each wave
@export var block_reward:int=100

var build_phase_time_remaining:int=build_phase_duration

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_level=self
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	enemy_spawner.connect("wave_started",player.show_wave_label)
	enemy_spawner.connect("enemy_count_updated",player.update_enemy_count)
	build_time_remaining_updated.connect(player.update_build_time_remaining)
	enemy_spawner.connect("wave_ended",end_wave)
	player.connect("building_ray_stopped_colliding",block_gridmap.reset_block_highlight)
	player.wave_start_demanded.connect(start_wave)
	build_phase_started.connect(player.show_prompt)
	build_phase_timer.timeout.connect(build_phase_timer_timeout)
	build_phase_timer.one_shot=true
	
	start_building_phase()

func start_building_phase():
	build_phase_time_remaining=build_phase_duration
	if player.state_machine.current_state.name!="Build":
		player.enter_building_state()
	build_phase_started.emit()
	build_phase_timer.start(1)
	build_time_remaining_updated.emit(build_phase_time_remaining)

func start_wave():
	build_phase_timer.stop()
	player.enter_fighting_state()
	enemy_spawner.begin_wave()

func end_wave():
	await get_tree().create_timer(1).timeout
	start_building_phase()
	player.building_manager.block_count[0]+=block_reward

func build_phase_timer_timeout():
	if build_phase_time_remaining>0:
		build_phase_time_remaining-=1
		build_phase_timer.start(1.0)
		build_time_remaining_updated.emit(build_phase_time_remaining)
	else:
		start_wave()

func game_over():
	pass
	
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("TEST_BUTTON"):
		##print($EnemySpawner/EnemySpawnArea.is_occupied)
		##print($EnemySpawner/EnemySpawnArea2.is_occupied)
		##print($EnemySpawner/EnemySpawnArea3.is_occupied)
		##print($EnemySpawner/EnemySpawnArea4.is_occupied)
		##print($EnemySpawner/EnemySpawnArea5.is_occupied)
		##print($EnemySpawner/EnemySpawnArea6.is_occupied)
		##print($EnemySpawner.enemy_spawn_areas)
		#$EnemySpawner.begin_wave()
