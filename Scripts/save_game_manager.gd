extends Node

var current_save_data : Dictionary[String, Dictionary]

func save_game() -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var save_datas : Dictionary[String, Dictionary]
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save_game"):
			print("persistent node '%s' is missing a save_game() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data : Dictionary[String, Dictionary]
		var node_raw_data : Dictionary = node.call("save_game")
		## Is global singleton
		if get_tree().root == node.get_parent():
			node_raw_data.get_or_add("node_type", node.name)
			save_datas.get_or_add(node.name, node_raw_data)
		else:
			save_datas.get_or_add(node.get_class(), node_raw_data)

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_datas)

	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)

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
