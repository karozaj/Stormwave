extends EnemyBaseClass

@onready var lightning:Node3D=$Lightning
@onready var raycast:RayCast3D=$RayCast3D
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var timer:Timer=$Timer

var thunder_sound:AudioStream=preload("res://audio/sfx/thunder.ogg")
var charging_sound:AudioStream=preload("res://audio/sfx/charge.ogg")
var death_sound:AudioStream=preload("res://audio/sfx/enemy_ghost_death.ogg")
@export var height_over_target:float=5.0
@export var attack_charging_time:float=1.5
var is_attacking:bool=false

func _ready() -> void:
	target=Global.player


func _process(delta: float) -> void:
	if target==null or is_dead:
		velocity=velocity.move_toward(Vector3.ZERO,7.5*delta)
	else:
		var current_location=global_transform.origin
		var next_location=target.global_position+Vector3(0,height_over_target,0)
		if Vector2(current_location.x,current_location.z).distance_to(Vector2(next_location.x,next_location.z)):
			$eye.look_at(target.global_position)
		if Vector2(current_location.x,current_location.z).distance_to(Vector2(next_location.x,next_location.z))>attack_range:
			var new_velocity=(next_location-current_location).normalized()*move_speed
			velocity=velocity.move_toward(new_velocity,7.5*delta)
		else:
			velocity=velocity.move_toward(Vector3.ZERO,7.5*delta)
			raycast.look_at(target.global_position)
			if can_attack:
				attack()
				can_attack=false
			
	move_and_slide()

func attack()->void:
	is_attacking=true
	audio_player.stream=charging_sound
	audio_player.play()
	timer.start(attack_charging_time)
	play_charge_sound()

func calculate_lightning_size(target_position:Vector3):
	lightning.look_at(Vector3(target_position.x, lightning.global_position.y,target_position.z))
	var distance:float=lightning.global_position.distance_to(target_position)
	var lightning_height:float=64.0*$Lightning/LightningSprite.pixel_size
	lightning.scale.y=distance/lightning_height
	var distance_v=abs(lightning.global_position.y-target_position.y)
	var lightning_rotation=acos(distance_v/distance)
	print(rad_to_deg(lightning_rotation))
	lightning.global_rotation.x=lightning_rotation
	print(lightning.global_rotation.x)
	lightning.visible=true
	
func die()->void:  
	if is_dead==false:
		is_dead=true
		$CollisionShape3D.set_deferred("disabled",true)
		audio_player.pitch_scale=0.5
		audio_player.stream=death_sound
		audio_player.play()
		#var tween=get_tree().create_tween()
		#tween.tween_property($Sprite3D,"modulate",Color.TRANSPARENT,3)
		timer.start(4)



func _on_timer_timeout() -> void:
	if is_dead:
		queue_free()
	if is_attacking:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			calculate_lightning_size(raycast.get_collision_point())
			audio_player.pitch_scale=1.0
			audio_player.stream=thunder_sound
			audio_player.play()
			if raycast.get_collider().has_method("damage"):
				raycast.get_collider().damage(base_damage,global_position)
		is_attacking=false
		$LightningTimer.start()
		$CooldownTimer.start(attack_cooldown)


func _on_lightning_timer_timeout() -> void:
	lightning.visible=false
	
func _on_cooldown_timer_timeout() -> void:
	can_attack=true
	
	
func play_charge_sound()->void:
	audio_player.pitch_scale=0.5
	audio_player.stream=charging_sound
	audio_player.play()
