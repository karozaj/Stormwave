extends Node3D
class_name MovementManager

@onready var coyote_timer:Timer=$CoyoteTimer
@onready var jump_buffer_timer:Timer=$BufferTimer

const SPEED:float=5.0
const SPRINT_SPEED:float=10.0

@export_category("Movement Parameters")
@export var jump_peak_time:float=.5
@export var jump_fall_time:float=.5
@export var jump_height:float=2.5
@export var jump_distance:float=10.0
@export var movement_lerp_val:float=0.0075
@export var sprint_lerp_val:float=0.01
#parameters to calculate
var jump_gravity:float=ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_gravity:float=jump_gravity*2
var jump_velocity:float
var speed:float
var sprint_speed:float
var walk_speed:float
#parameters to determine if player can jump
var jump_available:bool=true
var jump_buffer:bool=false

func _ready() -> void:
	calculate_movement_parameters()
	speed=walk_speed

func calculate_movement_parameters()->void:
	jump_gravity=(2*jump_height)/pow(jump_peak_time,2)
	fall_gravity=(2*jump_height)/pow(jump_fall_time,2)
	jump_velocity=jump_gravity*jump_peak_time
	sprint_speed=jump_distance/(jump_peak_time+jump_fall_time)
	walk_speed=sprint_speed/2.0

func set_sprint_speed(delta:float)->void:
	speed=lerp(speed,sprint_speed,1-pow(sprint_lerp_val,delta))
	
	
func set_walk_speed(delta:float)->void:
	speed=lerp(speed,walk_speed,1-pow(sprint_lerp_val,delta))
	
func _on_coyote_timer_timeout() -> void:
	jump_available=false

func _on_buffer_timer_timeout() -> void:
	jump_buffer=false
