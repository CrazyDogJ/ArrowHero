extends Node

class_name GameRandomGenerator

const enums := preload("res://Scripts/enums.gd")

@export var global_seed : String
var arrow_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var physics_rng : RandomNumberGenerator = RandomNumberGenerator.new()

func get_physics_rng_safe() -> RandomNumberGenerator:
	var c_seed = get_seed_safe()
	if physics_rng.seed == 0:
		physics_rng = Seed.generate_rng(c_seed)
	return physics_rng

func get_arrow_rng_safe() -> RandomNumberGenerator:
	var c_seed = get_seed_safe()
	if arrow_rng.seed == 0:
		arrow_rng = Seed.generate_rng(c_seed)
	return arrow_rng

func get_seed_safe() -> String:
	if global_seed.is_empty():
		global_seed = Seed.generate_seed_string(Seed.ALL_MIXED, 12)
	return global_seed

func generate_arrows(arrow_num : int) -> Array[enums.ArrowDirection]:
	var result : Array[enums.ArrowDirection]
	if arrow_num <= 0:
		return result
	for i in range(arrow_num):
		result.push_back(get_arrow_rng_safe().randi_range(1, 4))
	return result
