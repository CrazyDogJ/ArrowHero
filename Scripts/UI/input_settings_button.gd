class_name InputSettingsButton extends Button

@export var input_settings_scene : PackedScene
var input_settings_widget : Node

func _pressed() -> void:
	if input_settings_scene.can_instantiate():
		input_settings_widget = input_settings_scene.instantiate()
		var current_scene_root := get_tree().current_scene
		if is_instance_valid(current_scene_root):
			current_scene_root.add_child(input_settings_widget)
			input_settings_widget.set_z_index(2)

func _exit_tree() -> void:
	if is_instance_valid(input_settings_widget):
		input_settings_widget.queue_free()
	input_settings_widget = null
