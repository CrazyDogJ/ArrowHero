class_name SavingWidget extends Control

@export var saving_label : Label
@export var saving_icon : TextureRect

var is_saving : bool = true

func _process(delta: float) -> void:
	if is_instance_valid(saving_label):
		saving_label.text = tr("Saving...") if is_saving else tr("Game Saved")
	if is_instance_valid(saving_icon):
		saving_icon.visible = is_saving
