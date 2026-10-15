extends Button

#Override BaseButton virtual function.
func _pressed() -> void:
	get_tree().quit()
