extends CharacterBody3D
class_name Player
#used to notify enemies of player's death
signal player_died

const SENSITIVITY=0.004
var mouse_sensitivity:float=1.0

@onready var movement_manager:MovementManager=$MovementManager
@onready var weapon_manager:WeaponManager=$Pivot/WeaponCamera/WeaponManager
@onready var building_manager:BuildingManager=$Pivot/WeaponCamera/BuildingManager
@onready var state_machine:StateMachine=$StateMachine
#camera
@onready var pivot:Node3D=$Pivot
@onready var main_camera:Camera3D=$Pivot/MainCamera
@onready var weapon_camera:Camera3D=$Pivot/WeaponCamera
#audio players
@onready var footstep_audio_player:AudioStreamPlayer3D=$FootstepAudioPlayer
#ui
@onready var hud=$CanvasLayer/Hud
@onready var canvas_layer=$CanvasLayer

@export_category("Audio")
## Default pitch for footstep sound
@export var footstep_default_pitch:float=1.0
## How much footstep pitch can change
@export var footstep_pitch_variance:float=.15

var has_played_footstep_sound:bool=false
var was_on_floor:bool=true

#head bob variables
@export_category("Headbob")
## Head bob frequency
@export var headbob_frequency:float=1.75
## Head bob amplitude
@export var headbob_amplitude:float=0.075

var headbob_positon:float=0.0
var headbob_enabled:bool=true

#fov
@export_category("FOV")
## Base FOV
@export var base_fov:float=90.0
## How much FOV is increased when moving
@export var fov_increase:float=2.5

@export_category("Player")
## Determines how far the player is knocked back when damaged
@export var knockback_modifier:float=20.0
## Player health points on start
@export var starting_health:int=100
## How long the player is invincible after being hit
@export var invincibility_time:float=0.25
var health:int=100:
	set(value):
		health=value
		hud.update_health(health)
#var is_dead:bool=false
var is_invincible:bool=false

var rng:RandomNumberGenerator=RandomNumberGenerator.new()

func _ready() -> void:
	Global.player=self
	base_fov=Global.player_fov
	mouse_sensitivity=Global.player_sensitivity
	RenderingServer.viewport_attach_camera($CanvasLayer/SubViewportContainer/SubViewport.get_viewport_rid(),weapon_camera.get_camera_rid())
	health=starting_health
	rng.randomize()
	#hud.update_ammo(weapon_manager.ammo[weapon_manager.current_weapon_index])
	weapon_manager.ammo_count_changed.connect(hud.update_ammo)
	building_manager.block_count_changed.connect(hud.update_ammo)
	building_manager.player_height=$CollisionShape3D.shape.height
	building_manager.player_radius=$CollisionShape3D.shape.radius


func process_update(_delta:float):
		#for testing
	if Input.is_action_just_pressed("TEST_BUTTON"):
		if state_machine.current_state.name=="Combat":
			state_machine.transition_to_next_state(state_machine.current_state,"Build")
		elif state_machine.current_state.name=="Build":
			state_machine.transition_to_next_state(state_machine.current_state,"Combat")
	#if is_dead==false:
		#PROCESS INPUTS
	if Input.is_action_just_pressed("pause"):
		var pause_menu=preload("res://scenes/ui/pause_menu.tscn").instantiate()
		$CanvasLayer.add_child(pause_menu)
			

