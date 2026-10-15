class_name BranchRouteRun_AH extends BranchRouteRun

func _init() -> void:
	add_to_group("Persist")

func _get_rng() -> RandomNumberGenerator:
	return RandomGenerator.get_rng_safe("route")

func _post_node_append(node_id: int) -> void:
	var kind : String = nodes[node_id].get("kind")
	if kind == "battle":
		var enemy_count = _get_rng().randi_range(1, 1)
		nodes[node_id].get_or_add("enemy_count", enemy_count)
