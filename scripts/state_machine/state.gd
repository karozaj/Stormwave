extends Node
class_name State

@warning_ignore("unused_signal") #ignore unused signal warning because this is just a base class
signal finished(state:State,next_state:String, transition_data:Dictionary)

func enter(_transition_data:Dictionary={})->void:
	pass

func update(_delta:float)->void:
	pass
	
func physics_update(_delta:float)->void:
	pass

func damage(_damage_points:int, _origin:Vector3)->void:
	pass

func exit()->void:
	pass
