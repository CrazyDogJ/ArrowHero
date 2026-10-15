class_name BranchRouteMapRoot extends Node

@export var branch_route_map : BranchRouteMap
@export var close_button : Button
var close_button_visible : bool = false

func _ready() -> void:
	if is_instance_valid(close_button):
		close_button.visible = close_button_visible
