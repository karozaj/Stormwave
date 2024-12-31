#extends CharacterBody3D
#
#@export var movement_speed: float = 4.0
#
#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#@onready var target=Global.player
#var gravity:float=9.0
#@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
#
#func _ready() -> void:
	#navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	#
#
#func set_movement_target(movement_target: Vector3):
	#navigation_agent.set_target_position(movement_target)
	#
##func _process(delta: float) -> void:
		### Add the gravity.
	##if not is_on_floor():
		##velocity.y -= gravity * delta
	##
	##if target==null:
		##target=Global.player
		##return
	##update_target_location(target.global_position)
	##var current_location=global_transform.origin
	##var next_location=$NavigationAgent3D.get_next_path_position()
	##var new_velocity=(next_location-current_location).normalized()*SPEED
	##velocity.x=velocity.move_toward(new_velocity,0.25).x
	##velocity.z=velocity.move_toward(new_velocity,0.25).z
	##var looking_direction=Vector3(target.global_position.x,global_position.y,target.global_position.z)
	##look_at(looking_direction)
	#
#func _physics_process(delta):
	## Do not query when the map has never synchronized and is empty.
	#if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		#return
	#if navigation_agent.is_navigation_finished():
		#return
#
	#set_movement_target(Global.player.global_position)
	#
	#var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	#var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	#if navigation_agent.avoidance_enabled:
		#navigation_agent.set_velocity(new_velocity)
	#else:
		#_on_velocity_computed(new_velocity)
	#
#func _on_velocity_computed(safe_velocity: Vector3):
	#print(safe_velocity)
	#velocity = safe_velocity
	#move_and_slide()
	##var dir=player.global_position-global_position
	##dir.y=0.0
	##dir=dir.normalized()
	##velocity.x=dir.x*SPEED
	##velocity.z=dir.z*SPEED
	#
	#move_and_slide()
#
#func update_target_location(target_location)->void:
	#$NavigationAgent3D.target_position=target_location
extends CharacterBody3D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	set_movement_target(Vector3(50,50,50))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	set_movement_target(Global.player.global_position)
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return


	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
