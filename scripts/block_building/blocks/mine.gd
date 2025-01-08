extends ExplosiveBlock

var activation_sound:AudioStream=preload("res://audio/sfx/blocks/mine_activation.ogg")
var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")

func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	audio_player.pitch_scale=damaged_pitch+randf_range(-0.1,0.1)
	audio_player.stream=damaged_sound
	audio_player.play()
	$mine.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		explode()

func collect_block()->String:
	if gridmap.destroy_block(global_position)==true:
		if float(durability)>=float(max_durability)*0.9:
			call_deferred("queue_free")
			return block_name
		else:
			var effect:BlockDestroyedEffect=destroyed_effect.instantiate()
			effect.sound=destroyed_sound
			effect.pitch=destroyed_pitch
			get_parent().add_child(effect)
			effect.global_position=global_position
			call_deferred("queue_free")
			return "None"
	return "None"

func _on_area_3d_body_entered(_body: Node3D) -> void:
	$AudioStreamPlayer3D.stream=activation_sound
	$AudioStreamPlayer3D.play()
	$Timer.start()
	

func _on_timer_timeout() -> void:
	explode()
