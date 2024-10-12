extends WeaponBaseClass

@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var projectile_spawn_marker:Marker3D=$Cylinder/Marker3D
@onready var rocket_direction_ray:RayCast3D=$RayCast3D
var projectile_scene=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")
var shooting_sound:AudioStream=preload("res://audio/sfx/rocket_launcher.ogg")

func _ready() -> void:
	audio_player.stream=shooting_sound

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
