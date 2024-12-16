extends Node3D

var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")


func _on_area_3d_body_entered(_body: Node3D) -> void:
	var expl=explosion.instantiate()
	Global.current_level.add_child(expl)
	expl.global_position=global_position
	expl.explode()
	queue_free()
