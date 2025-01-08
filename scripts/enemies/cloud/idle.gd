extends State

@onready var state_owner:EnemyCloud=get_owner()


func update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3.ZERO,delta*state_owner.agility)
	state_owner.move_and_slide()


func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
