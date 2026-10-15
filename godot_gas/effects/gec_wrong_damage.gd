extends GameplayExecutionCalculation

class_name GEC_WrongDamage

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var player : MainPlayer = spec.context.causer as MainPlayer
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var wrong_damage : float = asc.get_attribute("wrong_damage").current_value
	if is_instance_valid(player):
		GlobalVars.spawn_damage_number(player.self_damage_number_spawn_node, Vector2(0,0), int(wrong_damage), null, Color.RED)
	return EffectCalculation.calculate_damage(wrong_damage, target_asc)
