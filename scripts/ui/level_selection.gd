extends Control
## Menu where levels can be selected

@onready var item_list:ItemList=$CenterContainer/VBoxContainer/HBoxContainer/VBoxPurchase/ItemList
@onready var level_image:TextureRect=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/TextureRect
@onready var level_desc:Label=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/Description
@onready var play_button:Button=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/ButtonPlay
@onready var level_score:Label=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/Score
## The level info resources required to display level info
@export var level_info_resources:Array[LevelInfo]

var selected_index:int=-1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in level_info_resources.size():
		level_info_resources[i].high_score=ScoreManager.get_score(level_info_resources[i].level_identifier)
		item_list.add_item(level_info_resources[i].level_name,level_info_resources[i].image)



func _on_item_list_item_selected(index: int) -> void:
	selected_index=index
	if level_info_resources[selected_index].playable==true:
		Global.scene_to_load=level_info_resources[selected_index].level_scene
		play_button.disabled=false
		
	else:
		play_button.disabled=true
	level_desc.text=level_info_resources[selected_index].level_description
	level_score.text="High score: "+str(level_info_resources[selected_index].high_score)
	level_image.texture=level_info_resources[selected_index].image
	

func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_button_play_pressed() -> void:
	if Global.scene_to_load.is_empty()==false:
		get_tree().change_scene_to_file("res://scenes/ui/loading_screen.tscn")
