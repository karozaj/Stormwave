extends WeaponBase

@onready var animation_player=$AnimationPlayer
@onready var hitbox:Area3D=$Cube/Hitbox
var shooting_sound:AudioStream=preload("res://audio/sfx/swing.ogg")


func _ready() -> void:
	audio_player.stream=shooting_sound


func shoot():
	animation_player.play("swing")
	hitbox.monitoring=true


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(base_damage, global_position)