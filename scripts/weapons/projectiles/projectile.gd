extends Area3D
class_name Projectile

## How much damage the projectile deals when directly hitting a target
@export var direct_damage:int=50
## How fast the projectile flies
@export var projectile_speed:float=15.0
## Timer that deletes the projectile on timeout
@export var projectile_lifetime_timer:Timer
## Determines if this projectile can be deflected
@export var can_be_deflected:bool=true

#the entity that shot the projectile
var projectile_owner:Object
var is_flying:bool=true

func _ready() -> void:
	projectile_lifetime_timer.start()

func _physics_process(delta: float) -> void:
	if is_flying:
		position-=transform.basis*Vector3(0,0,projectile_speed)*delta

func deflect(new_owner:Node3D, new_basis:Basis):
	if can_be_deflected:
		projectile_owner=new_owner
		transform.basis=new_basis
		projectile_lifetime_timer.stop()
		projectile_lifetime_timer.start()


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(direct_damage, global_position,projectile_owner)
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.has_method("damage"):
		area.damage(direct_damage, global_position,projectile_owner)
	queue_free()	


func _on_projectile_lifetime_timer_timeout() -> void:
	queue_free()
