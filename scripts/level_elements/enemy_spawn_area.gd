extends Area3D
class_name EnemySpawnArea
## Area where enemies can be spawned
##
## Marks the point where an enemy can be spawned and stores
## information about if there is anything obstructing the area.

@onready var spawn_point_marker:Marker3D=$Marker3D
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer

## Sound to be played when an enemy is spawned
@export var spawn_sound_effect:AudioStream

var is_occupied:bool=false
var occupants:Array=[]

func spawn_enemy(enemy:EnemyBaseClass, enemy_parent=get_parent(), initial_targets:Array=[]):
	enemy_parent.add_child(enemy)
	enemy.global_position=spawn_point_marker.global_position
	enemy.add_targets(initial_targets)
	play_sound_effect(spawn_sound_effect)
	animation_player.play("spawn")
	#print("spawn")

func _on_body_entered(body: Node3D) -> void:
	is_occupied=true
	occupants.append(body)


func _on_body_exited(body: Node3D) -> void:
	occupants.erase(body)
	if occupants.is_empty():
		is_occupied=false


func play_sound_effect(sound:AudioStream, pitch_from:float=-0.0,pitch_to:float=0.0, pitch_base:float=1.0)->void:
	audio_player.stream=sound
	audio_player.pitch_scale=pitch_base+randf_range(pitch_from,pitch_to)
	audio_player.play()
