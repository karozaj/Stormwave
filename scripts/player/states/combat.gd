extends State

@onready var state_owner:Player=get_owner()
var weapon_manager:WeaponManager

func enter(_transition_data:Dictionary={})->void:
	for placer in state_owner.building_manager.placers:
		placer.visible=false
	weapon_manager=state_owner.weapon_manager
	weapon_manager.select_weapon(1)
	
func update(delta:float)->void:
	state_owner.process_update(delta)
	#weapon selection
	if Input.is_action_just_pressed("next_weapon"):
		var next_weapon_index:int=(weapon_manager.current_weapon_index+1)%weapon_manager.weapons.size()
		weapon_manager.select_weapon(next_weapon_index)
	elif Input.is_action_just_pressed("previous_weapon"):
		var next_weapon_index:int=(weapon_manager.current_weapon_index-1)%weapon_manager.weapons.size()
		weapon_manager.select_weapon(next_weapon_index)
	elif Input.is_action_just_pressed("select_weapon_1"):
		weapon_manager.select_weapon(0)
	elif Input.is_action_just_pressed("select_weapon_2"):
		weapon_manager.select_weapon(1)
	elif Input.is_action_just_pressed("select_weapon_3"):
		weapon_manager.select_weapon(2)
	elif Input.is_action_just_pressed("select_weapon_4"):
		weapon_manager.select_weapon(3)
	elif Input.is_action_just_pressed("select_weapon_5"):
		weapon_manager.select_weapon(4)
		
func physics_update(delta:float)->void:
	state_owner.physics_process_update(delta)
	if Input.is_action_pressed("shoot"):
		weapon_manager.shoot()
	state_owner.move_and_slide()
	
func handle_input(event: InputEvent) -> void:
	state_owner.mouselook(event)
	
func damage(damage_points:int, origin:Vector3,damage_dealer)->void:
	state_owner.take_damage(damage_points,origin,damage_dealer)

#executes when leaving state
func exit()->void:
	weapon_manager.current_weapon.visible=false
