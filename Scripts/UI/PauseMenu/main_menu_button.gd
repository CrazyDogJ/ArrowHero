extends Button

@export var need_save : bool = true

func _pressed() -> void:
	get_tree().paused = false
	## if need_save:
		## SaveGameManager.save_game()
	LoadingScreenManager.go_to_scene("res://Scenes/MainMenu.tscn")
