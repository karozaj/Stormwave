extends BlockBaseClass
class_name ExplosiveBlock
## A block which explodes when damaged

var explosion=preload("res://scenes/weapons/projectiles/rocket_projectile.tscn")
#variable used to prevent block from exploding multiple times
var has_exploded:bool=false
## The explosion's radius
@export var explosion_radius:float=2.5
## Maximum explosion damage
@export var explosion_max_damage:int=100

func damage(dmg:int,_pos:Vector3,_dmg_dealer=null):
	durability-=dmg
	audio_player.play_sound(damaged_sound,damaged_pitch)
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
		var expl:RocketProjectile=explosion.instantiate()
		expl.explosion_radius=explosion_radius
		expl.explosion_max_damage=explosion_max_damage
		Global.current_level.add_child(expl)
		expl.global_position=global_position
		expl.explode()
		destroy_block()
