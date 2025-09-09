extends Control
class_name MenuWithNavigation
## For menus from which you can navigate to a different menu, all these menus should be inside the same scene

## The menu this script is attached to
@export var this_menu:Control
## Other menus that you can navigate to from this menu
@export var other_menus:Array[MenuWithNavigation]
## The buttons used to navigate to the other menus - the order of the menus must match the order of the buttons in the arrays
@export var navigation_buttons:Array[Button]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:## when inheriting from this class always remember to use super._ready()
	
	for button_index in len(navigation_buttons):
		navigation_buttons[button_index].pressed.connect(navigate_to_menu.bind(button_index))

func navigate_to_menu(index:int):
	if(index<len(other_menus)):
		disable_this_menu()
		other_menus[index].enable_this_menu()

func enable_this_menu():
	this_menu.visible=true

func disable_this_menu():
	this_menu.visible=false
