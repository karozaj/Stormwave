extends Control

@onready var play_button:Button=$VBoxContainer/ButtonPlay
@onready var credits_button:Button=$VBoxContainer/ButtonCredits
@onready var exit_button:Button=$VBoxContainer/ButtonExit


func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/level_selection.tscn")
	#var loading_screen:LoadingScreen=load("res://scenes/ui/loading_screen.tscn").instantiate()
	#loading_screen.scene_to_load="res://scenes/levels/level_1.tscn"
	#get_tree().root.add_child(loading_screen)
	#queue_free()
	

func _on_button_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")
	


func _on_button_exit_pressed() -> void:
	get_tree().quit()


func _on_button_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/options_menu.tscn")
