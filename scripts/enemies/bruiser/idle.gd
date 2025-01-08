extends State

@onready var state_owner:EnemyBruiser=get_owner()

#func enter(_transition_data:Dictionary={})->void:
	##state_owner.animation_tree.set("parameters/IdleWalkBlend/blend_amount",0.0)
	##state_owner.animation_tree.set("parameters/FallBlend/blend_amount",0.0)
	
func update(delta:float)->void:
	state_owner.velocity=state_owner.velocity.move_toward(Vector3(0.0,state_owner.velocity.y,0.0),delta*state_owner.agility)
	if state_owner.is_on_floor()==false:
		finished.emit(self,"Falling")
	state_owner.move_and_slide()


func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	finished.emit(self,"Pain",{"damage_points":damage_points,"origin":origin,"damage_dealer":damage_dealer})
