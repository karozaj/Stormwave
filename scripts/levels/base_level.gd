extends Node3D
class_name BaseLevel
## Base class for levels
##
## Should include a player, an enemy spawner and a nav region

## Emitted when 1 second passes in build phase
signal build_time_remaining_updated
## Emitted when the building phase starts
signal build_phase_started(message:String)
## Emitted when the fighting phase starts
signal fighting_phase_started(message:String)
## Emitted when the game is over
signal game_ended(score_message:String,message:String)

## The [Player] in this level
@export var player:Player
## The [NavRegion] in this level
@export var nav_region:NavRegion
## The [EnemySpawner] in this level
@export var enemy_spawner:EnemySpawner
## The [BlockGridMap] in this level
@export var block_gridmap:BlockGridMap
## the level's [WorldEnvironment]
@export var world_environment:WorldEnvironment
## Measures time left in building phase
@export var build_phase_timer:Timer
## How long the building phase is
@export var build_phase_duration:int=60
## How many blocks should player be rewarded after each wave
@export var block_reward:int=100
## How much of each type of ammo the player starts with (not including the axe)
@export var initial_ammo:Array[int]=[int(250),int(0),int(0),int(0)]
## How many of each block the player starts with
@export var initial_blocks:Array[int]=[250,0,0,0,0]
## [Generator]s in this level. Necessary if the objective is set to "Defense".
@export var generators:Array[Generator]
## Determines the player objective in this map[br]
## [b]Survival[/b] - the goal is to avoid dying for as long as possible[br]
## [b]Defense[/b] - the goal is to protect the generators
@export_enum("Survival","Defense") var objective:String
## A [b]unique[/b] [String] that identifies this level.
## [b]Must[/b] be consistent with the level_identifier in the corresponding [LevelInfo].
## Ideally should be consistent with the level scene file name and be something like "level_1"
@export var level_identifier:String
var build_phase_time_remaining:int=build_phase_duration
var game_has_ended:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_level=self
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
	fighting_phase_started.connect(MusicPlayer.play_battle_music.unbind(1))
	build_phase_started.connect(MusicPlayer.fade_out.unbind(1))
	game_ended.connect(MusicPlayer.fade_out.unbind(2))
	
	enemy_spawner.connect("wave_started",player.hud.show_wave_label)
	enemy_spawner.connect("enemy_count_updated",player.hud.update_enemy_count)
	build_time_remaining_updated.connect(player.hud.update_build_time_remaining)
	game_ended.connect(player.show_game_over_menu)
	enemy_spawner.connect("wave_ended",end_wave)
	player.connect("building_ray_stopped_colliding",block_gridmap.reset_block_highlight)
	player.wave_start_demanded.connect(start_wave)
	player.died.connect(game_over)
	for gen in generators:
		gen.died.connect(on_generator_destroyed)
		gen.map_updated.connect(nav_region.update_navmesh)
	build_phase_started.connect(player.hud.show_prompt)
	fighting_phase_started.connect(player.hud.show_prompt)
	build_phase_timer.timeout.connect(build_phase_timer_timeout)
	build_phase_timer.one_shot=true
	
	player.set_ammo(initial_ammo)
	player.set_blocks(initial_blocks)
	
	start_building_phase()

func start_building_phase():
	build_phase_time_remaining=build_phase_duration
	#if player.state_machine.current_state.name!="Build":
	player.enter_building_state()
	build_phase_started.emit("Press 'E' to open shop menu.")
	build_phase_timer.start(1)
	build_time_remaining_updated.emit(build_phase_time_remaining)

func start_wave():
	build_phase_timer.stop()
	if objective=="Survival":
		fighting_phase_started.emit("Survive!")
	elif objective=="Defense":
		fighting_phase_started.emit("Protect the generators!")
	player.enter_fighting_state()
	enemy_spawner.begin_wave()

func end_wave():
	await get_tree().create_timer(1).timeout
	start_building_phase()
	#player.building_manager.block_count[0]+=block_reward
	var block_res:ShopResource=load("res://resources/shop_resources/blocks/block.tres")
	player.modify_resource_count(block_res,block_reward)

func build_phase_timer_timeout():
	if build_phase_time_remaining>0:
		build_phase_time_remaining-=1
		build_phase_timer.start(1.0)
		build_time_remaining_updated.emit(build_phase_time_remaining)
	else:
		start_wave()

func on_generator_destroyed(sender):
	if is_instance_valid(sender):
		generators.erase(sender)
	var clean_array:Array[Generator]=[]
	for i in range(generators.size()):
		if generators[i]!=null and is_instance_valid(generators[i])==true:
			clean_array.append(generators[i])
	generators=clean_array
	if generators.size()<=0:
		game_over(null)

func game_over(sender):
	if game_has_ended==false:
		game_has_ended=true
		var score_message:String
		var message:String="You died."
		var score:int=0
		if build_phase_timer.is_stopped():
			score=enemy_spawner.current_wave_number-1
			score_message="You survived "+str(score)+" waves."
		else:
			score=enemy_spawner.current_wave_number
			score_message="You survived "+str(score)+" waves."
		
		if objective=="Defense" and generators.size()<=0:
			if sender is not Player:
				message="The generators were destroyed."
		
		ScoreManager.add_score(level_identifier,score)
		ScoreManager.save_scores()
		game_ended.emit(score_message,message)
	
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
