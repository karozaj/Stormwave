extends Node3D

@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var projectile_spawn_marker:Marker3D=$Cylinder/Marker3D
@onready var rocket_direction_ray:RayCast3D=$RayCast3D
@export var is_being_pulled_out:bool=false
@export var default_pitch:float=1.0
@export var pitch_variance:float=0.1
var projectile_scene=preload("res://scenes/weapons/rocket_projectile.tscn")
var rng:RandomNumberGenerator=RandomNumberGenerator.new()
var cooldown:float=0.8


func shoot():
	animation_player.play("shoot")
	var projectile=projectile_scene.instantiate()
	#this is so that the rocket doesnt collide with the player when they shoot downward
	projectile.set_collision_mask_value(1,false)
	projectile.transform.basis=rocket_direction_ray.global_transform.basis
	if Global.current_level!=null:
		Global.current_level.add_child(projectile)
	projectile.global_position=projectile_spawn_marker.global_position
	rocket_direction_ray.force_raycast_update()
	if rocket_direction_ray.is_colliding():
		projectile.explode()


func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
	audio_player.play()
