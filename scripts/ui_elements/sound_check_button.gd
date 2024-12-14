extends CheckButton
class_name SoundCheckButton
# Button that plays a given sound when toggled

@export_category("Press sound")
## Sound to be played when pressing this button
@export var press_sound:AudioStream
## Pitch of press_sound
@export var sound_pitch:float=1.0

func _ready() -> void:
	if press_sound==null:
		pressed.connect(UISoundPlayer.play_sound)
	else:
		pressed.connect(UISoundPlayer.play_sound.bind(press_sound,sound_pitch))
		
