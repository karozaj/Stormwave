extends Node3D
class_name BuildingManager

signal block_count_changed #signal used to notify hud about block change

@onready var cooldown_timer=$CooldownTimer
#placers
@onready var block_placer:PlacerBaseClass=$RightPosition/BlockPlacer
var placers:Array[PlacerBaseClass]=[]
var current_placer:PlacerBaseClass
var current_placer_index:int

var block_count:Array[int]=[10]
var can_use:bool=true
var no_blocks_sound:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	placers=[block_placer]
	for placer in placers:
		if placer.has_method("set_ray_position"):
			placer.set_ray_position(global_position)
	current_placer=block_placer
	current_placer_index=0
	#current_placer.animation_player.play("pullout")

func place()->void:
	if current_placer.is_being_pulled_out==false:
		if can_use:
			can_use=false
			cooldown_timer.wait_time=current_placer.cooldown
			cooldown_timer.start()
			if block_count[current_placer_index]>0:
				if current_placer.place():
					block_count[current_placer_index]-=1
					block_count_changed.emit()
			#else:
				#audio_player.stream=sound_no_blocks
				#audio_player.play()

func destroy()->void:
	current_placer.destroy()

func select_placer(index:int)->void:
	if can_use and current_placer.is_being_pulled_out==false:
		current_placer.visible=false
		current_placer_index=index
		current_placer=placers[current_placer_index]
		current_placer.is_being_pulled_out=true
		current_placer.animation_player.play("pullout")
		block_count_changed.emit()
		#audio_player.stream=sound_weapon_select
		#audio_player.play()


func _on_cooldown_timer_timeout() -> void:
	can_use=true