extends Node

var current_save_data : Dictionary[String, Dictionary]

const saving_widget_prefab = preload("res://Prefabs/SavingWidget.tscn")
var saving_widget : SavingWidget

signal save_finished(error: int)

var _thread: Thread = null

func show_saving_widget() -> void:
	remove_saving_widget()
	if saving_widget_prefab.can_instantiate():
		saving_widget = saving_widget_prefab.instantiate()
		saving_widget.is_saving = true
		get_tree().current_scene.add_child(saving_widget)

func remove_saving_widget(wait : bool = false) -> void:
	if not is_instance_valid(saving_widget):
		return
	if wait:
		saving_widget.is_saving = false
		get_tree().create_timer(2.0, false).timeout.connect(destroy_saving_widget)
	else:
		destroy_saving_widget()

func destroy_saving_widget() -> void:
	if not is_instance_valid(saving_widget):
		return
	saving_widget.queue_free()
	saving_widget = null

func save_async(data: Dictionary) -> int:
	if _thread != null:
		return ERR_BUSY

	# 创建独立快照，避免游戏继续运行时修改同一份数据。
	# data 只包含 JSON 兼容的数据，不要放 Node、Resource 等对象。
	var snapshot: Dictionary = data.duplicate(true)

	_thread = Thread.new()
	var error := _thread.start(_write_save.bind(snapshot))

	if error != OK:
		_thread = null

	return error

func _write_save(data: Dictionary) -> int:
	var json_text := JSON.stringify(data)

	var file := FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_line(json_text)
	file.flush()
	var error := file.get_error()
	file.close()

	return error

func save_game() -> void:
	if is_saving():
		return
	show_saving_widget()
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var save_datas : Dictionary[String, Dictionary]
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save_game"):
			print("persistent node '%s' is missing a save_game() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_raw_data : Dictionary = node.call("save_game")
		## Is global singleton
		if get_tree().root == node.get_parent():
			node_raw_data.get_or_add("node_type", node.name)
			save_datas.get_or_add(node.name, node_raw_data)
		else:
			save_datas.get_or_add(node.get_script().get_global_name(), node_raw_data)
	save_async(save_datas)

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var save_datas : Dictionary = json.data
		for node_id_string in save_datas.keys():
			var save_data : Dictionary = save_datas.get(node_id_string) as Dictionary
			if save_data.has("node_type"):
				var node_type : String = save_data["node_type"]
				var singleton_node : Node = get_tree().root.get_node(node_type)
				if singleton_node.has_method("load_game"):
					singleton_node.call("load_game", save_data)
			else:
				current_save_data.get_or_add(node_id_string, save_data)

func is_saving() -> bool:
	if _thread != null and _thread.is_alive():
		return true
	return false

func process_async_save_finish() -> void:
	if _thread == null or _thread.is_alive():
		return

	var error: int = _thread.wait_to_finish()
	_thread = null
	save_finished.emit(error)
	remove_saving_widget(true)

func _process(delta: float) -> void:
	process_async_save_finish()

func _exit_tree() -> void:
	if _thread != null:
		_thread.wait_to_finish()
		_thread = null
