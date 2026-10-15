extends Button

@export var map_scene : PackedScene
var route_map_instance : BranchRouteMapRoot

func _pressed() -> void:
	if map_scene.can_instantiate():
		route_map_instance = map_scene.instantiate() as BranchRouteMapRoot
		if is_instance_valid(route_map_instance):
			route_map_instance.close_button_visible = true
			route_map_instance.branch_route_map.bind(GlobalVars.round_time.route_run)
			get_tree().current_scene.add_child(route_map_instance)
			route_map_instance.set_z_index(2)

func _exit_tree() -> void:
	if is_instance_valid(route_map_instance):
		route_map_instance.queue_free()
	route_map_instance = null
