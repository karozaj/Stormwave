extends GPUParticles3D
class_name BlockDestroyedEffect

@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
var sound:AudioStream
var pitch:float=1.0

func _ready() -> void:
	emitting=true
	audio_player.pitch_scale=pitch+randf_range(-0.1,0.1)
	audio_player.stream=sound
	audio_player.play()

func _on_finished() -> void:
	#print("particle finished")
	queue_free()
