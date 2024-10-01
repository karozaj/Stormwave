extends CharacterBody3D

const SENSITIVITY=0.004

@onready var movement_manager=$MovementManager
@onready var weapon_manager=$Pivot/WeaponCamera/WeaponManager
#camera
@onready var pivot:Node3D=$Pivot
@onready var main_camera:Camera3D=$Pivot/MainCamera
@onready var weapon_camera:Camera3D=$Pivot/WeaponCamera
#audio players
@onready var footstep_audio_player=$FootstepAudioPlayer
@export_category("Audio")
@export var footstep_default_pitch:float=1.0
@export var footstep_pitch_variance:float=.15
var has_played_footstep_sound:bool=false
var was_on_floor:bool=true

#head bob variables
@export_category("Headbob")
@export var headbob_frequency:float=1.75
@export var headbob_amplitude:float=0.075
var headbob_positon:float=0.0

#fov
@export_category("FOV")
@export var base_fov:float=90.0
@export var fov_increase:float=2.5

var rng=RandomNumberGenerator.new()

func _ready() -> void:
	RenderingServer.viewport_attach_camera($CanvasLayer/SubViewportContainer/SubViewport.get_viewport_rid(),weapon_camera.get_camera_rid())
	rng.randomize()


func _physics_process(delta: float) -> void:
	#print(Vector2(velocity.x,velocity.z).length())
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
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#direction=direction.rotated(Vector3.UP, pivot.rotation.y)
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
	
	move_and_slide()
	
	if Input.is_action_pressed("shoot"):
		weapon_manager.shoot()
		
	#weapon selection
	if Input.is_action_just_pressed("next_weapon"):
		var next_weapon_index:int=(weapon_manager.weapon_index+1)%weapon_manager.weapons.size()
		weapon_manager.select_weapon(next_weapon_index)
	elif Input.is_action_just_pressed("previous_weapon"):
		var next_weapon_index:int=(weapon_manager.weapon_index-1)%weapon_manager.weapons.size()
		weapon_manager.select_weapon(next_weapon_index)
	elif Input.is_action_just_pressed("select_weapon_1"):
		weapon_manager.select_weapon(0)
	elif Input.is_action_just_pressed("select_weapon_2"):
		weapon_manager.select_weapon(1)
	elif Input.is_action_just_pressed("select_weapon_3"):
		weapon_manager.select_weapon(2)
	elif Input.is_action_just_pressed("select_weapon_4"):
		weapon_manager.select_weapon(3)
	elif Input.is_action_just_pressed("select_weapon_5"):
		weapon_manager.select_weapon(4)


func _unhandled_input(event: InputEvent) -> void:
	#mouselook
	if event is InputEventMouseMotion:
		#pivot.rotate_y(-event.relative.x * SENSITIVITY)
		rotate_y(-event.relative.x * SENSITIVITY)
		main_camera.rotate_x(-event.relative.y * SENSITIVITY)
		main_camera.rotation.x = clamp(main_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		weapon_camera.rotate_x(-event.relative.y * SENSITIVITY)
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
