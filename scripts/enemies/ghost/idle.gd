extends State

@onready var state_owner:EnemyGhost=get_owner()

func update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,5*state_owner.agility*delta)
	state_owner.move_and_slide()

func damage(damage_points:int, origin:Vector3)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin})