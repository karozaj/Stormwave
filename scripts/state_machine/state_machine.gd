extends Node
class_name StateMachine

## Determines which state the object will be in after spawning.
@export var initial_state: State = null
var current_state:State=null
var states:Dictionary={}

## states should be children of StateMachine node
func _ready() -> void:
	await owner.ready
	for child in get_children():
		if child is State:
			states[child.name]=child
			child.finished.connect(transition_to_next_state)
	initial_state.enter()
	current_state=initial_state


func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func transition_to_next_state(state:State, new_state_name:String, transition_data:Dictionary={}) -> void:
	if state != current_state:
		return
	var new_state = states.get(new_state_name)
	if new_state==null:
		printerr("State "+new_state_name+" does not exist in "+owner.name)
		return
	# Clean up the previous state
	if current_state:
		current_state.exit()
	# Intialize the new state
	new_state.enter(transition_data)
	current_state = new_state
