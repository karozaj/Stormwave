extends EnemyBaseClass

#@onready var sprite:AnimatedSprite3D=$AnimatedSprite3D
@onready var attack_area:Area3D=$AttackArea
@onready var timer:Timer=$Timer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer
var death_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_death.ogg")
var attack_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_attack.ogg")

@export var dash_speed:float=15.0
@export var attack_time:float=0.25
var is_attacking:bool=false

func _ready() -> void:
	target=Global.player

func _process(delta: float) -> void:
	if target!=null and !is_attacking:
		var current_location=global_transform.origin
		var next_location=target.global_position+Vector3(0,0.75,0)
		look_at(next_location)
		if current_location.distance_to(next_location)>attack_range:
			var new_velocity=(next_location-current_location).normalized()*move_speed
			velocity=velocity.move_toward(new_velocity,10*delta)
		elif can_attack:
			attack()
		else:
			var new_velocity=Vector3(0,0,0)
			velocity=velocity.move_toward(new_velocity,10*delta)

	move_and_slide()


func attack()->void:
	attack_area.monitoring=true
	is_attacking=true
	can_attack=false
	animation_player.play("attack")
	var current_location=global_transform.origin
	var next_location=target.global_position+Vector3(0,0.75,0)
	var new_velocity=(next_location-current_location).normalized()*dash_speed
	velocity=new_velocity
	timer.start(attack_time)
	audio_player.pitch_scale=1.0+randf_range(-.15,.15)
	audio_player.stream=attack_sound
	audio_player.play()


func die()->void:  
	if is_dead==false:
		is_dead=true
		$CollisionShape3D.set_deferred("disabled",true)
		audio_player.stream=death_sound
		audio_player.play()
		#var tween=get_tree().create_tween()
		#tween.tween_property(sprite,"modulate",Color.TRANSPARENT,3)
		timer.start(4)


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		target.damage(base_damage, global_position)


func _on_timer_timeout() -> void:
	if is_dead:
		queue_free()
	if is_attacking==true:
		is_attacking=false
		animation_player.play("idle")
		timer.start(attack_cooldown)
	else:
		can_attack=true
