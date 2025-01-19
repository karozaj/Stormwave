extends Area3D
class_name KillArea
## An area that damages bodies entering it. Can be used to kill entities outside of map

##Emitted when [KillArea] damages a body
signal body_damaged()

## How much damage is dealt when the area is entered
@export var damage:int=10000
## How often damage should be applied to bodies inside area
@export var damage_interval:float=1.0

var bodies:Array[Node3D]=[]

func deal_damage(body:Node3D):
	body.damage(damage, global_position ,null)
	body_damaged.emit()

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		if is_instance_valid(body)==true and bodies.has(body)==false and body.is_dead==false:
			body.died.connect(_on_body_died)
			bodies.append(body)
		deal_damage(body)

func _on_timer_timeout() -> void:
	for body in bodies:
		deal_damage(body)
	$Timer.start(damage_interval)


func _on_body_exited(body: Node3D) -> void:
	if bodies.has(body):
		body.died.disconnect(_on_body_died)
		bodies.erase(body)

func _on_body_died(body)->void:
	if bodies.has(body):
		body.died.disconnect(_on_body_died)
		bodies.erase(body)