func physics_process_update(delta:float):
	if not is_on_floor():
	# Add the gravity.
		if movement_manager.jump_available:
				if movement_manager.coyote_timer.is_stopped():
					movement_manager.coyote_timer.start()
		if velocity.y>=0 and Input.is_action_pressed("jump"):
			velocity.y -= movement_manager.jump_gravity * delta
		elif velocity.y>0:
			velocity.y -= 1.75*movement_manager.fall_gravity * delta
		else:
			velocity.y-= movement_manager.fall_gravity * delta
	else:
		movement_manager.jump_available=true
		movement_manager.coyote_timer.stop()
		if movement_manager.jump_buffer:
			jump()

	var direction=Vector3.ZERO
	##PHYSPROCESS INPUTS 
	#if is_dead==false:
	if Input.is_action_just_pressed("jump"):
		if movement_manager.jump_available:
			jump()
		else:
			movement_manager.jump_buffer=true
			movement_manager.jump_buffer_timer.start()
		
	if Input.is_action_pressed("sprint"):
		movement_manager.set_sprint_speed(delta)
	else:
		movement_manager.set_walk_speed(delta)
	
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var lerp_val:float=movement_manager.movement_lerp_val
	
	if is_on_floor()==false:
		lerp_val=lerp_val*2
	if direction:
		velocity.x = lerp(velocity.x,direction.x * movement_manager.speed,1-pow(lerp_val,delta))
		velocity.z = lerp(velocity.z,direction.z * movement_manager.speed,1-pow(lerp_val,delta))
	else :
		velocity.x = lerp(velocity.x,0.0,1-pow(lerp_val,delta))
		velocity.z = lerp(velocity.z,0.0,1-pow(lerp_val,delta))
		
	increase_fov_when_moving(delta,lerp_val)
	headbob(delta)
	if is_on_floor() and was_on_floor==false:
		play_footstep_sound()
	was_on_floor=is_on_floor()


func mouselook(event:InputEvent)->void:
		#mouselook
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY*mouse_sensitivity)
		main_camera.rotate_x(-event.relative.y * SENSITIVITY*mouse_sensitivity)
		main_camera.rotation.x = clamp(main_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		weapon_camera.rotate_x(-event.relative.y * SENSITIVITY*mouse_sensitivity)
		weapon_camera.rotation.x = clamp(weapon_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func jump()->void:
	velocity.y=movement_manager.jump_velocity
	movement_manager.jump_available=false


func headbob(delta:float)->void:
	headbob_positon+=delta*Vector2(velocity.x,velocity.z).length()*float(is_on_floor())
	var camera_position:Vector3=Vector3.ZERO
	var headbob_sin:float=sin(headbob_positon*headbob_frequency)
	camera_position.y=headbob_sin*headbob_amplitude
	camera_position.x=cos(headbob_positon*headbob_frequency/2.0)*headbob_amplitude
	if headbob_enabled:
		main_camera.transform.origin=camera_position
		weapon_camera.transform.origin=camera_position
	#check if footstep sound needs to be played
	if headbob_sin<=-0.9:
		if has_played_footstep_sound==false:
			play_footstep_sound()
			has_played_footstep_sound=true
	else:
		has_played_footstep_sound=false


func play_footstep_sound()->void:
	footstep_audio_player.pitch_scale=footstep_default_pitch+rng.randf_range(-footstep_pitch_variance,footstep_pitch_variance)
	footstep_audio_player.play()


func increase_fov_when_moving(delta:float,lerp_val:float)->void:
	var velocity_clamped:float=clamp(Vector2(velocity.x,velocity.z).length(),0.0,movement_manager.sprint_speed)
	var target_fov:float=base_fov+fov_increase*velocity_clamped
	main_camera.fov=lerp(main_camera.fov,target_fov,1-pow(lerp_val,delta))


func damage(damage_points:int, origin:Vector3)->void:
	state_machine.current_state.damage(damage_points,origin)

func take_damage(damage_points:int, origin:Vector3)->void:
	#if is_dead==false:
	if is_invincible==false:
		health-=damage_points
		var knockback_direction:Vector3=global_position-origin
		knockback_direction=knockback_direction.normalized()
		velocity+=knockback_direction*damage_points/100*knockback_modifier
		is_invincible=true
		var invincibility_timer=get_tree().create_timer(invincibility_time)
		invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
		hud.show_pain_overlay(damage_points)
		if health<=0:
			die()

func _on_invincibility_timer_timeout():
	is_invincible=false

func die()->void:
	state_machine.transition_to_next_state(state_machine.current_state,"Dead")
	var death_menu=load("res://scenes/ui/death_menu.tscn").instantiate()
	canvas_layer.add_child(death_menu)
	#if is_dead==false:
		#is_dead=true


#func update_hud_ammo(count:int)->void:
	#hud.update_ammo(count)
