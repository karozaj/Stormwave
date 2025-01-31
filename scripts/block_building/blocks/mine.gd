extends ExplosiveBlock
## A block which explodes when touched

var activation_sound:AudioStream=preload("res://audio/sfx/blocks/mine_activation.ogg")
var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")

func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	audio_player.play_sound(damaged_sound,damaged_pitch)
	$mine.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		explode()

func collect_block()->String:
	if gridmap.destroy_block(global_position)==true:
		if float(durability)>=float(max_durability)*0.9:
			call_deferred("queue_free")
			return block_name
		else:
			var effect:BlockDestroyedEffect=BlockDestroyedEffect.create_effect(destroyed_sound,destroyed_pitch)
			get_parent().add_child(effect)
			effect.global_position=global_position
			call_deferred("queue_free")
			return "None"
	return "None"

func _on_area_3d_body_entered(_body: Node3D) -> void:
	audio_player.play_sound(activation_sound,1.0)
	$Timer.start()
	

func _on_timer_timeout() -> void:
	explode()
