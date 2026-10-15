extends Button

func _pressed() -> void:
	SaveGameManager.load_game()
	LoadingScreenManager.go_to_scene("res://Scenes/MainGamePlay.tscn")

func _ready() -> void:
	disabled = not FileAccess.file_exists("user://savegame.save")
