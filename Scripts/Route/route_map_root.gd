class_name BranchRouteMapRoot extends Node

@export var branch_route_map : BranchRouteMap
@export var close_button : Button
var close_button_visible : bool = false

func _ready() -> void:
	if is_instance_valid(close_button):
		close_button.visible = close_button_visible
	if is_instance_valid(branch_route_map):
		if close_button_visible:
			branch_route_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
			branch_route_map.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
