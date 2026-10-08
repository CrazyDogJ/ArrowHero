extends MarginContainer

@export var margin_value = 16

#Override CanvasItem virtual function.
func _draw() -> void:
	add_theme_constant_override("margin_top", margin_value)
	add_theme_constant_override("margin_left", margin_value)
	add_theme_constant_override("margin_bottom", margin_value)
	add_theme_constant_override("margin_right", margin_value)
