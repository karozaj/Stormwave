extends Sprite3D
##A [Sprite3D] used for lightning effects

@export var base_wait_time:float=0.1
@export var wait_time_variance:float=0.075

func _on_timer_timeout() -> void:
	var rand=randi_range(0,1)
	if rand==0:
		flip_h=!flip_h
	else:
		flip_v=!flip_v
	$Timer.start(base_wait_time+randf_range(-wait_time_variance,wait_time_variance))
