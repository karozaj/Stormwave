extends CharacterBody3D
class_name Player

@warning_ignore("unused_signal")
## Emitted when the player dies
signal died(obj:Object)
@warning_ignore("unused_signal")
## Emitted when the raycast of current placer in building mode stops collidng, used to clear block highlight
signal building_ray_stopped_colliding
## Emitted when the start wave button in shop menu is pressed
signal wave_start_demanded

const SENSITIVITY=0.004
var mouse_sensitivity:float=1.0

@onready var movement_manager:MovementManager=$MovementManager
@onready var weapon_manager:WeaponManager=$Pivot/WeaponCamera/WeaponManager
@onready var building_manager:BuildingManager=$Pivot/WeaponCamera/BuildingManager
@onready var state_machine:StateMachine=$StateMachine
#Marker used to indicate where enemies should aim
@onready var aim_point:Marker3D=$AimPoint
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
## Footstep sound
@export var footstep_sound:AudioStream

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
@export var invincibility_time:float=0.4
var health:int=100:
	set(value):
		health=value
		hud.update_health(health)
var is_invincible:bool=false
var is_dead:bool=false

var pause_menu:PauseMenu
var shop_menu:ShopMenu
var death_menu:DeathMenu
var rng:RandomNumberGenerator=RandomNumberGenerator.new()

func _ready() -> void:
	Global.player=self
	base_fov=Global.player_fov
	mouse_sensitivity=Global.player_sensitivity
	RenderingServer.viewport_attach_camera($CanvasLayer/SubViewportContainer/SubViewport.get_viewport_rid(),weapon_camera.get_camera_rid())
	health=starting_health
	rng.randomize()
	weapon_manager.ammo_count_changed.connect(hud.update_ammo)
	building_manager.block_count_changed.connect(hud.update_ammo)
	building_manager.player_height=$CollisionShape3D.shape.height
	building_manager.player_radius=$CollisionShape3D.shape.radius
	
	footstep_audio_player.stream=footstep_sound


func process_update(_delta:float):
		#for testing
	#if Input.is_action_just_pressed("TEST_BUTTON"):
		#if state_machine.current_state.name=="Combat":
			#state_machine.transition_to_next_state(state_machine.current_state,"Build")
		#elif state_machine.current_state.name=="Build":
			#state_machine.transition_to_next_state(state_machine.current_state,"Combat")
		#PROCESS INPUTS
	if Input.is_action_just_pressed("pause") and is_instance_valid(pause_menu)==false:
		pause_menu=load("res://scenes/ui/pause_menu.tscn").instantiate()
		canvas_layer.add_child(pause_menu)

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


func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	state_machine.current_state.damage(damage_points,origin,damage_dealer)

func take_damage(damage_points:int, origin:Vector3,_damage_dealer)->void:
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
	if state_machine.current_state.name!="Dead":
		state_machine.transition_to_next_state(state_machine.current_state,"Dead")



func enter_building_state():
	if state_machine.current_state.name!="Dead" and state_machine.current_state.name!="Build":
		state_machine.transition_to_next_state(state_machine.current_state,"Build")
	
func enter_fighting_state():
	if state_machine.current_state.name!="Dead" and state_machine.current_state.name!="Combat":
		state_machine.transition_to_next_state(state_machine.current_state,"Combat")

func open_shop_menu():
	if is_instance_valid(shop_menu)==false:
		shop_menu=load("res://scenes/ui/shop.tscn").instantiate()
		canvas_layer.add_child(shop_menu)
		shop_menu.update_player_resource_count(get_resource_dict())
		shop_menu.resource_purchased.connect(on_resource_purchased)
		shop_menu.start_wave_pressed.connect(wave_start_demanded.emit)

func add_health(number:int):
	health+=number

func get_resource_dict()->Dictionary:
	var dict:Dictionary={"Health":health}
	dict.merge(weapon_manager.get_ammo_dict())
	dict.merge(building_manager.get_blocks_dict())
	return dict

func modify_resource_count(res:ShopResource, number_change:int=res.purchasable_number)->void:
	if res.type=="Health":
		health=clamp(health+number_change,0,res.max_number)
	elif res.type=="Ammo":
		var dict:Dictionary=weapon_manager.index_dict
		if dict.has(res.res_name):
			var index:int=dict[res.res_name]
			weapon_manager.ammo[index]=clamp(weapon_manager.ammo[index]+number_change,0,res.max_number)
		#for key in dict:
			#if res.res_name==key:
				#weapon_manager.ammo[dict[key]]=clamp(weapon_manager.ammo[dict[key]]+number_change,0,res.max_number)
			if state_machine.current_state.name=="Combat":
				if weapon_manager.current_weapon_index==dict[res.res_name]:
					weapon_manager.ammo_count_changed.emit(weapon_manager.ammo[weapon_manager.current_weapon_index])
	elif res.type=="Block":
		var dict:Dictionary=building_manager.index_dict
		if dict.has(res.res_name):
			var index:int=dict[res.res_name]
			building_manager.block_count[index]=clamp(building_manager.block_count[index]+number_change,0,res.max_number)
		#for key in dict:
			#if res.res_name==key:
				#building_manager.block_count[dict[key]]=clamp(building_manager.block_count[dict[key]]+number_change,0,res.max_number)
			if state_machine.current_state.name=="Build":
				if building_manager.current_placer_index==dict[res.res_name]:
					building_manager.block_count_changed.emit(building_manager.block_count[building_manager.current_placer_index])

#called when player buys something in the shop
func on_resource_purchased(res:ShopResource,currency:ShopResource,shop:ShopMenu)->void:
	modify_resource_count(res)
	modify_resource_count(currency,-res.price)
	
	shop.update_player_resource_count(get_resource_dict())
	shop.on_item_list_item_selected(shop.selected_index)

func show_game_over_menu(score_message:String,message:String)->void:
	death_menu=load("res://scenes/ui/death_menu.tscn").instantiate()
	death_menu.message=message
	death_menu.score_message=score_message
	canvas_layer.add_child(death_menu)

func on_game_ended(score_message:String,message:String)->void:
	if state_machine.current_state.name!="Dead":
		state_machine.transition_to_next_state(state_machine.current_state,"Dead")
	show_game_over_menu(score_message,message)

func set_ammo(new_ammo:Array[int])->void:
	if new_ammo.size()==(weapon_manager.ammo.size()-1):
		for i in new_ammo.size():
			weapon_manager.ammo[i+1]=new_ammo[i]
	if state_machine.current_state.name=="Combat":
		weapon_manager.ammo_count_changed.emit(weapon_manager.ammo[weapon_manager.current_weapon_index])

func set_blocks(new_blocks:Array[int])->void:
	if new_blocks.size()==building_manager.block_count.size():
		building_manager.block_count=new_blocks
	if state_machine.current_state.name=="Build":
		building_manager.block_count_changed.emit(building_manager.block_count[building_manager.current_placer_index])

func set_footstep_sound(new_sound:AudioStream=footstep_sound)->void:
	footstep_audio_player.stream=new_sound
