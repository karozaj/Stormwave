extends MenuWithNavigation
class_name KeyRebinding
#@export var actions_to_ignore:Array[String]=[
	#"TEST_BUTTON",
	#"escape",
	#"enter",
	#"pause"
#]
@export var rebinding_button_scene:PackedScene
@export var rebinding_buttons_parent:Control

@export var rebinding_overlay:ColorRect

var rebinding_buttons:Array[RebindingButton]

var is_rebinding:bool=false
var action_to_rebind=null
var rebinding_button=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	setup_rebinding_buttons()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_rebinding_buttons():
	rebinding_button=[]
	for child in rebinding_buttons_parent.get_children():
		child.queue_free()
	var actions=get_actions_array()
	for action in actions:
		var button_instance=rebinding_button_scene.instantiate()
		rebinding_buttons_parent.add_child(button_instance)
		var rebinding_button:RebindingButton=button_instance as RebindingButton
		rebinding_button.setup_rebinding_button(action,on_rebinding_button_pressed)
		rebinding_buttons.append(rebinding_button)

static func get_actions_array()->Array[String]:
	var actions_to_ignore:Array[String]=[
		"TEST_BUTTON",
		"escape",
		"enter",
		"pause"
	]
	var actions:Array[String]=[]
	for action in InputMap.get_actions():
		if(action.begins_with("ui_")) or (actions_to_ignore.has(action)):
			continue
		actions.append(action)
	return actions
	
func reset_to_default():
	InputMap.load_from_project_settings()
	setup_rebinding_buttons()

func on_rebinding_button_pressed(action_name:String,button:RebindingButton):
	start_rebinding(action_name,button)

func start_rebinding(action_name:String,button:RebindingButton):
	rebinding_button=button
	action_to_rebind=action_name
	is_rebinding=true
	rebinding_overlay.visible=true

func _input(event: InputEvent) -> void:
	if(is_rebinding and action_to_rebind!=null and rebinding_button!=null):
		if(event is InputEventKey or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed)):
			if(event is InputEventMouseButton and (event as InputEventMouseButton).double_click):
				(event as InputEventMouseButton).double_click=false
			
			InputMap.action_erase_events(action_to_rebind)
			InputMap.action_add_event(action_to_rebind,event)
			update_event_action(rebinding_button,event)
			finish_rebinding()
			
			accept_event()

func update_event_action(button:RebindingButton,event:InputEvent):
	button.set_button_text(event.as_text())

func finish_rebinding():
	rebinding_button=null
	action_to_rebind=null
	rebinding_overlay.visible=false
	OptionsSaving.save_keybinds()
