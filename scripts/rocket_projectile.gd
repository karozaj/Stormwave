extends Area3D

@onready var timer:Timer=$ProjectileLifetimeTimer
@onready var projectile_sprite:Sprite3D=$Sprite3D
@onready var explosion_sprite:Sprite3D=$ExplosionSprite
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var explosion_area:Area3D=$ExplosionArea
@onready var explosion_shape:Shape3D=$ExplosionArea/CollisionShape3D.shape
@onready var explosion_ray:RayCast3D=$RayCast3D
@export var direct_damage:int=150
@export var explosion_max_damage:int=100
@export var projectile_speed:float=15.0
@export var explosion_radius:float=2.5
var is_flying:bool=true

func _ready() -> void:
	explosion_shape.radius=0.25*explosion_radius
	timer.start()


func _physics_process(delta: float) -> void:
	if is_flying:
		position-=transform.basis*Vector3(0,0,projectile_speed)*delta


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(direct_damage, global_position)
	explode()


func explode()->void:
	set_deferred("monitoring",false)
	audio_player.play()
	projectile_sprite.visible=false
	is_flying=false
	explosion_sprite.visible=true
	var tween=get_tree().create_tween()
	tween.tween_property(explosion_sprite,"modulate",Color.TRANSPARENT,0.25)
	var tween_scale=get_tree().create_tween()
	tween_scale.tween_property(explosion_sprite,"scale",Vector3(1.5,1.5,1.5),0.25)
	explosion_area.monitoring=true
	var tween_explosion=get_tree().create_tween()
	tween_explosion.tween_property(explosion_shape,"radius",explosion_radius,0.25)

func _destroy_projectile():
	queue_free()


func _on_explosion_area_body_entered(body: Node3D) -> void:
	explosion_ray.target_position=to_local(body.global_position)
	explosion_ray.force_raycast_update()
	if explosion_ray.is_colliding() and explosion_ray.get_collider()==body:
		if body.has_method("damage"):
			explosion_ray.add_exception(body)
			var distance:float=global_position.distance_to(explosion_ray.get_collision_point())
			var damage_modifier:float=(explosion_radius-distance)/explosion_radius
			body.damage(explosion_max_damage*damage_modifier, global_position)
