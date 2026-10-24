extends Button

@export var pause_widget : Node

func _pressed() -> void:
	if is_instance_valid(pause_widget):
		pause_widget.queue_free()
	get_tree().paused = false
