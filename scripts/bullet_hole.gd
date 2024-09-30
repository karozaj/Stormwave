extends Decal

func _ready() -> void:
	var tween=get_tree().create_tween()
	tween.finished.connect(disappear)
	tween.tween_property(self,"modulate",Color.TRANSPARENT,1.5)


func disappear()->void:
	queue_free()
