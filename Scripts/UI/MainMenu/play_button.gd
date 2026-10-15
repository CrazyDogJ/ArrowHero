extends Button

@export var seed_edit_line : LineEdit

func _pressed() -> void:
	if is_instance_valid(seed_edit_line):
		var seed_string : String = seed_edit_line.text
		RandomGenerator.global_seed = seed_string
	LoadingScreenManager.go_to_scene("res://Scenes/MainGamePlay.tscn")
