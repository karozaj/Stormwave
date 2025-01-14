extends Node3D
class_name EnemySpawner
## Handles the spawning of enemies
##
## Handles the spawning of enemies
## Should contain EnemySpawnArea nodes
## Once an enemy dies, a new enemy is spawned if enemies remain the wave

signal wave_started(wave_number:int)
signal wave_ended
signal enemy_count_updated(current:int, max:int)

@onready var timer:Timer=$Timer

## The node that should be the parent of the spawned enemies.
## This node should be placed outside the map to prevent the enemies from being damaged
## before they can properly spawn
@export var enemy_parent_node:Node3D
## The scenes of the enemies that can be spawned
@export var enemy_scenes:Array[PackedScene]
## Determines how likely each enemy type is to spawn. A value must be defined for each enemy type.
@export var enemy_spawn_chance:Array[int]
## Determines by how much the chance of each enemy type spawning should increase between waves
@export var enemy_spawn_chance_increase:Array[int]
## The number of enemies in a wave
@export var wave_size:int
## How much the wave size increases with each wave
@export var wave_size_increase:int
## Maximum number of enemies in one wave (0 means no limit)
@export var max_wave_size:int
## Number of enemies that will be spawned at the same time. Should be smaller than the number of EnemySpawnAreas
@export var concurrent_enemies:int
## How many more concurrent enemies will be added between waves
@export var concurrent_enemies_increase:int
## Maximum number of enemies that can be spawned at the same time. Should be smaller than the number of EnemySpawnAreas
@export var max_concurrent_enemies:int

## Random nubmer generator seed
@export var rng_seed:int=randi()
## Enemies will target this node after spawning
@export var initial_enemy_targets:Array[Node3D]
## Should the target array be shuffled before spawning an enemy
@export var shuffle_targets:bool

var rng=RandomNumberGenerator.new()

## The EnemySpawnAreas where the enemies will be spawned
var enemy_spawn_areas:Array[EnemySpawnArea]

var current_wave_number:int=0
var current_wave:Array[EnemyBaseClass]
var current_wave_scenes:Array[PackedScene]
var current_wave_size:int
var current_subwaves:Array

var remaining_wave_enemies:Array[PackedScene]
var enemies_alive:int=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in get_tree().get_nodes_in_group("enemy_spawn_areas"):
		enemy_spawn_areas.append(x as EnemySpawnArea)
	print(enemy_spawn_areas.size())
	print("Number of enemy spawn areas: "+str(enemy_spawn_areas.size()))
	rng.seed=rng_seed
	if concurrent_enemies>enemy_spawn_areas.size():
		concurrent_enemies=enemy_spawn_areas.size()
	if max_concurrent_enemies>enemy_spawn_areas.size():
		max_concurrent_enemies=enemy_spawn_areas.size()

# generates a wave of enemies
func generate_wave()->Array[PackedScene]:
	var new_wave:Array[PackedScene]=[]
	for i in range(current_wave_size):
		new_wave.append(get_random_enemy_scene())
	return new_wave

func begin_wave():
	current_wave_number+=1
	wave_started.emit(current_wave_number)
	await get_tree().create_timer(1).timeout
	
	if max_wave_size>0:
		current_wave_size=clamp((wave_size+(current_wave_number-1)*wave_size_increase),0,max_wave_size)
	else:
		current_wave_size=(wave_size+(current_wave_number-1)*wave_size_increase)
		
	
	if current_wave_number>1:
		concurrent_enemies=clamp(concurrent_enemies+concurrent_enemies_increase,0,max_concurrent_enemies)
		
		for i in range(enemy_spawn_chance.size()):
			if (enemy_spawn_chance[i]+enemy_spawn_chance_increase[i]>=0):
				enemy_spawn_chance[i]+=enemy_spawn_chance_increase[i]
	enemies_alive=current_wave_size
	
	enemy_count_updated.emit(enemies_alive,current_wave_size)
	current_wave_scenes=generate_wave()
	remaining_wave_enemies=await spawn_enemies(current_wave_scenes)
	print(remaining_wave_enemies.size())

# returns random enemy from array of possible enemies
func get_random_enemy_scene()->PackedScene:
	var chosen_enemy:PackedScene=null
	var chance_sum:int=0
	for x in enemy_spawn_chance:
		chance_sum+=x
	
	var rand=rng.randf_range(0.0,chance_sum)
	#print(rand)
	for i in range(enemy_spawn_chance.size()):
		var current_spawn_chance:int=0
		for j in range(0,i+1):
			current_spawn_chance+=enemy_spawn_chance[j]
		#print(current_spawn_chance)
		if rand<=current_spawn_chance:
			chosen_enemy=enemy_scenes[i]
			return chosen_enemy
	
	chosen_enemy=enemy_scenes[0]
	return chosen_enemy

