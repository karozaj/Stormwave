extends Node3D

@onready var ray:RayCast3D=$Node3D/RayCast3D
@onready var bullet_hole_spawner:BulletHoleSpawner=$BulletHoleSpawner
@onready var audio_player:AudioStreamPlayer3D=$Area3D/AudioStreamPlayer3D
@onready var cooldown_timer:Timer=$CooldownTimer
var targets:Array[EnemyBaseClass]=[]

@export var health:int=50
## How much time should pass between attacks
@export var attack_cooldown:float=0.75
## How many points of damage attacks should deal
@export var base_damage:int=50
## Sound to be played when attacking
@export var attack_sound:AudioStream
var can_shoot:bool=true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if len(targets)>0:
		$Node3D.look_at(targets[0].global_position)
		if can_shoot:
			shoot()
			
func shoot()->void:
	ray.force_raycast_update()
	if ray.is_colliding():
		bullet_hole_spawner.spawn_bullet_hole(ray.get_collision_point(),ray.get_collision_normal())
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage, global_position)
	audio_player.play()
	can_shoot=false
	cooldown_timer.start(attack_cooldown)

func remove_target(trg:EnemyBaseClass):
	if trg in targets:
		targets.erase(trg)
		trg.died.disconnect(remove_target)

func damage(damage_points:int, _origin:Vector3)->void:
	health-=damage_points
	if health<=0:
		die()

func die():
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is EnemyBaseClass:
		var enemy:EnemyBaseClass=body as EnemyBaseClass
		targets.append(enemy)
		enemy.died.connect(remove_target)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is EnemyBaseClass:
		remove_target(body)


func _on_cooldown_timer_timeout() -> void:
	can_shoot=true
