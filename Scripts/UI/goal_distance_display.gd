extends Node

@export var round_time : RoundTime

@onready var stat_progress_bar : StatProgressBar = $StatProgressBar

func _process(delta: float) -> void:
	if is_instance_valid(round_time) and is_instance_valid(stat_progress_bar):
		var asc := round_time.get_node("AbilitySystemComponent") as AbilitySystemComponent
		var target_distance = asc.get_attribute("target_distance").current_value
		var current_distance = asc.get_attribute("current_distance").current_value
		stat_progress_bar.min_value = 0
		stat_progress_bar.max_value = target_distance
		stat_progress_bar.value = current_distance
