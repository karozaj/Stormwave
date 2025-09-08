extends MenuWithNavigation
## Credits screen

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print(meta)
	OS.shell_open(str(meta))
