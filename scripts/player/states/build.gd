extends State

@onready var state_owner:Player=get_owner()
var building_manager:BuildingManager

func enter(_transition_data:Dictionary={})->void:
	building_manager=state_owner.building_manager
	building_manager.select_placer(0)

	
func update(_delta:float)->void:
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
	#elif Input.is_action_just_pressed("select_weapon_2"):
		#building_manager.select_placer(1)
	#elif Input.is_action_just_pressed("select_weapon_3"):
		#building_manager.select_placer(2)
	#elif Input.is_action_just_pressed("select_weapon_4"):
		#building_manager.select_placer(3)
	#elif Input.is_action_just_pressed("select_weapon_5"):
		#building_manager.select_placer(4)
		
func physics_update(_delta:float)->void:
	if Input.is_action_pressed("place_block"):
		building_manager.place()
	elif Input.is_action_just_pressed("shoot"):
		building_manager.destroy()
		
#executes when leaving state
func exit()->void:
	building_manager.current_placer.visible=false
