extends Control
class_name Hud

@onready var health_label:Label=$VBoxContainer/HealthContainer/Label
@onready var ammo_label:Label=$VBoxContainer/AmmoContainer/Label
@onready var pain_overlay:TextureRect=$PainOverlay
@onready var game_status_label=$GameStatusLabel
@onready var wave_label:Label=$WaveLabel
@onready var prompt_label:Label=$PromptLabel

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

func update_enemy_count(current:int, max_enemies:int)->void:
	update_game_status_label(str(current)+"/"+str(max_enemies))

func update_build_time_remaining(time:int)->void:
	var time_string:String=str(time)
	#if time>=60:
	@warning_ignore("integer_division")
	var minutes:String=("%02d"%(floor(time/60)))
	var seconds:String=("%02d"%(time%60))
	time_string=minutes+":"+seconds
	update_game_status_label(time_string)

func update_game_status_label(s:String)->void:
	game_status_label.text=s
	#game_status_label.text=str(current_enemies)+"/"+str(enemies)

func show_wave_label(wave_number:int)->void:
	wave_label.text="WAVE "+str(wave_number)
	wave_label.modulate=Color.WHITE
	wave_label.visible=true
	await get_tree().create_timer(1).timeout
	var tween=get_tree().create_tween()
	tween.tween_property(wave_label,"modulate",Color.TRANSPARENT, 0.25)
	tween.finished.connect(hide_wave_label)

func show_prompt(message:String):
	prompt_label.text=message
	prompt_label.modulate=Color.WHITE
	prompt_label.visible=true
	await get_tree().create_timer(3).timeout
	var tween=get_tree().create_tween()
	tween.tween_property(prompt_label,"modulate",Color.TRANSPARENT, 0.25)
	tween.finished.connect(hide_prompt_label)

func hide_prompt_label():
	prompt_label.visible=false

func hide_wave_label():
	wave_label.visible=false
