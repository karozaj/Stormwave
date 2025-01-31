extends GPUParticles3D
class_name BlockDestroyedEffect
## [GPUParticles3D] effect used when blocks are destroyed

## Audio player that plays the given sound effect
@onready var audio_player:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d
## Sound to be played after the effect is created
var sound:AudioStream
## Pitch of the sound to be played
var pitch:float=1.0
## Pitch variance of the sound to be played
var sound_variance:float=0.1

## Use this function to create an effect
static func create_effect(sound_arg:AudioStream,pitch_arg:float=1.0,sound_variance_arg:float=0.1):
	var effect:BlockDestroyedEffect=load("res://scenes/block_building/block_destroyed_effect.tscn").instantiate()
	effect.sound=sound_arg
	effect.pitch=pitch_arg
	effect.sound_variance=sound_variance_arg
	return effect

func _ready() -> void:
	emitting=true
	audio_player.play_sound(sound,pitch,sound_variance)

## When particles stop emitting, free the scene
func _on_finished() -> void:
	queue_free()
