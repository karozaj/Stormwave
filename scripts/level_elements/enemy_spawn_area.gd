extends Area3D
class_name EnemySpawnArea
## Area where enemies can be spawned
##
## Marks the point where an enemy can be spawned and stores
## information about if there is anything obstructing the area.

@onready var spawn_point_marker:Marker3D=$Marker3D
@onready var audio_player:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d
@onready var animation_player:AnimationPlayer=$AnimationPlayer

## Sound to be played when an enemy is spawned
@export var spawn_sound_effect:AudioStream

var is_occupied:bool=false
var occupants:Array=[]

func spawn_enemy(enemy:EnemyBaseClass, enemy_parent=get_parent(), initial_targets:Array=[]):
	enemy_parent.add_child(enemy)
	enemy.global_position=spawn_point_marker.global_position
	enemy.add_targets(initial_targets)
	audio_player.play_sound(spawn_sound_effect,1.0,0.1)
	animation_player.play("spawn")

func _on_body_entered(body: Node3D) -> void:
	is_occupied=true
	occupants.append(body)


func _on_body_exited(body: Node3D) -> void:
	occupants.erase(body)
	if occupants.is_empty():
		is_occupied=false
