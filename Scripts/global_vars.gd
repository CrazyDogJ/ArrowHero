extends Node

var cards_manager : UpgradeCardsManager = null
var round_time : RoundTime = null
var damage_number_prefab : PackedScene = preload("res://Prefabs/DamageNumber.tscn")

func spawn_damage_number(node : Node2D, offset : Vector2, damage : int, tex: Texture2D = null, color: Color = Color.WHITE, size: int = 24) -> void:
	if damage <= 0:
		return
	if damage_number_prefab.can_instantiate() and is_instance_valid(node):
		var new_damage_number : DamageNumber = damage_number_prefab.instantiate()
		if is_instance_valid(new_damage_number):
			get_tree().current_scene.add_child(new_damage_number)
			var physRng: RandomNumberGenerator = RandomGenerator.get_rng_safe("physics")
			var random_offset : Vector2 = Vector2(physRng.randf_range(-100, 100), physRng.randf_range(-100, 100))
			new_damage_number.global_position = node.global_position + offset + random_offset
			new_damage_number.setup(damage, tex, color, size)
