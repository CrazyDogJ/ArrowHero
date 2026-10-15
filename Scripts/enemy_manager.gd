extends Node

class_name EnemyManager

@export var enemy_stat_bar : StatWidget
@export var enemy_time_bar : ProgressBar
@export var enemy_array : Array[PackedScene]
@export var player : Node
@export var player_asc : AbilitySystemComponent
var current_enemy : Enemy
var is_round_start : bool = false

func round_start() -> void:
	is_round_start = true
	spawn_enemy()

func round_end() -> void:
	is_round_start = false
	if is_instance_valid(current_enemy):
		current_enemy.queue_free()

func spawn_enemy() -> void:
	var index : int = RandomGenerator.get_rng_safe("enemy").randi_range(0, enemy_array.size() - 1)
	if enemy_array[index].can_instantiate():
		current_enemy = enemy_array[index].instantiate()
		add_child(current_enemy)
		if not is_instance_valid(player_asc):
			if is_instance_valid(player):
				player_asc = player.get_node("AbilitySystemComponent")
		current_enemy.target_asc = player_asc
		current_enemy.enemy_dead.connect(_on_enemy_dead)
		if is_instance_valid(enemy_stat_bar):
			enemy_stat_bar.asc = current_enemy.get_ability_component()

func _on_enemy_dead(attribute_name: String, old_value: float, new_value: float, effect_spec: GameplayEffectSpec) -> void:
	current_enemy = null
	spawn_enemy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_round_start:
		return
	if is_instance_valid(enemy_time_bar) and is_instance_valid(current_enemy) and is_instance_valid(current_enemy.get_ability_component()):
		enemy_time_bar.max_value = current_enemy.get_ability_component().get_attribute("time_period").current_value
		enemy_time_bar.value = current_enemy.current_time
