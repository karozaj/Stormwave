extends CharacterBody3D

var health:int=100
var knockback_modifier=20.0
var lerp_val:float=.05
var gravity=ProjectSettings.get_setting("physics/3d/default_gravity")


	
func _physics_process(delta: float) -> void:
	velocity.x = lerp(velocity.x,0.0,(1-pow(lerp_val,delta)))
	velocity.z = lerp(velocity.z,0.0,(1-pow(lerp_val,delta)))
	if is_on_floor()==false:
		velocity.y-= gravity * delta
	if velocity.y>0:
		velocity.y-=2*gravity*delta
	move_and_slide()


func damage(damage_points:int, origin:Vector3,_damage_dealer):
	health-=damage_points
	print("enemy damaged ",health)
	var knockback_direction:Vector3=global_position-origin
	knockback_direction=knockback_direction.normalized()
	velocity+=knockback_direction*damage_points/100*knockback_modifier
