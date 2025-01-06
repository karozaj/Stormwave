extends Control
class_name LoadingScreen

@onready var progress_bar:ProgressBar=$ProgressBar

#var scene_to_load:String=Global.scene_to_load
var scene_load_status = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(Global.scene_to_load)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress=[]
	scene_load_status = ResourceLoader.load_threaded_get_status(Global.scene_to_load, progress)
	
	#ResourceLoader.load_threaded_get_status(Global.scene_to_load,progress)
	print(progress[0]*100)
	
	if progress[0]==1:
	#if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene:PackedScene=ResourceLoader.load_threaded_get(Global.scene_to_load)
		get_tree().change_scene_to_packed(packed_scene)
