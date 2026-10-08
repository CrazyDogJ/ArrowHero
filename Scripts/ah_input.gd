const enums := preload("res://Scripts/enums.gd")

static func get_input_direction(event: InputEvent) -> enums.ArrowDirection:
	var result : enums.ArrowDirection = enums.ArrowDirection.Invalid
	if event.is_action_pressed("Up"):
		result = enums.ArrowDirection.Up
	if event.is_action_pressed("Right"):
		result = enums.ArrowDirection.Right
	if event.is_action_pressed("Down"):
		result = enums.ArrowDirection.Down
	if event.is_action_pressed("Left"):
		result = enums.ArrowDirection.Left
	return result

static func is_inputting_arrow_keys(event: InputEvent) -> bool:
	if event.is_pressed():
		return get_input_direction(event) != enums.ArrowDirection.Invalid
	return false
