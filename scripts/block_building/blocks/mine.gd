extends ExplosiveBlock


func damage(dmg:int,_pos:Vector3):
	durability-=dmg
	$mine.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		explode()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	explode()
