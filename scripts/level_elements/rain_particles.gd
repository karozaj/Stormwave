extends GPUParticles3D
## [GPUParticles3D] with a rain effect and [AudioStreamPlayer] for ambience


## The rain ambience
@export var rain_ambience:AudioStream
## The node this effect will follow (usually the [Player]) 
@export var node_to_follow:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.stream=rain_ambience
	$AudioStreamPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target_position=Vector3(node_to_follow.global_position.x,global_position.y,node_to_follow.global_position.z)
	global_position=target_position
