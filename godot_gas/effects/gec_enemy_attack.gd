extends GameplayExecutionCalculation

class_name GEC_EnemyAttack

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var value : float = asc.get_attribute("base_damage").current_value
	var target_player : MainPlayer = target_asc.get_parent() as MainPlayer
	if is_instance_valid(target_player):
		var spawn_node := target_player.self_damage_number_spawn_node
		if is_instance_valid(spawn_node):
			GlobalVars.spawn_damage_number(spawn_node, Vector2(0,0), int(value), null, Color.RED)
	return EffectCalculation.calculate_damage(value, target_asc)
