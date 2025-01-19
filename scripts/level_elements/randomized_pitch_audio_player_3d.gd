extends AudioStreamPlayer3D
class_name RandomizedPitchAudioPlayer3D
## Audio player with randomized pitch

## The base pitch
@export var base_pitch:float=1.0
## How much the pitch can change
@export var pitch_variance:float=0.1

func play_current_sound():
	self.pitch_scale=base_pitch+randf_range(-pitch_variance,pitch_variance)
	self.play()

func play_sound(sound:AudioStream, p:float=base_pitch,v:float=pitch_variance):
	self.stream=sound
	self.pitch_scale=p+randf_range(-v,v)
	self.play()
