extends GameplayAbility

const tags = preload("res://godot_gas/gameplay_tags.gd")
const enums = preload("res://Scripts/enums.gd")

func _init() -> void:
	trigger_event_tag = tags.Ability_Arrowinput

#Override GameplayAbility virtual function.
func _activate_ability() -> bool:
	commit_ability()
	var player : MainPlayer = owner_asc.get_parent()
	var input_event : InputEvent = current_event_payload
	if is_instance_valid(player) and is_instance_valid(input_event):
		player.process_input(input_event)
	end_ability()
	return true
