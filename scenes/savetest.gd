extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScoreManager.add_score("level_1",32)
	ScoreManager.add_score("level_2",432)
	ScoreManager.save_scores()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_shop"):
		ScoreManager.add_score("level_1",12)
		ScoreManager.add_score("level_2",3523)
		ScoreManager.save_scores()
		ScoreManager.load_scores()
		print(ScoreManager.scores)
