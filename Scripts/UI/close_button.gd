extends Button

@export var removing_node : Node

func _pressed() -> void:
	if is_instance_valid(removing_node):
		removing_node.queue_free()
