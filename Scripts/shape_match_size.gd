extends CollisionShape2D

@export var target_container : Container;

func _process(_delta: float) -> void:
	if is_instance_valid(target_container):
		var size = target_container.size
		shape.set_size(size)
