extends StaticBody3D
class_name Generator
## A generator which can be used as an objective for the enemies to destroy

## Emitted when generator is destroyed
signal died(sender)
## Emitted when the generator is destroyed, used to signal the navregion to update the navmesh
signal map_updated

@onready var aim_point:Marker3D=$AimPoint
@onready var audio_player:RandomizedPitchAudioPlayer3D=$RandomizedPitchAudioPlayer3d
## The generator's durability points
@export var durability:int=1000
@onready var max_durability:int=durability
## The sound played when the generator is damaged
@export var damaged_sound:AudioStream
## he sound played when the generator is destroyed
@export var destroyed_sound:AudioStream

var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")
var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")
var is_dead:bool=false


func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	audio_player.play_sound(damaged_sound,1.0,0.1)
	$Cylinder_001.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	$Cube.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		destroy()

func destroy():
	is_dead=true
	died.emit(self)
	map_updated.emit()
	var expl=explosion.instantiate()
	Global.current_level.add_child(expl)
	expl.global_position=aim_point.global_position
	expl.explode()
	var effect:BlockDestroyedEffect=destroyed_effect.instantiate()
	effect.sound=destroyed_sound
	Global.current_level.add_child(effect)
	effect.global_position=aim_point.global_position
	queue_free()
