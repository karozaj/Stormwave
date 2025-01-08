extends BlockBaseClass

#PLAN JEST TAKI:
#W gridmap ustawiamy tylko bloki których nie da sie zniszczyc
#inne komórki są puste, niewidzialne bez kolizji i jedynie sygnalizują istnienie obiektu lub jego brak
#w danej komórce
#Same bloki są osobnymi scenami, których pozycja jest równa pozycji jeden z komórek gridmapy
#To powinno znacznie ułatwić dynamiczne niszczenie i tworzenie bloków
#Kładzenie bloków będzie zarządzane przez gridmapę, natomiast niszczenie
#przez bloki, które będą notyfikować gridmapę o znisczeniu, a wtedy gridmapa usunie
#informacje o istnieniu obiektu w danej komórce
var destroyed_effect:PackedScene=preload("res://scenes/block_building/block_destroyed_effect.tscn")

#function called when a block is damaged by an enemy or by the player's weapons
#also sets transparency of damage overlay material to match the block's condition
func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	audio_player.pitch_scale=damaged_pitch+randf_range(-0.1,0.1)
	audio_player.stream=damaged_sound
	audio_player.play()
	$block.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		destroy_block()

func destroy_block()->bool:
	if gridmap.destroy_block(global_position)==true:
		var effect:BlockDestroyedEffect=destroyed_effect.instantiate()
		effect.sound=destroyed_sound
		effect.pitch=destroyed_pitch
		get_parent().add_child(effect)
		effect.global_position=global_position
		call_deferred("queue_free")
		return true
	return false

#function that destroys the block when player tries to collect it in building mode 
#and returns the name of the block if conditions are met
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
