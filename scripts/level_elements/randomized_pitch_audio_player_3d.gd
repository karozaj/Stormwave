extends AudioStreamPlayer3D
class_name RandomizedPitchAudioPlayer3D
## [AudioStreamPlayer3D] with randomized pitch

## The base pitch
@export var base_pitch:float=1.0
## How much the pitch can change
@export var pitch_variance:float=0.1

## Plays currently set sound
func play_current_sound(p:float=base_pitch,v:float=pitch_variance):
	self.pitch_scale=p+randf_range(-v,v)
	self.play()

## Sets new sound and plays it
func play_sound(sound:AudioStream=self.stream, p:float=base_pitch,v:float=pitch_variance):
	self.stream=sound
	self.pitch_scale=p+randf_range(-v,v)
	self.play()
