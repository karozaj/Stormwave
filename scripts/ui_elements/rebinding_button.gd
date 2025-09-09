extends VBoxContainer
class_name RebindingButton

@export var binding_name_label:Label
@export var binding_button:Button
##Displayed when no button is assigned to an action
@export var no_binding_text:String="None"


func setup_rebinding_button(binding_name:String, rebinding_method:Callable):
	set_label_text(binding_name)
	var events:Array[InputEvent]=InputMap.action_get_events(binding_name)
	if(events.size()>0):
		set_button_text(events[0].as_text())
	else:
		set_button_text(no_binding_text)
	
	binding_button.pressed.connect(rebinding_method.bind(binding_name,self))

func set_label_text(text:String):
	binding_name_label.text=text.capitalize().replace("_"," ")

func set_button_text(text:String):
	binding_button.text=text.trim_suffix(" (Physical)")
