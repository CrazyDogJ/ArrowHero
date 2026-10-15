class_name LoadingScreen extends Control

@export var progress_bar: ProgressBar

func _ready() -> void:
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0

	var error := ResourceLoader.load_threaded_request(
		LoadingScreenManager.target_scene_path, "PackedScene"
	)
	if error != OK:
		push_error("无法开始加载：%s" % LoadingScreenManager.target_scene_path)
		LoadingScreenManager.load_complete()
		set_process(false)


func _process(_delta: float) -> void:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(
		LoadingScreenManager.target_scene_path, progress
	)

	if not progress.is_empty():
		if is_instance_valid(progress_bar):
			progress_bar.value = progress[0] * 100.0

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)

			var scene := ResourceLoader.load_threaded_get(
				LoadingScreenManager.target_scene_path
			) as PackedScene

			if scene == null:
				push_error("目标资源不是有效场景")
				LoadingScreenManager.load_complete()
				return

			LoadingScreenManager.load_complete()
			var error := get_tree().change_scene_to_packed(scene)
			if error != OK:
				push_error("切换场景失败")

		ResourceLoader.THREAD_LOAD_FAILED, \
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			set_process(false)
			LoadingScreenManager.load_complete()
			push_error("加载失败：%s" % LoadingScreenManager.target_scene_path)
