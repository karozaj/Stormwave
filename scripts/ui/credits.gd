extends Control

func _on_button_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print(meta)
	OS.shell_open(str(meta))
