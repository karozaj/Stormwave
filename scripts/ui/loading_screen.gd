extends Control
class_name LoadingScreen
## Loading screen

@onready var progress_bar:ProgressBar=$CenterContainer/VBoxContainer/ProgressBar

var scene_load_status = 0
var progress:Array=[]
var update:float=0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var error=ResourceLoader.load_threaded_request(Global.scene_to_load)
	assert(error==OK)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scene_load_status=ResourceLoader.load_threaded_get_status(Global.scene_to_load,progress)
	if progress[0]>update:
		update=progress[0]
		
	if progress_bar.value<update*100:
		progress_bar.value=(lerp(progress_bar.value,update*100,delta))
	progress_bar.value+=delta*0.2*(0.9-progress_bar.value)
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene:PackedScene=ResourceLoader.load_threaded_get(Global.scene_to_load)
		assert(packed_scene!=null)
		var error=get_tree().change_scene_to_packed(packed_scene)
		assert(error==OK)
