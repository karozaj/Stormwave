extends Node3D

@onready var ray:RayCast3D=$RayCast3D
@onready var muzzle_flash:Sprite3D=$chaingun/Sprite3D
@onready var animation_player=$AnimationPlayer
@onready var audio_player=$AudioStreamPlayer3D
@export var default_pitch:float=0.9
@export var pitch_variance:float=0.1
@export var bullet_spread:float=10.0
var rng=RandomNumberGenerator.new()
var bullet_hole=preload("res://scenes/weapons/bullet_hole.tscn")
var base_damage:int=15
var cooldown:float=0.1
@export var is_being_pulled_out:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()



func set_ray_position(pos:Vector3)->void:
	ray.global_position=pos
	
	
func shoot():
	animation_player.play("shoot")
	var x_rot:float=deg_to_rad(rng.randf_range(-bullet_spread,bullet_spread))
	var y_rot:float=deg_to_rad(rng.randf_range(-bullet_spread,bullet_spread))
	ray.rotation=Vector3(x_rot,y_rot,0.0)
	ray.force_raycast_update()
	if ray.is_colliding():
		spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		print(ray.get_collider().name)
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage, global_position)
	
	
func muzzle_flash_flip():
	var flip_index:int=rng.randi_range(0,1)
	if flip_index==0:
		muzzle_flash.flip_h=!muzzle_flash.flip_h
	else:
		muzzle_flash.flip_v=!muzzle_flash.flip_v


func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-pitch_variance,pitch_variance)
	audio_player.play()


func spawn_bullet_hole(pos:Vector3, normal:Vector3):
	var instance=bullet_hole.instantiate()
	Global.current_level.add_child(instance)
	instance.global_position=pos
	var target:Vector3=instance.global_transform.origin+normal
	if normal!=Vector3.UP and normal!=Vector3.DOWN:
		instance.look_at(target,Vector3.UP)
		instance.rotate_object_local(Vector3(1,0,0),90)
