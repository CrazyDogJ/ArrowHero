extends Node

class_name StatWidget

@export var hp_bar : StatProgressBar
@export var sp_bar : StatProgressBar

@export var asc : AbilitySystemComponent
@export var asc_owner : Node

func _process(delta: float) -> void:
	if is_instance_valid(asc):
		if is_instance_valid(hp_bar):
			var max_health = asc.get_attribute("max_health")
			var current_health = asc.get_attribute("current_health")
			hp_bar.max_value = max_health.current_value
			hp_bar.value = current_health.current_value
		if is_instance_valid(sp_bar):
			var max_shield = asc.get_attribute("max_shield")
			var current_shield = asc.get_attribute("current_shield")
			sp_bar.max_value = max_shield.current_value
			sp_bar.value = current_shield.current_value
	else:
		if is_instance_valid(asc_owner):
			asc = asc_owner.get_node("AbilitySystemComponent")
