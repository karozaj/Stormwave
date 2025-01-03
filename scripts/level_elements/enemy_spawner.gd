extends Node3D
class_name EnemySpawner
## Handles the spawning of enemies
##
## Handles the spawning of enemies
## Should contain EnemySpawnArea nodes

## The node that should be the parent of the spawned enemies
@export var enemy_parent_node:Node3D
## The scenes of the enemies that can be spawned
@export var enemy_scenes:Array[PackedScene]
## The EnemySpawnAreas where the enemies will be spawned
@export var enemy_spawn_areas:Array[EnemySpawnArea]
## Maximum number of enemies that can be spawned at the same time. Can't be greater than the number of EnemySpawnAreas
@export var max_subwave_size:int
## The number of enemies in a wave
@export var wave_size:int
## How much the wave size increases with each wave
@export var wave_size_increase:int
## Determines how likely each enemy type is to spawn. A value must be defined for each enemy type.
@export var enemy_spawn_chance:Array[int]
## Determines by how much the chance of each enemy type spawning should increase between waves
@export var enemy_spawn_chance_increase:Array[int]
## Random nubmer generator seed
@export var rng_seed:int=randi()
var rng=RandomNumberGenerator.new()

var current_wave_number:int=0
var current_wave:Array[EnemyBaseClass]
var current_wave_scenes:Array[PackedScene]
var current_wave_size:int
var current_subwaves:Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.seed=rng_seed
	if max_subwave_size>enemy_spawn_areas.size():
		max_subwave_size=enemy_spawn_areas.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# generates a wave of enemies
func generate_wave()->Array[PackedScene]:
	current_wave_number+=1
	current_wave_size=wave_size+(current_wave_number-1)*wave_size_increase
	var new_wave:Array[PackedScene]=[]
	for i in range(wave_size):
		new_wave.append(get_random_enemy_scene())
	current_wave_scenes=new_wave
	return new_wave

# returns random enemy from array of possible enemies
func get_random_enemy_scene()->PackedScene:
	var chosen_enemy:PackedScene=null
	var chance_sum:int=0
	for x in enemy_spawn_chance:
		chance_sum+=x
	
	var rand=rng.randi_range(0,chance_sum)
	for i in enemy_spawn_chance.size():
		if rand<=enemy_spawn_chance[i]:
			chosen_enemy=enemy_scenes[i]
			return chosen_enemy
	
	chosen_enemy=enemy_scenes[0]
	return chosen_enemy

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

	
	
