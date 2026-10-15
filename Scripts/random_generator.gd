extends Node

const enums := preload("res://Scripts/enums.gd")

@export var global_seed : String

var rng_list : Dictionary[String, RandomNumberGenerator]

func clear_rng() -> void:
	rng_list.clear()

func get_rng_state_dictionary() -> Dictionary[String, int]:
	var result : Dictionary[String, int]
	for rng_name in rng_list.keys():
		var rng : RandomNumberGenerator = rng_list.get(rng_name) as RandomNumberGenerator
		result.get_or_add(rng_name, rng.state)
	return result

func load_rng_state_dictionary(in_dic : Dictionary) -> void:
	clear_rng()
	for rng_name in in_dic.keys():
		var c_seed: String = get_seed_safe()
		var new_rng: RandomNumberGenerator = Seed.generate_rng(c_seed)
		new_rng.state = in_dic.get(rng_name)
		rng_list.get_or_add(rng_name, new_rng)

func save_game() -> Dictionary:
	var save_dict = {
		"global_seed" : global_seed,
		"rng_list" : get_rng_state_dictionary()
	}
	return save_dict

func load_game(in_data : Dictionary) -> void:
	global_seed = in_data.get("global_seed")
	var rng_list_save_data : Dictionary = in_data.get("rng_list")
	load_rng_state_dictionary(rng_list_save_data)

func _init() -> void:
	add_to_group("Persist")

func get_rng_safe(rng_name : String) -> RandomNumberGenerator:
	if rng_name.is_empty():
		return null
	if rng_list.has(rng_name):
		return rng_list.get(rng_name)
	else:
		var c_seed: String = get_seed_safe()
		var new_rng: RandomNumberGenerator = Seed.generate_rng(c_seed)
		rng_list.get_or_add(rng_name, new_rng)
		return new_rng
	
func get_seed_safe() -> String:
	if global_seed.is_empty():
		global_seed = Seed.generate_seed_string(Seed.ALL_MIXED, 12)
	return global_seed
