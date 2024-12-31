extends State

@onready var state_owner:Player=get_owner()
var building_manager:BuildingManager

func enter(_transition_data:Dictionary={})->void:
	for weapon in state_owner.weapon_manager.weapons:
		weapon.visible=false
	building_manager=state_owner.building_manager
	building_manager.select_placer(0)

	
func update(delta:float)->void:
	state_owner.process_update(delta)
	#placer selection
	building_manager.current_placer.highlight()
	if Input.is_action_just_pressed("next_weapon"):
		var next_placer_index:int=(building_manager.current_placer_index+1)%building_manager.placers.size()
		building_manager.select_placer(next_placer_index)
	elif Input.is_action_just_pressed("previous_weapon"):
		var next_placer_index:int=(building_manager.current_placer_index-1)%building_manager.placers.size()
		building_manager.select_placer(next_placer_index)
	elif Input.is_action_just_pressed("select_weapon_1"):
		building_manager.select_placer(0)
	elif Input.is_action_just_pressed("select_weapon_2"):
		building_manager.select_placer(1)
	elif Input.is_action_just_pressed("select_weapon_3"):
		building_manager.select_placer(2)
	elif Input.is_action_just_pressed("select_weapon_4"):
		building_manager.select_placer(3)	
	elif Input.is_action_just_pressed("select_weapon_5"):
		building_manager.select_placer(4)
		
func physics_update(delta:float)->void:
	state_owner.physics_process_update(delta)
	if Input.is_action_pressed("place_block"):
		building_manager.place()
	elif Input.is_action_just_pressed("shoot"):
		building_manager.collect()
	state_owner.move_and_slide()

func handle_input(event: InputEvent) -> void:
	state_owner.mouselook(event)

func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	state_owner.take_damage(damage_points,origin,damage_dealer)	

#executes when leaving state
func exit()->void:
	building_manager.current_placer.visible=false
