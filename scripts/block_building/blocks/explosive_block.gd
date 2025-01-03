extends BlockBaseClass
class_name ExplosiveBlock

var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")
#variable used to prevent block from exploding multiple times
var has_exploded:bool=false


func damage(dmg:int,_pos:Vector3):
	durability-=dmg
	audio_player.pitch_scale=damaged_pitch+randf_range(-0.1,0.1)
	audio_player.stream=damaged_sound
	audio_player.play()
	if $AnimationPlayer.is_playing()==true:
		explode()
	if durability<-50:
		explode()
	if durability<0:
		if $AnimationPlayer.is_playing()==false:
			$AnimationPlayer.play("explode")


func explode()->void:
	if has_exploded==false:
		has_exploded=true
		var expl=explosion.instantiate()
		Global.current_level.add_child(expl)
		expl.global_position=global_position
		expl.explode()
		destroy_block()
