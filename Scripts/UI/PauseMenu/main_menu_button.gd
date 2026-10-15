extends Button

func _pressed() -> void:
	get_tree().paused = false
	SaveGameManager.save_game()
	LoadingScreenManager.go_to_scene("res://Scenes/MainMenu.tscn")
