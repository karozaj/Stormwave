extends Control

@onready var health_label:Label=$VBoxContainer/HealthContainer/Label
@onready var ammo_label:Label=$VBoxContainer/AmmoContainer/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_health(health:int)->void:
	health_label.text=str(health)
	if health<=25:
		health_label.modulate=Color.FIREBRICK
	else:
		health_label.modulate=Color.WHITE

func update_ammo(ammo)->void:
	ammo_label.text=str(ammo)
