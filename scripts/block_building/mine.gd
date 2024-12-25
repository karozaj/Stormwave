extends BlockBaseClass

var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")

func damage(dmg:int,_pos:Vector3):
	durability-=dmg
	$mine.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		explode()

func explode()->void:
	var expl=explosion.instantiate()
	Global.current_level.add_child(expl)
	expl.global_position=global_position
	expl.explode()
	destroy_block(global_position)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	explode()
