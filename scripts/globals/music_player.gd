extends AudioStreamPlayer
## An [AudioStreamPlayer] used for playing music

## Music played in the menu or during sections without combat
@export var calm_music:Array[AudioStream]
#Music played during combat
@export var battle_music:Array[AudioStream]
## Base volume
@export var base_volume:float

var tween:Tween

func _ready() -> void:
	volume_db=linear_to_db(base_volume)

func play_battle_music():
	if is_instance_valid(tween):
		tween.stop()
		tween.kill()
	print("play music")
	volume_db=linear_to_db(base_volume)
	stream=battle_music.pick_random()
	print(stream)
	play()
	print(db_to_linear(volume_db))
	print(playing)

func fade_out():
	tween=create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "volume_db",linear_to_db(0.001), 3)
	tween.finished.connect(stop)
