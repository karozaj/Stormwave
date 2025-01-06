extends Control

@onready var health_label:Label=$VBoxContainer/HealthContainer/Label
@onready var ammo_label:Label=$VBoxContainer/AmmoContainer/Label
@onready var pain_overlay:TextureRect=$PainOverlay
@onready var game_status_label=$GameStatusLabel
@onready var wave_label:Label=$WaveLabel

func update_health(health:int)->void:
	health_label.text=str(health)
	if health<=25:
		health_label.modulate=Color.FIREBRICK
	else:
		health_label.modulate=Color.WHITE

func update_ammo(ammo)->void:
	ammo_label.text=str(ammo)

func show_pain_overlay(damage_points:int)->void:
	var tween=get_tree().create_tween()
	tween.tween_property(pain_overlay,"modulate",Color.WHITE, 0.1)
	tween.finished.connect(hide_pain_overlay.bind(damage_points))

func hide_pain_overlay(damage_points:int)->void:
	var fadeout_time=damage_points/100.0*3.0
	var tween=get_tree().create_tween()
	tween.tween_property(pain_overlay,"modulate",Color.TRANSPARENT, fadeout_time)

func update_game_status_label(current_enemies:int, enemies:int):
	game_status_label.text=str(current_enemies)+"/"+str(enemies)

func show_wave_label(wave_number:int):
	wave_label.text="WAVE "+str(wave_number)
	wave_label.modulate=Color.WHITE
	wave_label.visible=true
	var tween=get_tree().create_tween()
	tween.tween_property(wave_label,"modulate",Color.TRANSPARENT, 1.0)
	tween.finished.connect(hide_wave_label)
	
func hide_wave_label():
	wave_label.visible=false
