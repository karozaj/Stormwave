extends EnemyBaseClass
class_name EnemyNavigation

## The enemy's navigation agent node
@export var navigation_agent:NavigationAgent3D
## The timer that determines how of the navigation agent's target can update
@export var target_update_timer:Timer
var new_safe_velocity:Vector3=Vector3.ZERO

func _ready() -> void:
	navigation_agent.velocity_computed.connect(on_navigation_agent_3d_velocity_computed)
	target_update_timer.timeout.connect(on_target_update_timer_timeout)

func _process(_delta: float) -> void:
	update_target_position()

# updates the navigation agent's target position
func update_navagent_target_position():
	if navigation_agent.target_position.distance_to(navigation_target_position)>1.0:
		navigation_agent.target_position=navigation_target_position

func on_target_update_timer_timeout() -> void:
	calculate_navigation_target_position_offset()
	update_navigation_target_position()
	update_navagent_target_position()
	target_update_timer.start()

func on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	new_safe_velocity=safe_velocity
	#velocity = velocity.move_toward(safe_velocity,agility)
	#move_and_slide()

func calculate_navigation_target_position_offset()->Vector3:
	navigation_target_position_offset=Vector3.ZERO
	return navigation_target_position_offset
