extends MenuWithNavigation
## Credits screen

@export var credits_reader:CreditsReader
@export var rich_text_label:RichTextLabel

func _ready() -> void:
	super._ready()
	#credits_reader.add_credits_text_to_rich_text_label(rich_text_label)
	rich_text_label.text=credits_reader.get_credits_string_richtext()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print(meta)
	OS.shell_open(str(meta))


func _on_main_menu_button_mouse_entered() -> void:
	rich_text_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
