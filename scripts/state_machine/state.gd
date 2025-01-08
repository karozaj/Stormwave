extends Node
class_name State
#finished signal is used to transition between states
@warning_ignore("unused_signal") #ignore unused signal warning because this is just a base class
signal finished(state:State,next_state:String, transition_data:Dictionary)
#executes when entering state
func enter(_transition_data:Dictionary={})->void:
	pass
#executes in _process function when in this state
func update(_delta:float)->void:
	pass
#executes in _physics_process function when in this state
func physics_update(_delta:float)->void:
	pass
#input
func handle_input(_event: InputEvent) -> void:
	pass
#executes when taking damage
func damage(_damage_points:int, _origin:Vector3,_damage_dealer)->void:
	pass
#executes when leaving state
func exit()->void:
	pass
