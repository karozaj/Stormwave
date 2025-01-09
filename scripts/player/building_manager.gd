extends Node3D
class_name BuildingManager

signal block_count_changed(count:int) #signal used to notify hud about block change

@onready var cooldown_timer=$CooldownTimer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
#placers
@onready var block_placer:PlacerBaseClass=$RightPosition/BlockPlacer
@onready var reinforced_block_placer:PlacerBaseClass=$RightPosition/ReinforcedBlockPlacer
@onready var explosive_block_placer:PlacerBaseClass=$RightPosition/ExplosiveBlockPlacer
@onready var mine_placer:PlacerBaseClass=$RightPosition/MinePlacer
@onready var turret_placer:PlacerBaseClass=$RightPosition/TurretPlacer

@onready var placers:Array[PlacerBaseClass]=[block_placer,reinforced_block_placer,explosive_block_placer,mine_placer,turret_placer]
var current_placer:PlacerBaseClass
var current_placer_index:int

var block_count:Array[int]=[0,0,0,0,0]
var can_use:bool=true
var no_blocks_sound:AudioStream=preload("res://audio/sfx/blocks/no_blocks.ogg")
var collect_sound:AudioStream=preload("res://audio/sfx/blocks/collect_block.ogg")
var switch_placer_sound:AudioStream=preload("res://audio/sfx/blocks/select_placer.ogg")
var player_height:float=1.75
var player_radius:float=0.35

var index_dict:Dictionary={"Block":0,"Reinforced block":1,"Explosive":2,"Mine":3,"Turret":4}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for placer in placers:
		if placer.has_method("set_ray_position"):
			placer.set_ray_position(global_position)
		placer.player_height=player_height
	current_placer=block_placer
	current_placer_index=0

func place()->void:
	if current_placer.is_being_pulled_out==false:
		if can_use:
			can_use=false
			cooldown_timer.wait_time=current_placer.cooldown
			cooldown_timer.start()
			if block_count[current_placer_index]>0:
				if current_placer.place():
					block_count[current_placer_index]-=1
					block_count_changed.emit(block_count[current_placer_index])
			else:
				play_sound(no_blocks_sound,0.0)


func collect()->void:
	var block_name:String=current_placer.collect()
	if block_name=="Block":
		block_count[0]+=1
		play_sound(collect_sound)
	elif block_name=="Reinforced Block":
		block_count[1]+=1
		play_sound(collect_sound)
	elif block_name=="Explosive Block":
		block_count[2]+=1
		play_sound(collect_sound)
	elif block_name=="Mine":
		block_count[3]+=1
		play_sound(collect_sound)
	elif block_name=="Turret":
		block_count[4]+=1
		play_sound(collect_sound)
	block_count_changed.emit(block_count[current_placer_index])

func select_placer(index:int)->void:
	if can_use and current_placer.is_being_pulled_out==false:
		current_placer.visible=false
		current_placer.ray.enabled=false
		current_placer_index=index
		current_placer=placers[current_placer_index]
		current_placer.ray.enabled=true
		current_placer.is_being_pulled_out=true
		current_placer.animation_player.play("pullout")
		play_sound(switch_placer_sound,0.0)
		block_count_changed.emit(block_count[current_placer_index])

#plays sound when collecting block
func play_sound(sound:AudioStream,v:float=0.1)->void:
	audio_player.stream=sound
	audio_player.pitch_scale=1.0+randf_range(-v,v)
	audio_player.play()

func _on_cooldown_timer_timeout() -> void:
	can_use=true

#func remove_blocks(number:int,type:String):
	#block_count[index_dict[type]]-=number
	#if current_placer_index==index_dict[type]:
		#block_count_changed.emit(block_count[current_placer_index])
#
#func add_blocks(number:int,type:String):
	#block_count[index_dict[type]]+=number
	#if current_placer_index==index_dict[type]:
		#block_count_changed.emit(block_count[current_placer_index])
	
func get_blocks_dict()->Dictionary:
	var dict:Dictionary={}
	for key in index_dict:
		dict[key]=block_count[index_dict[key]]
	return dict
