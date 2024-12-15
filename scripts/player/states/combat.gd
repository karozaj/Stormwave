extends State

@onready var state_owner:Player=get_owner()
var weapon_manager:WeaponManager

func enter(_transition_data:Dictionary={})->void:
	weapon_manager=state_owner.weapon_manager
	weapon_manager.select_weapon(1)
	
func update(_delta:float)->void:
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
		
func physics_update(_delta:float)->void:
	if Input.is_action_pressed("shoot"):
		weapon_manager.shoot()
	
#executes when leaving state
func exit()->void:
	weapon_manager.current_weapon.visible=false
