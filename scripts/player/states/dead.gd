extends State

@onready var state_owner:Player=get_owner()


func enter(_transition_data:Dictionary={})->void:
	state_owner.player_died.emit()