# spawns enemies from argument array, returns array of enemy scenes that could not be spawned
# if all enemies were spawned successfully, returns empty array
# to avoid spawning all enemies at once, there is a short delay between each enemy
# this is also an async function
func spawn_enemies(scenes:Array[PackedScene])->Array[PackedScene]:
	var remaining_enemies:Array[PackedScene]=[]
	var enemies_to_instantiate:Array[PackedScene]=[]
	var indices:Array[int]=[]
	for i in range(enemy_spawn_areas.size()):
		indices.append(i)
	
	for i in range(scenes.size()):
		if i<concurrent_enemies:
			enemies_to_instantiate.append(scenes[i])
		remaining_enemies.append(scenes[i])
	
	for enemy_scene in enemies_to_instantiate:
		if indices.size()>0:
			var spawn_area_index=indices.pick_random()
			indices.erase(spawn_area_index)
			
			if enemy_spawn_areas[spawn_area_index].is_occupied:
				while indices.size()>0:
					spawn_area_index=indices.pick_random()
					indices.erase(spawn_area_index)
					
					if enemy_spawn_areas[spawn_area_index].is_occupied==false:
						instantiate_enemy(enemy_scene,spawn_area_index)
						remaining_enemies.erase(enemy_scene)
						#print("breaking")
						break
			else:
				instantiate_enemy(enemy_scene,spawn_area_index)
				remaining_enemies.erase(enemy_scene)
		timer.start(randf_range(0.05,0.1))
		await timer.timeout

	#print(scenes)
	#print(remaining_enemies)
	#print(loops)
	#print(while_loops)
	
	return remaining_enemies

#spawns the enemy at a given spawn area
func instantiate_enemy(enemy_scene:PackedScene,spawn_area_index:int):
	var enemy:EnemyBaseClass=enemy_scene.instantiate()
	enemy.died.connect(_on_enemy_died)
	if shuffle_targets:
		initial_enemy_targets.shuffle()
	enemy_spawn_areas[spawn_area_index].spawn_enemy(enemy,enemy_parent_node,initial_enemy_targets)

func _on_enemy_died(_enemy):
	#enemies_alive-=1
	#print(remaining_wave_enemies.size())
	enemies_alive-=1
	enemy_count_updated.emit(enemies_alive,current_wave_size)
	if remaining_wave_enemies.size()>0:
		var enemy_to_spawn:PackedScene=remaining_wave_enemies[0]
		remaining_wave_enemies.erase(enemy_to_spawn)
		var remaining= await spawn_enemies([enemy_to_spawn])
		if remaining.size()>0:
			for x in remaining:
				remaining_wave_enemies.append(x)
	print(remaining_wave_enemies.size())
	if enemies_alive<=0:
		wave_ended.emit()
	#print(enemies_alive)
		

#func generate_subwaves(wave:Array)->Array:
	#var subwave_array:Array=[]
	#var number_of_subwaves:int=int(ceil(float(wave.size())/float(max_subwave_size)))
	#print(wave.size())
	#print(number_of_subwaves)
	#var enemies_in_subwave:int=int(ceil(float(wave.size())/float(number_of_subwaves)))
	#print(enemies_in_subwave)
	#var index_in_wave:int=0
	#
	#for i in range(number_of_subwaves):
		#var subwave:Array[PackedScene]=[]
		#for j in range(enemies_in_subwave):
			#if index_in_wave<wave.size():
				#subwave.append(wave[index_in_wave])
				#index_in_wave+=1
		#subwave_array.append(subwave)
	
	
	
	#return subwave_array

#func spawn_subwave():
	#var indices:Array[int]=[]
	#var index:int=0
	#for i in enemy_spawn_areas:
		#indices.append(index)
		#index+=1
		#
	#for x in max_subwave_size:
		#var spawn_area_index=indices.pick_random()
		##while enemy_spawn_areas[spawn_area_index].is_occupied==true:
			##indices.erase(spawn_area_index)
			##spawn_area_index=indices.pick_random()
			#
		#indices.erase(spawn_area_index)
		#var enemy:EnemyBaseClass=current_wave_scenes[x].instantiate()
		#enemy_spawn_areas[spawn_area_index].spawn_enemy(enemy,enemy_parent_node)
		#current_wave.append(enemy)
		##var rand=rng.randi_range(0,max_chance)
		##for chance in enemy_spawn_chance:
			##if rand<=chance:
				#
		#

	
	
