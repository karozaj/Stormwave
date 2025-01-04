extends StaticBody3D

signal died(sender)

@onready var aim_point:Marker3D=$AimPoint
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
## The generator's durability points
@export var durability:int=500
@onready var max_durability:int=durability
## The sound played when the generator is damaged
@export var damaged_sound:AudioStream
## he sound played when the generator is destroyed
@export var destroyed_sound:AudioStream

var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")
var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")
var is_dead:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	play_sound(damaged_sound)
	$Cylinder_001.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	$Cube.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		destroy()

func destroy():
	is_dead=true
	died.emit(self)
	var expl=explosion.instantiate()
	Global.current_level.add_child(expl)
	expl.global_position=aim_point.global_position
	expl.explode()
	var effect:BlockDestroyedEffect=destroyed_effect.instantiate()
	effect.sound=destroyed_sound
	Global.current_level.add_child(effect)
	effect.global_position=aim_point.global_position
	queue_free()

#plays given sound
func play_sound(sound:AudioStream, v:float=0.1,pitch:float=1.0):
	if audio_player.playing==false:
		audio_player.pitch_scale=pitch+randf_range(-v,v)
		audio_player.stream=sound
		audio_player.play()
