extends Node3D
class_name BaseLevel
## Base class for levels
##
## Should include a player, an enemy spawner and a nav region


## The player in this level
@export var player:Player
## The navigation region in this level
@export var nav_region:NavRegion
## The enemy spawner in this level
@export var enemy_spawner:EnemySpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
