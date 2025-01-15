extends MeshInstance3D
class_name WaterEffect
## Visual representation of water

## Sound played when the water is electrified
@export var electrify_sound_effect:AudioStream
## Audio playeers for playing sound effects
@export var audio_players: Array[RandomizedPitchAudioPlayer3D]


@onready var animation_player:AnimationPlayer=$AnimationPlayer

func play_electrify_sound()->void:
	for audio_player in audio_players:
		audio_player.play_sound(electrify_sound_effect)

func play_electrify_animation()->void:
	animation_player.play("electrify")
	play_electrify_sound()
