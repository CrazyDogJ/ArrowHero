extends Node

const DEFAULT_LOADING_SCENE: PackedScene = preload("res://Scenes/Loading.tscn")
var target_scene_path: String = ""

func go_to_scene(path: String) -> void:
	if ResourceLoader.exists(path):
		target_scene_path = path
		get_tree().change_scene_to_packed(DEFAULT_LOADING_SCENE)

func load_complete() -> void:
	target_scene_path = ""
