extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var target
var gravity:float=ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_range:float=2.0
var is_dead:bool=false
var health:int=50
var knockback_modifier:float=20.0

func _ready() -> void:
	target=Global.player
	$AnimatedSprite3D.play("idle")

func _physics_process(_delta: float) -> void:
	if target==null:
		return
	
	var looking_direction=Vector3(target.global_position.x,target.global_position.y,target.global_position.z)	
	look_at(looking_direction)
	
	var current_location=global_transform.origin
	var next_location=target.global_position+Vector3(0,0.75,0)
	if current_location.distance_to(next_location)>attack_range:
		var new_velocity=(next_location-current_location).normalized()*SPEED
		velocity.x=velocity.move_toward(new_velocity,0.25).x
		velocity.y=velocity.move_toward(new_velocity,0.25).y
		velocity.z=velocity.move_toward(new_velocity,0.25).z
	else:
		var new_velocity=Vector3(0,0,0)
		velocity.x=velocity.move_toward(new_velocity,0.25).x
		velocity.y=velocity.move_toward(new_velocity,0.25).y
		velocity.z=velocity.move_toward(new_velocity,0.25).z
	
	move_and_slide()

func damage(damage_points:int, origin:Vector3)->void:
	if is_dead==false:
		health-=damage_points
		var knockback_direction:Vector3=global_position-origin
		knockback_direction=knockback_direction.normalized()
		velocity+=knockback_direction*damage_points/100*knockback_modifier
		if health<=0:
			die()

	#
func die()->void:
	if is_dead==false:
		is_dead=true
		queue_free()
		
