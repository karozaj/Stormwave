extends Node3D

signal ammo_count_changed

@onready var audio_player=$AudioStreamPlayer3D
var sound_no_ammo:AudioStream=preload("res://audio/sfx/no_ammo.ogg")
var sound_weapon_select:AudioStream=preload("res://audio/sfx/change_weapon.ogg")
@onready var cooldown_timer:Timer=$CooldownTimer

@onready var axe=$RightPosition/Axe
@onready var pistol=$RightPosition/pistol
@onready var shotgun=$RightPosition/shotgun
@onready var chaingun=$CenterPosition/Chaingun
@onready var rocket_launcher=$CenterPosition/RocketLauncher
var weapons:Array
var current_weapon
var current_weapon_index:int=0
var ammo:Array=["∞",int(5),int(5),int(50),int(5)]
var can_shoot:bool=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapons=[axe,pistol,shotgun,chaingun,rocket_launcher]
	for weapon in weapons:
		if weapon.has_method("set_ray_position"):
			weapon.set_ray_position(global_position)
	current_weapon=pistol
	current_weapon_index=1
	current_weapon.animation_player.play("pullout")


func shoot()->void:
	if current_weapon.is_being_pulled_out==false:
		if can_shoot:
			can_shoot=false
			cooldown_timer.wait_time=current_weapon.cooldown
			cooldown_timer.start()
			if ammo[current_weapon_index] is not int or ammo[current_weapon_index]>0:
				current_weapon.shoot()
				if ammo[current_weapon_index] is not String:
					ammo[current_weapon_index]-=1
					ammo_count_changed.emit()
			else:
				audio_player.stream=sound_no_ammo
				audio_player.play()


func _on_cooldown_timer_timeout() -> void:
	can_shoot=true


func select_weapon(index:int)->void:
	if can_shoot and current_weapon.is_being_pulled_out==false:
		audio_player.stream=sound_weapon_select
		audio_player.play()
		current_weapon.visible=false
		current_weapon_index=index
		current_weapon=weapons[current_weapon_index]
		current_weapon.animation_player.play("pullout")
		ammo_count_changed.emit()