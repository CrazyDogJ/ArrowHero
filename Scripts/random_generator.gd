extends Node

const enums := preload("res://Scripts/enums.gd")

@export var global_seed : String

var store_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var loot_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var enemy_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var arrow_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var physics_rng : RandomNumberGenerator = RandomNumberGenerator.new()
var sound_rng : RandomNumberGenerator = RandomNumberGenerator.new()

func get_store_rng_safe() -> RandomNumberGenerator:
	var c_seed: String = get_seed_safe()
	if store_rng.seed == 0:
		store_rng = Seed.generate_rng(c_seed)
	return store_rng
	
func get_loot_rng_safe() -> RandomNumberGenerator:
	var c_seed: String = get_seed_safe()
	if loot_rng.seed == 0:
		loot_rng = Seed.generate_rng(c_seed)
	return loot_rng
	
func get_sound_rng_safe() -> RandomNumberGenerator:
	var c_seed: String = get_seed_safe()
	if sound_rng.seed == 0:
		sound_rng = Seed.generate_rng(c_seed)
	return sound_rng

func get_physics_rng_safe() -> RandomNumberGenerator:
	var c_seed: String = get_seed_safe()
	if physics_rng.seed == 0:
		physics_rng = Seed.generate_rng(c_seed)
	return physics_rng

func get_arrow_rng_safe() -> RandomNumberGenerator:
	var c_seed: String = get_seed_safe()
	if arrow_rng.seed == 0:
		arrow_rng = Seed.generate_rng(c_seed)
	return arrow_rng
	
func get_enemy_rng_safe() -> RandomNumberGenerator:
	var c_seed: String = get_seed_safe()
	if enemy_rng.seed == 0:
		enemy_rng = Seed.generate_rng(c_seed)
	return enemy_rng
	
func get_seed_safe() -> String:
	if global_seed.is_empty():
		global_seed = Seed.generate_seed_string(Seed.ALL_MIXED, 12)
	return global_seed

func generate_arrows(arrow_num : int, arrow_weights : Array[float]) -> Array[enums.ArrowDirection]:
	var result : Array[enums.ArrowDirection]
	if arrow_num <= 0:
		return result
	for i in range(arrow_num):
		var rng = get_arrow_rng_safe();
		var index = rng.rand_weighted(arrow_weights)
		result.push_back(index + 1)
	return result
